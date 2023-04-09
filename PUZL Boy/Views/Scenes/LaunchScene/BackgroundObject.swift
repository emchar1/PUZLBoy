//
//  BackgroundObject.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/26/22.
//

import SpriteKit

class BackgroundObject: SKNode {
    
    // MARK: - Properties
    
    let backgroundBorder: CGFloat = 1.5
    static let maxTier = 2
    private let tierLevel: Int
    private let backgroundType: BackgroundType
    private let spriteWidth: CGFloat = 500
    private var spriteScale: CGFloat = 1.0
    private var originalPosition: CGPoint = .zero

    private(set) var sprite = SKSpriteNode()
    private(set) var didFinishAnimating: Bool = false

    var objectSpeed: TimeInterval {
        var dayMultiplier: TimeInterval
        switch DayTheme.currentTheme {
        case .dawn: dayMultiplier = 2
        case .morning: dayMultiplier = 0.8
        case .afternoon: dayMultiplier = 1.5
        case .night: dayMultiplier = 2
        }
        
        guard backgroundType != .mountain else { return 20.0 * dayMultiplier }
        
        switch tierLevel {
        case 0: return dayMultiplier * (backgroundType != .cloud ? 3.0 : CGFloat.random(in: 50...100))
        case 1: return dayMultiplier * (backgroundType != .cloud ? 3.5 : CGFloat.random(in: 100...250))
        default: return dayMultiplier * (backgroundType != .cloud ? 4.0 : CGFloat.random(in: 250...500))
        }
    }
    
    var delay: TimeInterval {
        return TimeInterval.random(in: 1...3)
    }
    
    enum BackgroundType: String {
        case tree, boulder, mountain, cloud, moon
    }
    
    
    // MARK: - Initialization
    
    init(tierLevel: Int, backgroundType: BackgroundType) {
        self.tierLevel = tierLevel
        self.backgroundType = backgroundType
        
        super.init()

        setupBackgroundTypes()
        
        addChild(sprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBackgroundTypes() {
        var randPosition: CGFloat { CGFloat.random(in: 0...(2 * K.ScreenDimensions.iPhoneWidth)) }
        var mountainRandPosition: CGFloat { CGFloat.random(in: 0...(K.ScreenDimensions.iPhoneWidth - spriteWidth)) }
        
        switch backgroundType {
        case .mountain:
            setupSprite(position: CGPoint(x: mountainRandPosition, y: K.ScreenDimensions.height / backgroundBorder),
                        anchorPoint: .zero,
                        scale: 0.4,
                        alpha: 0.75,
                        color: DayTheme.spriteColor,
                        colorBlendFactor: DayTheme.spriteShade,
                        zPosition: K.ZPosition.backgroundObjectMountain)
        case .moon:
            setupSprite(position: CGPoint(x: K.ScreenDimensions.iPhoneWidth - spriteWidth, y: K.ScreenDimensions.height - spriteWidth),
                        anchorPoint: .zero,
                        scale: 0.7,
                        alpha: DayTheme.currentTheme == .night ? 1.0 : (DayTheme.currentTheme == .dawn ? 0.5 : 0.0),
                        color: .clear,
                        colorBlendFactor: 0,
                        zPosition: K.ZPosition.backgroundObjectMoon)
        default:
            switch tierLevel {
            case 0:
                setupSprite(position: CGPoint(x: randPosition, y: getYPosition(offset: (backgroundType == .cloud ? -0.3 : 0.5))),
                            anchorPoint: .zero,
                            scale: 0.75,
                            alpha: backgroundType == .cloud ? 0.6 : 1.0,
                            color: backgroundType == .cloud ? .clear : DayTheme.spriteColor,
                            colorBlendFactor: DayTheme.spriteShade,
                            zPosition: backgroundType == .cloud ? K.ZPosition.backgroundObjectCloud : K.ZPosition.backgroundObjectTier0)
            case 1:
                setupSprite(position: CGPoint(x: randPosition, y: getYPosition(offset: (backgroundType == .cloud ? -0.2 : 0.25))),
                            anchorPoint: .zero,
                            scale: 0.5,
                            alpha: backgroundType == .cloud ? 0.6 : 0.9,
                            color: backgroundType == .cloud ? .clear : DayTheme.spriteColor,
                            colorBlendFactor: DayTheme.spriteShade,
                            zPosition: backgroundType == .cloud ? K.ZPosition.backgroundObjectCloud : K.ZPosition.backgroundObjectTier1)
            default:
                setupSprite(position: CGPoint(x: randPosition, y: getYPosition(offset: (backgroundType == .cloud ? -0.1 : 0.2))),
                            anchorPoint: .zero,
                            scale: 0.25,
                            alpha: backgroundType == .cloud ? 0.6 : 0.85,
                            color: backgroundType == .cloud ? .clear : DayTheme.spriteColor,
                            colorBlendFactor: DayTheme.spriteShade,
                            zPosition: backgroundType == .cloud ? K.ZPosition.backgroundObjectCloud : K.ZPosition.backgroundObjectTier2)
            } //end switch tierLevel
        }//end switch backgroundTypes
    }//end setupBackgroundTypes
    
    private func getYPosition(offset: CGFloat) -> CGFloat {
        return K.ScreenDimensions.height / (backgroundBorder + offset)
    }
    
    private func setupSprite(position: CGPoint, anchorPoint: CGPoint, scale: CGFloat, alpha: CGFloat, color: UIColor, colorBlendFactor: CGFloat, zPosition: CGFloat) {
        
        let imageName = "\(backgroundType.rawValue)\(Int.random(in: 0...BackgroundObject.maxTier))"
        
        spriteScale = scale
        
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: imageName))
        sprite.position = position
        sprite.anchorPoint = anchorPoint
        sprite.setScale(scale)
        sprite.alpha = alpha
        sprite.color = color
        sprite.colorBlendFactor = colorBlendFactor
        sprite.zPosition = zPosition
        
        originalPosition = position
    }
    
    
    // MARK: - Helper Functions
    
    func animateSprite(withDelay delay: TimeInterval?, shouldReverse: Bool = false, completion: (() -> Void)? = nil) {
        let xOffset: CGFloat = shouldReverse ? 1000 : -1000
        let animation = SKAction.move(by: CGVector(dx: xOffset, dy: 0), duration: objectSpeed)

        var xBoundaryCheck: Bool {
            shouldReverse ? sprite.position.x > K.ScreenDimensions.iPhoneWidth : sprite.position.x + sprite.size.width < 0
        }

        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: delay == nil ? 0 : self.delay * 2 * delay!),
            SKAction.repeatForever(SKAction.sequence([
                animation,
                SKAction.run { [unowned self] in
                    if xBoundaryCheck {
                        stopSprite()
                        completion?()
                    }
                }
            ]))
        ])
        
        sprite.run(sequence)
    }
    
    func stopSprite() {
        didFinishAnimating = true
        sprite.removeAllActions()
    }
    
    func resetSprite(shouldStartAtEdge: Bool, shouldReverse: Bool = false) {
        let edgePositionStart: CGFloat = shouldReverse ? -sprite.size.width - CGFloat.random(in: 0...K.ScreenDimensions.iPhoneWidth) : K.ScreenDimensions.iPhoneWidth + CGFloat.random(in: 0...K.ScreenDimensions.iPhoneWidth)
        
        sprite.position = originalPosition

        if shouldStartAtEdge {
            sprite.position.x = edgePositionStart
        }
        
        didFinishAnimating = false
    }
}
