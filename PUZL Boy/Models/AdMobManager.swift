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
    static let rewardedID = "ca-app-pub-3047242308312153/7555829885"
    static let eddiesiPhoneTestingDeviceID = "6ff74173a673785005b5692f63fbaa25"//"00008110-000808E61E6A801E"
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
                print("Error laoding the interstitial: \(error!.localizedDescription)")
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
                print("Error loeding the rewarded: \(error!.localizedDescription)")
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
        print("Ad did fail to present full screen content.")
        
        if ad.isEqual(interstitialAd) {
            delegate?.interstitialFailed()
        }
        else if ad.isEqual(rewardedAd) {
            delegate?.rewardedFailed()
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
        
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
            print("Dismissed an interstitial ad.")
        }
        else if ad.isEqual(rewardedAd) {
            createAndLoadRewarded()
            delegate?.didDismissRewarded()
            print("Dismissed a rewarded ad.")
        }
    }
    
    
}