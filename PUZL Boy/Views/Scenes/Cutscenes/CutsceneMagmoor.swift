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
    
    //General
    private var leftPlayerPositionInitial: CGPoint { CGPoint(x: screenSize.width * 2/5,
                                                             y: screenSize.height * 1/3 + playerLeft.sprite.size.height / 2) }
    private var leftPlayerPositionFinal: CGPoint { CGPoint(x: screenSize.width * 2/5 * 0.5, 
                                                           y: screenSize.height * (1/4 + (1/3 * 0.5)) + playerLeft.sprite.size.height / 4) }
    private var rightPlayerPositionInitial: CGPoint { CGPoint(x: screenSize.width * 1/2, y: screenSize.height * 2/3) }
    private var rightPlayerPositionFinal: CGPoint { CGPoint(x: screenSize.width * 1/2, y: screenSize.height * 2/3) }
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
        
        letterbox.setHeight(screenSize.height / 2)
        
        playerLeft.sprite.position = leftPlayerPositionInitial
        playerRight.sprite.position = rightPlayerPositionInitial
        
        speechPlayerLeft.position += leftPlayerPositionInitial
        speechPlayerRight.position += rightPlayerPositionFinal
        
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
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
        }
        
        playScene1()
//        transitionScene(narrateText: "MARLIN: You tried to overthrow the Elders!! What did you expect was going to happen?!?! Are you insane, Magmoor?!!", playScene: playScene1)
//        run(SKAction.sequence([
//            SKAction.wait(forDuration: initialPause + 18),
//            SKAction.run { [unowned self] in
//                transitionScene(narrateText: "We weren't always at odds with each other. There was a time when we were quite good friends. We went to school together. Studied magic together. So it was only natural we became close.", playScene: playScene1)
//            }
//        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 22 + 18),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "Then war broke out. The division among the Mystics had been deepening. Magmoor and I led one faction. We defeated those who opposed us. He reveled in his glory..... to grave consequences.", playScene: playScene2)
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 46 + 18),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "I did what I had to do: I banished him to the Realm of Limbo. Peace eventually returned, but it will take years to repair the damage he caused.", playScene: playScene3)
            }
        ]))
        
        run(SKAction.wait(forDuration: 82 + 18)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
        }
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
    private func transitionScene(narrateText: String, playScene: @escaping (() -> Void)) {
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
//        let initialPause: TimeInterval = 6
//        let floatActionKey = "floatAction"
//        let floatAction = SKAction.repeatForever(SKAction.sequence([
//            SKAction.moveBy(x: 0, y: 25, duration: 0.75),
//            SKAction.moveBy(x: 0, y: -25, duration: 0.75)
//        ]))
//        let descendAction = SKAction.moveTo(y: leftPlayerPositionFinal.y, duration: 4)
//        descendAction.timingMode = .easeOut
        parallaxManager.changeSet(set: .sand)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)

        parallaxManager.backgroundSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0),
                SKAction.moveTo(x: 0, duration: 0),
                SKAction.moveTo(y: screenSize.height * 1/4, duration: 0)
            ])
        ]))

//        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: 0.12))
//        playerLeft.sprite.run(floatAction, withKey: floatActionKey)
//        playerLeft.sprite.run(SKAction.sequence([
//            SKAction.wait(forDuration: initialPause),
//            SKAction.moveTo(x: leftPlayerPositionFinal.x, duration: 5),
//            SKAction.wait(forDuration: 1),
//            descendAction
//        ])) { [unowned self] in
//            playerLeft.sprite.removeAction(forKey: floatActionKey)
//        }
        
        
        
        
        
        
        
        // TODO: - Magmoor illusion trail
//        var illusionStep = 1
//
//        playerLeft.sprite.run(SKAction.sequence([
//            SKAction.repeat(SKAction.sequence([
//                SKAction.run { [unowned self] in
//                    let illusionSprite = SKSpriteNode(imageNamed: "VillainIdle (1)")
//                    illusionSprite.size = Player.size
//                    illusionSprite.position = CGPoint(x: 0, y: leftPlayerPositionFinal.y - leftPlayerPositionInitial.y)
//                    illusionSprite.zPosition = -1
//                    illusionSprite.name = playerLeftNodeName + "illusionStep\(illusionStep)"
//                    
//                    playerLeft.sprite.addChild(illusionSprite)
//                },
//                SKAction.wait(forDuration: 0.1),
//                SKAction.run { [unowned self] in
//                    if let illusionSprite = playerLeft.sprite.childNode(withName: playerLeftNodeName + "illusionStep\(illusionStep)") {
//                        illusionSprite.run(SKAction.sequence([
//                            SKAction.fadeOut(withDuration: 0.5),
//                            SKAction.removeFromParent()
//                        ]))
//                    }
//                    
//                    illusionStep += 1
//                }
//            ]), count: 10)
//        ]))
        
        
        
        
        
        
        
        
        
        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: 0.12))
        playerLeft.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0),
                SKAction.move(to: leftPlayerPositionFinal, duration: 0)
            ])
        ]))
        
        playerRight.sprite.run(animatePlayerWithTextures(player: playerRight, textureType: .idle, timePerFrame: 0.12))
        playerRight.sprite.setScale(0.5)
        playerRight.sprite.xScale *= -1
        
//        playerRight.sprite.run(SKAction.sequence([
//            SKAction.wait(forDuration: initialPause + 5),
//            SKAction.moveTo(x: rightPlayerPositionFinal.x, duration: 5)
//        ]))
        
//        parallaxManager.animate()
//        run(SKAction.sequence([
//            SKAction.wait(forDuration: initialPause + 10),
//            SKAction.run { [unowned self] in
//                parallaxManager.stopAnimation()
//            }
//        ]))
    }
    
    private func playScene2() {
        let pauseDuration: TimeInterval = 10

        animateParallax(changeSet: .sand, duration: pauseDuration)
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

        
        //Animate Magmoor transformation
        let waitBeforeTransformation: TimeInterval = 22
        let fadeDuration: TimeInterval = 0.1
//        let zoomScale: CGFloat = 0.5
        let zoomDuration: TimeInterval = 0.25
        let timePerFrame: TimeInterval = 0.06 * 2

        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: timePerFrame))

        parallaxManager.backgroundSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: waitBeforeTransformation + fadeDuration * 11 + 3),
            SKAction.group([
                SKAction.scale(to: 1, duration: zoomDuration),
                SKAction.move(to: .zero, duration: zoomDuration)
            ])
        ]))
        
        backgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: waitBeforeTransformation + fadeDuration * 11 + 3 + zoomDuration),
            shakeBackground(duration: 2)
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
