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
    private var explodeBoulderAtlas: SKTextureAtlas
    private var explodeBoulderTextures: [SKTexture]
    private var player = Player(type: .hero)

    enum AnimationKey: String {
        case playerRespawn, playerIdle, playerMove, playerGlide, playerMarsh, playerPowerUp, playerParty
    }
    
    
    // MARK: - Initialization
    
    init(shouldSpawn: Bool) {
        sprite = player.sprite
        player.sprite.alpha = shouldSpawn ? 0 : 1

        explodeBoulderAtlas = SKTextureAtlas(named: "explode")
        explodeBoulderTextures = []

        for i in 1...7 {
            explodeBoulderTextures.append(explodeBoulderAtlas.textureNamed("explode2 (\(i))"))
        }
                
        startIdleAnimation(hasSword: false, hasHammer: false)

        if shouldSpawn {
            startRespawnAnimation()
        }
    }
    
    
    // MARK: - Animation Functions
    
    private func startRespawnAnimation() {
        player.sprite.run(SKAction.fadeAlpha(to: 1.0, duration: 0.75 * PartyModeSprite.shared.speedMultiplier),
                          withKey: AnimationKey.playerRespawn.rawValue)
    }
    
    ///Helper function to go with startIdleAnimation()
    func restartIdleAnimation(hasSword: Bool, hasHammer: Bool, isPartying: Bool) {
        var idleTexture: Player.Texture = Player.Texture.idle
        
        if hasSword && hasHammer {
            idleTexture = Player.Texture.idleHammerSword
        }
        else if hasSword {
            idleTexture = Player.Texture.idleSword
        }
        else if hasHammer {
            idleTexture = Player.Texture.idleHammer
        }
        
        let animation = SKAction.animate(with: player.textures[idleTexture.rawValue],
                                         timePerFrame: isPartying ? PartyModeSprite.shared.quarterNote / TimeInterval(player.textures[Player.Texture.idle.rawValue].count) : animationSpeed * 1.5)

        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.run(SKAction.repeatForever(animation), withKey: AnimationKey.playerIdle.rawValue)
    }
    
    func startIdleAnimation(hasSword: Bool, hasHammer: Bool) {
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
        AudioManager.shared.stopSound(for: "movetile1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movetile2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movetile3", fadeDuration: fadeDuration)

        restartIdleAnimation(hasSword: hasSword, hasHammer: hasHammer, isPartying: PartyModeSprite.shared.isPartying)
        
        isAnimating = false
        
        if PartyModeSprite.shared.isPartying {
            startPartyAnimation(hasSword: hasSword, hasHammer: hasHammer)
        }
        else {
            stopPartyAnimation(hasSword: hasSword, hasHammer: hasHammer)
        }
    }
    
    func startMoveAnimation(animationType: Player.Texture, soundFXType: Player.Texture) {
        let animationRate: TimeInterval = animationType == .marsh ? 1.25 : 1
        let animation = SKAction.animate(with: player.textures[animationType.rawValue],
                                         timePerFrame: animationSpeed * animationRate * PartyModeSprite.shared.speedMultiplier)

        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)
        
        isAnimating = true

        if animationType == .glide || animationType == .glideSword || animationType == .glideHammer || animationType == .glideHammerSword {
            AudioManager.shared.playSound(for: "moveglide", interruptPlayback: false)

            player.sprite.run(SKAction.sequence([
                SKAction.repeat(animation, count: 1),
                SKAction.wait(forDuration: 2.0 * PartyModeSprite.shared.speedMultiplier)
            ]), withKey: AnimationKey.playerGlide.rawValue)
        }
        else {
            switch soundFXType {
            case .run:
                AudioManager.shared.playSound(for: "moverun\(Int.random(in: 1...4))")
            case .marsh:
                AudioManager.shared.playSound(for: "movemarsh\(Int.random(in: 1...3))")
            case .sand:
                AudioManager.shared.playSound(for: "movesand\(Int.random(in: 1...3))")
            case .party:
                AudioManager.shared.playSound(for: "movetile\(Int.random(in: 1...3))")
            case .walk:
                AudioManager.shared.playSound(for: "movewalk")
            default:
                print("Unknown soundFXType")
            }
            
            player.sprite.run(SKAction.repeatForever(animation), withKey: AnimationKey.playerMove.rawValue)
        }
    }
    
    ///Fades the player as he's exiting through the gate
    func startPlayerExitAnimation() {
        let runAnimation = SKAction.animate(with: player.textures[Player.Texture.run.rawValue],
                                            timePerFrame: animationSpeed * PartyModeSprite.shared.speedMultiplier)
        let exitAction = SKAction.group([
            SKAction.repeatForever(runAnimation),
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
        
        AudioManager.shared.playSound(for: "lavasizzle")

        player.sprite.run(lavaEffect)
    }
    
    func startWarpAnimation(shouldReverse: Bool, stopAnimating: Bool, completion: @escaping (() -> Void)) {
        isAnimating = true
        
        let warpEffect = SKAction.group([
            SKAction.rotate(byAngle: -3 * .pi, duration: 1.0 * PartyModeSprite.shared.speedMultiplier),
            SKAction.scale(to: shouldReverse ? player.scale : 0, duration: 1.0 * PartyModeSprite.shared.speedMultiplier)
        ])
        
        player.sprite.run(warpEffect) { [unowned self] in
            isAnimating = !stopAnimating
            completion()
        }
    }
    
    func startPowerUpAnimation() {
        AudioManager.shared.playSound(for: "pickupitem")
    }
    
    func startPartyAnimation(hasSword: Bool, hasHammer: Bool) {
        let speed: TimeInterval = PartyModeSprite.shared.quarterNote / 2
        
        let sequenceAnimation = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: speed),
            SKAction.colorize(with: .orange, colorBlendFactor: 1.0, duration: speed),
            SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: speed),
            SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: speed),
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: speed),
            SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: speed),
            SKAction.colorize(with: .purple, colorBlendFactor: 1.0, duration: speed),
            SKAction.colorize(with: .systemPink, colorBlendFactor: 1.0, duration: speed)
        ])
        
        restartIdleAnimation(hasSword: hasSword, hasHammer: hasHammer, isPartying: true)
        player.sprite.run(SKAction.repeatForever(sequenceAnimation), withKey: AnimationKey.playerParty.rawValue)
    }
    
    func stopPartyAnimation(hasSword: Bool, hasHammer: Bool) {
        restartIdleAnimation(hasSword: hasSword, hasHammer: hasHammer, isPartying: false)
        player.sprite.removeAction(forKey: AnimationKey.playerParty.rawValue)
        player.sprite.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0))
    }
    
    func startItemCollectAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, item: LevelType, sound: LevelType = .gem, completion: @escaping (() -> Void)) {
        let itemSprite = SKSpriteNode(imageNamed: item.description)
        itemSprite.position = gameboard.getLocation(at: panel) + GameboardSprite.padding / 2
        itemSprite.zPosition = K.ZPosition.itemsAndEffects + 10
        itemSprite.setScale(gameboard.panelSize / itemSprite.size.width)
        
        gameboard.sprite.addChild(itemSprite)
        
        itemSprite.run(SKAction.group([
            SKAction.scale(by: 2, duration: 0.25),
            SKAction.fadeOut(withDuration: 0.25)
        ])) {
            itemSprite.removeFromParent()
        }
        
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
            SKAction.fadeAlpha(to: 0, duration: 0.5 * PartyModeSprite.shared.speedMultiplier)
        ])
        
        isAnimating = true
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))")
        AudioManager.shared.playSound(for: "swordslash")
        AudioManager.shared.playSound(for: "enemydeath", delay: 0.8 * PartyModeSprite.shared.speedMultiplier)

        gameboard.sprite.addChild(attackSprite)

        attackSprite.run(animation) {
            attackSprite.removeFromParent()
            
            //Enemy death animation
            let enemyTopSprite = SKSpriteNode(imageNamed: "enemy (1)")
            let enemyBottomSprite = SKSpriteNode(imageNamed: "enemy (2)")
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
                        
            enemyTopSprite.run(SKAction.group([
                SKAction.moveBy(x: -animationMove, y: animationMove, duration: animationDuration * PartyModeSprite.shared.speedMultiplier),
                SKAction.fadeOut(withDuration: animationDuration * 2 * PartyModeSprite.shared.speedMultiplier)
            ])) {
                enemyTopSprite.removeFromParent()
            }

            enemyBottomSprite.run(SKAction.group([
                SKAction.moveBy(x: animationMove, y: -animationMove, duration: animationDuration * PartyModeSprite.shared.speedMultiplier),
                SKAction.fadeOut(withDuration: animationDuration * 2 * PartyModeSprite.shared.speedMultiplier)
            ])) { [unowned self] in
                enemyBottomSprite.removeFromParent()
                isAnimating = false
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
        AudioManager.shared.playSound(for: "bouldersmash", delay: 0.8 * PartyModeSprite.shared.speedMultiplier)

        gameboard.sprite.addChild(attackSprite)

        attackSprite.run(animation) { [unowned self] in
            animateExplosion(on: gameboard, at: panel, scale: scale) { }
            
            completion()
        }
    }
    
    func animateExplosion(on gameboard: GameboardSprite, at panel: K.GameboardPosition, scale: CGFloat, completion: @escaping () -> Void) {
        let timePerFrame: TimeInterval = 0.06
        let explodeSprite = SKSpriteNode(texture: explodeBoulderTextures[0])
        explodeSprite.position = gameboard.getLocation(at: panel)
        explodeSprite.zPosition = K.ZPosition.itemsAndEffects
        explodeSprite.setScale(scale * (gameboard.panelSize / explodeSprite.size.width))

        gameboard.sprite.addChild(explodeSprite)

        explodeSprite.run(SKAction.group([
            SKAction.animate(with: explodeBoulderTextures, timePerFrame: timePerFrame),
            SKAction.scale(by: 1.25, duration: timePerFrame * Double(explodeBoulderTextures.count) * 2),
            SKAction.fadeOut(withDuration: timePerFrame * Double(explodeBoulderTextures.count) * 2)
        ])) { [unowned self] in
            explodeSprite.removeFromParent()
            isAnimating = false
            
            completion()
        }
    }
        
    func startKnockbackAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, isAttacked: Bool, direction: Controls, completion: @escaping (() -> Void)) {
        
        let speedMultiplier: TimeInterval = PartyModeSprite.shared.speedMultiplier
        let newDirection = isAttacked ? direction.getOpposite : direction
        let knockback: CGFloat = 10
        let blinkColor: UIColor = .systemRed
        
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

            switch direction { //direction of dragon in relation to PUZL Boy
            case .up:
                dragonOffset = (-1, 0)
                flameOffset = flameOffset * CGPoint(x: 0.25, y: -0.125)
                rotationDirectionType = .rotateCounterClockwise
                antiRotationDirection = .rotateClockwise
                rotationAngle = -.pi / 2
            case .down:
                dragonOffset = (1, 0)
                flameOffset = flameOffset * CGPoint(x: -0.2, y: 0.125)
                rotationDirectionType = .rotateClockwise
                antiRotationDirection = .rotateCounterClockwise
                rotationAngle = .pi / 2
            case .left:
                dragonOffset = (0, -1)
                flameOffset = flameOffset * CGPoint(x: 0.125, y: 0.25)
                rotationDirectionType = .none
                antiRotationDirection = .none
                rotationAngle = 0
            case .right:
                dragonOffset = (0, 1)
                flameOffset = flameOffset * CGPoint(x: -0.125, y: 0.25)
                rotationDirectionType = .flipHorizontal
                antiRotationDirection = .flipHorizontal
                rotationAngle = 0
            }
            
            let dragonPosition = (panel.row + dragonOffset.row, panel.col + dragonOffset.col)
            
            gameboard.rotateOverlay(at: dragonPosition, directionType: rotationDirectionType, duration: 0.2 * speedMultiplier) { [unowned self] in
                Haptics.shared.executeCustomPattern(pattern: .enemy)
                AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
                AudioManager.shared.playSound(for: "enemyflame")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameboard.rotateOverlay(at: dragonPosition, directionType: antiRotationDirection, duration: 0.2 * speedMultiplier) { [unowned self] in
                        isAnimating = false
                        completion()
                    }
                }
            }
            
            ParticleEngine.shared.animateParticles(type: .dragonFireLite,
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
            
            player.sprite.run(knockbackAnimation) { [unowned self] in
                isAnimating = false
                completion()
            }
        }
    }
    
    func startDeadAnimation(completion: @escaping (() -> Void)) {
        let animation = SKAction.animate(with: player.textures[Player.Texture.dead.rawValue], timePerFrame: animationSpeed / 2)

        isAnimating = true

        AudioManager.shared.playSound(for: "boydead")
        
        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)
        player.sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 1.5)])) { [unowned self] in
            isAnimating = false
            completion()
        }
    }

    
    // MARK: - Getters & Setters

    func setScale(panelSize: CGFloat) {
        player.sprite.setScale(Player.getStandardScale(panelSize: panelSize))
        player.setScale(abs(player.sprite.xScale))
    }
}
