//
//  BackgroundObject.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/26/22.
//

import SpriteKit

enum BackgroundType: String {
    case tree, boulder, mountain, cloud
}

struct BackgroundObject {
    
    // MARK: - Properties
    
    static let maxTier = 2
    let tierLevel: Int
    let backgroundType: BackgroundType
    let sprite: SKSpriteNode
    let spriteWidth: CGFloat = 500
    let backgroundBorder: CGFloat = 1.5

    var endPosition: CGPoint {
        return CGPoint(x: -spriteWidth, y: sprite.position.y)
    }
    
    var speed: TimeInterval {
        guard backgroundType != .mountain else { return 12.0 }
        
        switch tierLevel {
        case 0: return backgroundType != .cloud ? 3.0 : 100
        case 1: return backgroundType != .cloud ? 3.5 : 50
        default: return backgroundType != .cloud ? 4.0 : 25
        }
    }
    
    var delay: TimeInterval {
        return TimeInterval.random(in: 1...3)
    }
    
    
    // MARK: - Initialization
    
    init(tierLevel: Int, backgroundType: BackgroundType) {
        self.tierLevel = tierLevel
        self.backgroundType = backgroundType
        
        let textureName = "\(backgroundType.rawValue)\(Int.random(in: 0...BackgroundObject.maxTier))"
        
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: textureName))
        sprite.anchorPoint = .zero

        guard backgroundType != .mountain else {
            sprite.position = CGPoint(x: K.iPhoneWidth / 2, y: K.height / backgroundBorder)
            sprite.setScale(0.4)
            sprite.alpha = 0.75
            sprite.zPosition = K.ZPosition.backgroundObjectTier2
            return
        }
        
        switch tierLevel {
        case 0:
            sprite.position = backgroundType == .cloud ? CGPoint(x: K.iPhoneWidth / 2, y: K.height / (backgroundBorder - 0.3)) : CGPoint(x: K.iPhoneWidth, y: K.height / (backgroundBorder + 0.5))
            sprite.setScale(0.75)
            sprite.alpha = backgroundType == .cloud ? 0.6 : 1.0
            sprite.zPosition = K.ZPosition.backgroundObjectTier0
        case 1:
            sprite.position = backgroundType == .cloud ? CGPoint(x: K.iPhoneWidth / 4, y: K.height / (backgroundBorder - 0.2)) : CGPoint(x: K.iPhoneWidth, y: K.height / (backgroundBorder + 0.25))
            sprite.setScale(0.5)
            sprite.alpha = backgroundType == .cloud ? 0.6 : 0.9
            sprite.zPosition = K.ZPosition.backgroundObjectTier1
        default:
            sprite.position = backgroundType == .cloud ? CGPoint(x: 2 * K.iPhoneWidth / 3, y: K.height / (backgroundBorder - 0.1)) : CGPoint(x: K.iPhoneWidth, y: K.height / (backgroundBorder + 0.2))
            sprite.setScale(0.25)
            sprite.alpha = backgroundType == .cloud ? 0.6 : 0.85
            sprite.zPosition = K.ZPosition.backgroundObjectTier2
        }
        
    }
}
