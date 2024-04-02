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
    private var scale: CGFloat

    private(set) var sprite: SKSpriteNode!
    private var textures: [SKTexture]!
    private var atlas: SKTextureAtlas!
    
    
    // MARK: - Initialization
    
    init(scale: CGFloat = 0.65) {
        self.scale = scale
        
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
        sprite.zPosition = K.ZPosition.player
    }
    
    
    // MARK: - Functions
    
    mutating func setScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
    func animate(toNode node: SKNode, from positionOrig: CGPoint, to positionNew: CGPoint, duration: TimeInterval) {
        let animation = SKAction.animate(with: textures, timePerFrame: 0.2)
        
        sprite.position = positionOrig
        
        sprite.run(SKAction.group([
            SKAction.repeatForever(animation),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: -10, duration: 0.85),
                SKAction.moveBy(x: 0, y: 20, duration: 0.35),
            ]))
        ]))
        
        //There are two ways the flying dragon can move, based on if positionNew.y == 0 or not. I hate writing it this way...
        if positionNew.y == 0 {
            sprite.run(SKAction.sequence([
                SKAction.moveTo(x: positionNew.x, duration: duration),
                SKAction.removeFromParent()
            ]))
        }
        else {
            sprite.run(SKAction.sequence([
                SKAction.move(to: positionNew, duration: duration),
                SKAction.removeFromParent()
            ]))
        }
        
        node.addChild(sprite)
    }
}
