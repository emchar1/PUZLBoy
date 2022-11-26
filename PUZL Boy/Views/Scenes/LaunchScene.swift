//
//  LaunchScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/22.
//

import SpriteKit

class LaunchScene: SKScene {
    
    // MARK: - Properties
    
    private var playerTextures: [SKTexture] = []
    private var sprite: SKSpriteNode
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        let playerAtlas = SKTextureAtlas(named: "player")

        for i in 1...15 {
            playerTextures.append(playerAtlas.textureNamed("Run (\(i))"))
        }

        sprite = SKSpriteNode(texture: playerTextures[0])
        sprite.position = CGPoint(x: K.iPhoneWidth / 2 - 50, y: K.height / 2)
        sprite.setScale(2)

        super.init(size: size)
        
        animateSprite()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateSprite() {
        let animation = SKAction.animate(with: playerTextures, timePerFrame: 0.05)
        
        sprite.run(SKAction.repeatForever(animation))
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(color: .systemCyan, size: self.size)
        background.anchorPoint = .zero
        
        addChild(background)
        addChild(sprite)
    }
}
