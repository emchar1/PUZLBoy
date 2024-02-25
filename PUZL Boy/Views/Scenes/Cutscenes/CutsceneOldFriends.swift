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
        
        speechPlayerLeft.position += playerLeft.sprite.position
        speechPlayerRight.position += playerRight.sprite.position

        skipSceneSprite.delegate = self
    }
    
    
    // MARK: - Animate Functions
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)
        
        let frameRate: TimeInterval = 0.06
        let playerLeftSpeed: TimeInterval = playerLeft.scaleMultiplier / playerRight.scaleMultiplier
        let magmoorAnimate = SKAction.animate(with: playerLeft.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate * playerLeftSpeed)
        let marlinAnimate = SKAction.animate(with: playerRight.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        
        parallaxManager.animate()
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
        }
        
        playerLeft.sprite.run(SKAction.repeatForever(magmoorAnimate))
        playerRight.sprite.run(SKAction.repeatForever(marlinAnimate))
        
        setTextArray(items: [
            SpeechBubbleItem(profile: speechPlayerLeft, chat: "Beep."),
            SpeechBubbleItem(profile: speechPlayerRight, chat: "Boop.")
        ]) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
        }
        
    }
    
}


// MARK: - SkipSceneSprite Delegate

extension CutsceneOldFriends: SkipSceneSpriteDelegate {
    func buttonWasTapped() {
        //No fade duration because the protocol function does it's own .white fade transition.
        cleanupScene(buttonTap: .buttontap1, fadeDuration: nil)
    }
    
}
