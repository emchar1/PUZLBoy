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
    
    private var leftPlayerPositionInitial: CGPoint {
        CGPoint(x: screenSize.width * 2/5,
                y: screenSize.height * 1/3 + playerLeft.sprite.size.height * 1/2)
    }
    private var leftPlayerPositionFinal: CGPoint {
        CGPoint(x: screenSize.width * 1.5/5,
                y: screenSize.height * (1/4 + (1/3 * 0.5)) + playerLeft.sprite.size.height * 1/2 * 0.5)
    }
    private var rightPlayerPositionInitial: CGPoint {
        CGPoint(x: screenSize.width * 1/2, 
                y: screenSize.height * 2/3)
    }
    private var rightPlayerPositionFinal: CGPoint {
        CGPoint(x: screenSize.width * 4/5,
                y: screenSize.height * (1/4 + (1/3 * 0.5)) + playerLeft.sprite.size.height * 1/2 * 0.5)
    }
    
    
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

        //Parallax
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

        //Elders
        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: 0.1))
        playerLeft.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0),
                SKAction.move(to: leftPlayerPositionFinal, duration: 0)
            ])
        ]))
        
        let elder1 = Player(type: .elder1)
        elder1.sprite.position = leftPlayerPositionInitial + CGPoint(x: -250, y: 50)
        elder1.sprite.setScale(elder1.scaleMultiplier * Player.cutsceneScale * 0.9)
        elder1.sprite.zPosition += 4
        elder1.sprite.run(animatePlayerWithTextures(player: elder1, textureType: .idle, timePerFrame: 0.09))
        elder1.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.group([
                SKAction.scale(to: 0.5 * 0.9, duration: 0),
                SKAction.move(to: leftPlayerPositionFinal + CGPoint(x: -125, y: 25), duration: 0)
            ])
        ]))
        
        backgroundNode.addChild(elder1.sprite)
        
        let elder2 = Player(type: .elder2)
        elder2.sprite.position = leftPlayerPositionInitial + CGPoint(x: -350, y: -100)
        elder2.sprite.setScale(elder2.scaleMultiplier * Player.cutsceneScale)
        elder2.sprite.zPosition += 6
        elder2.sprite.run(animatePlayerWithTextures(player: elder2, textureType: .idle, timePerFrame: 0.08))
        elder2.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0),
                SKAction.move(to: leftPlayerPositionFinal + CGPoint(x: -175, y: -50), duration: 0)
            ])
        ]))
        
        backgroundNode.addChild(elder2.sprite)

        
        //Magmoor
        playerRight.sprite.run(animatePlayerWithTextures(player: playerRight, textureType: .idle, timePerFrame: 0.12))
        playerRight.sprite.setScale(0)
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 4.5),
            SKAction.group([
                SKAction.scaleX(to: -0.2, duration: 0.5),
                SKAction.scaleY(to: 0.2, duration: 0.5)
            ]),
            SKAction.wait(forDuration: 3),
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.8, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.6, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.4, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1)
            ]),
            SKAction.group([
                SKAction.scaleX(to: -0.5, duration: 0),
                SKAction.scaleY(to: 0.5, duration: 0),
                SKAction.move(to: rightPlayerPositionFinal, duration: 0)
            ]),
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.4, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.6, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.8, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 1, duration: 0.1)
            ])
        ]))
        
        let redWarp = SKSpriteNode(imageNamed: "warp4")
        redWarp.scale(to: .zero)
        redWarp.position = rightPlayerPositionInitial
        redWarp.zPosition = playerRight.sprite.zPosition - 5
        redWarp.run(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.scale(to: 1, duration: 0.5),
            SKAction.group([
                SKAction.rotate(toAngle: .pi, duration: 3),
                SKAction.sequence([
                    SKAction.wait(forDuration: 2.5),
                    SKAction.scale(to: 1.25, duration: 0.25),
                    SKAction.scale(to: 0, duration: 0.25)
                ])
            ])
        ]))
        
        backgroundNode.addChild(redWarp)
        
        showBloodSky(fadeDuration: 6, delay: 4)
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
