//
//  GameViewController.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return true }
    private var levelLoaded = false
    
    
    
    var interstitialAd: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let launchScene = LaunchScene(size: K.ScreenDimensions.screenSize)

        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(launchScene)
        
        
        
        K.mainViewController = self
        createAndLoadInterstitial()
        
        
        

        //Call this once, before calling LevelBuilder.getLevels().
        FIRManager.enableDBPersistence

        GameCenterManager.shared.viewController = self
        GameCenterManager.shared.getUser { user in
            //Ensures everything below the guard statement only gets called ONCE!
            guard !self.levelLoaded else { return }
            
            LevelBuilder.getLevels {
                FIRManager.initializeSaveStateFirestoreRecords(user: user) { saveStateModel in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        let gameScene = GameScene(size: K.ScreenDimensions.screenSize, user: user, saveStateModel: saveStateModel)
                        
                        skView.presentScene(gameScene, transition: SKTransition.doorsOpenVertical(withDuration: 2.0))
                        
                        self.levelLoaded = true
                        
                        
                        
                        
                        
                        
                        self.createAndLoadInterstitial()
//                        AdMobManager.shared.adBannerView?.load(GADRequest())
                    }
                }
            }
        }//end GameCenterManager.shared.getUser()
        
    }//end viewDidLoad()
    
    
}







extension GameViewController: GADFullScreenContentDelegate {
    private func createAndLoadInterstitial() {
        let request = GADRequest()
        
        
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3047242308312153/9074783932", request: request) { interstitialAd, error in
            guard error == nil else { return print(error!.localizedDescription) }
            self.interstitialAd = interstitialAd
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    
    
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Whoopsie daisies, ad did fail to present full screen content.")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        //Queues up the next interstitial ad
        createAndLoadInterstitial()
    }
}
