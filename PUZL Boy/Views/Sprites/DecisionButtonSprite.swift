//
//  DecisionButtonSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/27/23.
//

import SpriteKit

class DecisionButtonSprite: SKNode {
    
    // MARK: - Properties
    
    let buttonSize = CGSize(width: 400, height: 120)
    let shadowOffset = CGPoint(x: -8, y: 8)
    let iconScale: CGFloat = 90
    private(set) var sprite: SKShapeNode
    private var topSprite: SKShapeNode
    
    
    // MARK: - Initialization
    
    init(text: String, color: UIColor) {
        sprite = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        sprite.fillColor = .clear
        sprite.lineWidth = 0
        
        topSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        topSprite.fillColor = color
        topSprite.fillTexture = SKTexture(image: .chatGradientTexture)
        topSprite.lineWidth = 4
        topSprite.strokeColor = .white
        topSprite.position = shadowOffset

        super.init()
                
        let shadowSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        shadowSprite.fillColor = .black
        shadowSprite.lineWidth = 0
        shadowSprite.alpha = 0.05
        
        let textNode = SKLabelNode(text: text)
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIFont.chatFontSize
        textNode.fontColor = UIFont.chatFontColor
        textNode.position = CGPoint(x: 0, y: -18)
        
        let iconNode = SKSpriteNode(imageNamed: "Run (6)")
        iconNode.scale(to: CGSize(width: iconScale * Player.size.width / Player.size.height, height: iconScale))
        iconNode.position = CGPoint(x: 65, y: 0)

        addChild(sprite)
        sprite.addChild(shadowSprite)
        sprite.addChild(topSprite)
        topSprite.addChild(textNode)
        topSprite.addChild(iconNode)
    }
        
    func tapButton() {
        topSprite.position = .zero
        
        topSprite.run(SKAction.move(to: shadowOffset, duration: 0.25))
        
        AudioManager.shared.playSound(for: "buttontap")
        Haptics.shared.addHapticFeedback(withStyle: .soft)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}