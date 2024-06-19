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
        CGPoint(x: screenSize.width * 1/2 + 175,
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
        let cutTime: TimeInterval = 10
        let warpTime: TimeInterval = cutTime + 3
        let attackTime: TimeInterval = 10
        let magmoorWait: TimeInterval = 6
        let forcefieldSpawnTime: TimeInterval = warpTime + magmoorWait + 3.5 + attackTime //3.5 from 1s after warp time + 0.5s + 2s for phasing

        //Parallax
        parallaxManager.changeSet(set: .sand)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        parallaxManager.backgroundSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: cutTime),
            SKAction.group([
                SKAction.scale(to: 2, duration: 0),
                SKAction.move(to: CGPoint(x: 0, y: -screenSize.height / 2 + 400), duration: 0)
//                SKAction.move(to: CGPoint(x: 0, y: screenSize.height * 1/4), duration: 0) //OLD - Zoom out
            ])
        ]))
        
        //Elders
        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: 0.1))
        playerLeft.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: cutTime),
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
            SKAction.wait(forDuration: cutTime),
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
            SKAction.wait(forDuration: cutTime),
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0),
                SKAction.move(to: leftPlayerPositionFinal + CGPoint(x: -175, y: -50), duration: 0)
            ])
        ]))
        
        backgroundNode.addChild(elder2.sprite)
        
        let forcefieldSprite = SKSpriteNode(imageNamed: "forcefield")
        forcefieldSprite.position = leftPlayerPositionFinal - CGPoint(x: 125, y: 0)
        forcefieldSprite.setScale(0)
        forcefieldSprite.alpha = 0
        forcefieldSprite.zPosition = K.ZPosition.player + 10
        
        forcefieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: forcefieldSpawnTime),
            SKAction.group([
                SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 4, duration: 2)),
                SKAction.sequence([
                    SKAction.scale(to: 3.2, duration: 0.25),
                    SKAction.repeatForever(SKAction.sequence([
                        SKAction.scale(to: 2.9, duration: 1),
                        SKAction.scale(to: 3.1, duration: 1)
                    ]))
                ]),
                SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.25),
                    SKAction.repeatForever(SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                        SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                        SKAction.wait(forDuration: 1)
                    ]))
                ]),
                SKAction.run {
                    AudioManager.shared.playSound(for: "forcefield")
                    AudioManager.shared.playSound(for: "forcefield2")
                }
            ])
        ]))
        
        forcefieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: forcefieldSpawnTime + 6),
            SKAction.run {
                AudioManager.shared.stopSound(for: "forcefield", fadeDuration: 1)
                AudioManager.shared.stopSound(for: "forcefield2", fadeDuration: 1)
            },
            SKAction.scale(to: 3.2, duration: 0.5),
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ]))
        
        backgroundNode.addChild(forcefieldSprite)
        
        
        //Magmoor
        playerRight.sprite.run(SKAction.group([
            animatePlayerWithTextures(player: playerRight, textureType: .idle, timePerFrame: 0.12),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
                SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
            ]))
        ]))
        
        playerRight.sprite.setScale(0)

        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: warpTime + 1),
            SKAction.group([
                SKAction.scaleX(to: -0.2, duration: 0.5),
                SKAction.scaleY(to: 0.2, duration: 0.5)
            ]),
            SKAction.wait(forDuration: magmoorWait),
            SKAction.sequence([
                SKAction.fadeAlpha(to: 1.0, duration: 0.1),
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
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.4, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.6, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 0.8, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            ]),
            SKAction.run { [unowned self] in
                let initialPosition = rightPlayerPositionFinal
                let delayAttack: TimeInterval = attackTime
                
                //should sort by increasing order of offsetPosition.y value!!! I hate how this is manual...
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 100, y: -110), delayAttack: delayAttack, index: 1)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -100, y: -100), delayAttack: delayAttack, index: 2)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 210, y: -60), delayAttack: delayAttack, index: 3)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -185, y: -30), delayAttack: delayAttack, index: 4)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 150, y: 20), delayAttack: delayAttack, index: 5)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -80, y: 40), delayAttack: delayAttack, index: 6)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 80, y: 70), delayAttack: delayAttack, index: 7)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 220, y: 80), delayAttack: delayAttack, index: 8)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -150, y: 100), delayAttack: delayAttack, index: 9)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 140, y: 120), delayAttack: delayAttack, index: 10)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -10, y: 150), delayAttack: delayAttack, index: 11)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 235, y: 160), delayAttack: delayAttack, index: 12)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 105, y: 185), delayAttack: delayAttack, index: 13)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -100, y: 190), delayAttack: delayAttack, index: 14)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -40, y: 220), delayAttack: delayAttack, index: 15)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 50, y: 225), delayAttack: delayAttack, index: 16)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 145, y: 245), delayAttack: delayAttack, index: 17)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -160, y: 250), delayAttack: delayAttack, index: 18)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 240, y: 260), delayAttack: delayAttack, index: 19)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 20, y: 270), delayAttack: delayAttack, index: 20)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -25, y: 290), delayAttack: delayAttack, index: 21)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 110, y: 300), delayAttack: delayAttack, index: 22)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -100, y: 305), delayAttack: delayAttack, index: 23)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 70, y: 310), delayAttack: delayAttack, index: 24)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 190, y: 310), delayAttack: delayAttack, index: 25)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 130, y: 330), delayAttack: delayAttack, index: 26)
            }
        ]))
        
        let redWarp = SKSpriteNode(imageNamed: "warp4")
        redWarp.scale(to: .zero)
        redWarp.position = rightPlayerPositionInitial
        redWarp.zPosition = playerRight.sprite.zPosition - 5
        redWarp.run(SKAction.sequence([
            SKAction.wait(forDuration: warpTime),
            SKAction.scale(to: 1, duration: 0.5),
            SKAction.group([
                SKAction.rotate(toAngle: .pi, duration: 5),
                SKAction.sequence([
                    SKAction.wait(forDuration: 4.5),
                    SKAction.scale(to: 1.25, duration: 0.25),
                    SKAction.scale(to: 0, duration: 0.25)
                ])
            ])
        ]))
        
        backgroundNode.addChild(redWarp)
        
        showBloodSky(bloodOverlayAlpha: 0.25, fadeDuration: 6, delay: warpTime)
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
    
    
    // MARK: - Misc. Helper Functions
    
    private func duplicateMagmoor(from startPoint: CGPoint, to offsetPoint: CGPoint, delayAttack: TimeInterval? = nil, index: CGFloat = 1) {
        let initialScale: CGFloat = 0.5
        let finalScale: CGFloat = initialScale - offsetPoint.y * 0.001
        let indexLeadingZeroes = String(format: "%02d", index)
        let moveDuration: TimeInterval = 0.25

        let duplicate = Player(type: .villain)
        duplicate.sprite.position = startPoint
        duplicate.sprite.setScale(initialScale)
        duplicate.sprite.xScale *= -1
        duplicate.sprite.anchorPoint.y = 0.25 //WHY is it 0.25?!?!
        duplicate.sprite.zPosition = playerRight.sprite.zPosition - index
        duplicate.sprite.name = "MagmoorDuplicate\(indexLeadingZeroes)"
        
        duplicate.sprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.move(to: startPoint + offsetPoint, duration: moveDuration),
                SKAction.scaleX(to: -1 * finalScale, duration: moveDuration),
                SKAction.scaleY(to: finalScale, duration: moveDuration)
            ]),
            SKAction.group([
                animatePlayerWithTextures(player: duplicate, textureType: .idle, timePerFrame: 0.12 + TimeInterval.random(in: -0.05...0)),
                SKAction.repeatForever(SKAction.sequence([
                    SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
                    SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
                ]))
            ])
        ]))
        
        backgroundNode.addChild(duplicate.sprite)
        
        
        //Magic blast lite attack
        run(SKAction.sequence([
            SKAction.wait(forDuration: delayAttack ?? 0),
            SKAction.run { [unowned self] in
                let angleOfAttack: CGFloat = SpriteMath.Trigonometry.getAngles(startPoint: startPoint, endPoint: leftPlayerPositionFinal).beta * (leftPlayerPositionFinal.y < startPoint.y ? 1 : -1)
                
                AudioManager.shared.playSound(for: "magicblast")
                
                ParticleEngine.shared.animateParticles(type: .magicBlastLite,
                                                       toNode: duplicate.sprite,
                                                       position: CGPoint(x: 190, y: 220),
                                                       scale: 2,
                                                       angle: angleOfAttack,
                                                       duration: 0)
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
