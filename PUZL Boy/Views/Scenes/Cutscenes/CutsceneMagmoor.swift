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
    
    private var elder1: Player!
    private var elder2: Player!
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
        
        letterbox.setHeight(screenSize.height / 2)
        
        playerLeft.sprite.position = leftPlayerPositionInitial
        playerRight.sprite.position = rightPlayerPositionInitial
        playerRight.sprite.setScale(0)
        
        speechPlayerLeft.position += leftPlayerPositionInitial
        speechPlayerRight.position += rightPlayerPositionFinal
        
        elder1 = Player(type: .elder1)
        elder1.sprite.position = leftPlayerPositionInitial + CGPoint(x: -400, y: -100)
        elder1.sprite.setScale(elder1.scaleMultiplier * Player.cutsceneScale)
        elder1.sprite.zPosition += 6
        
        elder2 = Player(type: .elder2)
        elder2.sprite.position = leftPlayerPositionInitial + CGPoint(x: -200, y: 75)
        elder2.sprite.setScale(elder2.scaleMultiplier * Player.cutsceneScale * 0.9)
        elder2.sprite.zPosition += 4
        
        fadeTransitionNode.fillColor = .white
        
        skipSceneSprite.delegate = self
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)
        
        //Custom implementation here, if needed.
    }
    
    
    // MARK: - Animate Functions
    
//    /**
//     Helper function that animates a player by settingh up positions, rotations, scaling and adds the appropriate animations.
//     - parameters:
//        - player: the Player object which gets changed due to the inout modifier.
//        - position: initial position of the Player object.
//        - scale: initial scale of the player object.
//        - shouldFlipHorizontally: true if player should be facing left.
//        - shouldRotateClockwise: true if player is to slowly rotate clockwise.
//     */
//    private func animatePlayer(player: inout Player, position: CGPoint, scale: CGFloat, shouldFlipHorizontally: Bool, shouldRotateClockwise: Bool, duration: TimeInterval) {
//        let rotationRange: CGFloat = .pi / 8
//        let randomRotation: CGFloat = CGFloat.random(in: -rotationRange...rotationRange)
//        let scaleIncrease: CGFloat = 1.25
//        let flipHorizontally: CGFloat = shouldFlipHorizontally ? -1 : 1
//        let rotateClockwise: CGFloat = shouldRotateClockwise ? -1 : 1
//        let timePerFrame: TimeInterval = 0.06 * 2
//
//        player.sprite.position = position
//        player.sprite.setScale(scale)
//        player.sprite.xScale *= flipHorizontally
//        player.sprite.zRotation = randomRotation
//        
//        player.sprite.removeAllActions()
//        
//        player.sprite.run(SKAction.group([
//            animatePlayerWithTextures(player: player, textureType: .idle, timePerFrame: timePerFrame),
//            SKAction.rotate(toAngle: rotateClockwise * rotationRange + randomRotation, duration: duration),
//            SKAction.scaleX(to: flipHorizontally * scale * scaleIncrease, y: scale * scaleIncrease, duration: duration)
//        ]))
//    }
    
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
    
//    /**
//     Animates the parallaxManager scene with a slight scaling increase, and changes the set if needed.
//     - parameter set: changes the set to the inputted value, or doesn't if set is nil.
//     */
//    private func animateParallax(changeSet set: ParallaxObject.SetType? = nil, duration: TimeInterval) {
//        let scale: CGFloat = 2
//        let scaleIncrease: CGFloat = 1.1
//        
//        if let set = set {
//            parallaxManager.changeSet(set: set)
//            parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
//        }
//        
//        parallaxManager.backgroundSprite.setScale(scale)
//        parallaxManager.backgroundSprite.position = CGPoint(x: -screenSize.width / 2, y: -screenSize.height / 2 + 400)
//        
//        parallaxManager.backgroundSprite.run(SKAction.scale(to: scale * scaleIncrease, duration: duration))
//    }
    
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
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
            
            speechNarrator.setValues(color: .cyan.lightenColor(factor: 6), animationSpeed: 0.05)
            speechNarrator.setText(text: "MARLIN: The Elders are Mystics of the highest order. Ancient and wise, they created the laws that govern our home realm.", superScene: self, completion: nil)
            
//            narrateArray(items: [ //Order of elders' origin story.
//                NarrationItem(text: "MARLIN: The Elders are Mystics of the highest order. Ancient and wise, they created the laws that govern our home realm.||||||||", fontColor: .cyan.lightenColor(factor: 6), animationSpeed: 0.05, handler: nil),
//                NarrationItem(text: "By drawing them into the desert, you thought you could ambush them and cut them off at the knees. Your miscalculation cost you dearly.||||||||", fontColor: .cyan.lightenColor(factor: 6), animationSpeed: 0.05, handler: nil),
//                NarrationItem(text: "MAGMOOR: The council saw me as the biggest threat to their rule. They do not want to expand their power but to crush those who challenge them.||||||||", fontColor: .red.lightenColor(factor: 6), animationSpeed: 0.1, handler: nil),
//                NarrationItem(text: "You do not want to challenge them. You seek to replace them.", fontColor: .cyan.lightenColor(factor: 6), animationSpeed: 0.05, handler: nil)
//            ], completion: nil)
        }
        
        playScene1()
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 15),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "By drawing them into the Ararian Desert, you thought you could ambush them and cut them off at the knees. But your miscalculation cost you dearly.", playScene: playScene2)
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 15 + 30),
            SKAction.run { [unowned self] in
                transitionScene(narrateText: "This is Magmoor floating around endlessly in the Limbo Realm (planet background???)", playScene: playScene3)
            }
        ]))
        
        run(SKAction.wait(forDuration: 45 + 25)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
            print("Cleanup done.")
        }
    }
    
    
    // MARK: - Animation Scene Helper Functions
    
    private func playScene1() {
        let scaleDuration: TimeInterval = 15
        let scaleRate: CGFloat = 1.5
        
        //Parallax
        parallaxManager.changeSet(set: .ice)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        parallaxManager.backgroundSprite.run(SKAction.group([
            SKAction.moveBy(x: -80, y: -80, duration: scaleDuration),
            SKAction.scale(by: scaleRate, duration: scaleDuration)
        ]))
        
        //Elders
        playerLeft.sprite.run(animatePlayerWithTextures(player: playerLeft, textureType: .idle, timePerFrame: 0.1))
        playerLeft.sprite.run(SKAction.scale(by: scaleRate, duration: scaleDuration))
        
        elder1.sprite.run(animatePlayerWithTextures(player: elder1, textureType: .idle, timePerFrame: 0.09))
        elder1.sprite.run(SKAction.scale(by: scaleRate, duration: scaleDuration))
                
        elder2.sprite.run(animatePlayerWithTextures(player: elder2, textureType: .idle, timePerFrame: 0.05))
        elder2.sprite.run(SKAction.scale(by: scaleRate * 0.9, duration: scaleDuration))
        
        backgroundNode.addChild(elder1.sprite)
        backgroundNode.addChild(elder2.sprite)
    }
    
    
    // TODO: - This needs to be a long scene. Need to add close up of elders attacking Magmoor, close up of Magmoor with spawns, then wide shot with spawns dissolving (spin and explode?) and finally Magmoor warping out.
    private func playScene2() {
        let warpTime: TimeInterval = 3
        let attackTime: TimeInterval = 3
        let magmoorWait: TimeInterval = 6
        let forcefieldSpawnTime: TimeInterval = warpTime + magmoorWait + 3.5 + attackTime //3.5s = 1s after warpTime + 0.5s + 2s for teleporting
        let forcefieldDuration: TimeInterval = 6

        
        //Wide Shot Setup
        parallaxManager.changeSet(set: .sand)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position = CGPoint(x: 0, y: -screenSize.height / 2 + 400)

        playerLeft.sprite.setScale(0.5)
        playerLeft.sprite.position = leftPlayerPositionFinal
        
        elder1.sprite.setScale(0.5)
        elder1.sprite.position = leftPlayerPositionFinal + CGPoint(x: -175, y: -50)
        
        elder2.sprite.setScale(0.5 * 0.9)
        elder2.sprite.position = leftPlayerPositionFinal + CGPoint(x: -90, y: 25)
        

        //Magmoor Red Warp
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
        
        showBloodSky(bloodOverlayAlpha: 0.25, fadeDuration: magmoorWait, delay: warpTime)
        
        
        //Magmoor Animation
        let magmoorWarpInAction: SKAction = SKAction.group([
            SKAction.scaleX(to: -0.2, duration: 0.5),
            SKAction.scaleY(to: 0.2, duration: 0.5)
        ])
        
        let magmoorFadeOutAction: SKAction = SKAction.sequence([
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
        ])
        
        let magmoorTeleportRightAction: SKAction = SKAction.group([
            SKAction.scaleX(to: -0.5, duration: 0),
            SKAction.scaleY(to: 0.5, duration: 0),
            SKAction.move(to: rightPlayerPositionFinal, duration: 0)
        ])
        
        let magmoorFadeInAction: SKAction = SKAction.sequence([
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
        ])
        
        playerRight.sprite.run(SKAction.group([
            animatePlayerWithTextures(player: playerRight, textureType: .idle, timePerFrame: 0.12),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 15, duration: 1 + TimeInterval.random(in: 0...1)),
                SKAction.moveBy(x: 0, y: -15, duration: 1 + TimeInterval.random(in: 0...1))
            ]))
        ]))
        
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: warpTime + 1),
            magmoorWarpInAction,
            SKAction.wait(forDuration: magmoorWait),
            magmoorFadeOutAction,
            magmoorTeleportRightAction,
            magmoorFadeInAction,
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
        let forcefieldSprite = SKSpriteNode(imageNamed: "forcefield")
        forcefieldSprite.position = leftPlayerPositionFinal - CGPoint(x: 125, y: 0)
        forcefieldSprite.setScale(0)
        forcefieldSprite.alpha = 0
        forcefieldSprite.zPosition = K.ZPosition.player + 10
        
        let forcefieldRotateAction: SKAction = SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 4, duration: 2))
        
        let forcefieldPulseAction: SKAction = SKAction.sequence([
            SKAction.scale(to: 3.2, duration: 0.25),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 2.9, duration: 1),
                SKAction.scale(to: 3.1, duration: 1)
            ]))
        ])
        
        let forcefieldFadeAction: SKAction = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                SKAction.wait(forDuration: 1)
            ]))
        ])
        
        let forcefieldPlaySoundAction: SKAction = SKAction.run {
            AudioManager.shared.playSound(for: "forcefield")
            AudioManager.shared.playSound(for: "forcefield2")
        }
        
        forcefieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: forcefieldSpawnTime),
            SKAction.group([
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
                AudioManager.shared.stopSound(for: "forcefield2", fadeDuration: 1)
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
    }
    
    
    // MARK: - Misc. Helper Functions
    
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
        
        duplicate.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: delaySpawn ?? 0),
            SKAction.group([
                SKAction.fadeIn(withDuration: moveDuration),
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
