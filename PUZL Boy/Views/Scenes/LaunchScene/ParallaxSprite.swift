//
//  ParallaxSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/12/23.
//

import SpriteKit

class ParallaxSprite: SKNode {
    
    // MARK: - Properties
    
    private var parallaxObject: ParallaxObject
    private var sprites: [SKSpriteNode] = []
    
    
    // MARK: - Initialization
    
    init(object: ParallaxObject) {
        parallaxObject = object
        
        super.init()

        setupSprites()
        
        // IMPORTANT!! Put node name here, not in individual sprites so LaunchScene can iterate through node names correctly
        name = parallaxObject.nodeName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        for i in 0...1 {
            let sprite = SKSpriteNode(imageNamed: parallaxObject.imageName)
            sprite.anchorPoint = .zero
            sprite.position = CGPoint(x: CGFloat(i) * parallaxObject.sizeScaled, y: 0)
            sprite.setScale(parallaxObject.scale)
            sprite.color = DayTheme.spriteColor
            sprite.colorBlendFactor = DayTheme.spriteShade
            sprite.zPosition = parallaxObject.zPosition
                        
            addChild(sprite)

            sprites.append(sprite)
        }
    }
    
    
    // MARK: - Functions
    
    func animate() {
        let moveAction = SKAction.moveBy(x: -parallaxObject.sizeScaled, y: 0, duration: parallaxObject.speed)
        let resetAction = SKAction.moveTo(x: parallaxObject.sizeScaled, duration: 0)
        
        sprites[0].run(SKAction.repeatForever(SKAction.sequence([moveAction, resetAction, moveAction])))
        sprites[1].run(SKAction.repeatForever(SKAction.sequence([moveAction, moveAction, resetAction])))
    }
    
    
}
