//
//  AdMobManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/14/23.
//

import Foundation
import GoogleMobileAds


protocol AdMobManagerDelegate: AnyObject {
    func willPresentInterstitial()
    func didDismissInterstitial()
    func interstitialFailed()
}

class AdMobManager: NSObject {
    
    // MARK: - Properties
    
    //The shared property
    static let shared: AdMobManager = {
        let adMobManager = AdMobManager()
        return adMobManager
    }()
        
    //Public properties
    var superVC: UIViewController?
    weak var delegate: AdMobManagerDelegate?

    //Ad properties
    private(set) var interstitialAd: GADInterstitialAd?
    private var adsWatched = 0

    //UID properties
    private let puzlBoyAppID = "ca-app-pub-3047242308312153~8487486800"
    private let myFirstInterstitialID = "ca-app-pub-3047242308312153/9074783932"
    private let eddiesiPhoneTestingDeviceID = "00008110-000808E61E6A801E"
    private let testingSimulatorID = GADSimulatorID
    
        
    // MARK: - Initialization
    
    override init() {
        super.init()

    }
    
    
    // MARK: - Functions
    
    ///Prepares an interstitial ad to be presented, when it's ready.
    func createAndLoadInterstitial() {
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: AdMobManager.shared.myFirstInterstitialID, request: request) { interstitialAd, error in
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
}


// MARK: - GADFullScreenContentDelegate

extension AdMobManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        
        delegate?.interstitialFailed()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
        
        delegate?.willPresentInterstitial()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        //Queues up the next interstitial ad
        createAndLoadInterstitial()
        adsWatched += 1
        
        // TODO: - AdMobster achievement
        if adsWatched == 50 {
            //AdMobster achievement!!
        }
        
        delegate?.didDismissInterstitial()
    }
}
