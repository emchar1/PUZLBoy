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
    private var player = Player()

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
    
    func startMoveAnimation(animationType: Player.Texture) {
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
            switch animationType {
            case .run, .runSword, .runHammer, .runHammerSword:
                AudioManager.shared.playSound(for: "moverun\(Int.random(in: 1...4))")
            case .marsh, .marshSword, .marshHammer, .marshHammerSword:
                AudioManager.shared.playSound(for: "movemarsh\(Int.random(in: 1...3))")
            case .sand, .sandSword, .sandHammer, .sandHammerSword:
                AudioManager.shared.playSound(for: "movesand\(Int.random(in: 1...3))")
            case .party:
                AudioManager.shared.playSound(for: "movetile\(Int.random(in: 1...3))")
            case .walk:
                AudioManager.shared.playSound(for: "movewalk")

                //Fades the player as he's entering the gate
//                let sequence = SKAction.sequence([SKAction.wait(forDuration: 0.55), SKAction.fadeAlpha(to: 0, duration: 0.2)])
//                sprite.run(SKAction.group([SKAction.repeatForever(animation), sequence]), withKey: AnimationKey.playerMove.rawValue)
//
//                return
            default:
                print("Unknown animationType")
            }
            
            player.sprite.run(SKAction.repeatForever(animation), withKey: AnimationKey.playerMove.rawValue)
        }
    }
    
    func startMarshEffectAnimation() {
        let marshEffect = SKAction.sequence([
            SKAction.colorize(with: .systemPurple, colorBlendFactor: 1.0, duration: 0.0),
            SKAction.wait(forDuration: 0.5 * PartyModeSprite.shared.speedMultiplier),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.5 * PartyModeSprite.shared.speedMultiplier)
        ])
        
        AudioManager.shared.playSound(for: "movepoisoned\(Int.random(in: 1...4))")

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
        
        player.sprite.run(warpEffect) {
            self.isAnimating = !stopAnimating
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
    
    func startGemCollectAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, isParty: Bool, completion: @escaping (() -> Void)) {
        let gemSprite = SKSpriteNode(imageNamed: isParty ? "partyGem" : "gem")
        gemSprite.position = gameboard.getLocation(at: panel)
        gemSprite.zPosition = K.ZPosition.itemsAndEffects
        gemSprite.setScale(gameboard.panelSize / gemSprite.size.width)
        
        gameboard.sprite.addChild(gemSprite)
        
        gemSprite.run(SKAction.group([
            SKAction.scale(by: 1.75, duration: 0.25 * PartyModeSprite.shared.speedMultiplier),
            SKAction.fadeOut(withDuration: 0.25 * PartyModeSprite.shared.speedMultiplier)
        ])) {
            gemSprite.removeFromParent()
        }
        
        completion()
        
        AudioManager.shared.playSound(for: isParty ? "gemcollectparty" : "gemcollect")
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
            ])) {
                enemyBottomSprite.removeFromParent()
                self.isAnimating = false
            }

            //Points animation
            ScoringEngine.addScoreAnimation(score: 1000,
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
            SKAction.fadeAlpha(to: 0, duration: 0.5 * PartyModeSprite.shared.speedMultiplier)
        ])
        
        isAnimating = true
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))")
        AudioManager.shared.playSound(for: "hammerswing")
        AudioManager.shared.playSound(for: "bouldersmash", delay: 0.8 * PartyModeSprite.shared.speedMultiplier)

        gameboard.sprite.addChild(attackSprite)

        attackSprite.run(animation) { [unowned self] in
            attackSprite.removeFromParent()
            
            let timePerFrame: TimeInterval = 0.06
            let explodeSprite = SKSpriteNode(texture: explodeBoulderTextures[0])
            explodeSprite.position = gameboard.getLocation(at: panel)
            explodeSprite.zPosition = K.ZPosition.itemsAndEffects
            explodeSprite.setScale(scale * (gameboard.panelSize / explodeSprite.size.width))

            gameboard.sprite.addChild(explodeSprite)

            explodeSprite.run(SKAction.group([
                SKAction.animate(with: explodeBoulderTextures, timePerFrame: timePerFrame * PartyModeSprite.shared.speedMultiplier),
                SKAction.scale(by: 1.25, duration: timePerFrame * Double(explodeBoulderTextures.count) * 2 * PartyModeSprite.shared.speedMultiplier),
                SKAction.fadeOut(withDuration: timePerFrame * Double(explodeBoulderTextures.count) * 2 * PartyModeSprite.shared.speedMultiplier)
            ])) {
                explodeSprite.removeFromParent()
                self.isAnimating = false
            }

            completion()
        }
    }
        
    func startKnockbackAnimation(isAttacked: Bool, direction: Controls, completion: @escaping (() -> Void)) {
        let newDirection = isAttacked ? direction.getOpposite : direction
        let knockback: CGFloat = 10
        let blinkColor: UIColor = .systemRed
        var moveAction: SKAction
        var unmoveAction: SKAction
        
        isAnimating = true
        
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
            SKAction.wait(forDuration: 0.2 * PartyModeSprite.shared.speedMultiplier),
            unmoveAction
        ])
        
        let blinkAnimation = SKAction.sequence([
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * PartyModeSprite.shared.speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 1.0, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * PartyModeSprite.shared.speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.75, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * PartyModeSprite.shared.speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.5, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * PartyModeSprite.shared.speedMultiplier),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.25, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12 * PartyModeSprite.shared.speedMultiplier),
        ])
        
        AudioManager.shared.playSound(for: "boygrunt\(Int.random(in: 1...2))")

        player.sprite.run(isAttacked ? SKAction.sequence([knockbackAnimation, blinkAnimation]) : knockbackAnimation) {
            self.isAnimating = false
            completion()
        }
    }
    
    func startDeadAnimation(completion: @escaping (() -> Void)) {
        let animation = SKAction.animate(with: player.textures[Player.Texture.dead.rawValue], timePerFrame: animationSpeed / 2)

        isAnimating = true

        AudioManager.shared.playSound(for: "boydead")
        
        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)
        player.sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 1.5)])) {
            self.isAnimating = false
            completion()
        }
    }

    
    // MARK: - Getters & Setters

    func setScale(panelSize: CGFloat) {
        //Changed scale from 0.5 to 1 to 1.5 due to new hero width size from 313 to original 614 to new 946
        let scale: CGFloat = 1.5
        
        player.sprite.setScale(scale * (panelSize / Player.size.width))
        player.setScale(abs(player.sprite.xScale))
    }
}
