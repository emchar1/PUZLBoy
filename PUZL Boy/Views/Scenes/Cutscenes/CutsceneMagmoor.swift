//
//  CutsceneMagmoor.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/6/24.
//

import SpriteKit

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

    private var subtitlePosition: CGPoint {
        CGPoint(x: screenSize.width * 1/2,
                y: screenSize.height * 1/2 - 300)
    }

    private var elder1: Player!
    private var elder2: Player!
    private var redWarp: SKSpriteNode!
    private var magmoorScarySprite: MagmoorScarySprite!
    
    
    // MARK: - Initialization
    
    init() {
        super.init(size: K.ScreenDimensions.size, playerLeft: .elder0, playerRight: .villain, xOffsetsArray: nil)
        
        //Custom implementation here, if needed.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let scene3Length: TimeInterval = 14
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
        }
        
        speechNarrator.setValues(color: .cyan.lightenColor(factor: 6), animationSpeed: 0.05)
        speechNarrator.setText(
            text: "MARLIN: The Council consists of the Elders: our oldest and most powerful Mystics. They govern and rule over our home realm, Mystaria.",
            superScene: self,
            completion: nil)
        
        playScene1(sceneLength: scene1Length)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: scene1Length),
            SKAction.run { [unowned self] in
                transitionScene(
                    narrateText: "By ambushing the Elders in the Sands of Solitude, Magmoor attempted to steal their power and become the most powerful Mystic to ever exist. But his miscalculation would cost him dearly!",
                    playScene: playScene2)
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: scene1Length + scene2Length),
            SKAction.run { [unowned self] in
                transitionScene(
                    narrateText: "For his treasonous act, the Elders banished Magmoor to the NETHER REALM for all eternity.........",
                    playScene: playScene3)
            }
        ]))
        
        run(SKAction.wait(forDuration: scene1Length + scene2Length + scene3Length)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
        }
    }
    
    
    // MARK: - Scene Sequences
    
    private func playScene1(sceneLength: TimeInterval) {

        //Properties and Subfunctions
        let letterboxDuration: TimeInterval = 3
        let fadeDuration: TimeInterval = 1
        let cutsceneDuration: TimeInterval = (sceneLength - letterboxDuration) / 3
        
        let whiteBackgroundNode = SKShapeNode(rectOf: screenSize)
        var forestRealmSprite = SKSpriteNode(imageNamed: "forestrealm")
        var lavaRealmSprite = SKSpriteNode(imageNamed: "lavarealm")
        var iceRealmSprite = SKSpriteNode(imageNamed: "icerealm")
        
        func setupRealm(sprite: inout SKSpriteNode,
                        xPositionOffset: CGFloat = -screenSize.width / 2,
                        scaleMultiplier: CGFloat,
                        zPosition: CGFloat) {
            
            sprite.position = CGPoint(x: xPositionOffset, y: -screenSize.height / 4)
            sprite.anchorPoint = .zero
            sprite.size = CGSize(width: 2300, height: 512)
            sprite.setScale((screenSize.height / 512) * scaleMultiplier)
            sprite.alpha = 0
            sprite.zPosition = zPosition
            
            whiteBackgroundNode.addChild(sprite)
        }
        
        func animateRealm(sceneOrder: Int) -> SKAction {
            return SKAction.sequence([
                SKAction.wait(forDuration: letterboxDuration),
                SKAction.fadeIn(withDuration: fadeDuration),
                SKAction.wait(forDuration: TimeInterval(sceneOrder) * cutsceneDuration - fadeDuration),
                SKAction.fadeOut(withDuration: fadeDuration),
                SKAction.removeFromParent()
            ])
        }

        AudioManager.shared.playSound(for: "ageofruin2")

        
        //Realms Setup
        whiteBackgroundNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        whiteBackgroundNode.fillColor = .white
        whiteBackgroundNode.lineWidth = 0
        whiteBackgroundNode.zPosition = K.ZPosition.parallaxLayer0 + 10
                
        setupRealm(sprite: &forestRealmSprite, xPositionOffset: -536 * 2 - 50, scaleMultiplier: 0.5, zPosition: 15)
        setupRealm(sprite: &lavaRealmSprite, scaleMultiplier: 0.5, zPosition: 10)
        setupRealm(sprite: &iceRealmSprite, scaleMultiplier: 0.5, zPosition: 5)

        backgroundNode.addChild(whiteBackgroundNode)

        
        //Realms Animation
        whiteBackgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: sceneLength + 1.5),
            SKAction.removeFromParent()
        ]))
        
        let delayDuration: TimeInterval = 1
        
        forestRealmSprite.run(animateRealm(sceneOrder: 1))
        forestRealmSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 4.5 + delayDuration),
            SKAction.repeat(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 20, duration: 0.05),
                SKAction.moveBy(x: 0, y: -20, duration: 0.05),

            ]), count: 3)
        ]))
        
        lavaRealmSprite.run(animateRealm(sceneOrder: 2))
        iceRealmSprite.run(animateRealm(sceneOrder: 3))
        
        
        //Elders
        setupElders()
        animateElders(letterboxDuration: letterboxDuration, cutsceneDuration: cutsceneDuration, fadeDuration: fadeDuration)
    }
    
    private func playScene2() {
        
        //Timing Properties
        let warpPause: TimeInterval = 6
        let zoomInPause: TimeInterval = 3
        let holdPause: TimeInterval = 7
        let thirdPause: TimeInterval = 2
        let attackPause: TimeInterval = 3
        let elderPauses: TimeInterval = warpPause + zoomInPause + holdPause + thirdPause + 2 //why extra 2s??? cannot be anything else!

        let elderDialoguePause: TimeInterval = 6.2
        let elderMagmoorPanPause: TimeInterval = 1.1
        let magmoorDialoguePause: TimeInterval = 5.3
        
        let forcefieldOffsetDuration: TimeInterval = 1.5
        let forcefieldSpawnPause: TimeInterval = warpPause + zoomInPause + holdPause + thirdPause + attackPause + elderDialoguePause + elderMagmoorPanPause + magmoorDialoguePause + forcefieldOffsetDuration //6 + 3 + 7 + 2 + 3 + 6.2 + 1.1 + 5.3 + 1.5 = 35.1s
        let forcefieldDuration: TimeInterval = 8

        //IMPORTANT: any animatePlayerWithTextures() should always be called FIRST, before any other SKActions!!
        animatePlayerWithTextures(player: &playerRight, textureType: .idle, timePerFrame: 0.12)

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
            SKAction.moveBy(x: -screenSize.width, y: 0, duration: 0.35)
        ]))
        
        
        //Speech Dialogue & Cuts
        speechPlayerLeft.position.x = leftPlayerPositionInitial.x - 150
        speechPlayerLeft.position.y = leftPlayerPositionInitial.y + 250
        speechPlayerLeft.updateTailOrientation(.bottomRight)
        speechPlayerRight.position.x = screenSize.width / 2 - 150
        speechPlayerRight.position.y = leftPlayerPositionInitial.y + 250

        wideShotWithRedWarp(magmoorPosition: rightPlayerPositionInitial, shouldTransportElders: true)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: elderPauses),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.05, chat: "Stop this, Magmoor!! You are outnumbered 3 to 1.||||"),
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "\"Outnumbered,\" you say?!! Then let's try—||||/3 to 100!"),
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.01, chat: "⚡️SHIELD!!!⚡️")
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
                    SKAction.moveTo(x: rightPlayerPositionFinal.x - 150, duration: 0.35),
                    SKAction.moveTo(y: rightPlayerPositionFinal.y + playerRight.sprite.size.height * 0.5 - 50, duration: 0.35)
                ]))

                speechPlayerLeft.run(SKAction.group([
                    SKAction.moveTo(x: leftPlayerPositionFinal.x + 25, duration: 0),
                    SKAction.moveTo(y: leftPlayerPositionFinal.y + playerLeft.sprite.size.height * 0.5 - 25, duration: 0)
                ]))
                
                speechPlayerLeft.updateTailOrientation(.bottomLeft)
                
                panToWideShot(magmoorPosition: rightPlayerPositionFinal, moveScaleDuration: 0.35)
            },
            SKAction.wait(forDuration: attackPause + forcefieldDuration),
            SKAction.run { [unowned self] in
                speechPlayerLeft.updateTailOrientation(.bottomRight)
                speechPlayerLeft.position.x = leftPlayerPositionInitial.x - 150
                speechPlayerLeft.position.y = leftPlayerPositionInitial.y + 250

                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.01, chat: "⚡️MINIMIZE!!!⚡️")
                ], completion: nil)
                
                closeupElders()
            },
            SKAction.wait(forDuration: 3), //random pause value #1
            SKAction.run { [unowned self] in
                speechPlayerLeft.position.x += 150
                speechPlayerLeft.updateTailOrientation(.bottomLeft)

                wideShotWithRedWarp(magmoorPosition: rightPlayerPositionFinal, shouldTransportElders: false)
                explodeMagmoorDuplicates(delay: 0.5)
            },
            SKAction.wait(forDuration: 2), //random pause value #2
            SKAction.run { [unowned self] in
                wideShotElderBanish()
            },
            SKAction.wait(forDuration: 1.3),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, speed: 0.01, chat: "⚡️BANISH!!!⚡️")
                ], completion: nil)

                closeupElder0()
            },
            SKAction.wait(forDuration: 0.25),
            SKAction.run { [unowned self] in
                closeupElder1()
            },
            SKAction.wait(forDuration: 0.25),
            SKAction.run { [unowned self] in
                closeupElder2()
            },
            SKAction.wait(forDuration: 0.25),
            SKAction.run { [unowned self] in
                wideShotElderBanish2()
                hideBloodSky(fadeDuration: 3.5)
            },
            SKAction.wait(forDuration: 3.5), //random pause value #3
            SKAction.run { [unowned self] in
                speechPlayerRight.position.x = screenSize.width / 2 - 150
                speechPlayerRight.position.y = leftPlayerPositionInitial.y + 250
                
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "NOOOOO!!!!!")
                ], completion: nil)
                
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
                SKAction.wait(forDuration: attackPause + forcefieldDuration)
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
            SKAction.wait(forDuration: forcefieldSpawnPause + forcefieldDuration - forcefieldOffsetDuration),
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
        
        showBloodSky(fadeDuration: holdPause, delay: warpPause)
        
        
        //Magmoor
        let farMagmoorScale: CGFloat = 0.1
        let nearMagmoorScale: CGFloat = 0.8
        let magmoorFadeInDuration: TimeInterval = 2.5
        let subtitleMagmoor = SubtitleLabelNode(text: "Magmoor", color: .red, position: subtitlePosition)
        
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
            Player.moveWithIllusions(playerNode: playerRight.sprite,
                                     backgroundNode: backgroundNode,
                                     color: .black,
                                     playSound: true,
                                     startPoint: playerRight.sprite.position,
                                     endPoint: rightPlayerPositionFinal,
                                     startScale: farMagmoorScale,
                                     endScale: nearMagmoorScale),
            SKAction.run { [unowned self] in
                magmoorScarySprite.pulseImage(backgroundColor: .black, delay: 0.25)
            }
        ])
        
        let magmoorFadeInAction: SKAction = SKAction.sequence([ //2.5s in total
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
        
        subtitleMagmoor.showSubtitle(to: backgroundNode,
                                     waitDuration: holdPause - magmoorFadeInDuration - 0.75 - 1,
                                     fadeDuration: 1,
                                     delay: warpPause + zoomInPause + magmoorFadeInDuration)
        
        playerRight.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
            SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
        ])))
        
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: warpPause + zoomInPause + 1),
            SKAction.moveTo(y: screenSize.height / 2, duration: 0),
            SKAction.group([
                SKAction.scaleX(to: -playerRight.scaleMultiplier * Player.cutsceneScale * 1.75, duration: magmoorFadeInDuration),
                SKAction.scaleY(to: playerRight.scaleMultiplier * Player.cutsceneScale * 1.75, duration: magmoorFadeInDuration),
                magmoorFadeInAction
            ]),
            SKAction.wait(forDuration: holdPause - magmoorFadeInDuration - 0.75), //why the extra 0.75???
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
    
    private func playScene3() {
        let scaleDuration: TimeInterval = 8
        
        parallaxManager.backgroundSprite.removeAllActions()
        setParallaxPositionAndScale(scale: 1)

        parallaxManager.changeSet(set: .planet)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        parallaxManager.backgroundSprite.zRotation = 0
        parallaxManager.backgroundSprite.position.x = -screenSize.width
        
        parallaxManager.backgroundSprite.run(SKAction.group([
            SKAction.move(to: CGPoint(x: -screenSize.width / 4, y: screenSize.height / 4), duration: scaleDuration),
            SKAction.scale(to: 0.5, duration: scaleDuration)
        ]))
        
        playerRight.sprite.removeAllActions()

        playerRight.sprite.setScale(1.5)
        playerRight.sprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + 200)
        playerRight.sprite.alpha = 1
        playerRight.sprite.zRotation = .pi / 4
        
        animatePlayerWithTextures(player: &playerRight, textureType: .idle, timePerFrame: 0.12)

        playerRight.sprite.run(SKAction.group([
            SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 8, duration: 2)),
            SKAction.scale(to: 0.25, duration: scaleDuration)
        ]))
        
        playerLeft.sprite.removeFromParent()
        elder1.sprite.removeFromParent()
        elder2.sprite.removeFromParent()

        removeMagmoorDuplicates()
        
        Haptics.shared.stopHapticEngine()
    }
    
    
    // MARK: - Scene #1 Helper Functions
    
    private func setupElders() {
        playerLeft.sprite.position = CGPoint(x: screenSize.width / 2 + 150, y: screenSize.height / 2 - 400)
        playerLeft.sprite.setScale(0.5)
        playerLeft.sprite.zRotation = -3/4 * .pi
        playerLeft.sprite.color = .systemBlue
        playerLeft.sprite.colorBlendFactor = 1
        playerLeft.sprite.alpha = 0

        elder1.sprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + 50)
        elder1.sprite.setScale(0.5)
        elder1.sprite.color = .orange
        elder1.sprite.colorBlendFactor = 1
        elder1.sprite.alpha = 0

        elder2.sprite.position = CGPoint(x: screenSize.width / 2 - 50, y: screenSize.height / 4 + elder2.sprite.size.height / 2 * 0.5 + 512 + 100)
        elder2.sprite.setScale(0.5)
        elder2.sprite.color = .brown
        elder2.sprite.colorBlendFactor = 1
        elder2.sprite.alpha = 0
    }
    
    private func animateElders(letterboxDuration: TimeInterval, cutsceneDuration: TimeInterval, fadeDuration: TimeInterval) {

        //Ice Elder
        let shakeDuration: TimeInterval = 0.01
        let totalShakeDuration: TimeInterval = 1
        let rotateDuration: TimeInterval = 0.3
        
        let subtitleIceMystic = SubtitleLabelNode(text: "Melchior", color: .cyan.darkenColor(factor: 4), position: subtitlePosition)
        subtitleIceMystic.showSubtitle(to: backgroundNode,
                                       waitDuration: cutsceneDuration - 2 * fadeDuration - totalShakeDuration,
                                       fadeDuration: fadeDuration,
                                       delay: letterboxDuration + 2 * cutsceneDuration + fadeDuration + totalShakeDuration)
        
        playerLeft.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: letterboxDuration + 2 * cutsceneDuration),
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.repeat(SKAction.sequence([
                SKAction.moveBy(x: -10, y: 0, duration: shakeDuration),
                SKAction.moveBy(x: 10, y: 0, duration: shakeDuration),
            ]), count: Int(totalShakeDuration / (2 * shakeDuration))),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &playerLeft, textureType: .idle, timePerFrame: 0.1)
                AudioManager.shared.playSound(for: "enemyice")
                ParticleEngine.shared.animateParticles(type: .magicElderIce,
                                                       toNode: playerLeft.sprite,
                                                       position: .zero,
                                                       scale: 2,
                                                       zPosition: 1,
                                                       duration: 0)
            },
            SKAction.group([
                SKAction.sequence([
                    SKAction.moveTo(y: screenSize.height / 2 + 25, duration: 2/3 * rotateDuration),
                    SKAction.moveTo(y: screenSize.height / 2 - 25, duration: 1/3 * rotateDuration)
                ]),
                SKAction.moveTo(x: screenSize.width / 2, duration: rotateDuration),
                SKAction.rotate(toAngle: 0, duration: rotateDuration),
                SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration),
            ]),
            SKAction.wait(forDuration: cutsceneDuration - 2 * fadeDuration - totalShakeDuration),
            SKAction.fadeOut(withDuration: fadeDuration)
        ]))

        
        //Fire Elder
        let pauseDuration: TimeInterval = 1
        
        let subtitleFireMystic = SubtitleLabelNode(text: "Magmus", color: .orange.darkenColor(factor: 4), position: subtitlePosition)
        subtitleFireMystic.showSubtitle(to: backgroundNode,
                                        waitDuration: cutsceneDuration - 2 * fadeDuration - pauseDuration,
                                        fadeDuration: fadeDuration,
                                        delay: letterboxDuration + cutsceneDuration + fadeDuration + pauseDuration)
        
        elder1.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: letterboxDuration + cutsceneDuration + pauseDuration),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &elder1, textureType: .idle, timePerFrame: 0.09)
                ParticleEngine.shared.animateParticles(type: .magicElderFire,
                                                       toNode: backgroundNode,
                                                       position: elder1.sprite.position + CGPoint(x: -550, y: 350),
                                                       scale: 2,
                                                       zPosition: K.ZPosition.itemsAndEffects,
                                                       duration: 0)
            },
            SKAction.wait(forDuration: fadeDuration),
            SKAction.run { [unowned self] in
                AudioManager.shared.playSound(for: "enemyflame")
                ParticleEngine.shared.animateParticles(type: .magicElderFire2,
                                                       toNode: backgroundNode,
                                                       position: elder1.sprite.position + CGPoint(x: 0, y: -50),
                                                       scale: 1,
                                                       zPosition: K.ZPosition.itemsAndEffects + 2,
                                                       duration: 0)
            },
            SKAction.fadeIn(withDuration: fadeDuration / 2),
            SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration / 2),
            SKAction.wait(forDuration: cutsceneDuration - 2 * fadeDuration - pauseDuration),
            SKAction.fadeOut(withDuration: fadeDuration)
        ]))

        
        //Earth Elder
        let moveDuration: TimeInterval = 0.25
        let delayDuration: TimeInterval = 1
        
        let subtitleEarthMystic = SubtitleLabelNode(text: "Merton", color: .systemGreen.darkenColor(factor: 2), position: subtitlePosition)
        subtitleEarthMystic.showSubtitle(to: backgroundNode,
                                         waitDuration: cutsceneDuration - 2 * fadeDuration - 2 * moveDuration,
                                         fadeDuration: fadeDuration,
                                         delay: letterboxDuration + fadeDuration + 2 * moveDuration)
        
        elder2.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: letterboxDuration),
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.wait(forDuration: delayDuration),
            SKAction.moveBy(x: 50, y: 0, duration: moveDuration),
            SKAction.moveBy(x: 0, y: -100, duration: moveDuration),
            SKAction.run { [unowned self] in
                animatePlayerWithTextures(player: &elder2, textureType: .idle, timePerFrame: 0.05)
                AudioManager.shared.playSound(for: "boyimpact")
                ParticleEngine.shared.animateParticles(type: .magicElderEarth,
                                                       toNode: elder2.sprite,
                                                       position: CGPoint(x: 0, y: -elder2.sprite.size.height / 2 - 50),
                                                       scale: 2,
                                                       zPosition: 1,
                                                       duration: 0)
                ParticleEngine.shared.animateParticles(type: .magicElderEarth2,
                                                       toNode: elder2.sprite,
                                                       position: CGPoint(x: 0, y: -elder2.sprite.size.height / 2),
                                                       scale: 2,
                                                       zPosition: -1,
                                                       duration: 0)
            },
            SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration),
            SKAction.wait(forDuration: cutsceneDuration - 2 * fadeDuration - 2 * moveDuration - delayDuration),
            SKAction.fadeOut(withDuration: fadeDuration)
        ]))
    }
    
    
    // MARK: - Scene #2 Helper Functions
    
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
    
    private func closeupElder0() {
        setParallaxPositionAndScale(scale: 2)
        parallaxManager.backgroundSprite.position.y -= 200

        animatePlayerWithTextures(player: &playerLeft, textureType: .idle, timePerFrame: 0.1)
        animatePlayerWithTextures(player: &elder1, textureType: .idle, timePerFrame: 0.09)
        animatePlayerWithTextures(player: &elder2, textureType: .idle, timePerFrame: 0.05)

        playerLeft.sprite.position = CGPoint(x: screenSize.width / 2, y: leftPlayerPositionFinal.y)
        playerLeft.sprite.setScale(2)
        playerLeft.sprite.xScale *= -1

        elder1.sprite.position = CGPoint(x: -800, y: 0)
        elder2.sprite.position = CGPoint(x: -800, y: 0)
    }
    
    private func closeupElder1() {
        parallaxManager.backgroundSprite.position.x += 400

        elder1.sprite.position = CGPoint(x: screenSize.width / 2, y: leftPlayerPositionFinal.y)
        elder1.sprite.setScale(2)

        playerLeft.sprite.position = CGPoint(x: screenSize.width + 800, y: 0)
        elder2.sprite.position = CGPoint(x: -800, y: 0)
    }
    
    private func closeupElder2() {
        parallaxManager.backgroundSprite.position.x -= 200
        parallaxManager.backgroundSprite.position.y += 300

        elder2.sprite.position = CGPoint(x: screenSize.width / 2, y: leftPlayerPositionFinal.y)
        elder2.sprite.setScale(2)

        playerLeft.sprite.position = CGPoint(x: screenSize.width + 800, y: 0)
        elder1.sprite.position = CGPoint(x: -800, y: 0)
    }
    
    private func wideShotElderBanish() {
        //Necessary animations. Call these BEFORE any other SKActions!
        animatePlayerWithTextures(player: &playerLeft, textureType: .idle, timePerFrame: 0.1)
        animatePlayerWithTextures(player: &elder1, textureType: .run, timePerFrame: 0.05)
        animatePlayerWithTextures(player: &elder2, textureType: .run, timePerFrame: 0.05)

        //Setup positions
        let elderPositionInitial: CGFloat = screenSize.width * 5/6
        let elderPositionFinal: CGFloat = screenSize.width * 1/6
        let elder2FinalPosition = CGPoint(x: elderPositionFinal + 100, y: leftPlayerPositionFinal.y - 200)

        parallaxManager.backgroundSprite.run(SKAction.moveTo(x: 0, duration: 0.25))
        
        playerLeft.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: elderPositionInitial, duration: 0.25),
            SKAction.scaleX(to: -playerLeft.sprite.xScale, duration: 0)
        ]))
        
        elder1.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: elderPositionInitial - 125, duration: 0.25),
            SKAction.scaleX(to: -elder1.sprite.xScale, duration: 0),
            SKAction.moveTo(x: elderPositionFinal, duration: 1)
        ]))
        
        elder2.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: elderPositionInitial - 175, duration: 0.25),
            SKAction.scaleX(to: -elder2.sprite.xScale, duration: 0),
            SKAction.group([
                SKAction.move(to: elder2FinalPosition, duration: 1),
                SKAction.scaleX(to: -elder2.sprite.xScale * 1.2, duration: 1),
                SKAction.scaleY(to: elder2.sprite.yScale * 1.2, duration: 1)
            ])
        ]))

        playerRight.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: screenSize.width + 800, duration: 0.25)
        ]))
    }
    
    private func wideShotElderBanish2() {
        //Setup positions
        let elder0Position = CGPoint(x: screenSize.width * 5/6, y: leftPlayerPositionFinal.y)
        let elder1Position = CGPoint(x: screenSize.width * 1/6, y: leftPlayerPositionFinal.y)
        let elder2Position = CGPoint(x: elder1Position.x + 100, y: leftPlayerPositionFinal.y - 200)
        let elderScale: CGFloat = 0.5
        let elderExplosionDelay: TimeInterval = 1.25
        let elderExplosionDuration: TimeInterval = 4

        func stretchSprite(_ sprite: SKSpriteNode) -> SKAction {
            return SKAction.sequence([
                SKAction.wait(forDuration: elderExplosionDelay),
                SKAction.scaleX(to: sprite.xScale * 0.6, duration: elderExplosionDuration)
            ])
        }
        
        setParallaxPositionAndScale(scale: 1)
        parallaxManager.backgroundSprite.position = CGPoint(x: 0, y: 0)

        playerLeft.sprite.position = elder0Position
        playerLeft.sprite.setScale(elderScale)
        playerLeft.sprite.xScale *= -1

        elder1.sprite.position = elder1Position
        elder1.sprite.setScale(elderScale * 0.9)

        elder2.sprite.position = elder2Position
        elder2.sprite.setScale(elderScale * 1.2)

        backgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.75),
            shakeBackground(duration: 1.8)
        ]))

        elderAttack(player: &playerLeft, elderRank: 0, shouldBanish: true)
        elderAttack(player: &elder1, elderRank: 1, shouldBanish: true)
        elderAttack(player: &elder2, elderRank: 2, shouldBanish: true, elder2Position: elder2Position + CGPoint(x: 100, y: 0))

        //Stretchy stretchy! Put this AFTER animatePlayerWithTextures()
        parallaxManager.backgroundSprite.run(stretchSprite(parallaxManager.backgroundSprite))
        playerLeft.sprite.run(stretchSprite(playerLeft.sprite))
        elder1.sprite.run(stretchSprite(elder1.sprite))
        elder2.sprite.run(stretchSprite(elder2.sprite))

        //Magic Elder Explosion
        run(SKAction.sequence([
            SKAction.wait(forDuration: elderExplosionDelay),
            SKAction.run { [unowned self] in
                AudioManager.shared.playSound(for: "magicelderexplosion")
                Haptics.shared.executeCustomPattern(pattern: .thunder)
                
                ParticleEngine.shared.animateParticles(type: .magicElderExplosion,
                                                       toNode: backgroundNode,
                                                       position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2),
                                                       scale: 0.8,
                                                       angle: 0,
                                                       zPosition: K.ZPosition.itemsAndEffects,
                                                       duration: elderExplosionDuration)

                ParticleEngine.shared.animateParticles(type: .magicElderExplosionStars,
                                                       toNode: backgroundNode,
                                                       position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2),
                                                       scale: 0.8,
                                                       angle: 0,
                                                       zPosition: K.ZPosition.itemsAndEffects + 2,
                                                       duration: elderExplosionDuration)
            }
        ]))
    }
    
    private func closeupMagmoorBanish() {
        let playerRightScale = playerRight.scaleMultiplier * Player.cutsceneScale
        let banishDuration: TimeInterval = 4.5
        
        parallaxManager.backgroundSprite.removeAllActions()
        setParallaxPositionAndScale(scale: 2)
        parallaxManager.backgroundSprite.position.x = -screenSize.width * 2
        parallaxManager.backgroundSprite.run(SKAction.rotate(byAngle: -.pi / 4, duration: banishDuration))

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
                                               duration: banishDuration)

        ParticleEngine.shared.animateParticles(type: .magicElderExplosionStars,
                                               toNode: backgroundNode,
                                               position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2),
                                               scale: 1.5,
                                               angle: 0,
                                               zPosition: K.ZPosition.itemsAndEffects + 2,
                                               duration: banishDuration)
        
        hideMagmoorDuplicates()
    }
    
    private func wideShotWithRedWarp(magmoorPosition: CGPoint, shouldTransportElders: Bool) {
        let elderScale: CGFloat = 0.5

        setParallaxPositionAndScale(scale: 1)

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
        
        if shouldTransportElders {
            let fadeInElder = SKAction.sequence([
                SKAction.wait(forDuration: 2),
                SKAction.fadeIn(withDuration: 3)
            ])
            
            playerLeft.sprite.run(fadeInElder)
            elder1.sprite.run(fadeInElder)
            elder2.sprite.run(fadeInElder)
        }
        
        showMagmoorDuplicates()
    }
    
    private func panToWideShot(magmoorPosition: CGPoint, moveScaleDuration: TimeInterval) {
        let elderScale: CGFloat = 0.5

        parallaxManager.backgroundSprite.run(SKAction.group([
            SKAction.move(to: CGPoint(x: -screenSize.width / 2, y: 0), duration: moveScaleDuration),
            SKAction.scale(to: 1, duration: moveScaleDuration)
        ]))
        
        playerLeft.sprite.run(SKAction.group([
            SKAction.move(to: leftPlayerPositionFinal, duration: moveScaleDuration),
            SKAction.scale(to: elderScale, duration: moveScaleDuration)
        ]))

        elder1.sprite.run(SKAction.group([
            SKAction.move(to: leftPlayerPositionFinal + CGPoint(x: -125, y: 25), duration: moveScaleDuration),
            SKAction.scale(to: elderScale * 0.9, duration: moveScaleDuration)
        ]))

        elder2.sprite.run(SKAction.group([
            SKAction.move(to: leftPlayerPositionFinal + CGPoint(x: -175, y: -50), duration: moveScaleDuration),
            SKAction.scale(to: elderScale, duration: moveScaleDuration)
        ]))
        
        playerRight.sprite.run(SKAction.group([
            SKAction.move(to: magmoorPosition, duration: moveScaleDuration),
            SKAction.scaleX(to: -elderScale, duration: moveScaleDuration),
            SKAction.scaleY(to: elderScale, duration: moveScaleDuration)
        ]))
        
        showMagmoorDuplicates()
    }

    
    // MARK: - Scene #2 Shared Functions
    
    private func setParallaxPositionAndScale(scale: CGFloat) {
        parallaxManager.backgroundSprite.setScale(scale)

        switch scale {
        case 1:
            parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width / 2, y: 0)
        case 2:
            parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width, y: -screenSize.height / 2 + 400)
        case 0.5: //not currently in use?
            parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width, y: letterbox.height / 2)
        default:
            parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width, y: 0)
        }
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
                                               emissionAngleRangeDegrees: shouldBanish ? 8 : nil,
                                               zPosition: 0,
                                               duration: 0)

        animatePlayerWithTextures(player: &player, textureType: .attack, timePerFrame: 0.06, repeatCount: 1)
    }
    
    private func duplicateMagmoor(from startPoint: CGPoint, to offsetPoint: CGPoint, delaySpawn: TimeInterval? = nil, delayAttack: TimeInterval? = nil, index: CGFloat = 1) {
        let initialScale: CGFloat = 0.5
        let finalScale: CGFloat = initialScale - offsetPoint.y * 0.0005
        let indexLeadingZeroes = String(format: "%02d", index)
        let moveDuration: TimeInterval = 0.25
        let animationTimePerFrame = 0.12 - TimeInterval.random(in: 0...0.06)

        let duplicate = Player(type: .villain)
        duplicate.sprite.position = startPoint
        duplicate.sprite.setScale(initialScale)
        duplicate.sprite.xScale *= -1
        duplicate.sprite.alpha = 0
        duplicate.sprite.anchorPoint.y = 0.25 //WHY is it 0.25?!?!
        duplicate.sprite.zPosition = playerRight.sprite.zPosition - index
        duplicate.sprite.name = "MagmoorDuplicate\(indexLeadingZeroes)"
        
        
        //Float animation
        duplicate.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
            SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
        ])))
        
        //Attack animation
        duplicate.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: (delaySpawn ?? 0) + (delayAttack ?? 0)),
            SKAction.animate(with: duplicate.textures[Player.Texture.attack.rawValue], timePerFrame: animationTimePerFrame),
            SKAction.wait(forDuration: 7),
            SKAction.repeatForever(SKAction.animate(with: duplicate.textures[Player.Texture.idle.rawValue], timePerFrame: animationTimePerFrame))
        ]))
        
        //Movement animation
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
                                                       position: CGPoint(x: 190, y: 0),
                                                       scale: 2,
                                                       angle: angleOfAttack,
                                                       zPosition: 25,
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
                SKAction.removeFromParent(),
            ]))
            
        }

        AudioManager.shared.playSound(for: "magicdisappear", delay: delay)
        Haptics.shared.executeCustomPattern(pattern: .sand)
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
