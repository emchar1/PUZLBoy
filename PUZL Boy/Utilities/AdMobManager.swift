//
//  AdMobManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/14/23.
//

import Foundation
import GoogleMobileAds


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
    static let myFirstInterstitialID = "ca-app-pub-3047242308312153/9074783932"
    static let rewardedID = "ca-app-pub-3940256099942544/1712485313"
    // FIXME: - IMPORTANT!!!!! USE THIS WHEN SHIPPING AD!!!
//    static let rewardedID = "ca-app-pub-3047242308312153/7555829885"
    static let eddiesiPhoneTestingDeviceID = "3f4aed5e3dafdbe6435ec3679a8e07fa"//"00008110-000808E61E6A801E"
    static let momsiPhoneTestingDeviceID = "6582222a25a290e89ca6a1c4f29924d6"
    static let testingSimulatorID = GADSimulatorID
        
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
    
    
    // MARK: - Interstitial Functions
    
    ///Prepares an interstitial ad to be presented, when it's ready.
    func createAndLoadInterstitial() {
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: AdMobManager.myFirstInterstitialID, request: request) { interstitialAd, error in
            guard error == nil else {
                print("Error loading the interstitial: \(error!.localizedDescription)")
                return
            }
            
            self.interstitialAd = interstitialAd
            self.interstitialAd?.fullScreenContentDelegate = self
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
                print("Error loading the rewarded: \(error!.localizedDescription)")
                return
            }
            
            self.rewardedAd = rewardedAd
            self.rewardedAd?.fullScreenContentDelegate = self
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
    
    
}
