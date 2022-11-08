//
//  PlayerSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/6/22.
//

import SpriteKit

class PlayerSprite {
    
    // MARK: - Properties
    
    let playerSize = CGSize(width: 614, height: 564)
    let animationSpeed: TimeInterval = 0.06
    
    var sprite: SKSpriteNode
    var playerAtlas: SKTextureAtlas
    var playerTextures: [[SKTexture]]
    
    enum Texture: Int {
        case idle = 0, run, walk, dead
    }

    var inventory: Inventory {
        didSet {
            if hasHammers() && !hasSwords() {
//                sprite.strokeColor = .systemPink
            }
            else if hasSwords() && !hasHammers() {
//                sprite.strokeColor = .cyan
            }
            else if hasHammers() && hasSwords() {
//                sprite.strokeColor = .purple
            }
            else {
//                sprite.strokeColor = .clear
            }
        }
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

        for i in 1...15 {
            playerTextures[Texture.idle.rawValue].append(playerAtlas.textureNamed("Idle (\(i))"))
            playerTextures[Texture.run.rawValue].append(playerAtlas.textureNamed("Run (\(i))"))
            playerTextures[Texture.walk.rawValue].append(playerAtlas.textureNamed("Walk (\(i))"))
            playerTextures[Texture.dead.rawValue].append(playerAtlas.textureNamed("Dead (\(i))"))
        }
                    
        sprite = SKSpriteNode(texture: playerTextures[Texture.idle.rawValue][0])
        sprite.size = playerSize
        sprite.setScale(0.5)
        sprite.position = CGPoint(x: position.x, y: position.y)
        sprite.zPosition = K.ZPosition.player
        
        startIdleAnimation()
    }
    
    
    // MARK: - Helper Functions
    
    func startIdleAnimation() {
        let animation = SKAction.animate(with: playerTextures[Texture.idle.rawValue], timePerFrame: animationSpeed)
        
        sprite.removeAllActions()
        sprite.run(SKAction.repeatForever(animation), withKey: "playerIdleAnimation")
    }
    
    func startMoveAnimation(didWin: Bool) {
        let animation = SKAction.animate(with: playerTextures[didWin ? Texture.walk.rawValue : Texture.run.rawValue], timePerFrame: animationSpeed)

        sprite.removeAllActions()
        sprite.run(SKAction.repeatForever(animation), withKey: "playerMoveAnimation")
    }
    
    
    // MARK: - Getters & Setters

    func hasHammers() -> Bool {
        return inventory.hammers > 0
    }

    func hasSwords() -> Bool {
        return inventory.swords > 0
    }
        
    func setScale(panelSize: CGFloat) {
        
        
        //FIXME: - Changed 0.5 to 1 due to new hero width size from 313 to original 614
        sprite.setScale(1 * (panelSize / playerSize.width))
    }
}
