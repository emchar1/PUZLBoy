//
//  PartyEffectSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/11/23.
//

import SpriteKit

class PartyEffectSprite: SKNode {
    
    // MARK: - Properties
    
    private var sprite: SKShapeNode

    
    // MARK: - Initialization
    
    override init() {
        let radius: CGFloat = CGFloat.random(in: 50...500)
        
        sprite = SKShapeNode(ellipseIn: CGRect(x: -radius / 2, y: -radius / 2, width: radius, height: radius))
        sprite.position = CGPoint(x: CGFloat.random(in: 0...K.ScreenDimensions.iPhoneWidth), y: CGFloat.random(in: 0...K.ScreenDimensions.height))
        sprite.fillColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        sprite.lineWidth = 0
        sprite.alpha = 0
        sprite.zPosition = K.ZPosition.partyForegroundOverlay + 10
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func animateEffect(to superScene: SKNode) {
        addChild(sprite)
        superScene.addChild(self)
        
        let fadeDuration = TimeInterval.random(in: 0.25...1)
        let waitDuration = TimeInterval.random(in: 1...2)
        let randomAlpha = CGFloat.random(in: 0.1..<0.5)
        
        sprite.run(SKAction.sequence([
            SKAction.fadeAlpha(to: randomAlpha, duration: fadeDuration),
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeAlpha(to: 0, duration: fadeDuration)
        ])) { [unowned self] in
            sprite.removeFromParent()
            removeFromParent()
        }
    }
    
}
