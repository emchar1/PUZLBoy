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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let launchScene = LaunchScene(size: K.ScreenDimensions.screenSize)

        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(launchScene)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            LevelBuilder.getLevels {
                let gameScene = GameScene(size: K.ScreenDimensions.screenSize)
                
                skView.presentScene(gameScene, transition: SKTransition.doorsOpenVertical(withDuration: 2.0))
            }
        }
    }
    
    
}

