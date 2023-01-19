//
//  GameViewController.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return true }
    private var levelLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let launchScene = LaunchScene(size: K.ScreenDimensions.screenSize)

        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(launchScene)
        
        AdMobManager.shared.superVC = self
        AdMobManager.shared.createAndLoadInterstitial()
        AdMobManager.shared.createAndLoadRewarded()

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
                    }
                }
            }
        }//end GameCenterManager.shared.getUser()
        
    }//end viewDidLoad()
    
    
}

