//
//  BackgroundObject.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/26/22.
//

import SpriteKit

struct BackgroundObject {
    
    // MARK: - Properties
    
    let backgroundBorder: CGFloat = 1.5
    static let maxTier = 2
    private let tierLevel: Int
    private let backgroundType: BackgroundType
    private let spriteWidth: CGFloat = 500
    private var spriteScale: CGFloat = 1.0
    private(set) var sprite = SKSpriteNode()

    var endPosition: CGPoint {
        return CGPoint(x: -sprite.size.width, y: sprite.position.y)
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
    
    enum BackgroundType: String {
        case tree, boulder, mountain, cloud, moon, grass
    }
    
    
    // MARK: - Initialization
    
    init(tierLevel: Int, backgroundType: BackgroundType) {
        self.tierLevel = tierLevel
        self.backgroundType = backgroundType
        
        setupBackgroundTypes()
    }
    
    private mutating func setupBackgroundTypes() {
        switch backgroundType {
        case .mountain:
            setupSprite(imageNameShouldIncludeTier: true,
                        position: CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / backgroundBorder),
                        anchorPoint: .zero,
                        scale: 0.4,
                        alpha: 0.75,
                        color: DayTheme.spriteColor,
                        colorBlendFactor: DayTheme.spriteShade,
                        zPosition: K.ZPosition.backgroundObjectTier2)
        case .moon:
            setupSprite(imageNameShouldIncludeTier: true,
                        position: CGPoint(x: K.ScreenDimensions.iPhoneWidth - spriteWidth, y: K.ScreenDimensions.height - spriteWidth),
                        anchorPoint: .zero,
                        scale: 0.7,
                        alpha: DayTheme.currentTheme == .night ? 1.0 : 0.0,
                        color: .clear,
                        colorBlendFactor: 0,
                        zPosition: K.ZPosition.backgroundObjectTier4)
        case .grass:
            spriteScale = 0.2
            
            for i in 0..<200 {
                let spriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "grass0"))
                spriteNode.position = CGPoint(x: CGFloat(i) * spriteWidth * spriteScale, y: 0)
                spriteNode.anchorPoint = .zero
                spriteNode.setScale(spriteScale)
                spriteNode.zPosition = K.ZPosition.panel
                                
                sprite.addChild(spriteNode)
            }
            
            sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth, y: 0)
            sprite.anchorPoint = .zero
        default:
            switch tierLevel {
            case 0:
                setupSprite(imageNameShouldIncludeTier: true,
                            position: backgroundType == .cloud ? CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / (backgroundBorder - 0.3)) : CGPoint(x: K.ScreenDimensions.iPhoneWidth, y: K.ScreenDimensions.height / (backgroundBorder + 0.5)),
                            anchorPoint: .zero,
                            scale: 0.75,
                            alpha: backgroundType == .cloud ? 0.6 : 1.0,
                            color: backgroundType == .cloud ? .clear : DayTheme.spriteColor,
                            colorBlendFactor: DayTheme.spriteShade,
                            zPosition: backgroundType == .cloud ? K.ZPosition.backgroundObjectTier3 : K.ZPosition.backgroundObjectTier0)
            case 1:
                setupSprite(imageNameShouldIncludeTier: true,
                            position: backgroundType == .cloud ? CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: K.ScreenDimensions.height / (backgroundBorder - 0.2)) : CGPoint(x: K.ScreenDimensions.iPhoneWidth, y: K.ScreenDimensions.height / (backgroundBorder + 0.25)),
                            anchorPoint: .zero,
                            scale: 0.5,
                            alpha: backgroundType == .cloud ? 0.6 : 0.9,
                            color: backgroundType == .cloud ? .clear : DayTheme.spriteColor,
                            colorBlendFactor: DayTheme.spriteShade,
                            zPosition: backgroundType == .cloud ? K.ZPosition.backgroundObjectTier3 : K.ZPosition.backgroundObjectTier1)
            default:
                setupSprite(imageNameShouldIncludeTier: true,
                            position: backgroundType == .cloud ? CGPoint(x: K.ScreenDimensions.iPhoneWidth / 3, y: K.ScreenDimensions.height / (backgroundBorder - 0.1)) : CGPoint(x: K.ScreenDimensions.iPhoneWidth, y: K.ScreenDimensions.height / (backgroundBorder + 0.2)),
                            anchorPoint: .zero,
                            scale: 0.25,
                            alpha: backgroundType == .cloud ? 0.6 : 0.85,
                            color: backgroundType == .cloud ? .clear : DayTheme.spriteColor,
                            colorBlendFactor: DayTheme.spriteShade,
                            zPosition: backgroundType == .cloud ? K.ZPosition.backgroundObjectTier3 : K.ZPosition.backgroundObjectTier2)
            } //end switch tierLevel
        }//end switch backgroundTypes
    }//end setupBackgroundTypes
    
    private mutating func setupSprite(imageNameShouldIncludeTier: Bool, position: CGPoint, anchorPoint: CGPoint, scale: CGFloat, alpha: CGFloat, color: UIColor, colorBlendFactor: CGFloat, zPosition: CGFloat) {
        
        let imageName = "\(backgroundType.rawValue)\(imageNameShouldIncludeTier ? "\(Int.random(in: 0...BackgroundObject.maxTier))" : "")"
        
        spriteScale = scale
        
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: imageName))
        sprite.position = position
        sprite.anchorPoint = anchorPoint
        sprite.setScale(scale)
        sprite.alpha = alpha
        sprite.color = color
        sprite.colorBlendFactor = colorBlendFactor
        sprite.zPosition = zPosition
    }
    
    
    // MARK: - Helper Functions
    
    func animateSprite(withDelay delay: TimeInterval?) {
        let animation = SKAction.move(to: endPosition, duration: speed)
        let sequence = SKAction.sequence([SKAction.wait(forDuration: delay == nil ? 0 : self.delay * 2 * delay!),
                                          SKAction.repeat(animation, count: 1)])
        sprite.run(sequence)
    }
}
