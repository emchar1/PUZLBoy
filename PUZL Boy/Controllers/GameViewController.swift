//
//  GameViewController.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import UIKit
import SpriteKit
import GameplayKit
import FirebaseAuth

class GameViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return true }
    private var levelLoaded = false
    private var user: User?
    private var saveStateModel: SaveStateModel?
    private let skView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var launchScene: LaunchScene? = LaunchScene(size: K.ScreenDimensions.screenSize)

        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(launchScene)
//        skView.presentScene(TitleScene(size: K.ScreenDimensions.screenSize)) //DEBUG ONLY
        view = skView

        AdMobManager.shared.superVC = self
        AdMobManager.shared.createAndLoadInterstitial()
        AdMobManager.shared.createAndLoadRewarded()

        //Call this once, before calling LevelBuilder.getLevels().
        FIRManager.enableDBPersistence

        GameCenterManager.shared.viewController = self
        GameCenterManager.shared.getUser { user in
            //Ensures everything below the guard statement only gets called ONCE!
            guard !self.levelLoaded else { return }
            
            //Should call LevelBuilder.getLevels BEFORE calling FIRManager.initializeSaveStateFirestoreRecords
            LevelBuilder.getLevels {
                FIRManager.initializeFirestore(user: user) { saveStateModel, error in
                    //No error handling...
                    
                    self.user = user
                    self.saveStateModel = saveStateModel
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + LoadingSprite.loadingDuration) {
                        launchScene?.animateTransition(animationSequence: .jump) {
                            let titleScene = TitleScene(size: K.ScreenDimensions.screenSize)
                            titleScene.titleSceneDelegate = self
                            
                            self.skView.presentScene(titleScene)
                            
                            launchScene = nil
                        }
                                                
                        self.levelLoaded = true
                    }
                }
            }
        }//end GameCenterManager.shared.getUser()
                
        print("Testing device info: \(UIDevice.modelInfo)")
    }//end viewDidLoad()
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            guard let skView = view as? SKView, let scene = skView.scene as? GameScene else { return }
            
            scene.shake()
        }
    }
}


// MARK: - TitleSceneDelegate

extension GameViewController: TitleSceneDelegate {
    func didTapStart() {
        let gameScene = GameScene(size: K.ScreenDimensions.screenSize, user: user, saveStateModel: saveStateModel)
        
        skView.presentScene(gameScene, transition: SKTransition.fade(with: .white, duration: 1.0))
    }
}
