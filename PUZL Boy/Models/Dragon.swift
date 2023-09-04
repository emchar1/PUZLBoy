//
//  Dragon.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/3/23.
//

import SpriteKit

struct Dragon {
    // MARK: - Properties
    
    static let size = CGSize(width: 328, height: 248)
    private(set) var scale: CGFloat = 0.5

    private(set) var sprite: SKSpriteNode!
    private(set) var textures: [SKTexture]!
    private var atlas: SKTextureAtlas!
    
    
    // MARK: - Initialization
    
    init() {
        setupSprite()
    }
    
    private mutating func setupSprite() {
        atlas = SKTextureAtlas(named: "dragon")
        
        textures = []

        for i in 1...6 {
            textures.append(atlas.textureNamed("flyingDragon (\(i))"))
        }
        
        sprite = SKSpriteNode(texture: textures[0])
        sprite.size = Dragon.size
        sprite.setScale(scale)
        sprite.position = .zero
        sprite.zPosition = K.ZPosition.player
    }
    
    
    // MARK: - Functions
    
    mutating func setScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
    func animate(toNode node: SKNode) {
        let animation = SKAction.animate(with: textures, timePerFrame: 0.2)
        
        sprite.run(SKAction.repeatForever(animation))
        
        node.addChild(sprite)
    }
}
