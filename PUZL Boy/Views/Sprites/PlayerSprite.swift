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
    private var explodeBoulderAtlas: SKTextureAtlas
    private var explodeBoulderTextures: [SKTexture]
    private var player = Player()

    enum AnimationKey: String {
        case playerRespawn, playerIdle, playerMove, playerGlide, playerMarsh, playerPowerUp
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
                
        startIdleAnimation()

        if shouldSpawn {
            startRespawnAnimation()
        }
    }
    
    
    // MARK: - Animation Functions
    
    private func startRespawnAnimation() {
        player.sprite.run(SKAction.fadeAlpha(to: 1.0, duration: 0.75), withKey: AnimationKey.playerRespawn.rawValue)
    }
    
    func startIdleAnimation() {
        let fadeDuration: TimeInterval = 0.25
        let animation = SKAction.animate(with: player.textures[Player.Texture.idle.rawValue], timePerFrame: animationSpeed + 0.02)
        
        AudioManager.shared.stopSound(for: "moverun1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun3", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun4", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movewalk", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movemarsh", fadeDuration: fadeDuration)

        player.sprite.run(SKAction.repeatForever(animation), withKey: AnimationKey.playerIdle.rawValue)
    }
    
    func startMoveAnimation(animationType: Player.Texture) {
        let animationRate: TimeInterval = animationType == .marsh ? 1.25 : 1
        let animation = SKAction.animate(with: player.textures[animationType.rawValue], timePerFrame: animationSpeed * animationRate)

        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)

        if animationType == .glide {
            AudioManager.shared.playSound(for: "moveglide", interruptPlayback: false)

            player.sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 2.0)]),
                              withKey: AnimationKey.playerGlide.rawValue)
        }
        else {
            switch animationType {
            case .run:
                AudioManager.shared.playSound(for: "moverun\(Int.random(in: 1...4))")
            case .walk:
                AudioManager.shared.playSound(for: "movewalk")

                //Fades the player as he's entering the gate
//                let sequence = SKAction.sequence([SKAction.wait(forDuration: 0.55), SKAction.fadeAlpha(to: 0, duration: 0.2)])
//                sprite.run(SKAction.group([SKAction.repeatForever(animation), sequence]), withKey: AnimationKey.playerMove.rawValue)
//
//                return
            case .marsh:
                AudioManager.shared.playSound(for: "movemarsh")
            default:
                print("Unknown animationType")
            }
            
            player.sprite.run(SKAction.repeatForever(animation), withKey: AnimationKey.playerMove.rawValue)
        }
    }
    
    func startMarshEffectAnimation() {
        let marshEffect = SKAction.sequence([
            SKAction.colorize(with: .systemPurple, colorBlendFactor: 1.0, duration: 0.0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.5)
        ])
        
        AudioManager.shared.playSound(for: "movepoisoned")

        player.sprite.run(marshEffect, withKey: AnimationKey.playerMarsh.rawValue)
    }
    
    func startWarpAnimation(shouldReverse: Bool, completion: @escaping (() -> ())) {
        let warpEffect = SKAction.group([
            SKAction.rotate(byAngle: -3 * .pi, duration: 1.0),
            SKAction.scale(to: shouldReverse ? player.scale : 0, duration: 1.0)
        ])
        
        player.sprite.run(warpEffect, completion: completion)
    }
    
    func startPowerUpAnimation() {
        AudioManager.shared.playSound(for: "pickupitem")
    }
    
    func startGemCollectAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, completion: @escaping (() -> ())) {
        let gemSprite = SKSpriteNode(imageNamed: "gem")
        gemSprite.position = gameboard.getLocation(at: panel)
        gemSprite.zPosition = K.ZPosition.items
        gemSprite.setScale(gameboard.panelSize / gemSprite.size.width)
        
        gameboard.sprite.addChild(gemSprite)
        
        gemSprite.run(SKAction.group([
            SKAction.scale(by: 2, duration: 0.5),
            SKAction.fadeOut(withDuration: 0.5)
        ])) {
            gemSprite.removeFromParent()
        }
        
        completion()
        
        AudioManager.shared.playSound(for: "gemcollect")
    }
    
    func startSwordAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, completion: @escaping (() -> ())) {
        let scale: CGFloat = 0.9
        let attackSprite = SKSpriteNode(texture: SKTexture(imageNamed: "iconSword"))
        attackSprite.position = gameboard.getLocation(at: panel)
        attackSprite.zPosition = K.ZPosition.items
        attackSprite.setScale(scale * (gameboard.panelSize / attackSprite.size.width))

        let animation = SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.rotate(byAngle: -3 * .pi / 2, duration: 0.25),
            SKAction.fadeAlpha(to: 0, duration: 0.5)
        ])
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))")
        AudioManager.shared.playSound(for: "swordslash")
        AudioManager.shared.playSound(for: "enemydeath", delay: 0.8)

        gameboard.sprite.addChild(attackSprite)

        attackSprite.run(animation) {
            attackSprite.removeFromParent()
            
            //Enemy death animation
            let enemyTopSprite = SKSpriteNode(imageNamed: "enemy (1)")
            let enemyBottomSprite = SKSpriteNode(imageNamed: "enemy (2)")
            let enemyScale = gameboard.panelSize / enemyTopSprite.size.width

            enemyTopSprite.position = gameboard.getLocation(at: panel)
            enemyTopSprite.zPosition = K.ZPosition.items
            enemyTopSprite.setScale(enemyScale)

            enemyBottomSprite.position = gameboard.getLocation(at: panel)
            enemyBottomSprite.zPosition = K.ZPosition.items
            enemyBottomSprite.setScale(enemyScale)
            
            gameboard.sprite.addChild(enemyTopSprite)
            gameboard.sprite.addChild(enemyBottomSprite)
            
            let animationDuration: TimeInterval = 0.3
            let animationMove: CGFloat = 300 * enemyScale
                        
            enemyTopSprite.run(SKAction.group([
                SKAction.moveBy(x: -animationMove, y: animationMove, duration: animationDuration),
                SKAction.fadeOut(withDuration: animationDuration * 2)
            ])) {
                enemyTopSprite.removeFromParent()
            }

            enemyBottomSprite.run(SKAction.group([
                SKAction.moveBy(x: animationMove, y: -animationMove, duration: animationDuration),
                SKAction.fadeOut(withDuration: animationDuration * 2)
            ])) {
                enemyBottomSprite.removeFromParent()
            }

            //Points animation
            ScoringEngine.addScoreAnimation(score: 1000,
                                            usedContinue: nil,
                                            originSprite: gameboard.sprite,
                                            location: gameboard.getLocation(at: panel))
            
            completion()
        }
    }
    
    func startHammerAnimation(on gameboard: GameboardSprite, at panel: K.GameboardPosition, completion: @escaping (() -> ())) {
        let scale: CGFloat = 0.75
        let attackSprite = SKSpriteNode(texture: SKTexture(imageNamed: "iconHammer"))
        attackSprite.position = gameboard.getLocation(at: panel)
        attackSprite.zPosition = K.ZPosition.items
        attackSprite.setScale(scale * (gameboard.panelSize / attackSprite.size.width))

        let animation = SKAction.sequence([
            SKAction.rotate(byAngle: -3 * .pi / 4, duration: 0.2),
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeAlpha(to: 0, duration: 0.5)
        ])
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))")
        AudioManager.shared.playSound(for: "hammerswing")
        AudioManager.shared.playSound(for: "bouldersmash", delay: 0.8)

        gameboard.sprite.addChild(attackSprite)

        attackSprite.run(animation) { [unowned self] in
            attackSprite.removeFromParent()
            
            let timePerFrame: TimeInterval = 0.06
            let explodeSprite = SKSpriteNode(texture: explodeBoulderTextures[0])
            explodeSprite.position = gameboard.getLocation(at: panel)
            explodeSprite.zPosition = K.ZPosition.items
            explodeSprite.setScale(scale * (gameboard.panelSize / explodeSprite.size.width))

            gameboard.sprite.addChild(explodeSprite)

            explodeSprite.run(SKAction.group([
                SKAction.animate(with: explodeBoulderTextures, timePerFrame: timePerFrame),
                SKAction.scale(by: 1.25, duration: timePerFrame * Double(explodeBoulderTextures.count) * 2),
                SKAction.fadeOut(withDuration: timePerFrame * Double(explodeBoulderTextures.count) * 2)
            ])) {
                explodeSprite.removeFromParent()
            }

            completion()
        }
    }
        
    func startKnockbackAnimation(isAttacked: Bool, direction: Controls, completion: @escaping (() -> ())) {
        let newDirection = isAttacked ? direction.getOpposite : direction
        let knockback: CGFloat = 10
        let blinkColor: UIColor = .systemRed
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
            SKAction.wait(forDuration: 0.2),
            unmoveAction
        ])
        
        let blinkAnimation = SKAction.sequence([
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 1.0, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.75, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.5, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12),
            SKAction.colorize(with: blinkColor, colorBlendFactor: 0.25, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12),
        ])
        
        AudioManager.shared.playSound(for: "boygrunt\(Int.random(in: 1...2))")

        player.sprite.run(isAttacked ? SKAction.sequence([knockbackAnimation, blinkAnimation]) : knockbackAnimation, completion: completion)
    }
    
    func startDeadAnimation(completion: @escaping (() -> ())) {
        let animation = SKAction.animate(with: player.textures[Player.Texture.dead.rawValue], timePerFrame: animationSpeed / 2)

        AudioManager.shared.playSound(for: "boydead")

        player.sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        player.sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)
        player.sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 1.5)]), completion: completion)
    }

    
    // MARK: - Getters & Setters

    func setScale(panelSize: CGFloat) {
        //Changed scale from 0.5 to 1 to 1.5 due to new hero width size from 313 to original 614 to new 946
        let scale: CGFloat = 1.5
        
        player.sprite.setScale(scale * (panelSize / Player.size.width))
        player.setScale(abs(player.sprite.xScale))
    }
}
