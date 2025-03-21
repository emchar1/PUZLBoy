//
//  PlayerSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/6/22.
//

import SpriteKit

class PlayerSprite {
    
    // MARK: - Properties
    
    private let animationSpeed: TimeInterval = 0.04

    private(set) var sprite: SKSpriteNode
    private(set) var isAnimating: Bool = false
    private var explodeAtlas: SKTextureAtlas
    private var player = Player(type: AgeOfRuin.isActive ? .youngTrainer : .hero)

    enum AnimationKey: String {
        case playerRespawn, playerIdle, playerMove, playerGlide, playerMarsh, playerPowerUp, playerParty
    }
    
    
    // MARK: - Initialization
    
    init(shouldSpawn: Bool) {
        sprite = player.sprite
        player.sprite.alpha = shouldSpawn ? 0 : 1
        explodeAtlas = SKTextureAtlas(named: "explode")
                
        startIdleAnimation()

        if shouldSpawn {
            startRespawnAnimation()
        }
    }
    
    deinit {
        print("deinit PlayerSprite")
    }
    
    
    // MARK: - Animation Functions
    
    //Made this public because inbetweenRealm functions in ChatEngineDelegate now need access 3/21/24
    func startRespawnAnimation() {
        player.sprite.run(SKAction.fadeAlpha(to: 1.0, duration: 0.75 * PartyModeSprite.shared.speedMultiplier),
                          withKey: AnimationKey.playerRespawn.rawValue)
    }
    
    //Added this function on 3/21/24 for inbetweenRealm functions
    func resetRespawnAnimation() {
        player.sprite.removeAction(forKey: AnimationKey.playerRespawn.rawValue)
        player.sprite.alpha = 0
    }
    
    ///Helper function to go with startIdleAnimation()
    func restartIdleAnimation(isPartying: Bool) {
        let partyingTimePerFrame = PartyModeSprite.shared.quarterNote / TimeInterval(player.textures[Player.Texture.idle.rawValue].count)
        let animation = Player.animate(player: player, type: .idle, timePerFrame: isPartying ? partyingTimePerFrame : 0.06)

        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.run(animation, withKey: AnimationKey.playerIdle.rawValue)
    }
    
    func startIdleAnimation() {
        let fadeDuration: TimeInterval = 0.25
        AudioManager.shared.stopSound(for: "moverun1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun3", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun4", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movewalk", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movemarsh1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movemarsh2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movemarsh3", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movesand1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movesand2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movesand3", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movesnow1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movesnow2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movesnow3", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movetile1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movetile2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movetile3", fadeDuration: fadeDuration)

        restartIdleAnimation(isPartying: PartyModeSprite.shared.isPartying)
        
        isAnimating = false
        
        if PartyModeSprite.shared.isPartying {
            startPartyAnimation()
        }
        else {
            stopPartyAnimation()
        }
    }
    
    func startMoveAnimation(animationType: Player.Texture, soundFXType: Player.Texture) {
        func playMoveSoundFX() {
            var moveSound: String?
            var count = 0
            
            repeat {
                switch soundFXType {
                case .run:      moveSound = "moverun\(Int.random(in: 1...4))"
                case .marsh:    moveSound = "movemarsh\(Int.random(in: 1...3))"
                case .sand:     moveSound = FireIceTheme.soundMovementSandSnow
                case .party:    moveSound = "movetile\(Int.random(in: 1...3))"
                case .walk:     moveSound = "movewalk"
                default:        moveSound = nil
                }
                
                count += 1
                
                if count > 20 { break } //avoids infinite loop
            } while moveSound != nil && AudioManager.shared.isPlaying(audioKey: moveSound!)
            
            if let moveSound = moveSound {
                AudioManager.shared.playSound(for: moveSound)
            }
        }
        
        let timePerFrameMultiplier: TimeInterval = (soundFXType == .marsh ? 1.5 : 1) * PartyModeSprite.shared.speedMultiplier
        
        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)
        
        isAnimating = true

        if animationType == .glide {
            AudioManager.shared.playSound(for: "moveglide", interruptPlayback: false)

            player.sprite.run(SKAction.sequence([
                Player.animate(player: player, type: animationType, timePerFrameMultiplier: timePerFrameMultiplier, repeatCount: 1),
                SKAction.wait(forDuration: 2.0 * PartyModeSprite.shared.speedMultiplier)
            ]), withKey: AnimationKey.playerGlide.rawValue)
        }
        else {
            playMoveSoundFX()
            
            player.sprite.run(Player.animate(player: player, type: animationType, timePerFrameMultiplier: timePerFrameMultiplier), withKey: AnimationKey.playerMove.rawValue)
        }
    }
    
    ///Fades the player as he's exiting through the gate
    func startPlayerExitAnimation() {
        let exitAction = SKAction.group([
            Player.animate(player: player, type: .run, timePerFrameMultiplier: PartyModeSprite.shared.speedMultiplier),
            SKAction.scaleX(to: player.sprite.xScale / 4, y: player.sprite.yScale / 4, duration: 0.5),
            SKAction.fadeOut(withDuration: 0.5)
        ])

        player.sprite.run(exitAction)

        AudioManager.shared.playSoundThenStop(for: "movetile\(Int.random(in: 1...3))", playForDuration: 0.2, fadeOut: 0.8)
    }
    
    func startMarshEffectAnimation() {
        let marshEffect = SKAction.sequence([
            SKAction.colorize(with: .systemPurple, colorBlendFactor: 1.0, duration: 0.0),
            SKAction.wait(forDuration: 0.5 * PartyModeSprite.shared.speedMultiplier),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.5 * PartyModeSprite.shared.speedMultiplier)
        ])
        
        AudioManager.shared.playSound(for: "movepoisoned\(Int.random(in: 1...3))")

        player.sprite.run(marshEffect, withKey: AnimationKey.playerMarsh.rawValue)
    }
    
    func startLavaEffectAnimation() {
        let lavaEffect = SKAction.sequence([
            SKAction.colorize(with: .systemOrange, colorBlendFactor: 1.0, duration: 0.0),
            SKAction.wait(forDuration: 0.5),
            SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: 0.5)
        ])
        
        AudioManager.shared.playSoundThenStop(for: "lavasizzle", playForDuration: 1, fadeOut: 1.5)
        
        player.sprite.run(lavaEffect)
    }
    
    func startWaterDrownAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition) {
        AudioManager.shared.playSound(for: "waterdrown")
        
        animateExplosion(on: gameboard, at: panel, scale: 1, textureName: "waterSplash", textureFrames: 6) { }
        
        player.sprite.run(SKAction.group([
            SKAction.repeat(SKAction.sequence([
                SKAction.rotate(byAngle: .pi / 12, duration: 0.1),
                SKAction.rotate(byAngle: -.pi / 12, duration: 0.1),
            ]), count: 8),
            SKAction.sequence([
                SKAction.moveBy(x: 0, y: -player.scale * player.sprite.size.height / 2, duration: 1.5),
                SKAction.fadeOut(withDuration: 0.25)
            ])
        ]))
    }
    
    func startWarpAnimation(shouldReverse: Bool, stopAnimating: Bool, completion: @escaping (() -> Void)) {
        isAnimating = true
        
        let warpEffect = SKAction.group([
            SKAction.rotate(byAngle: -3 * .pi, duration: 1.0 * PartyModeSprite.shared.speedMultiplier),
            SKAction.scale(to: shouldReverse ? player.scale : 0, duration: 1.0 * PartyModeSprite.shared.speedMultiplier)
        ])
        
        player.sprite.run(warpEffect) { [weak self] in
            self?.isAnimating = !stopAnimating
            completion()
        }
    }
    
    func startPowerUpAnimation() {
        AudioManager.shared.playSound(for: "pickupitem")
    }
    
    func startPartyAnimation() {
        let speed: TimeInterval = PartyModeSprite.shared.quarterNote / 2
        let sequenceAnimation = SKAction.colorizeWithRainbowColorSequence(duration: speed)
        
        restartIdleAnimation(isPartying: true)
        player.sprite.run(SKAction.repeatForever(sequenceAnimation), withKey: AnimationKey.playerParty.rawValue)
    }
    
    func stopPartyAnimation() {
        restartIdleAnimation(isPartying: false)
        player.sprite.removeAction(forKey: AnimationKey.playerParty.rawValue)
        player.sprite.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0))
    }
    
    func startItemCollectAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, item: LevelType, sound: LevelType = .gem, completion: @escaping (() -> Void)) {
        let itemSprite = SKSpriteNode(imageNamed: item.description + AgeOfRuin.ruinSuffix)
        itemSprite.position = gameboard.getLocation(at: panel) + GameboardSprite.padding / 2
        itemSprite.zPosition = K.ZPosition.itemsAndEffects + 10
        itemSprite.setScale(gameboard.panelSize / itemSprite.size.width)
        
        gameboard.sprite.addChild(itemSprite)
        
        itemSprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(by: 2, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
        
        completion()
        
        switch sound {
        case .heart:
            AudioManager.shared.playSound(for: "pickupheart")
        case .partyGem:
            AudioManager.shared.playSound(for: "gemcollectparty")
        case .partyGemDouble:
            AudioManager.shared.playSound(for: "gemcollectparty")
            AudioManager.shared.playSound(for: "gemcollectparty2x")
        case .partyGemTriple:
            AudioManager.shared.playSound(for: "gemcollectparty")
            AudioManager.shared.playSound(for: "gemcollectparty3x")
        case .partyTime:
            AudioManager.shared.playSound(for: "pickuptime")
        case .partyHint:
            AudioManager.shared.playSound(for: "pickupitem")
        case .partyLife:
            AudioManager.shared.playSound(for: "gemcollectpartylife")
            AudioManager.shared.playSound(for: "boywin")
        case .partyFast:
            AudioManager.shared.playSound(for: "partyfast")
        case .partySlow:
            AudioManager.shared.playSound(for: "partyslow")
        case .partyBomb, .partyBoom:
            AudioManager.shared.playSound(for: "boyimpact")
            AudioManager.shared.playSound(for: "boydead")
        case .boundary: //used when speedUp and speedDown are at their limit, i.e. "boundary"
            AudioManager.shared.playSound(for: "gemcollectparty")
        default:
            AudioManager.shared.playSound(for: "gemcollect")
        }
    }
    
    func startSwordAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, completion: @escaping (() -> Void)) {
        let scale: CGFloat = 0.9
        let attackSprite = SKSpriteNode(texture: SKTexture(imageNamed: "iconSword"))
        attackSprite.position = gameboard.getLocation(at: panel)
        attackSprite.zPosition = K.ZPosition.itemsAndEffects
        attackSprite.setScale(scale * (gameboard.panelSize / attackSprite.size.width))

        let animation = SKAction.sequence([
            SKAction.wait(forDuration: 0.25 * PartyModeSprite.shared.speedMultiplier),
            SKAction.rotate(byAngle: -3 * .pi / 2, duration: 0.25 * PartyModeSprite.shared.speedMultiplier),
            SKAction.fadeAlpha(to: 0, duration: 0.5 * PartyModeSprite.shared.speedMultiplier),
            SKAction.removeFromParent()
        ])
        
        isAnimating = true
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))")
        AudioManager.shared.playSound(for: "swordslash")
        AudioManager.shared.stopSound(for: "enemydeath") //Due to the length of the sound, need to stop it in case you consecutively kill dragons
        AudioManager.shared.playSound(for: "enemydeath", delay: 0.8 * PartyModeSprite.shared.speedMultiplier)

        gameboard.sprite.addChild(attackSprite)

        attackSprite.run(animation) {
            //Enemy death animation
            let enemyTopSprite = SKSpriteNode(imageNamed: FireIceTheme.spriteEnemyExplode + AgeOfRuin.ruinSuffix + " (1)")
            let enemyBottomSprite = SKSpriteNode(imageNamed: FireIceTheme.spriteEnemyExplode + AgeOfRuin.ruinSuffix + " (2)")
            let enemyScale = gameboard.panelSize / enemyTopSprite.size.width

            enemyTopSprite.position = gameboard.getLocation(at: panel)
            enemyTopSprite.zPosition = K.ZPosition.itemsAndEffects
            enemyTopSprite.setScale(enemyScale)

            enemyBottomSprite.position = gameboard.getLocation(at: panel)
            enemyBottomSprite.zPosition = K.ZPosition.itemsAndEffects
            enemyBottomSprite.setScale(enemyScale)
            
            gameboard.sprite.addChild(enemyTopSprite)
            gameboard.sprite.addChild(enemyBottomSprite)
            
            let animationDuration: TimeInterval = 0.3
            let animationMove: CGFloat = 150 / 3 * enemyScale
                        
            enemyTopSprite.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: -animationMove, y: animationMove, duration: animationDuration * PartyModeSprite.shared.speedMultiplier),
                    SKAction.fadeOut(withDuration: animationDuration * 2 * PartyModeSprite.shared.speedMultiplier)
                ]),
                SKAction.removeFromParent()
            ]))

            enemyBottomSprite.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: animationMove, y: -animationMove, duration: animationDuration * PartyModeSprite.shared.speedMultiplier),
                    SKAction.fadeOut(withDuration: animationDuration * 2 * PartyModeSprite.shared.speedMultiplier)
                ]),
                SKAction.removeFromParent()
            ])) { [weak self] in
                self?.isAnimating = false
            }
            
            //Points animation
            ScoringEngine.addScoreAnimation(score: ScoringEngine.killEnemyScore,
                                            usedContinue: nil,
                                            originSprite: gameboard.sprite,
                                            location: gameboard.getLocation(at: panel))
            
            completion()
        }
    }
    
    func startHammerAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, completion: @escaping (() -> Void)) {
        let scale: CGFloat = 0.75
        let attackSprite = SKSpriteNode(texture: SKTexture(imageNamed: "iconHammer"))
        attackSprite.position = gameboard.getLocation(at: panel)
        attackSprite.zPosition = K.ZPosition.itemsAndEffects
        attackSprite.setScale(scale * (gameboard.panelSize / attackSprite.size.width))

        let animation = SKAction.sequence([
            SKAction.rotate(byAngle: -3 * .pi / 4, duration: 0.2 * PartyModeSprite.shared.speedMultiplier),
            SKAction.wait(forDuration: 0.3 * PartyModeSprite.shared.speedMultiplier),
            SKAction.fadeAlpha(to: 0, duration: 0.5 * PartyModeSprite.shared.speedMultiplier),
            SKAction.removeFromParent()
        ])
        
        isAnimating = true
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))")
        AudioManager.shared.playSound(for: "hammerswing")
        AudioManager.shared.stopSound(for: "bouldersmash") //Due to the length of the sound, need to stop it in case you consecutively break boulders
        AudioManager.shared.playSound(for: "bouldersmash", delay: 0.8 * PartyModeSprite.shared.speedMultiplier)

        gameboard.sprite.addChild(attackSprite)

        attackSprite.run(animation) { [weak self] in
            self?.animateExplosion(on: gameboard, at: panel, scale: scale, textureName: "explode2", textureFrames: 7) { }
            
            completion()
        }
    }
    
    func animateExplosion(on gameboard: GameboardSprite, at panel: K.GameboardPosition, scale: CGFloat, textureName: String, textureFrames: Int, completion: @escaping () -> Void) {
        var explodeTextures: [SKTexture] = []

        for i in 1...textureFrames {
            explodeTextures.append(explodeAtlas.textureNamed("\(textureName + AgeOfRuin.ruinSuffix) (\(i))"))
        }

        let timePerFrame: TimeInterval = 0.06
        let explodeSprite = SKSpriteNode(texture: explodeTextures[0])
        explodeSprite.position = gameboard.getLocation(at: panel)
        explodeSprite.zPosition = K.ZPosition.itemsAndEffects
        explodeSprite.setScale(scale * (gameboard.panelSize / explodeSprite.size.width))

        gameboard.sprite.addChild(explodeSprite)

        explodeSprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.animate(with: explodeTextures, timePerFrame: timePerFrame),
                SKAction.scale(by: 1.25, duration: timePerFrame * Double(explodeTextures.count) * 2),
                SKAction.fadeAlpha(to: textureName == "explode2" ? 0 : 1, duration: timePerFrame * Double(explodeTextures.count) * 2)
            ]),
            SKAction.removeFromParent()
        ])) { [weak self] in
            self?.isAnimating = false
            
            completion()
        }
    }
        
    func startKnockbackAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, isAttacked: Bool, direction: Controls, completion: @escaping (() -> Void)) {
        
        let speedMultiplier: TimeInterval = PartyModeSprite.shared.speedMultiplier
        let newDirection = isAttacked ? direction.getOpposite : direction
        let knockback: CGFloat = 10
        let blinkColor: UIColor = FireIceTheme.overlaySystemColor
        
        isAnimating = true

        //Setup Knockback Actions
        var moveAction: SKAction
        var unmoveAction: SKAction
        
        switch newDirection {
        case .up:
            moveAction = SKAction.moveBy(x: 0, y: knockback, duration: 0)
            unmoveAction = SKAction.moveBy(x: 0, y: -knockback, duration: 0)
        case .down:
            moveAction = SKAction.moveBy(x: 0, y: -knockback, duration: 0)
            unmoveAction = SKAction.moveBy(x: 0, y: knockback, duration: 0)
        case .left:
            moveAction = SKAction.moveBy(x: -knockback, y: 0, duration: 0)
            unmoveAction = SKAction.moveBy(x: knockback, y: 0, duration: 0)
        case .right:
            moveAction = SKAction.moveBy(x: knockback, y: 0, duration: 0)
            unmoveAction = SKAction.moveBy(x: -knockback, y: 0, duration: 0)
        default:
            moveAction = SKAction.moveBy(x: 0, y: 0, duration: 0)
            unmoveAction = SKAction.moveBy(x: 0, y: 0, duration: 0)
            print("Unknown direction in PlayerSprite.startKnockbackAnimation()")
        }
        
        let knockbackAnimation = SKAction.sequence([
            moveAction,
            SKAction.colorize(with: blinkColor, colorBlendFactor: isAttacked ? 1.0 : 0.0, duration: 0),
            SKAction.wait(forDuration: 0.2 * speedMultiplier),
            unmoveAction
        ])
        
        let blinkAnimation = SKAction.sequence([
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 1.0, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.9, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.8, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.7, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.6, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.5, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.4, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.3, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.2, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * speedMultiplier)
        ])
        

        //Handle two cases:
        //  1.) isAttacked: attack by an enemy
        //  2.) !isAttacked: bump into a boulder, for ex.
        if isAttacked {
            let rotationDirectionType: GameboardSprite.RotateDirectionType
            let antiRotationDirection: GameboardSprite.RotateDirectionType
            let rotationAngle: CGFloat
            let dragonOffset: K.GameboardPosition
            var flameOffset = CGPoint(x: gameboard.panelSize, y: gameboard.panelSize)

            switch direction { //position of dragon in relation to PUZL Boy
            case .up:
                dragonOffset = (-1, 0)
                flameOffset = flameOffset * CGPoint(x: 0.2125, y: -0.0)
                rotationDirectionType = .rotateCounterClockwise
                antiRotationDirection = .rotateClockwise
                rotationAngle = -.pi / 2
            case .down:
                dragonOffset = (1, 0)
                flameOffset = flameOffset * CGPoint(x: -0.1625, y: 0.0625)
                rotationDirectionType = .rotateClockwise
                antiRotationDirection = .rotateCounterClockwise
                rotationAngle = .pi / 2
            case .left:
                dragonOffset = (0, -1)
                flameOffset = flameOffset * CGPoint(x: 0.0625, y: 0.2125)
                rotationDirectionType = .none
                antiRotationDirection = .none
                rotationAngle = 0
            case .right:
                dragonOffset = (0, 1)
                flameOffset = flameOffset * CGPoint(x: -0.0, y: 0.2125)
                rotationDirectionType = .flipHorizontal
                antiRotationDirection = .flipHorizontal
                rotationAngle = 0
            default:
                dragonOffset = (0, 0)
                rotationDirectionType = .none
                antiRotationDirection = .none
                rotationAngle = 0
                print("Unknown direction in PlayerSprite.startKnockbackAnimation()")
            }
            
            let dragonPosition = (panel.row + dragonOffset.row, panel.col + dragonOffset.col)
            let rotateDuration: TimeInterval = 0.2 * speedMultiplier
            
            gameboard.rotateEnemy(at: dragonPosition, directionType: rotationDirectionType, duration: rotateDuration) {
                Haptics.shared.executeCustomPattern(pattern: .enemy)
                AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
                AudioManager.shared.playSound(for: FireIceTheme.soundEnemyAttack)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + rotateDuration + 0.5) {
                gameboard.rotateEnemy(at: dragonPosition, directionType: antiRotationDirection, duration: rotateDuration) { [weak self] in
                    self?.isAnimating = false
                    completion()
                }
            }
            
            ParticleEngine.shared.animateParticles(type: FireIceTheme.particleTypeDragonFireLite,
                                                   toNode: gameboard.sprite,
                                                   position: gameboard.getLocation(at: dragonPosition) + flameOffset,
                                                   scale: 3 / CGFloat(gameboard.panelCount),
                                                   angle: rotationAngle,
                                                   shouldFlipHorizontally: direction == .right,
                                                   duration: 2)
            
            Haptics.shared.executeCustomPattern(pattern: .boulder)

            player.sprite.run(SKAction.sequence([knockbackAnimation, blinkAnimation]))
        }
        else {
            Haptics.shared.executeCustomPattern(pattern: .boulder)
            AudioManager.shared.playSound(for: "boygrunt\(Int.random(in: 1...2))")
            
            player.sprite.run(knockbackAnimation) { [weak self] in
                self?.isAnimating = false
                completion()
            }
        }
    }
    
    func startDeadAnimation(shouldDrown: Bool, completion: @escaping (() -> Void)) {
        isAnimating = true
        AudioManager.shared.playSound(for: "boydead")
        
        let deadAction = shouldDrown ? Player.animate(player: player, type: .drown, repeatCount: 7) : SKAction.sequence([
            Player.animate(player: player, type: .dead, repeatCount: 1),
            SKAction.wait(forDuration: 1.5)
        ])
        
        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)
        
        player.sprite.run(deadAction) { [weak self] in
            self?.isAnimating = false
            completion()
        }
    }
    
    func hidePlayer() {
        player.sprite.run(SKAction.fadeOut(withDuration: 1))
    }

    
    // MARK: - Getters & Setters

    func setPlayerSpriteScale(panelSize: CGFloat) {
        player.sprite.setScale(Player.getGameboardScale(panelSize: panelSize)) // 1.5 / panelCount
        player.setPlayerScale(abs(player.sprite.xScale)) // Always seems to be 0.5
    }
}
