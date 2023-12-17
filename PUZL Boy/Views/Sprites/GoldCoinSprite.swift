//
//  GoldCoinSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/11/23.
//

import SpriteKit

class GoldCoinSprite: SKNode {
    
    // MARK: - Properties
    
    private var atlas: SKTextureAtlas
    private var textures: [SKTexture]
    private(set) var sprite: SKSpriteNode
    
    
    // MARK: - Initialization
    
    override init() {
        atlas = SKTextureAtlas(named: "goldCoin")
        textures = []

        for i in 0..<17 {
            textures.append(atlas.textureNamed("goldCoin\(i)"))
        }
        
        sprite = SKSpriteNode(texture: textures[0])
        sprite.scale(to: CGSize(width: 50, height: 50))
    
        super.init()
        
        addChild(sprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func animateTextures() {
        sprite.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.04)))
    }
}
