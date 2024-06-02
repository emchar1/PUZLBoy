//
//  CutsceneOldFriends.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/6/24.
//

import SpriteKit

// TODO: - Cutscene Magmoor

class CutsceneMagmoor: Cutscene {
    
    // MARK: - Properties
    
    private var playerMagmoor: Player!
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
        
        playerMagmoor = Player(type: .villain)
        playerMagmoor.sprite.alpha = 0
        playerMagmoor.sprite.zPosition = playerLeft.sprite.zPosition + 5

        speechPlayerLeft.position = CGPoint(x: speechPlayerLeft.bubbleDimensions.width / 2 + 30, y: screenSize.height * 2 / 3 + 50)
        speechPlayerRight.position = CGPoint(x: screenSize.width - speechPlayerRight.bubbleDimensions.width / 2 - 30, y: screenSize.height * 2 / 3)
        speechPlayerLeft.updateTailOrientation(.topLeft)
        speechPlayerRight.updateTailOrientation(.topRight)
        
        fadeTransitionNode.fillColor = .white

        skipSceneSprite.delegate = self
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)

        //Custom implementation here, if needed.
    }

    
    // MARK: - Animate Functions
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)
        
        let initialPause: TimeInterval = 6
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
        }
         
        animateParallax(changeSet: nil, duration: initialPause)
        
        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true,
                      duration: initialPause)
        
        animatePlayer(player: &playerRight,
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false,
                      duration: initialPause)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: initialPause),
            SKAction.run { [unowned self] in
                animateScene(narrateText: "We weren't always at odds with each other. There was a time when we were quite good friends. We went to school together. Studied magic together. So it was only natural we became close.", playScene: playScene1)
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 42),
            SKAction.run { [unowned self] in
                animateScene(narrateText: "Then war broke out. The division among the Mystics had been deepening. Magmoor and I led one faction. We defeated those who opposed us. He reveled in his glory..... to grave consequences.", playScene: playScene2)
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 66),
            SKAction.run { [unowned self] in
                animateScene(narrateText: "I did what I had to do: I banished him to the Realm of Limbo—|||||||||||||||||||| Peace eventually returned, but it will take years to repair the damage he caused.", playScene: playScene3)
            }
        ]))
        
        run(SKAction.wait(forDuration: 102)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
        }
    }
    
    /**
     Helper function that animates a player by settingh up positions, rotations, scaling and adds the appropriate animations.
     - parameters:
        - player: the Player object which gets changed due to the inout modifier.
        - position: initial position of the Player object.
        - scale: initial scale of the player object.
        - shouldFlipHorizontally: true if player should be facing left.
        - shouldRotateClockwise: true if player is to slowly rotate clockwise.
     */
    private func animatePlayer(player: inout Player, position: CGPoint, scale: CGFloat, shouldFlipHorizontally: Bool, shouldRotateClockwise: Bool, duration: TimeInterval) {
        let rotationRange: CGFloat = .pi / 8
        let randomRotation: CGFloat = CGFloat.random(in: -rotationRange...rotationRange)
        let scaleIncrease: CGFloat = 1.25
        let flipHorizontally: CGFloat = shouldFlipHorizontally ? -1 : 1
        let rotateClockwise: CGFloat = shouldRotateClockwise ? -1 : 1
        let timePerFrame: TimeInterval = 0.06 * 2

        player.sprite.position = position
        player.sprite.setScale(scale)
        player.sprite.xScale *= flipHorizontally
        player.sprite.zRotation = randomRotation
        
        player.sprite.removeAllActions()
        
        player.sprite.run(SKAction.group([
            animatePlayerWithTextures(player: player, textureType: .idle, timePerFrame: timePerFrame),
            SKAction.rotate(toAngle: rotateClockwise * rotationRange + randomRotation, duration: duration),
            SKAction.scaleX(to: flipHorizontally * scale * scaleIncrease, y: scale * scaleIncrease, duration: duration)
        ]))
    }
    
    /**
     Helper function that returns an SKAction of an animation of a player object's texture array, repeated forever.
     - parameters:
        - player: the player object to animate.
        - textureType: the type of animation texture to play.
        - timePerFrame: the duration of each frame of the animation.
     - returns: an SKAction of the animation.
     */
    private func animatePlayerWithTextures(player: Player, textureType: Player.Texture, timePerFrame: TimeInterval) -> SKAction {
        return SKAction.repeatForever(SKAction.animate(with: player.textures[textureType.rawValue], timePerFrame: timePerFrame))
    }
    
    /**
     Animates Magmoor's transformation from youngMagmoor to the villain we all know today.
     - parameters:
        - alpha: the opacity with which to pulse today's Magmoor; youngMagmoor is pulsed at 1 - alpha.
        - duration: the time duration with which to execute these animations.
     - returns: an SKAction of the resulting animation.
     */
    private func animatePulseMagmoor(alpha: CGFloat, duration: TimeInterval) -> SKAction {
        return SKAction.sequence([
            SKAction.run { [unowned self] in
                playerLeft.sprite.run(SKAction.fadeOut(withDuration: duration))
                playerMagmoor.sprite.run(SKAction.fadeAlpha(to: alpha, duration: duration))
            },
            SKAction.wait(forDuration: duration),
            SKAction.run { [unowned self] in
                playerLeft.sprite.run(SKAction.fadeAlpha(to: 1 - alpha, duration: duration))
                playerMagmoor.sprite.run(SKAction.fadeOut(withDuration: duration))
            },
            SKAction.wait(forDuration: duration)
        ])
    }
    
    /**
     Animates the parallaxManager scene with a slight scaling increase, and changes the set if needed.
     - parameter set: changes the set to the inputted value, or doesn't if set is nil.
     */
    private func animateParallax(changeSet set: ParallaxObject.SetType?, duration: TimeInterval) {
        let scale: CGFloat = 2
        let scaleIncrease: CGFloat = 1.1
        
        if let set = set {
            parallaxManager.changeSet(set: set)
            parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        }
            
        parallaxManager.backgroundSprite.setScale(scale)
        parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width / 2, y: -screenSize.height / 2 + 400)

        parallaxManager.backgroundSprite.run(SKAction.scale(to: scale * scaleIncrease, duration: duration))
    }
    
    /**
     Animates a quick white flash used to separate scenes within the Cutscene, then plays a narration text overlay along with an accompanying scene.
     - parameters:
        - narrateText: the narrated text to play.
        - playScene: a completion handler that plays an accompanying scene.
     */
    private func animateScene(narrateText: String, playScene: @escaping (() -> Void)) {
        //fadeTransitionNode is initially added to backgroundNode, so remove it first to prevent app crashing due to it already having a parent node.
        fadeTransitionNode.removeAllActions()
        fadeTransitionNode.removeFromParent()

        backgroundNode.addChild(fadeTransitionNode)
        
        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1),
            SKAction.run { [unowned self] in
                speechNarrator.setText(text: narrateText, superScene: self, completion: nil)
                playScene()
            },
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ]))
    }
    
    
    // MARK: - Animation Scene Helper Functions
    
    private func playScene1() {
        let pauseDuration: TimeInterval = 8
        
        animateParallax(changeSet: .marsh, duration: pauseDuration)

        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true,
                      duration: pauseDuration)
        
        animatePlayer(player: &playerRight, 
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false,
                      duration: pauseDuration)

        run(SKAction.sequence([
            SKAction.wait(forDuration: pauseDuration),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "Wait. Why do we all look the same?"),
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "I told you! Budget."),
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "Yeah, but... it really detracts from the immersion."),
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "...kinda like what you're doing right now??"),
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "Fair.")
                ], completion: nil)
            }
        ]))
    }
    
    private func playScene2() {
        let pauseDuration: TimeInterval = 10

        animateParallax(changeSet: .sand, duration: pauseDuration)

        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true,
                      duration: pauseDuration)
        
        animatePlayer(player: &playerRight,
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false,
                      duration: pauseDuration)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: pauseDuration),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "You couldn't find other images to use?"),
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "Shh!! Pay attention! I'm not going to repeat myself."),
                ], completion: nil)
            }
        ]))
    }
    
    private func playScene3() {
        let pauseDuration: TimeInterval = 12
        
        animateParallax(changeSet: .lava, duration: pauseDuration)
        parallaxManager.backgroundSprite.removeAllActions()
        
        //Setup sprites
        let initialScale: CGFloat = 2
        let initialPosition: CGPoint = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        playerLeft.sprite.setScale(initialScale)
        playerLeft.sprite.position = initialPosition
        playerLeft.sprite.zRotation = 0
        playerLeft.sprite.removeAllActions()
        
        playerRight.sprite.alpha = 0

        playerMagmoor.sprite.setScale(initialScale)
        playerMagmoor.sprite.position = initialPosition

        playerMagmoor.sprite.removeAllActions()
        playerMagmoor.sprite.removeFromParent()
        backgroundNode.addChild(playerMagmoor.sprite)

        
        //Animate Magmoor transformation
        let waitBeforeTransformation: TimeInterval = 22
        let fadeDuration: TimeInterval = 0.1
        let zoomScale: CGFloat = 0.5
        let zoomDuration: TimeInterval = 0.25
        let timePerFrame: TimeInterval = 0.06 * 2

        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: timePerFrame))
        playerMagmoor.sprite.run(animatePlayerWithTextures(player: playerMagmoor, textureType: .idle, timePerFrame: timePerFrame))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: waitBeforeTransformation),
            animatePulseMagmoor(alpha: 0.1, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.2, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.3, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.4, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.5, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.6, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.7, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.8, duration: fadeDuration),
            animatePulseMagmoor(alpha: 0.9, duration: fadeDuration),
            animatePulseMagmoor(alpha: 1.0, duration: fadeDuration),
            SKAction.run { [unowned self] in
                playerMagmoor.sprite.run(SKAction.fadeIn(withDuration: fadeDuration))
            }
        ]))

        parallaxManager.backgroundSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: waitBeforeTransformation + fadeDuration * 11 + 3),
            SKAction.group([
                SKAction.scale(to: 1, duration: zoomDuration),
                SKAction.move(to: .zero, duration: zoomDuration)
            ])
        ]))

        playerMagmoor.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: waitBeforeTransformation + fadeDuration * 11 + 3),
            SKAction.group([
                SKAction.scale(to: zoomScale, duration: zoomDuration),
                SKAction.moveTo(y: screenSize.height / 3, duration: zoomDuration)
            ])
        ]))
        
        backgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: waitBeforeTransformation + fadeDuration * 11 + 3 + zoomDuration),
            shakeBackground(duration: 2)
        ]))
        
        //Animate magicExplosion particle engine
        run(SKAction.sequence([
            SKAction.wait(forDuration: waitBeforeTransformation + fadeDuration * 11 + 3 + zoomDuration + 3),
            SKAction.run { [unowned self] in
                ParticleEngine.shared.animateParticles(type: .magicExplosion,
                                                       toNode: backgroundNode,
                                                       position: playerMagmoor.sprite.position,
                                                       scale: 1,
                                                       zPosition: playerMagmoor.sprite.zPosition - 5,
                                                       duration: 0)
            }
        ]))
        
        
        //Side convo
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "We're all just lazy palette swaps, ya know."),
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "Do you want to tell this story??!"),
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "No. Continue.")
                ], completion: nil)
            }
        ]))
    }
}


// MARK: - SkipSceneSprite Delegate

extension CutsceneMagmoor: SkipSceneSpriteDelegate {
    func buttonWasTapped() {
        //No fade duration because the protocol function does it's own .white fade transition in GameViewController.
        cleanupScene(buttonTap: .buttontap1, fadeDuration: nil)
    }
    
}
