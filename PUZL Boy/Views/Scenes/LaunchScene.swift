//
//  LaunchScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/22.
//

import SpriteKit

class LaunchScene: SKScene {
    
    // MARK: - Properties
    
    private let treeCount = 5
    private var treeSprites: [SKSpriteNode] = []
    private var playerTextures: [SKTexture] = []
    private var playerSprite: SKSpriteNode
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        //Setup playerSprite
        let playerAtlas = SKTextureAtlas(named: "player")
        
        for i in 1...15 {
            playerTextures.append(playerAtlas.textureNamed("Run (\(i))"))
        }
        
        playerSprite = SKSpriteNode(texture: playerTextures[0])
        playerSprite.position = CGPoint(x: K.iPhoneWidth / 2 - 50, y: K.height / 2)
        playerSprite.setScale(2)
        playerSprite.zPosition = K.ZPosition.player
        
        
        //Setup treeSprites
        for i in 0...treeCount {
            let treeSprite = SKTexture(imageNamed: "tree\(Int.random(in: 0...2))")
            
            treeSprites.append(SKSpriteNode(texture: treeSprite))
            treeSprites[i].position = CGPoint(x: K.iPhoneWidth, y: K.height / 2 + CGFloat.random(in: 0...K.height / 4))
            treeSprites[i].setScale(CGFloat.random(in: 0.25...0.75))
            treeSprites[i].zPosition = K.ZPosition.panel
        }
        
        
        super.init(size: size)
        
        animateSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateSprites() {
        let playerAnimation = SKAction.animate(with: playerTextures, timePerFrame: 0.05)
        playerSprite.run(SKAction.repeatForever(playerAnimation))
        
        for i in 0...treeCount {
            let treeAnimation = SKAction.move(to: CGPoint(x: -treeSprites[i].size.width, y: treeSprites[i].position.y),
                                              duration: TimeInterval.random(in: 2...5))
            treeSprites[i].run(SKAction.repeat(treeAnimation, count: 1))
        }
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(color: .cyan, size: self.size)
        background.anchorPoint = .zero
        background.zPosition = K.ZPosition.gameboard
        
        addChild(background)
        addChild(playerSprite)
        
        for i in 0...treeCount {
            addChild(treeSprites[i])
        }
    }
    
}
