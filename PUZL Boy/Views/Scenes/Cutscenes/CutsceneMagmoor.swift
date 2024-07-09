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
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
                
        letterbox.setHeight(screenSize.height / 2)
        speechPlayerLeft.position += leftPlayerPositionInitial
        speechPlayerRight.position += rightPlayerPositionFinal
        fadeTransitionNode.fillColor = .white

        skipSceneSprite.delegate = self

        playerRight.sprite.position = rightPlayerPositionInitial
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1
        playerRight.sprite.alpha = 0
                
        elder1 = Player(type: .elder1)
        elder1.sprite.zPosition += 4
        
        elder2 = Player(type: .elder2)
        elder2.sprite.zPosition += 6
        
        redWarp = SKSpriteNode(imageNamed: "warp4")
        redWarp.scale(to: .zero)
        redWarp.zPosition = playerRight.sprite.zPosition - 5
        
        //Add new sprite nodes to background
        backgroundNode.addChild(elder1.sprite)
        backgroundNode.addChild(elder2.sprite)
        backgroundNode.addChild(redWarp)
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)
        
        let fadeDuration: TimeInterval = 2
        
        AudioManager.shared.stopSound(for: "ageofruin2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "forcefield", fadeDuration: fadeDuration)
    }
    
    
    // MARK: - Animate Functions
    
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
        
        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1),
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [unowned self] in
                speechNarrator.setText(text: narrateText, superScene: self, completion: nil)
                playScene()
            },
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ]))
    }
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)
        
        let sceneEndLength: TimeInterval = 75 //Length until end of song on "Aaaaaahhh!"
        let scene1Length: TimeInterval = 15
        let scene2Length: TimeInterval = sceneEndLength - scene1Length
        let scene3Length: TimeInterval = 25
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
            
            speechNarrator.setValues(color: .cyan.lightenColor(factor: 6), animationSpeed: 0.05)
            speechNarrator.setText(text: "MARLIN: The Elders are very powerful Mystics. Ancient and wise, they created the laws that govern our home realm.", superScene: self, completion: nil)
        }
        
        playScene1(sceneLength: scene1Length)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: scene1Length),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "By drawing them into the Ararian Desert, you thought you could ambush them and cut them off at the knees. But your miscalculation cost you dearly.", playScene: playScene2)
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: scene1Length + scene2Length),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "This is Magmoor floating around endlessly in the Limbo Realm (planet background???)", playScene: playScene3)
            }
        ]))
        
        run(SKAction.wait(forDuration: scene1Length + scene2Length + scene3Length)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
            print("Cleanup done.")
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
        
        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: 0.1))
        playerLeft.sprite.run(SKAction.scale(by: scaleRate, duration: sceneLength))
        
        elder1.sprite.run(animatePlayerWithTextures(player: elder1, textureType: .idle, timePerFrame: 0.09))
        elder1.sprite.run(SKAction.scale(by: scaleRate * 0.9, duration: sceneLength))
                
        elder2.sprite.run(animatePlayerWithTextures(player: elder2, textureType: .idle, timePerFrame: 0.05))
        elder2.sprite.run(SKAction.scale(by: scaleRate, duration: sceneLength))
                
        AudioManager.shared.playSound(for: "ageofruin2")
    }
    
    
    // TODO: - This needs to be a long scene. Need to add close up of elders attacking Magmoor, close up of Magmoor with spawns, then wide shot with spawns dissolving (spin and explode?) and finally Magmoor warping out.
    private func playScene2() {
        
        //Shared Properties
        let warpTime: TimeInterval = 3
        let zoomInPause: TimeInterval = 2
        let holdPause: TimeInterval = 6
        let thirdPause: TimeInterval = 3
        let attackTime: TimeInterval = 3
        
        
        //Parallax
        parallaxManager.changeSet(set: .sand)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        parallaxManager.backgroundSprite.position = CGPoint(x: 0, y: -screenSize.height / 2 + 400)
        parallaxManager.backgroundSprite.setScale(2)
        
        
        //Elders
        wideShotWithRedWarp()
        
        func elderAnimation(finalPosition: CGPoint, elderScale: CGFloat) -> SKAction {
            return SKAction.sequence([
                SKAction.wait(forDuration: warpTime + zoomInPause),
                SKAction.group([
                    SKAction.move(to: CGPoint(x: -screenSize.width / 2, y: -screenSize.height / 2), duration: 0.25),
                    SKAction.scale(to: elderScale * 8, duration: 0.25),
                    SKAction.fadeOut(withDuration: 0.25)
                ]),
                SKAction.wait(forDuration: holdPause),
                SKAction.group([
                    SKAction.move(to: finalPosition, duration: 0),
                    SKAction.scale(to: elderScale, duration: 0),
                    SKAction.fadeIn(withDuration: 0)
                ])
            ])
        }
        
        playerLeft.sprite.run(elderAnimation(finalPosition: leftPlayerPositionFinal, elderScale: 0.5))
        elder1.sprite.run(elderAnimation(finalPosition: leftPlayerPositionFinal + CGPoint(x: -125, y: 25), elderScale: 0.5 * 0.9))
        elder2.sprite.run(elderAnimation(finalPosition: leftPlayerPositionFinal + CGPoint(x: -175, y: -50), elderScale: 0.5))
        
        
        //Red Warp
        redWarp.run(SKAction.sequence([
            SKAction.repeat(SKAction.rotate(byAngle: .pi / 16, duration: 0.25), count: Int(warpTime + zoomInPause) * 4),
            SKAction.repeat(SKAction.rotate(byAngle: .pi / 16, duration: 1), count: Int(holdPause) + 1),
            SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 16, duration: 0.25))
        ]))
        
        redWarp.run(SKAction.sequence([
            SKAction.wait(forDuration: warpTime + zoomInPause + 0.25),
            SKAction.run { [unowned self] in
                AudioManager.shared.playSound(for: "magicwarp")
                
                ParticleEngine.shared.animateParticles(type: .warp4Slow,
                                                       toNode: backgroundNode,
                                                       position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2),
                                                       scale: 2,
                                                       zPosition: playerRight.sprite.zPosition - 2,
                                                       duration: holdPause - 1)
            }
        ]))
        
        redWarp.run(SKAction.sequence([
            SKAction.wait(forDuration: warpTime),
            SKAction.scale(to: 1, duration: 0.5),
            SKAction.wait(forDuration: zoomInPause - 0.5),
            SKAction.group([
                SKAction.moveTo(y: screenSize.height / 2, duration: 0.25),
                SKAction.scale(to: 8, duration: 0.25)
            ]),
            SKAction.wait(forDuration: holdPause - 1.5),
            SKAction.scale(to: 8.25, duration: 0.25),
            SKAction.scale(to: 0, duration: 0.25)
        ]))
        
        showBloodSky(bloodOverlayAlpha: 0.25, fadeDuration: holdPause, delay: warpTime)
        
        
        //Magmoor Animation
        let farMagmoorScale: CGFloat = 0.2
        let nearMagmoorScale: CGFloat = 0.5
        
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
        
        let magmoorTeleportAction: SKAction = Player.moveWithIllusions(magmoorNode: playerRight.sprite, 
                                                                       backgroundNode: backgroundNode,
                                                                       startPoint: playerRight.sprite.position, 
                                                                       endPoint: rightPlayerPositionFinal,
                                                                       startScale: farMagmoorScale,
                                                                       endScale: nearMagmoorScale)
        
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
        
        playerRight.sprite.run(SKAction.group([
            animatePlayerWithTextures(player: playerRight, textureType: .idle, timePerFrame: 0.12),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
                SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
            ]))
        ]))
        
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: warpTime + zoomInPause + 1),
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
            SKAction.fadeOut(withDuration: 0.1),
            magmoorTeleportAction,
            SKAction.group([
                SKAction.scaleX(to: -nearMagmoorScale, duration: 0),
                SKAction.scaleY(to: nearMagmoorScale, duration: 0),
                SKAction.move(to: rightPlayerPositionFinal, duration: 0),
                SKAction.fadeIn(withDuration: 0)
            ]),
            SKAction.run { [unowned self] in
                let initialPosition = rightPlayerPositionFinal
                let delaySpawn: TimeInterval = 1
                let delayAttack: TimeInterval = attackTime
                
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
        
        
        //Forcefield Animation
        let forcefieldSpawnTime: TimeInterval = warpTime + attackTime + zoomInPause + holdPause + thirdPause + 2.5 //Why 2.5???
        let forcefieldDuration: TimeInterval = 6
        
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
        }
        
        forcefieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: forcefieldSpawnTime),
            SKAction.group([
                forcefieldAppearAction,
                forcefieldRotateAction,
                forcefieldPulseAction,
                forcefieldFadeAction,
                forcefieldPlaySoundAction
            ])
        ]))
        
        forcefieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: forcefieldSpawnTime + forcefieldDuration),
            SKAction.run {
                AudioManager.shared.stopSound(for: "forcefield", fadeDuration: 1)
            },
            SKAction.scale(to: 3.2, duration: 0.5),
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ]))
        
        backgroundNode.addChild(forcefieldSprite)
    }
    
    // TODO: - Magmoor floating sadly, endlessly in the Limbo Realm for "eternity."
    private func playScene3() {
        parallaxManager.changeSet(set: .lava)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
                
        //Setup sprites
        let initialScale: CGFloat = 1.5
        let initialPosition: CGPoint = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let limboDuration: TimeInterval = 2
        
        playerRight.sprite.setScale(initialScale)
        playerRight.sprite.position = initialPosition
        playerRight.sprite.zRotation = 0
        
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
    
    private func closeupElders() {
        playerLeft.sprite.position = leftPlayerPositionInitial
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)

        elder1.sprite.position = leftPlayerPositionInitial + CGPoint(x: -250, y: 50)
        elder1.sprite.setScale(elder1.scaleMultiplier * Player.cutsceneScale * 0.9)

        elder2.sprite.position = leftPlayerPositionInitial + CGPoint(x: -350, y: -100)
        elder2.sprite.setScale(elder2.scaleMultiplier * Player.cutsceneScale)
        
        playerRight.sprite.position = CGPoint(x: screenSize.width + 800, y: 0)

        redWarp.position = CGPoint(x: screenSize.width + 800, y: 0)
    }
    
    private func wideShotWithRedWarp() {
        let elderScale: CGFloat = 0.5
        
        playerLeft.sprite.position = leftPlayerPositionFinal
        playerLeft.sprite.setScale(elderScale)

        elder1.sprite.position = leftPlayerPositionFinal + CGPoint(x: -125, y: 25)
        elder1.sprite.setScale(elderScale * 0.9)

        elder2.sprite.position = leftPlayerPositionFinal + CGPoint(x: -175, y: -50)
        elder2.sprite.setScale(elderScale)
        
        playerRight.sprite.position = rightPlayerPositionInitial
        
        redWarp.position = rightPlayerPositionInitial
    }
    
    private func duplicateMagmoor(from startPoint: CGPoint, to offsetPoint: CGPoint, delaySpawn: TimeInterval? = nil, delayAttack: TimeInterval? = nil, index: CGFloat = 1) {
        let initialScale: CGFloat = 0.5
        let finalScale: CGFloat = initialScale - offsetPoint.y * 0.001
        let indexLeadingZeroes = String(format: "%02d", index)
        let moveDuration: TimeInterval = 0.25

        let duplicate = Player(type: .villain)
        duplicate.sprite.position = startPoint
        duplicate.sprite.setScale(initialScale)
        duplicate.sprite.xScale *= -1
        duplicate.sprite.alpha = 0
        duplicate.sprite.anchorPoint.y = 0.25 //WHY is it 0.25?!?!
        duplicate.sprite.zPosition = playerRight.sprite.zPosition - index
        duplicate.sprite.name = "MagmoorDuplicate\(indexLeadingZeroes)"
        
        duplicate.sprite.run(SKAction.group([
            animatePlayerWithTextures(player: duplicate, textureType: .idle, timePerFrame: 0.12 + TimeInterval.random(in: -0.05...0)),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
                SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
            ]))
        ]))
        
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
                                                       duration: 0)
            }
        ]))
    } //end duplicateMagmoor()
    
    private func removeMagmoorDuplicates() {
        for node in backgroundNode.children {
            guard let name = node.name else { continue }
            
            if name.contains("MagmoorDuplicate") {
                node.removeAllActions()
                node.removeFromParent()
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
