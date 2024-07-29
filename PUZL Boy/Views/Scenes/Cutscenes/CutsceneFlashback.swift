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
        
        let centerPoint = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
                
        playerLeft.sprite.position = centerPoint + CGPoint(x: -150, y: 0)
        playerLeft.sprite.setScale(0.5)
        playerLeft.sprite.alpha = 0
        
        playerRight.sprite.position = centerPoint + CGPoint(x: 150, y: 0)
        playerRight.sprite.setScale(0.5)
        playerRight.sprite.xScale *= -1
        playerRight.sprite.alpha = 0
        
        speechPlayerLeft.position = centerPoint + CGPoint(x: 0, y: 300)
        speechPlayerRight.position = centerPoint + CGPoint(x: 0, y: 300)
        
        dimOverlayNode.alpha = 1
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)
        
        //Custom implementation here, if needed.
    }
    
    
    // MARK: - Functions
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)

        //Players
        animatePlayerWithTextures(player: &playerLeft, textureType: .idle, timePerFrame: 0.05)
        animatePlayerWithTextures(player: &playerRight, textureType: .idle, timePerFrame: 0.06)

        playerLeft.sprite.run(SKAction.fadeIn(withDuration: 3))
        playerRight.sprite.run(SKAction.fadeIn(withDuration: 3))

        //Speech Bubbles
        run(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "What's wrong??"),
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "This doesn't feel right.")
                ], completion: nil)
            }
        ]))
    }
}
