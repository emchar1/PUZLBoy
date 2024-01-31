//
//  FlyingDragon.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/3/23.
//

import SpriteKit

struct FlyingDragon {
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
        atlas = SKTextureAtlas(named: "flyingDragon")
        
        textures = []

        for i in 1...6 {
            textures.append(atlas.textureNamed("flyingDragon (\(i))"))
        }
        
        sprite = SKSpriteNode(texture: textures[0])
        sprite.size = FlyingDragon.size
        sprite.setScale(scale)
        sprite.position = .zero
        sprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        sprite.zPosition = K.ZPosition.parallaxLayer0 - 1
    }
    
    
    // MARK: - Functions
    
    mutating func setScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
    func animate(toNode node: SKNode, from positionOrig: CGPoint, to positionNew: CGPoint, duration: TimeInterval, reverseDirection: Bool = false) {
        let animation = SKAction.animate(with: textures, timePerFrame: 0.2)
        
        sprite.position = positionOrig
        sprite.xScale = reverseDirection ? -scale : scale
        
        sprite.run(SKAction.group([
            SKAction.repeatForever(animation),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: -10, duration: 0.85),
                SKAction.moveBy(x: 0, y: 20, duration: 0.35),
            ])),
            SKAction.sequence([
                SKAction.moveTo(x: positionNew.x, duration: duration),
                SKAction.run {
                    sprite.removeAllActions()
                },
                SKAction.removeFromParent()
            ])
        ]))
        
        node.addChild(sprite)
    }
}
