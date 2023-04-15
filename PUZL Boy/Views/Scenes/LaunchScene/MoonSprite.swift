//
//  MoonSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/14/23.
//

import SpriteKit

class MoonSprite: SKNode {
    
    let spriteSize = CGSize(width: 500, height: 500)
    
    init(position: CGPoint, scale: CGFloat, moonPhase: Int? = nil) {
        super.init()
        
        let moonPhaseAdjusted: Int = moonPhase == nil ? Int.random(in: 0...9) : max(0, min(9, moonPhase!))
        var moonAlpha: CGFloat = 1
        var moonColor: UIColor = .clear
        var moonColorBlendFactor: CGFloat = 0
        
        switch DayTheme.currentTheme {
        case .dawn:
            moonAlpha = 0.5
        case .morning:
            moonAlpha = 0
        case .afternoon:
            moonAlpha = 0.1
        case .night:
            moonAlpha = 1.0
            
            if Int.random(in: 0...4) == 0 {
                moonColor = .orange
                
                switch moonPhaseAdjusted {
                case 0: moonColorBlendFactor = 0.65
                case 1: moonColorBlendFactor = 0.5
                case 2: moonColorBlendFactor = 0.25
                case 3: moonColorBlendFactor = 0.1
                default: moonColorBlendFactor = 0
                }
            }
        }
                
        let sprite = SKSpriteNode(imageNamed: "moon\(moonPhaseAdjusted)")
        sprite.anchorPoint = .zero
        sprite.position = position - CGPoint(x: spriteSize.width, y: spriteSize.height)
        sprite.setScale(scale)
        sprite.alpha = moonAlpha
        sprite.color = moonColor
        sprite.colorBlendFactor = moonColorBlendFactor
        sprite.zPosition = K.ZPosition.backgroundObjectMoon
        
        if DayTheme.currentTheme == .night {
            sprite.addGlow(textureName: "moon\(moonPhaseAdjusted)")
        }
        
        addChild(sprite)

        self.name = LaunchScene.nodeName_skyObjectNode // set self.name, NOT sprite.name!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
