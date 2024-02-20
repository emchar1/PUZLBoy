//
//  CutsceneOldFriends.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/6/24.
//

import SpriteKit

class CutsceneOldFriends: Cutscene {
    
    // MARK: - Properties
    
    //Custom properties go here.
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
        
        playerLeft.setPlayerScale(1.5)
        playerRight.setPlayerScale(1.5)
        
        speechPlayerLeft.position += playerLeft.sprite.position
        speechPlayerRight.position += playerRight.sprite.position

//        skipIntroSprite.delegate = self
    }
    
    
    // MARK: - Animate Functions
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)
        
        let frameRate: TimeInterval = 0.06
        let magmoorAnimate = SKAction.animate(with: playerLeft.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        let marlinAnimate = SKAction.animate(with: playerRight.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        
        self.completion = completion
        
        parallaxManager.animate()
        
        letterbox.show()// { [unowned self] in
//            addChild(skipIntroSprite)
//            skipIntroSprite.animateSprite()
//        }
        
        playerLeft.sprite.run(SKAction.repeatForever(magmoorAnimate))
        playerRight.sprite.run(SKAction.repeatForever(marlinAnimate))
        
        setTextArray(items: [
            SpeechBubbleItem(profile: speechPlayerLeft, chat: "Marlin, you gotta keep trying. Trials are tomorrow!"),
            SpeechBubbleItem(profile: speechPlayerRight, chat: "I have been at it for hours! I'm just not as talented as you!")
        ], completion: completion)
        
    }
    
}


// MARK: - SkipIntroSprite Delegate

extension CutsceneOldFriends: SkipIntroSpriteDelegate {
    func buttonWasTapped() {
        super.skipIntroHelper(fadeDuration: 1)
    }
    
}
