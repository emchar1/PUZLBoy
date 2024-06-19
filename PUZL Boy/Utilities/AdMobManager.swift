//
//  AdMobManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/14/23.
//

import Foundation
import GoogleMobileAds
import AppTrackingTransparency


protocol AdMobManagerDelegate: AnyObject {
    //Interstitial functions
    func willPresentInterstitial()
    func didDismissInterstitial()
    func interstitialFailed()

    //Rewarded functions
    func willPresentRewarded()
    func didDismissRewarded()
    func rewardedFailed()
}


class AdMobManager: NSObject {
    
    // MARK: - Properties
    
    //The shared property
    static let shared: AdMobManager = {
        let adMobManager = AdMobManager()
        return adMobManager
    }()
    
    //UID properties
    static let puzlBoyAppID = "ca-app-pub-3047242308312153~8487486800"
    
    // FIXME: - IMPORTANT!!!!! USE THESE WHEN SHIPPING AD!!!
//    static let interstitialID = "ca-app-pub-9970112736079022/6969280486"
//    static let rewardedID = "ca-app-pub-9970112736079022/9450590704"

    // FIXME: - ...AND DELETE THESE TEST ONES!!!
    static let interstitialID = "ca-app-pub-3940256099942544/5135589807"
    static let rewardedID = "ca-app-pub-3940256099942544/1712485313"

    
    static let eddiesiPhoneTestingDeviceID = "3f4aed5e3dafdbe6435ec3679a8e07fa" //Eddie's iPhone 14 Pro
    static let momsiPhoneTestingDeviceID = "6582222a25a290e89ca6a1c4f29924d6"
    static let testingSimulatorID = GADSimulatorID
    
    //Checks for Ad Readiness
    static var interstitialAdIsReady = false
    static var rewardedAdIsReady = false
        
    //Public properties
    var superVC: UIViewController?
    weak var delegate: AdMobManagerDelegate?
    
    //Ad properties
    private(set) var interstitialAd: GADInterstitialAd?
    private(set) var rewardedAd: GADRewardedAd?
    
        
    // MARK: - Initialization
    
    override init() {
        super.init()

    }
    
    
    // MARK: - Request Functions
    
    @available(iOS 14, *)
    func requestIDFAPermission() {
        guard checkForIDFAPermission() == .notDetermined else { return print("   AdMobManager.requestIDFAPermission() status: !(.notDetermined), exiting...") }
        
        ATTrackingManager.requestTrackingAuthorization { _ in
            print("   AdMobManager.requestIDFAPermission() status: .notDetermined, requesting access...")
        }
    }
    
    @available(iOS 14, *)
    @discardableResult private func checkForIDFAPermission() -> ATTrackingManager.AuthorizationStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status {
        case .authorized:
            print("AdMobManager.checkForIDFAPermission() status: .authorized")
        case .denied:
            print("AdMobManager.checkForIDFAPermission() status: .denied")
        case .restricted:
            print("AdMobManager.checkForIDFAPermission() status: .restricted")
        case .notDetermined:
            print("AdMobManager.checkForIDFAPermission() status: .notDetermined")
        @unknown default:
            print("AdMobManager.checkForIDFAPermission() status: @unknown")
        }
        
        return status
    }
    
    
    // MARK: - Interstitial Functions
    
    ///Prepares an interstitial ad to be presented, when it's ready.
    func createAndLoadInterstitial() {
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: AdMobManager.interstitialID, request: request) { interstitialAd, error in
            guard error == nil else {
                AdMobManager.interstitialAdIsReady = false
                print("Error loading the interstitial: \(error!.localizedDescription)")
                return
            }
            
            self.interstitialAd = interstitialAd
            self.interstitialAd?.fullScreenContentDelegate = self
            
            AdMobManager.interstitialAdIsReady = true
            print("Interstitial ad has been loaded and is ready to present...")
        }
    }
    
    ///Presents the prepared interstitial ad.
    func presentInterstitial() {
        guard let superVC = superVC else { return }
        
        interstitialAd?.present(fromRootViewController: superVC)
    }
    
    
    // MARK: - Rewarded Functions
    
    ///Prepares a rewarded ad to be presented, when it's ready.
    func createAndLoadRewarded() {
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: AdMobManager.rewardedID, request: request) { rewardedAd, error in
            guard error == nil else {
                AdMobManager.rewardedAdIsReady = false
                print("Error loading the rewarded: \(error!)")
                return
            }
            
            self.rewardedAd = rewardedAd
            self.rewardedAd?.fullScreenContentDelegate = self
            
            AdMobManager.rewardedAdIsReady = true
            print("Rewarded ad has been loaded and is ready to present...")
        }
    }
    
    /**
     Presents the prepared rewarded ad.
     - parameter completion: The completion handler, which returns the rewarded element.
     */
    func presentRewarded(completion: ((GADAdReward) -> Void)?) {
        guard let superVC = superVC else { return }
        
        rewardedAd?.present(fromRootViewController: superVC) { [unowned self] in
            guard let rewardedAd = rewardedAd else { return }

            completion?(rewardedAd.adReward)
        }
    }
}


// MARK: - GADFullScreenContentDelegate

extension AdMobManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if ad.isEqual(interstitialAd) {
            delegate?.interstitialFailed()
        }
        else if ad.isEqual(rewardedAd) {
            delegate?.rewardedFailed()
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad.isEqual(interstitialAd) {
            delegate?.willPresentInterstitial()
        }
        else if ad.isEqual(rewardedAd) {
            delegate?.willPresentRewarded()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        GameCenterManager.shared.updateProgress(achievement: .adMobster, shouldReportImmediately: true)
        
        if ad.isEqual(interstitialAd) {
            createAndLoadInterstitial()
            delegate?.didDismissInterstitial()
        }
        else if ad.isEqual(rewardedAd) {
            createAndLoadRewarded()
            delegate?.didDismissRewarded()
        }
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("User clicked on the ad!")
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("Impression recorded.")
    }
}
