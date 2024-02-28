//
//  CutsceneOldFriends.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/6/24.
//

import SpriteKit

class CutsceneOldFriends: Cutscene {
    
    // MARK: - Properties
    
    private var playerMagmoor: Player!
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
        
        playerMagmoor = Player(type: .villain)
        playerMagmoor.sprite.alpha = 0
        playerMagmoor.sprite.zPosition = playerLeft.sprite.zPosition + 5

        speechPlayerLeft.position += playerLeft.sprite.position
        speechPlayerRight.position += playerRight.sprite.position
        
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
        
        let fadeDuration: TimeInterval = 2
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
        }
        
        dimOverlayNode.run(SKAction.fadeAlpha(to: 0.5, duration: 3))
         
        run(SKAction.sequence([
            SKAction.run { [unowned self] in
                animateParallax(changeSet: nil)

                animatePlayer(player: &playerLeft,
                              position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                              scale: 2,
                              shouldFlipHorizontally: false,
                              shouldRotateClockwise: true)
                
                animatePlayer(player: &playerRight,
                              position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                              scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                              shouldFlipHorizontally: true,
                              shouldRotateClockwise: false)
            },
            SKAction.wait(forDuration: 3 * fadeDuration),
            SKAction.run { [unowned self] in
                animateFlash(fadeDuration: fadeDuration) { [unowned self] in
                    speechNarrator.setText(text: "We weren't always at each other's throat. There was a time when we were quite good friends. We went to school together. Studied magic together. So it was only natural we became close.", superScene: self, completion: nil)
                    playScene1()
                }
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 9 * fadeDuration),
            SKAction.run { [unowned self] in
                animateFlash(fadeDuration: fadeDuration) { [unowned self] in
                    speechNarrator.setText(text: "Then war broke out. The division among the Mystics had been deepening. Magmoor and I led one faction. We defeated those who opposed us. He reveled in his glory..... to grave consequences.", superScene: self, completion: nil)
                    playScene2()
                }
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 15 * fadeDuration),
            SKAction.run { [unowned self] in
                animateFlash(fadeDuration: fadeDuration) { [unowned self] in
                    speechNarrator.setText(text: "I did what I had to do: I banished him to the Realm of Limbo. Peace eventually returned, but it took hundreds of years to mend the damage he caused.", superScene: self, completion: nil)
                    playScene3()
                }
            }
        ]))
        
        run(SKAction.wait(forDuration: 24 * fadeDuration)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
        }
        
//        let frameRate: TimeInterval = 0.06
//        let playerLeftSpeed: TimeInterval = playerLeft.scaleMultiplier / playerRight.scaleMultiplier
//        let magmoorAnimate = SKAction.animate(with: playerLeft.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate * playerLeftSpeed)
//        let marlinAnimate = SKAction.animate(with: playerRight.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
//        
//        parallaxManager.animate()
//        
//        //Queue this up for the next subscene to prevent brief pause... it works apparently!
//        parallaxManager.changeSet(set: .ice)
//        parallaxManager.animate()
//        
//        letterbox.show { [unowned self] in
//            addChild(skipSceneSprite)
//            skipSceneSprite.animateSprite()
//        }
//        
//        playerLeft.sprite.run(SKAction.repeatForever(magmoorAnimate))
//        playerRight.sprite.run(SKAction.repeatForever(marlinAnimate))
//        
//        setTextArray(items: [
//            SpeechBubbleItem(profile: speechPlayerLeft, chat: "Beep."),
//            SpeechBubbleItem(profile: speechPlayerRight, chat: "Boop.")
//        ]) { [unowned self] in
//            let fadeDuration: TimeInterval = 3
//            
//            flashScene(fadeDuration: fadeDuration) { [unowned self] in
//                parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
//                parallaxManager.changeSet(set: .lava)
//                parallaxManager.animate()
//            }
//            
//            run(SKAction.sequence([
//                SKAction.wait(forDuration: fadeDuration),
//                SKAction.run { [unowned self] in
//                    setTextArray(items: [
//                        SpeechBubbleItem(profile: speechPlayerLeft, chat: "Everything you see here you can touch") { [unowned self] in
//                            parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
//                        },
//                        SpeechBubbleItem(profile: speechPlayerRight, chat: "You can look but you cannot touch!")
//                    ]) { [unowned self] in
//                        cleanupScene(buttonTap: nil, fadeDuration: nil)
//                    }
//                }
//            ]))
//        }
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
    private func animatePlayer(player: inout Player, position: CGPoint, scale: CGFloat, shouldFlipHorizontally: Bool, shouldRotateClockwise: Bool) {
        let rotationRange: CGFloat = .pi / 8
        let randomRotation: CGFloat = CGFloat.random(in: -rotationRange...rotationRange)
        let scaleIncrease: CGFloat = 1.25
        let flipHorizontally: CGFloat = shouldFlipHorizontally ? -1 : 1
        let rotateClockwise: CGFloat = shouldRotateClockwise ? -1 : 1
        let animationDuration: TimeInterval = 12

        player.sprite.position = position
        player.sprite.setScale(scale)
        player.sprite.xScale *= flipHorizontally
        player.sprite.zRotation = randomRotation
        
        player.sprite.removeAllActions()
        
        player.sprite.run(SKAction.group([
            animatePlayerWithTextures(player: player, textureType: .idle, timePerFrame: 0.06 * 2),
            SKAction.rotate(toAngle: rotateClockwise * rotationRange + randomRotation, duration: animationDuration),
            SKAction.scaleX(to: flipHorizontally * scale * scaleIncrease, y: scale * scaleIncrease, duration: animationDuration)
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
    private func animateParallax(changeSet set: ParallaxObject.SetType?) {
        let scale: CGFloat = 2
        let scaleIncrease: CGFloat = 1.1
        let animationDuration: TimeInterval = 12
        
        if let set = set {
            parallaxManager.changeSet(set: set)
            parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        }
            
        parallaxManager.backgroundSprite.setScale(scale)
        parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width / 2, y: -screenSize.height / 2 + 400)

        parallaxManager.backgroundSprite.run(SKAction.scale(to: scale * scaleIncrease, duration: animationDuration))
    }
    
    /**
     Animates a quick white flash, used to separate scenes within the Cutscene.
     - parameters:
        - fadeDuration: the length of time of the animation duration.
        - completion: a completion handler to return when the flash is completed (almost complete; actually calls it when it's fully opaque)
     */
    private func animateFlash(fadeDuration: TimeInterval, completion: (() -> Void)?) {
        //fadeTransitionNode is initially added to backgroundNode, so remove it first to prevent app crashing due to it already having a parent node.
        fadeTransitionNode.removeAllActions()
        fadeTransitionNode.removeFromParent()

        backgroundNode.addChild(fadeTransitionNode)
        
        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeDuration / 3),
            SKAction.run {
                completion?()
            },
            SKAction.wait(forDuration: fadeDuration / 3),
            SKAction.fadeOut(withDuration: fadeDuration / 3),
            SKAction.removeFromParent()
        ]))
    }
    
    
    // MARK: - Animation Scene Helper Functions
    
    private func playScene1() {
        animateParallax(changeSet: .marsh)

        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true)
        
        animatePlayer(player: &playerRight, 
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false)
    }
    
    private func playScene2() {
        animateParallax(changeSet: .ice)

        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true)
        
        animatePlayer(player: &playerRight,
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false)
    }
    
    private func playScene3() {
        animateParallax(changeSet: .lava)
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
        let textureDuration: TimeInterval = 0.06 * 2
        let fadeDuration: TimeInterval = 0.1
        let zoomScale: CGFloat = 0.5
        let zoomDuration: TimeInterval = 0.25
        
        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: textureDuration))
        playerMagmoor.sprite.run(animatePlayerWithTextures(player: playerMagmoor, textureType: .idle, timePerFrame: textureDuration))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
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
            SKAction.wait(forDuration: fadeDuration * 11 + 2 + 3),
            SKAction.group([
                SKAction.scale(to: 1, duration: zoomDuration),
                SKAction.move(to: .zero, duration: zoomDuration)
            ])
        ]))

        playerMagmoor.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: fadeDuration * 11 + 2 + 3),
            SKAction.group([
                SKAction.scale(to: zoomScale, duration: zoomDuration),
                SKAction.moveTo(y: screenSize.height / 3, duration: zoomDuration)
            ])
        ]))
    }
}


// MARK: - SkipSceneSprite Delegate

extension CutsceneOldFriends: SkipSceneSpriteDelegate {
    func buttonWasTapped() {
        //No fade duration because the protocol function does it's own .white fade transition in GameViewController.
        cleanupScene(buttonTap: .buttontap1, fadeDuration: nil)
    }
    
}
