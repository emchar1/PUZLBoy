//
//  CutsceneFlashback.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/25/24.
//

import SpriteKit

class CutsceneFlashback: Cutscene {
    
    // MARK: - Properties
    
    
    // MARK: - Initialization
    
    init() {
        super.init(size: K.ScreenDimensions.size, playerLeft: .youngTrainer, playerRight: .youngVillain, xOffsetsArray: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupScene() {
        super.setupScene()
        
        animatePlayerWithTextures(player: &playerLeft, textureType: .walk, timePerFrame: 0.06)
        animatePlayerWithTextures(player: &playerRight, textureType: .walk, timePerFrame: 0.06)
                
        playerLeft.sprite.position = CGPoint(x: -300, y: screenSize.height / 2)
        playerLeft.sprite.setScale(0.5)
        
        playerRight.sprite.position = CGPoint(x: -100, y: screenSize.height / 2)
        playerRight.sprite.setScale(0.5)
//        playerRight.sprite.xScale *= -1

        dimOverlayNode.alpha = 1
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)
        
        //Custom implementation here, if needed.
    }
    
    
    // MARK: - Functions
    
    override func animateScene(completion: (() -> Void)?) {
        playerLeft.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: screenSize.width / 2 - 100, duration: 4),
            SKAction.wait(forDuration: 4),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &playerLeft, textureType: .walk, timePerFrame: 0.12)
            },
            SKAction.moveTo(x: screenSize.width / 4, duration: 4),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &playerLeft, textureType: .idle, timePerFrame: 0.06)
            }
        ]))
        
        playerRight.sprite.run(SKAction.moveTo(x: screenSize.width / 2 + 100, duration: 4))
    }
}
