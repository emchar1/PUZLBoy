//
//  PlayerSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/6/22.
//

import SpriteKit

class PlayerSprite {
    
    // MARK: - Properties
    
    private let playerSize = CGSize(width: 946, height: 564)
    private let animationSpeed: TimeInterval = 0.04
    private var spriteScale = 0.5
    
    var inventory: Inventory
    private(set) var sprite: SKSpriteNode
    private var playerAtlas: SKTextureAtlas
    private var playerTextures: [[SKTexture]]
    private var explodeEnemyAtlas: SKTextureAtlas
    private var explodeEnemyTextures: [SKTexture]
    private var explodeBoulderAtlas: SKTextureAtlas
    private var explodeBoulderTextures: [SKTexture]

    enum Texture: Int {
        case idle = 0, run, win, dead, glide, marsh
        
        var animationSpeed: TimeInterval {
            switch self {
            case .run:
                return 0.5
            case .win:
                return 0.75
            case .glide:
                return 0.5
            case .marsh:
                return 1.0
            default:
                return 0.25
            }
        }
    }
    
    enum AnimationKey: String {
        case playerRespawn, playerIdle, playerMove, playerGlide, playerMarsh, playerPowerUp
    }
    
    
    // MARK: - Initialization
    
    init(shouldSpawn: Bool) {
        inventory = Inventory(hammers: 0, swords: 0)
        playerAtlas = SKTextureAtlas(named: "player")
        playerTextures = []
        playerTextures.append([]) //idle
        playerTextures.append([]) //run
        playerTextures.append([]) //win
        playerTextures.append([]) //marsh
        playerTextures.append([]) //dead
        playerTextures.append([]) //glide

        for i in 1...15 {
            playerTextures[Texture.idle.rawValue].append(playerAtlas.textureNamed("Idle (\(i))"))
            playerTextures[Texture.run.rawValue].append(playerAtlas.textureNamed("Run (\(i))"))
            playerTextures[Texture.win.rawValue].append(playerAtlas.textureNamed("Walk (\(i))"))
            playerTextures[Texture.marsh.rawValue].append(playerAtlas.textureNamed("Run (\(i))"))
            playerTextures[Texture.dead.rawValue].append(playerAtlas.textureNamed("Dead (\(i))"))
            
            if i == 5 {
                playerTextures[Texture.glide.rawValue].append(playerAtlas.textureNamed("Run (\(i))"))
            }
        }
        
        explodeEnemyAtlas = SKTextureAtlas(named: "explode")
        explodeEnemyTextures = []
        explodeBoulderAtlas = SKTextureAtlas(named: "explode")
        explodeBoulderTextures = []

        for i in 1...7 {
            explodeEnemyTextures.append(explodeEnemyAtlas.textureNamed("explode (\(i))"))
            explodeBoulderTextures.append(explodeEnemyAtlas.textureNamed("explode2 (\(i))"))
        }
                    
        sprite = SKSpriteNode(texture: playerTextures[Texture.idle.rawValue][0])
        sprite.size = playerSize
        sprite.setScale(spriteScale)
        sprite.alpha = shouldSpawn ? 0 : 1 //important for respawn to work!
        sprite.position = .zero
        sprite.zPosition = K.ZPosition.player
        
        startIdleAnimation()

        if shouldSpawn {
            startRespawnAnimation()
        }
    }
    
    
    // MARK: - Animation Functions
    
    private func startRespawnAnimation() {
        sprite.run(SKAction.fadeAlpha(to: 1.0, duration: 0.75), withKey: AnimationKey.playerRespawn.rawValue)
    }
    
    func startIdleAnimation() {
        let fadeDuration: TimeInterval = 0.25
        let animation = SKAction.animate(with: playerTextures[Texture.idle.rawValue], timePerFrame: animationSpeed + 0.02)
        
        AudioManager.shared.stopSound(for: "moverun1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun3", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "moverun4", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movewalk", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "movemarsh", fadeDuration: fadeDuration)

        sprite.run(SKAction.repeatForever(animation), withKey: AnimationKey.playerIdle.rawValue)
    }
    
    func startMoveAnimation(animationType: Texture) {
        let animationRate: TimeInterval = animationType == .marsh ? 1.25 : 1
        let animation = SKAction.animate(with: playerTextures[animationType.rawValue], timePerFrame: animationSpeed * animationRate)

        sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)

        if animationType == .glide {
            AudioManager.shared.playSound(for: "moveglide", interruptPlayback: false)

            sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 2.0)]), withKey: AnimationKey.playerGlide.rawValue)
        }
        else {
            switch animationType {
            case .run:
                AudioManager.shared.playSound(for: "moverun\(Int.random(in: 1...4))")
            case .win:
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
            
            sprite.run(SKAction.repeatForever(animation), withKey: AnimationKey.playerMove.rawValue)
        }
    }
    
    func startMarshEffectAnimation() {
        let marshEffect = SKAction.sequence([
            SKAction.colorize(with: .systemPurple, colorBlendFactor: 1.0, duration: 0.0),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.5)
        ])
        
        AudioManager.shared.playSound(for: "movepoisoned")

        sprite.run(marshEffect, withKey: AnimationKey.playerMarsh.rawValue)
    }
    
    func startWarpAnimation(shouldReverse: Bool, completion: @escaping (() -> ())) {
        let warpEffect = SKAction.group([SKAction.rotate(byAngle: -3 * .pi, duration: 1.0),
                                         SKAction.scale(to: shouldReverse ? spriteScale : 0, duration: 1.0)])
        
        sprite.run(warpEffect, completion: completion)
    }
    
    func startPowerUpAnimation() {
        AudioManager.shared.playSound(for: "pickupitem")
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

        attackSprite.run(animation) { [unowned self] in
            attackSprite.removeFromParent()
            
            //Explosion sprite
            let explodeSprite = SKSpriteNode(texture: explodeEnemyTextures[0])
            explodeSprite.position = gameboard.getLocation(at: panel)
            explodeSprite.zPosition = K.ZPosition.items
            explodeSprite.setScale(scale * (gameboard.panelSize / explodeSprite.size.width))

            gameboard.sprite.addChild(explodeSprite)

            explodeSprite.run(SKAction.animate(with: explodeEnemyTextures, timePerFrame: 0.05)) {
                explodeSprite.removeFromParent()
            }

            //Points sprite
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
            
            let explodeSprite = SKSpriteNode(texture: explodeBoulderTextures[0])
            explodeSprite.position = gameboard.getLocation(at: panel)
            explodeSprite.zPosition = K.ZPosition.items
            explodeSprite.setScale(scale * (gameboard.panelSize / explodeSprite.size.width))

            gameboard.sprite.addChild(explodeSprite)

            explodeSprite.run(SKAction.animate(with: explodeBoulderTextures, timePerFrame: 0.05)) {
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

        sprite.run(isAttacked ? SKAction.sequence([knockbackAnimation, blinkAnimation]) : knockbackAnimation, completion: completion)
    }
    
    func startDeadAnimation(completion: @escaping (() -> ())) {
        let animation = SKAction.animate(with: playerTextures[Texture.dead.rawValue], timePerFrame: animationSpeed / 2)

        AudioManager.shared.playSound(for: "boydead")

        sprite.removeAction(forKey: AnimationKey.playerIdle.rawValue)
        sprite.removeAction(forKey: AnimationKey.playerMove.rawValue)
        sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 1.5)]), completion: completion)
    }

    
    // MARK: - Getters & Setters

    func hasHammers() -> Bool {
        return inventory.hammers > 0
    }

    func hasSwords() -> Bool {
        return inventory.swords > 0
    }
        
    func setScale(panelSize: CGFloat) {
        //Changed scale from 0.5 to 1 to 1.5 due to new hero width size from 313 to original 614 to new 946
        let scale: CGFloat = 1.5
        
        sprite.setScale(scale * (panelSize / playerSize.width))
        spriteScale = abs(sprite.xScale)
    }
}
