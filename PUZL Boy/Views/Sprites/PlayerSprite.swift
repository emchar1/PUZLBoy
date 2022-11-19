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
    
    var inventory: Inventory
    private(set) var sprite: SKSpriteNode
    private var playerAtlas: SKTextureAtlas
    private var playerTextures: [[SKTexture]]
    
    enum Texture: Int {
        case idle = 0, run, walk, dead, glide
    }
    
    
    // MARK: - Initialization
    
    init(position: CGPoint) {
        inventory = Inventory(hammers: 0, swords: 0)
        playerAtlas = SKTextureAtlas(named: "player")
        playerTextures = []
        playerTextures.append([]) //idle
        playerTextures.append([]) //run
        playerTextures.append([]) //walk
        playerTextures.append([]) //dead
        playerTextures.append([]) //glide

        for i in 1...15 {
            playerTextures[Texture.idle.rawValue].append(playerAtlas.textureNamed("Idle (\(i))"))
            playerTextures[Texture.run.rawValue].append(playerAtlas.textureNamed("Run (\(i))"))
            playerTextures[Texture.walk.rawValue].append(playerAtlas.textureNamed("Walk (\(i))"))
            playerTextures[Texture.dead.rawValue].append(playerAtlas.textureNamed("Dead (\(i))"))
            
            if i == 5 {
                playerTextures[Texture.glide.rawValue].append(playerAtlas.textureNamed("Run (\(i))"))
            }
        }
                    
        sprite = SKSpriteNode(texture: playerTextures[Texture.idle.rawValue][0])
        sprite.size = playerSize
        sprite.setScale(0.5)
        sprite.position = CGPoint(x: position.x, y: position.y)
        sprite.zPosition = K.ZPosition.player
        
        startIdleAnimation()
    }
    
    
    // MARK: - Animation Functions
    
    func startIdleAnimation() {
        let animation = SKAction.animate(with: playerTextures[Texture.idle.rawValue], timePerFrame: animationSpeed)
        
        sprite.removeAllActions()
        sprite.run(SKAction.repeatForever(animation), withKey: "playerIdleAnimation")
        
        K.audioManager.stopSound(for: "boyrun", fadeDuration: 0.25)
        K.audioManager.stopSound(for: "boywalk", fadeDuration: 0.25)
        print("iiiiidle")
    }
    
    func startMoveAnimation(animationType: Texture) {
        let animation = SKAction.animate(with: playerTextures[animationType.rawValue], timePerFrame: animationSpeed)

        sprite.removeAllActions()
        
        if animationType == .glide {
            sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 2.0)]), withKey: "playerMoveAnimation")
            
            K.audioManager.playSound(for: "boyglide", interruptPlayback: false)
        }
        else {
            sprite.run(SKAction.repeatForever(animation), withKey: "playerMoveAnimation")
            
            K.audioManager.playSound(for: animationType == .run ? "boyrun" : "boywalk")
        }
    }

    func startDeadAnimation(completion: @escaping (() -> ())) {
        let animation = SKAction.animate(with: playerTextures[Texture.dead.rawValue], timePerFrame: animationSpeed / 2)

        sprite.removeAllActions()
        sprite.run(SKAction.sequence([SKAction.repeat(animation, count: 1), SKAction.wait(forDuration: 1.5)]), completion: completion)
        
        K.audioManager.playSound(for: "boydead")
    }
    
    func hitObject(isAttacked: Bool, direction: Controls, completion: @escaping (() -> ())) {
        let newDirection = isAttacked ? direction.getOpposite : direction
        let hitDistance: CGFloat = 10
        var moveAction: SKAction
        var unmoveAction: SKAction
        
        switch newDirection {
        case .up:
            moveAction = SKAction.moveBy(x: 0, y: hitDistance, duration: 0)
            unmoveAction = SKAction.moveBy(x: 0, y: -hitDistance, duration: 0)
        case .down:
            moveAction = SKAction.moveBy(x: 0, y: -hitDistance, duration: 0)
            unmoveAction = SKAction.moveBy(x: 0, y: hitDistance, duration: 0)
        case .left:
            moveAction = SKAction.moveBy(x: -hitDistance, y: 0, duration: 0)
            unmoveAction = SKAction.moveBy(x: hitDistance, y: 0, duration: 0)
        case .right:
            moveAction = SKAction.moveBy(x: hitDistance, y: 0, duration: 0)
            unmoveAction = SKAction.moveBy(x: -hitDistance, y: 0, duration: 0)
        }
        
        let hitAction = SKAction.sequence([
            moveAction,
            SKAction.colorize(with: .systemPink, colorBlendFactor: isAttacked ? 1.0 : 0.0, duration: 0),
            SKAction.wait(forDuration: 0.2),
            unmoveAction,
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
        ])
        
        sprite.run(hitAction, completion: completion)

        K.audioManager.playSound(for: "boygrunt\(Int.random(in: 1...2))")
    }

    
    // MARK: - Getters & Setters

    func hasHammers() -> Bool {
        return inventory.hammers > 0
    }

    func hasSwords() -> Bool {
        return inventory.swords > 0
    }
        
    func setScale(panelSize: CGFloat) {
        
        
        //FIXME: - Changed 0.5 to 1 to 1.5 due to new hero width size from 313 to original 614 to new 946
        sprite.setScale(1.5 * (panelSize / playerSize.width))
    }
}
