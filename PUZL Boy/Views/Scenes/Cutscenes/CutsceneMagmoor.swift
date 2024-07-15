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
        CGPoint(x: screenSize.width * 1/2 + 200,
                y: screenSize.height * 1/3 + 856 * 1/2) //856 instead of playerLeft.sprite.size.height
    }
    
    private var leftPlayerPositionFinal: CGPoint {
        CGPoint(x: screenSize.width * 1.5/5,
                y: screenSize.height * (1/4 + (1/3 * 0.5)) + 282 * 1/2 * 0.5) //282 instead of playerLeft.sprite.size.height
    }
    
    private var rightPlayerPositionInitial: CGPoint {
        CGPoint(x: screenSize.width * 1/2,
                y: screenSize.height * 2/3)
    }
    
    private var rightPlayerPositionFinal: CGPoint {
        CGPoint(x: screenSize.width * 4/5,
                y: screenSize.height * (1/4 + (1/3 * 0.5)) + 282 * 1/2 * 0.5) //282 instead of playerLeft.sprite.size.height
    }
    
    private var elder1: Player!
    private var elder2: Player!
    private var redWarp: SKSpriteNode!
    private var magmoorScarySprite: MagmoorScarySprite!
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
                
        letterbox.setHeight(screenSize.height / 2)
        fadeTransitionNode.fillColor = .white

        skipSceneSprite.delegate = self

        playerRight.sprite.alpha = 0
                
        elder1 = Player(type: .elder1)
        elder1.sprite.zPosition += 4
        
        elder2 = Player(type: .elder2)
        elder2.sprite.zPosition += 6
        
        redWarp = SKSpriteNode(imageNamed: "warp4")
        redWarp.scale(to: .zero)
        redWarp.zPosition = playerRight.sprite.zPosition - 5
        
        magmoorScarySprite = MagmoorScarySprite(boundingBox: CGRect(x: 0, y: 0, width: screenSize.width, height: letterbox.height / 2))
        magmoorScarySprite.zPosition = playerRight.sprite.zPosition - 3
        
        //Add new sprite nodes to background
        backgroundNode.addChild(elder1.sprite)
        backgroundNode.addChild(elder2.sprite)
        backgroundNode.addChild(redWarp)
        backgroundNode.addChild(magmoorScarySprite)
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)
        
        let fadeDuration: TimeInterval = 2
        
        AudioManager.shared.stopSound(for: "ageofruin2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "forcefield", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "forcefield2", fadeDuration: fadeDuration)
    }
    
    
    // MARK: - Animate Functions
    
    /**
     Helper function that removes all existing actions and runs an animation on the Player inout argument.
     - parameters:
        - player: the player object to animate.
        - textureType: the type of animation texture to play.
        - timePerFrame: the duration of each frame of the animation.
        - repeatCount: number of times to play the animation, or -1 to repeat forever.
        - completion: handler to execute after the end of the animation. Note: if repeat forever, completion will never be called.
     */
    private func animatePlayerWithTextures(player: inout Player, textureType: Player.Texture, timePerFrame: TimeInterval, repeatCount: Int = -1, completion: (() -> Void)? = nil) {
        let animateAction = SKAction.animate(with: player.textures[textureType.rawValue], timePerFrame: timePerFrame)
        let repeatAction = repeatCount == -1 ? SKAction.repeatForever(animateAction) : SKAction.repeat(animateAction, count: repeatCount)
        
        player.sprite.removeAllActions()
        
        player.sprite.run(repeatAction) {
            completion?()
        }
    }
    
    /**
     Animates a quick white flash used to separate scenes within the Cutscene, then plays a narration text overlay along with an accompanying scene.
     - parameters:
        - narrateText: the narrated text to play.
        - playScene: a completion handler that plays an accompanying scene.
     */
    private func transitionScene(narrateText: String, playScene: @escaping (() -> Void)) {
        //fadeTransitionNode is initially added to backgroundNode, so remove it FIRST to prevent app crashing from already having a parent node.
        fadeTransitionNode.removeAllActions()
        fadeTransitionNode.removeFromParent()
        backgroundNode.addChild(fadeTransitionNode)
        
        //temporarily remove skipSceneSprite. Somehow, tapping it during a transition prevents the cutscene from releasing properly, creating a potential memory leak!
        skipSceneSprite.removeFromParent()
        
        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1),
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [unowned self] in
                speechNarrator.setText(text: narrateText, superScene: self, completion: nil)
                playScene()
            },
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            addChild(skipSceneSprite)
        }
    }
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)
        
        let sceneEndLength: TimeInterval = 74 //Length until end of song on "Aaaaaahhh!". Keep at 74, it works when viewing from whole game!
        let scene1Length: TimeInterval = 15
        let scene2Length: TimeInterval = sceneEndLength - scene1Length
        let scene3Length: TimeInterval = 12
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
            
            speechNarrator.setValues(color: .cyan.lightenColor(factor: 6), animationSpeed: 0.05)
            speechNarrator.setText(text: "MARLIN: The Council consists of our forefathers, the Elders. Benevolent and wise, they created the laws that govern our Home Realm.", superScene: self, completion: nil)
        }
        
        playScene1(sceneLength: scene1Length)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: scene1Length),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "By drawing the Elders into the Ararian Desert, you thought you could ambush them and usurp their power. But your miscalculation would cost you dearly!", playScene: playScene2)
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: scene1Length + scene2Length),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "For your act of treason, they exiled you to the Limbo Realm for all eternity.........", playScene: playScene3)
            }
        ]))
        
        run(SKAction.wait(forDuration: scene1Length + scene2Length + scene3Length)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
        }
    }
    
    
    // MARK: - Animation Scene Helper Functions
    
    private func playScene1(sceneLength: TimeInterval) {
        let scaleRate: CGFloat = 1.5
        
        //Parallax
        parallaxManager.changeSet(set: .ice)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        parallaxManager.backgroundSprite.run(SKAction.group([
            SKAction.moveBy(x: -80, y: -80, duration: sceneLength),
            SKAction.scale(by: scaleRate, duration: sceneLength)
        ]))
        
        //Elders
        closeupElders()
        
        animatePlayerWithTextures(player: &playerLeft, textureType: .idle, timePerFrame: 0.1)
        playerLeft.sprite.run(SKAction.scale(by: scaleRate, duration: sceneLength))
        
        animatePlayerWithTextures(player: &elder1, textureType: .idle, timePerFrame: 0.09)
        elder1.sprite.run(SKAction.group([
            SKAction.moveBy(x: -75, y: 0, duration: sceneLength),
            SKAction.scale(by: scaleRate * 0.9, duration: sceneLength)
        ]))
                
        animatePlayerWithTextures(player: &elder2, textureType: .idle, timePerFrame: 0.05)
        elder2.sprite.run(SKAction.group([
            SKAction.moveBy(x: -150, y: 0, duration: sceneLength),
            SKAction.scale(by: scaleRate, duration: sceneLength)
        ]))
                
        AudioManager.shared.playSound(for: "ageofruin2")
    }
    
    private func playScene2() {
        
        //Timing Properties
        let warpPause: TimeInterval = 6
        let zoomInPause: TimeInterval = 3
        let holdPause: TimeInterval = 6
        let thirdPause: TimeInterval = 3
        let attackPause: TimeInterval = 3
        let elderPauses: TimeInterval = warpPause + zoomInPause + holdPause + thirdPause + 2 //why extra 2s??? cannot be anything else!

        let elderDialoguePause: TimeInterval = 6.2
        let elderMagmoorPanPause: TimeInterval = 1.1
        let magmoorDialoguePause: TimeInterval = 5.3
        
        let forcefieldExtraPause: TimeInterval = 0.4
        let forcefieldSpawnPause: TimeInterval = warpPause + zoomInPause + holdPause + thirdPause + attackPause + elderDialoguePause + elderMagmoorPanPause + magmoorDialoguePause + forcefieldExtraPause //6 + 2 + 6 + 3 + 3 + 6.2 + 1.1 + 5.3 + 0.4 = 33.0s
        let forcefieldDuration: TimeInterval = 8
        
        
        //Parallax
        parallaxManager.changeSet(set: .sand)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        parallaxManager.backgroundSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: warpPause + zoomInPause),
            SKAction.group([
                SKAction.moveTo(x: -screenSize.width * 3/2, duration: 0.25),
                SKAction.moveTo(y: -screenSize.height, duration: 0.25),
                SKAction.scale(to: 2, duration: 0.25)
            ]),
            SKAction.wait(forDuration: holdPause),
            SKAction.group([
                SKAction.moveTo(x: -screenSize.width / 2, duration: 0),
                SKAction.moveTo(y: 0, duration: 0),
                SKAction.scale(to: 1, duration: 0)
            ]),
            SKAction.wait(forDuration: thirdPause + 2 + elderDialoguePause),
            SKAction.moveBy(x: -screenSize.width, y: 0, duration: 0.35), //another hard coded number?! oye!
        ]))
        
        
        //Speech Dialogue & Cuts
        speechPlayerLeft.position.x = leftPlayerPositionInitial.x - 150
        speechPlayerLeft.position.y = leftPlayerPositionInitial.y + 250
        speechPlayerLeft.updateTailOrientation(.bottomRight)
        speechPlayerRight.position.x = screenSize.width / 2 - 150
        speechPlayerRight.position.y = leftPlayerPositionInitial.y + 250

        wideShotWithRedWarp(magmoorPosition: rightPlayerPositionInitial)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: elderPauses),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.05, chat: "Stop this, Magmoor!! We outnumber you 3 to 1.||||"),
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "\"Outnumber,\" you say?!! Then let's try—||||/100 to 3!"),
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.01, chat: "SHIELD!!")
                ], completion: nil)
                
                closeupElders()
            },
            SKAction.wait(forDuration: 0.25 + elderDialoguePause),
            SKAction.run { [unowned self] in
                speechPlayerLeft.run(SKAction.moveBy(x: -screenSize.width, y: 0, duration: 0.25))
            },
            SKAction.wait(forDuration: 0.25 + magmoorDialoguePause),
            SKAction.run { [unowned self] in
                speechPlayerRight.run(SKAction.group([
                    SKAction.moveTo(x: rightPlayerPositionFinal.x - 150, duration: 0),
                    SKAction.moveTo(y: rightPlayerPositionFinal.y + playerRight.sprite.size.height * 0.5 - 50, duration: 0)
                ]))

                speechPlayerLeft.run(SKAction.group([
                    SKAction.moveTo(x: leftPlayerPositionFinal.x + 25, duration: 0),
                    SKAction.moveTo(y: leftPlayerPositionFinal.y + playerLeft.sprite.size.height * 0.5 - 25, duration: 0)
                ]))
                
                speechPlayerLeft.updateTailOrientation(.bottomLeft)
                
                wideShotWithRedWarp(magmoorPosition: rightPlayerPositionFinal)
            },
            SKAction.wait(forDuration: attackPause + forcefieldDuration + forcefieldExtraPause),
            SKAction.run { [unowned self] in
                speechPlayerLeft.updateTailOrientation(.bottomRight)
                speechPlayerLeft.position.x = leftPlayerPositionInitial.x - 150
                speechPlayerLeft.position.y = leftPlayerPositionInitial.y + 250

                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.01, chat: "REDUCE!!")
                ], completion: nil)
                
                closeupElders()
            },
            SKAction.wait(forDuration: 3), //random pause value, need to tweak
            SKAction.run { [unowned self] in
                speechPlayerLeft.updateTailOrientation(.bottomLeft)
                speechPlayerLeft.position.x += 150

                wideShotWithRedWarp(magmoorPosition: rightPlayerPositionFinal)
                explodeMagmoorDuplicates(delay: 0.5)
            },
            SKAction.wait(forDuration: 3), //random pause value, need to tweak
            SKAction.run { [unowned self] in
                speechPlayerLeft.updateTailOrientation(.bottomRight)
                speechPlayerLeft.position.x = screenSize.width * 5/6 - 200
                speechPlayerLeft.position.y -= 200
                
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.01, chat: "BANISH!!")
                ], completion: nil)

                wideShotElderBanish()
            },
            SKAction.wait(forDuration: 4), //random pause value, need to tweak
            SKAction.run { [unowned self] in
                closeupMagmoorBanish()
            }
        ]))

        
        //Elders
        func animateElderHelper(positionOffset: CGPoint = .zero, scaleMultiplier: CGFloat = 1) -> SKAction {
            return SKAction.sequence([
                SKAction.wait(forDuration: warpPause + zoomInPause),
                SKAction.group([
                    SKAction.move(to: CGPoint(x: -screenSize.width / 2, y: -screenSize.height / 2), duration: 0.25),
                    SKAction.scale(to: 0.5 * scaleMultiplier * 8, duration: 0.25),
                    SKAction.fadeOut(withDuration: 0.25)
                ]),
                SKAction.wait(forDuration: holdPause),
                SKAction.group([
                    SKAction.move(to: leftPlayerPositionFinal + positionOffset, duration: 0),
                    SKAction.scale(to: 0.5 * scaleMultiplier, duration: 0),
                    SKAction.fadeIn(withDuration: 0)
                ]),
                SKAction.wait(forDuration: thirdPause + 2 + elderDialoguePause),
                SKAction.moveBy(x: -screenSize.width, y: 0, duration: 0.25),
                SKAction.wait(forDuration: magmoorDialoguePause),
                SKAction.wait(forDuration: attackPause + forcefieldDuration + forcefieldExtraPause)
            ])
        }

        playerLeft.sprite.run(animateElderHelper()) { [unowned self] in
            elderAttack(player: &playerLeft, elderRank: 0)
        }
        
        elder1.sprite.run(animateElderHelper(positionOffset: CGPoint(x: -125, y: 25), scaleMultiplier: 0.9)) { [unowned self] in
            elderAttack(player: &elder1, elderRank: 1)
        }
        
        elder2.sprite.run(animateElderHelper(positionOffset: CGPoint(x: -175, y: -50))) { [unowned self] in
            elderAttack(player: &elder2, elderRank: 2)
        }
        
        
        //Forcefield
        let forcefieldSprite = SKSpriteNode(imageNamed: "forcefield")
        forcefieldSprite.position = leftPlayerPositionFinal - CGPoint(x: 125, y: 0)
        forcefieldSprite.setScale(0)
        forcefieldSprite.alpha = 0
        forcefieldSprite.zPosition = K.ZPosition.player + 10
        
        let forcefieldAppearAction: SKAction = SKAction.group([
            SKAction.scale(to: 3.2, duration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)
        ])
        
        let forcefieldRotateAction: SKAction = SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 4, duration: 2))
        
        let forcefieldPulseAction: SKAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 2.9, duration: 1),
            SKAction.scale(to: 3.1, duration: 1)
        ]))
        
        let forcefieldFadeAction: SKAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5),
            SKAction.wait(forDuration: 1)
        ]))
        
        let forcefieldPlaySoundAction: SKAction = SKAction.run {
            AudioManager.shared.playSound(for: "forcefield")
            AudioManager.shared.playSound(for: "forcefield2")
        }
        
        forcefieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: forcefieldSpawnPause),
            SKAction.group([
                forcefieldAppearAction,
                forcefieldRotateAction,
                forcefieldPulseAction,
                forcefieldFadeAction,
                forcefieldPlaySoundAction
            ])
        ]))
        
        forcefieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: forcefieldSpawnPause + forcefieldDuration),
            SKAction.run {
                AudioManager.shared.stopSound(for: "forcefield", fadeDuration: 1)
                AudioManager.shared.stopSound(for: "forcefield2", fadeDuration: 1)
            },
            SKAction.scale(to: 3.2, duration: 0.5),
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ]))
        
        backgroundNode.addChild(forcefieldSprite)
        
        
        //Red Warp
        redWarp.run(SKAction.sequence([
            SKAction.repeat(SKAction.rotate(byAngle: .pi / 16, duration: 0.25), count: Int(warpPause + zoomInPause) * 4),
            SKAction.repeat(SKAction.rotate(byAngle: .pi / 16, duration: 1), count: Int(holdPause) + 1),
            SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 16, duration: 0.25))
        ]))
        
        redWarp.run(SKAction.sequence([
            SKAction.wait(forDuration: warpPause + zoomInPause + 0.25),
            SKAction.run { [unowned self] in
                AudioManager.shared.playSound(for: "magicwarp")
                AudioManager.shared.playSound(for: "magicwarp2")
                
                ParticleEngine.shared.animateParticles(type: .warp4Slow,
                                                       toNode: backgroundNode,
                                                       position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2),
                                                       scale: 2,
                                                       zPosition: playerRight.sprite.zPosition - 2,
                                                       duration: holdPause - 1)
            }
        ]))
        
        redWarp.run(SKAction.sequence([
            SKAction.wait(forDuration: warpPause),
            SKAction.scale(to: 0.5, duration: 0.5),
            SKAction.wait(forDuration: zoomInPause - 0.5),
            SKAction.group([
                SKAction.moveTo(y: screenSize.height / 2, duration: 0.25),
                SKAction.scale(to: 8, duration: 0.25)
            ]),
            SKAction.wait(forDuration: holdPause - 1.5),
            SKAction.scale(to: 10.25, duration: 0.25),
            SKAction.scale(to: 0, duration: 0.25)
        ]))
        
        showBloodSky(bloodOverlayAlpha: 0.25, fadeDuration: holdPause, delay: warpPause)
        
        
        //Magmoor
        let farMagmoorScale: CGFloat = 0.1
        let nearMagmoorScale: CGFloat = 0.8
        
        func magmoorTeleport(endPoint: CGPoint) -> SKAction {
            let faceDirection: CGFloat = Bool.random() ? 1 : -1
            let randomScale = CGFloat.random(in: 0.2...1)

            return SKAction.group([
                SKAction.fadeOut(withDuration: 0),
                SKAction.move(to: endPoint, duration: 0),
                SKAction.scaleX(to: faceDirection * randomScale, duration: 0),
                SKAction.scaleY(to: randomScale, duration: 0),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.2...0.8), duration: 0.2)
            ])
        }
        
        let magmoorTeleportAction: SKAction = SKAction.group([
            Player.moveWithIllusions(magmoorNode: playerRight.sprite,
                                     backgroundNode: backgroundNode,
                                     startPoint: playerRight.sprite.position,
                                     endPoint: rightPlayerPositionFinal,
                                     startScale: farMagmoorScale,
                                     endScale: nearMagmoorScale),
            SKAction.run { [unowned self] in
                magmoorScarySprite.pulseImage(backgroundColor: .black, delay: 0.25)
            }
        ])
        
        let magmoorFadeInAction: SKAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: 0.05),
            SKAction.fadeAlpha(to: 0.1, duration: 0.05),
            SKAction.fadeAlpha(to: 0, duration: 0.05),
            SKAction.fadeAlpha(to: 0.2, duration: 0.05),
            SKAction.fadeAlpha(to: 0, duration: 0.05),
            SKAction.fadeAlpha(to: 0.3, duration: 0.05),
            SKAction.fadeAlpha(to: 0, duration: 0.1),
            SKAction.fadeAlpha(to: 0.4, duration: 0.1),
            SKAction.fadeAlpha(to: 0, duration: 0.1),
            SKAction.fadeAlpha(to: 0.5, duration: 0.2),
            SKAction.fadeAlpha(to: 0, duration: 0.2),
            SKAction.fadeAlpha(to: 0.6, duration: 0.25),
            SKAction.fadeAlpha(to: 0, duration: 0.25),
            SKAction.fadeAlpha(to: 0.8, duration: 0.25),
            SKAction.fadeAlpha(to: 0, duration: 0.25),
            SKAction.fadeAlpha(to: 1, duration: 0.5)
        ])
        
        animatePlayerWithTextures(player: &playerRight, textureType: .idle, timePerFrame: 0.12)

        playerRight.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
            SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
        ])))
        
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: warpPause + zoomInPause + 1),
            SKAction.moveTo(y: screenSize.height / 2, duration: 0),
            SKAction.group([
                SKAction.scaleX(to: -playerRight.scaleMultiplier * Player.cutsceneScale * 1.75, duration: 2.5),
                SKAction.scaleY(to: playerRight.scaleMultiplier * Player.cutsceneScale * 1.75, duration: 2.5),
                magmoorFadeInAction
            ]),
            SKAction.wait(forDuration: holdPause - 2.5 - 0.75), //why the extra 0.75???
            SKAction.group([
                SKAction.moveTo(y: rightPlayerPositionInitial.y, duration: 0),
                SKAction.scaleX(to: -farMagmoorScale, duration: 0),
                SKAction.scaleY(to: farMagmoorScale, duration: 0)
            ]),
            SKAction.wait(forDuration: thirdPause),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.5),
                magmoorTeleportAction,
            ]),
            SKAction.group([
                SKAction.scaleX(to: -nearMagmoorScale, duration: 0),
                SKAction.scaleY(to: nearMagmoorScale, duration: 0),
                SKAction.move(to: rightPlayerPositionFinal, duration: 0),
                SKAction.fadeIn(withDuration: 0)
            ]),
            SKAction.wait(forDuration: elderDialoguePause + elderMagmoorPanPause),
            SKAction.group([
                SKAction.scaleX(to: playerRight.scaleMultiplier * Player.cutsceneScale * -1, duration: 0),
                SKAction.scaleY(to: playerRight.scaleMultiplier * Player.cutsceneScale, duration: 0),
                SKAction.moveTo(y: leftPlayerPositionInitial.y, duration: 0),
                SKAction.moveTo(x: screenSize.width / 2, duration: 0.25),
            ]),
            SKAction.wait(forDuration: magmoorDialoguePause),
            SKAction.run { [unowned self] in
                let initialPosition = rightPlayerPositionFinal
                let delaySpawn: TimeInterval = 1
                let delayAttack: TimeInterval = attackPause
                
                //should sort by increasing order of offsetPosition.y value!!! I hate how this is manual...
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 100, y: -420), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 1)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -60, y: -380), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 2)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -185, y: -330), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 3)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 210, y: -260), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 4)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -80, y: -225), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 5)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 150, y: -120), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 6)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 100, y: -110), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 7)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -100, y: -100), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 8)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 210, y: -60), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 9)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -185, y: -30), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 10)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 150, y: 20), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 11)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -80, y: 40), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 12)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 80, y: 70), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 13)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 220, y: 80), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 14)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -150, y: 100), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 15)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 140, y: 120), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 16)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -10, y: 150), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 17)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 235, y: 160), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 18)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 105, y: 185), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 19)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -100, y: 190), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 20)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -40, y: 220), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 21)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 50, y: 225), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 22)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 145, y: 245), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 23)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -160, y: 250), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 24)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 240, y: 260), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 25)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 20, y: 270), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 26)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -25, y: 290), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 27)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 110, y: 300), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 28)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: -100, y: 305), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 29)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 70, y: 310), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 30)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 190, y: 310), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 31)
                duplicateMagmoor(from: initialPosition, to: CGPoint(x: 130, y: 330), delaySpawn: delaySpawn, delayAttack: delayAttack, index: 32)
            }
        ]))
    }
    
    // TODO: - Magmoor floating sadly, endlessly in the Limbo Realm for "eternity."
    private func playScene3() {
        let initialScale: CGFloat = 1.5
        let initialPosition: CGPoint = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let limboDuration: TimeInterval = 2
        
        hideBloodSky(fadeDuration: 0)

        parallaxManager.changeSet(set: .planet)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)

        setParallaxPositionAndScale(scale: 1.01)
        
        parallaxManager.backgroundSprite.run(SKAction.group([
            SKAction.repeatForever(SKAction.moveBy(x: 45, y: 45, duration: limboDuration)),
            SKAction.repeatForever(SKAction.scale(by: 0.95, duration: limboDuration))
        ]))
        
        playerRight.sprite.removeAllActions()

        playerRight.sprite.setScale(initialScale)
        playerRight.sprite.position = initialPosition
        playerRight.sprite.alpha = 1
        playerRight.sprite.zRotation = 0
        
        animatePlayerWithTextures(player: &playerRight, textureType: .idle, timePerFrame: 0.12)

        playerRight.sprite.run(SKAction.group([
            SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 12, duration: limboDuration)),
            SKAction.repeatForever(SKAction.scale(by: 0.95, duration: limboDuration))
        ]))
        
        playerLeft.sprite.removeFromParent()
        elder1.sprite.removeFromParent()
        elder2.sprite.removeFromParent()

        removeMagmoorDuplicates()
        
        AudioManager.shared.playSound(for: "wompwomp", delay: 1)
    }
    
    
    // MARK: - Misc. Helper Functions
    
    private func setParallaxPositionAndScale(scale: CGFloat) {
        parallaxManager.backgroundSprite.setScale(scale)

        switch scale {
        case 1:
            parallaxManager.backgroundSprite.position = CGPoint(x: 0, y: 0)
        case 2:
            parallaxManager.backgroundSprite.position = CGPoint(x: 0, y: -screenSize.height / 2 + 400)
        case 0.5:
            parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width, y: letterbox.height / 2)
        default:
            parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width, y: 0)
        }
    }
    
    private func closeupElders() {
        setParallaxPositionAndScale(scale: 2)

        playerLeft.sprite.position = leftPlayerPositionInitial
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)

        elder1.sprite.position = leftPlayerPositionInitial + CGPoint(x: -250, y: 50)
        elder1.sprite.setScale(elder1.scaleMultiplier * Player.cutsceneScale * 0.9)

        elder2.sprite.position = leftPlayerPositionInitial + CGPoint(x: -350, y: -100)
        elder2.sprite.setScale(elder2.scaleMultiplier * Player.cutsceneScale)
        
        playerRight.sprite.position = CGPoint(x: screenSize.width + 800, y: 0)
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1

        redWarp.position = CGPoint(x: screenSize.width + 800, y: 0)
        
        hideMagmoorDuplicates()
    }
    
    private func wideShotElderBanish() {
        //Necessary animations
        animatePlayerWithTextures(player: &playerLeft, textureType: .idle, timePerFrame: 0.1)
        animatePlayerWithTextures(player: &elder1, textureType: .run, timePerFrame: 0.05)
        animatePlayerWithTextures(player: &elder2, textureType: .run, timePerFrame: 0.05)

        //Setup positions
        let elderPositionInitial: CGFloat = screenSize.width * 5/6
        let elderPositionFinal: CGFloat = screenSize.width * 1/6
        let elder2FinalPosition = CGPoint(x: elderPositionFinal + 100, y: leftPlayerPositionFinal.y - 200)

        parallaxManager.backgroundSprite.run(SKAction.moveTo(x: 0, duration: 0.25))
        
        backgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            shakeBackground(duration: 1.8)
        ]))

        playerLeft.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: elderPositionInitial, duration: 0.25),
            SKAction.scaleX(to: -playerLeft.sprite.xScale, duration: 0),
            SKAction.wait(forDuration: 1),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &playerLeft, textureType: .elderAttack, timePerFrame: 0.1, repeatCount: 1)
                elderAttack(player: &playerLeft, elderRank: 0, shouldBanish: true)
            }
        ]))
        
        elder1.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: elderPositionInitial - 125, duration: 0.25),
            SKAction.scaleX(to: -elder1.sprite.xScale, duration: 0),
            SKAction.moveTo(x: elderPositionFinal, duration: 1),
            SKAction.scaleX(to: elder1.sprite.xScale, duration: 0),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &elder1, textureType: .elderAttack, timePerFrame: 0.1, repeatCount: 1)
                elderAttack(player: &elder1, elderRank: 1, shouldBanish: true)
            }
        ]))
        
        elder2.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: elderPositionInitial - 175, duration: 0.25),
            SKAction.scaleX(to: -elder2.sprite.xScale, duration: 0),
            SKAction.group([
                SKAction.move(to: elder2FinalPosition, duration: 1),
                SKAction.scaleX(to: -elder2.sprite.xScale * 1.2, duration: 1),
                SKAction.scaleY(to: elder2.sprite.yScale * 1.2, duration: 1)
            ]),
            SKAction.scaleX(to: elder2.sprite.xScale * 1.2, duration: 0),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &elder2, textureType: .elderAttack, timePerFrame: 0.1, repeatCount: 1)
                elderAttack(player: &elder2, elderRank: 2, shouldBanish: true, elder2Position: elder2FinalPosition + CGPoint(x: 100, y: 0))
            }
        ]))

        playerRight.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: screenSize.width + 800, duration: 0.25)
        ]))
        
        //Magic Elder Explosion
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.4),
            SKAction.run { [unowned self] in
                AudioManager.shared.playSound(for: "magicelderexplosion")
                
                ParticleEngine.shared.animateParticles(type: .magicElderExplosion,
                                                       toNode: backgroundNode,
                                                       position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2),
                                                       scale: 0.8,
                                                       angle: 0,
                                                       zPosition: K.ZPosition.itemsAndEffects,
                                                       duration: 6)
            }
        ]))
    }
    
    private func closeupMagmoorBanish() {
        let playerRightScale = playerRight.scaleMultiplier * Player.cutsceneScale
        let banishDuration: TimeInterval = 4
        
        setParallaxPositionAndScale(scale: 2)

        playerLeft.sprite.position = CGPoint(x: -800, y: 0)
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)

        elder1.sprite.position = CGPoint(x: -800, y: 0)
        elder1.sprite.setScale(elder1.scaleMultiplier * Player.cutsceneScale * 0.9)

        elder2.sprite.position = CGPoint(x: -800, y: 0)
        elder2.sprite.setScale(elder2.scaleMultiplier * Player.cutsceneScale)
        
        playerRight.sprite.position = CGPoint(x: screenSize.width / 2, y: leftPlayerPositionInitial.y)
        playerRight.sprite.setScale(playerRightScale)
        playerRight.sprite.xScale *= -1
        playerRight.sprite.zPosition = K.ZPosition.itemsAndEffects + 5
        
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.group([
                SKAction.repeat(SKAction.sequence([
                    SKAction.moveBy(x: 20, y: 0, duration: 0.05),
                    SKAction.moveBy(x: -20, y: 0, duration: 0.05)
                ]), count: Int(banishDuration / 0.1)),
                SKAction.scaleX(to: -playerRightScale * 0.1, duration: banishDuration),
                SKAction.scaleY(to: playerRightScale * 2, duration: banishDuration),
                SKAction.rotate(toAngle: .pi / 6, duration: banishDuration),
                SKAction.fadeAlpha(to: 0.5, duration: banishDuration)
            ])
        ]))

        redWarp.position = CGPoint(x: screenSize.width + 800, y: 0)
        
        ParticleEngine.shared.removeParticles(fromNode: backgroundNode)
        ParticleEngine.shared.animateParticles(type: .magicElderExplosion,
                                               toNode: backgroundNode,
                                               position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2),
                                               scale: 1.5,
                                               angle: 0,
                                               zPosition: K.ZPosition.itemsAndEffects,
                                               duration: 5)

        
        hideMagmoorDuplicates()
    }
    
    private func wideShotWithRedWarp(magmoorPosition: CGPoint) {
        let elderScale: CGFloat = 0.5

        setParallaxPositionAndScale(scale: 1)
        parallaxManager.backgroundSprite.run(SKAction.moveTo(x: -screenSize.width / 2, duration: 0))

        playerLeft.sprite.position = leftPlayerPositionFinal
        playerLeft.sprite.setScale(elderScale)

        elder1.sprite.position = leftPlayerPositionFinal + CGPoint(x: -125, y: 25)
        elder1.sprite.setScale(elderScale * 0.9)

        elder2.sprite.position = leftPlayerPositionFinal + CGPoint(x: -175, y: -50)
        elder2.sprite.setScale(elderScale)
        
        playerRight.sprite.position = magmoorPosition
        playerRight.sprite.setScale(elderScale)
        playerRight.sprite.xScale *= -1
        
        redWarp.position = rightPlayerPositionInitial
        
        showMagmoorDuplicates()
    }
    
    private func elderAttack(player: inout Player, elderRank: Int, shouldBanish: Bool = false, elder2Position: CGPoint? = nil) {
        let angle: CGFloat
        let reduceAngle: CGFloat = .pi / 9
        let colorSequence: SKKeyframeSequence
        let colorSequenceTimes: [NSNumber] = [0.1, 0.2, 0.4]
        var alphaSequence: SKKeyframeSequence?
        
        if shouldBanish {
            alphaSequence = SKKeyframeSequence(keyframeValues: [1, -0.25, -1], times: [0.1, 0.3, 0.4])
        }
        
        switch elderRank {
        case 0: //Ice
            angle = shouldBanish ? .pi / 6 : 0

            colorSequence = SKKeyframeSequence(keyframeValues: [
                UIColor(red: 0/255, green: 48/255, blue: 128/255, alpha: 1),
                UIColor(red: 44/255, green: 193/255, blue: 255/255, alpha: 1),
                UIColor(red: 212/255, green: 212/255, blue: 255/255, alpha: 1)
            ], times: colorSequenceTimes)
        case 1: //Fire
            angle = shouldBanish ? .pi / 8 : reduceAngle

            colorSequence = SKKeyframeSequence(keyframeValues: [
                UIColor(red: 64/255, green: 32/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 100/255, alpha: 1)
            ], times: colorSequenceTimes)
        default: //Elder #2: Earth
            let elder2BanishAngle: CGFloat = SpriteMath.Trigonometry.getAngles(
                startPoint: elder2Position ?? .zero,
                endPoint: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
            ).beta
            
            angle = shouldBanish ? elder2BanishAngle : -reduceAngle

            colorSequence = SKKeyframeSequence(keyframeValues: [
                UIColor(red: 0/255, green: 48/255, blue: 0/255, alpha: 1),
                UIColor(red: 128/255, green: 192/255, blue: 64/255, alpha: 1),
                UIColor(red: 255/255, green: 169/255, blue: 255/255, alpha: 1)
            ], times: colorSequenceTimes)
        }
            
        //Magic reduce attack
        AudioManager.shared.playSound(for: shouldBanish ? "magicelderbanish" : "magicelderreduce")
        ParticleEngine.shared.animateParticles(type: .magicElder,
                                               toNode: player.sprite,
                                               position: CGPoint(x: 140, y: -120),
                                               scale: 2,
                                               angle: angle,
                                               colorSequence: colorSequence,
                                               alphaSequence: alphaSequence,
                                               zPosition: 0,
                                               duration: 0)

        animatePlayerWithTextures(player: &player, textureType: .elderAttack, timePerFrame: 0.06, repeatCount: 1)
    }
    
    private func duplicateMagmoor(from startPoint: CGPoint, to offsetPoint: CGPoint, delaySpawn: TimeInterval? = nil, delayAttack: TimeInterval? = nil, index: CGFloat = 1) {
        let initialScale: CGFloat = 0.5
        let finalScale: CGFloat = initialScale - offsetPoint.y * 0.001
        let indexLeadingZeroes = String(format: "%02d", index)
        let moveDuration: TimeInterval = 0.25

        var duplicate = Player(type: .villain)
        duplicate.sprite.position = startPoint
        duplicate.sprite.setScale(initialScale)
        duplicate.sprite.xScale *= -1
        duplicate.sprite.alpha = 0
        duplicate.sprite.anchorPoint.y = 0.25 //WHY is it 0.25?!?!
        duplicate.sprite.zPosition = playerRight.sprite.zPosition - index
        duplicate.sprite.name = "MagmoorDuplicate\(indexLeadingZeroes)"
        
        animatePlayerWithTextures(player: &duplicate, textureType: .idle, timePerFrame: 0.12 + TimeInterval.random(in: -0.05...0))

        duplicate.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
            SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
        ])))
        
        duplicate.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: delaySpawn ?? 0),
            SKAction.group([
                SKAction.fadeIn(withDuration: moveDuration),
                SKAction.move(to: startPoint + offsetPoint, duration: moveDuration),
                SKAction.scaleX(to: -1 * finalScale, duration: moveDuration),
                SKAction.scaleY(to: finalScale, duration: moveDuration)
            ])
        ]))
        
        backgroundNode.addChild(duplicate.sprite)
        
        
        //Magic blast lite attack
        run(SKAction.sequence([
            SKAction.wait(forDuration: (delaySpawn ?? 0) + (delayAttack ?? 0)),
            SKAction.run { [unowned self] in
                let angleOfAttack: CGFloat = SpriteMath.Trigonometry.getAngles(startPoint: startPoint, endPoint: leftPlayerPositionFinal).beta * (leftPlayerPositionFinal.y < startPoint.y ? 1 : -1)
                
                AudioManager.shared.playSound(for: "magicblast")
                
                ParticleEngine.shared.animateParticles(type: .magicBlastLite,
                                                       toNode: duplicate.sprite,
                                                       position: CGPoint(x: 190, y: 220),
                                                       scale: 2,
                                                       angle: angleOfAttack,
                                                       zPosition: 50,
                                                       duration: 0)
            }
        ]))
    }
    
    private func removeMagmoorDuplicates() {
        processMagmoorDuplicates { node in
            node.removeAllActions()
            node.removeFromParent()
        }
    }
    
    private func hideMagmoorDuplicates() {
        processMagmoorDuplicates { node in
            node.alpha = 0
        }
    }
    
    private func showMagmoorDuplicates() {
        processMagmoorDuplicates { node in
            node.alpha = 1
        }
    }
    
    private func explodeMagmoorDuplicates(delay: TimeInterval = 0) {
        processMagmoorDuplicates { node in
            let randomDelay: TimeInterval = TimeInterval.random(in: 0...0.5)
            
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: delay + randomDelay),
                SKAction.group([
                    SKAction.scaleX(to: -0.2, duration: 0.25),
                    SKAction.scaleY(to: 0.2, duration: 0.25),
                    SKAction.moveBy(x: 0, y: CGFloat.random(in: 50...100), duration: 0.25),
                    SKAction.fadeOut(withDuration: 0.25)
                ]),
                SKAction.removeFromParent()
            ]))
            
        }

        AudioManager.shared.playSound(for: "magicdisappear", delay: delay)
    }
    
    private func processMagmoorDuplicates(handler: (SKNode) -> Void) {
        for node in backgroundNode.children {
            guard let name = node.name else { continue }
            
            if name.contains("MagmoorDuplicate") {
                handler(node)
            }
        }
    }
    
}


// MARK: - SkipSceneSprite Delegate

extension CutsceneMagmoor: SkipSceneSpriteDelegate {
    func buttonWasTapped() {
        //No fade duration because the protocol function does it's own .white fade transition in GameViewController.
        cleanupScene(buttonTap: .buttontap1, fadeDuration: nil)
    }
    
}
