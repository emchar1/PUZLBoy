//
//  DecisionButtonSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/27/23.
//

import SpriteKit

protocol DecisionButtonSpriteDelegate: AnyObject {
    func buttonWasTapped(_ node: DecisionButtonSprite)
}

class DecisionButtonSprite: SKNode {
    
    // MARK: - Properties
    
    static let tappableAreaName = "DecisionButtonSpriteTappableArea"

    let buttonSize = CGSize(width: K.ScreenDimensions.iPhoneWidth * (4 / 9), height: K.ScreenDimensions.iPhoneWidth / 8)
    let shadowOffset = CGPoint(x: -8, y: -8)
    let iconScale: CGFloat = UIDevice.isiPad ? 120 : 90

    private var isPressed: Bool = false
    private(set) var tappableAreaNode: SKShapeNode
    private var sprite: SKShapeNode
    private var topSprite: SKShapeNode
    private var textNode: SKLabelNode

    weak var delegate: DecisionButtonSpriteDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, color: UIColor, iconImageName: String?) {
        let cornerRadius: CGFloat = 16
        
        tappableAreaNode = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        tappableAreaNode.fillColor = .clear
        tappableAreaNode.strokeColor = .clear
        tappableAreaNode.lineWidth = 4
        tappableAreaNode.zPosition = 20
        tappableAreaNode.name = DecisionButtonSprite.tappableAreaName

        sprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        sprite.fillColor = .clear
        sprite.lineWidth = 0
        
        topSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        topSprite.fillColor = color
        topSprite.fillTexture = SKTexture(image: .chatGradientTexture)
        topSprite.strokeColor = .white
        topSprite.lineWidth = 4
        topSprite.position = .zero

        textNode = SKLabelNode(text: text)
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.chatFontSize
        textNode.fontColor = UIFont.chatFontColor
        textNode.position = CGPoint(x: 0, y: -18)
        textNode.zPosition = 10
        textNode.addDropShadow()
        
        super.init()
                
        let shadowSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        shadowSprite.fillColor = .black
        shadowSprite.lineWidth = 0
        shadowSprite.alpha = 0.05
                
        if let iconImageName = iconImageName {
            let lineWidth: CGFloat = 4
            
            let maskNode = SKShapeNode(rectOf: buttonSize - CGSize(width: lineWidth * 2, height: lineWidth * 2), cornerRadius: cornerRadius)
            maskNode.fillColor = .orange
            maskNode.lineWidth = lineWidth
            maskNode.strokeColor = .white

            let cropNode = SKCropNode()
            cropNode.position = .zero
            cropNode.maskNode = maskNode
            
            let iconNode = SKSpriteNode(imageNamed: iconImageName)
//            iconNode.scale(to: CGSize(width: iconScale * Player.size.width / Player.size.height, height: iconScale))
            iconNode.position = CGPoint(x: UIDevice.isiPad ? 96 : 64, y: 0)
        
//            topSprite.addChild(iconNode)
            topSprite.addChild(cropNode)
            cropNode.addChild(iconNode)
        }
                
        addChild(tappableAreaNode)
        addChild(sprite)
        sprite.addChild(shadowSprite)
        sprite.addChild(topSprite)
        topSprite.addChild(textNode)
    }
            
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Touches
    
    func touchDown(in location: CGPoint) {
        isPressed = true
                
        topSprite.position = shadowOffset
    }
    
    func touchUp() {
        isPressed = false

        topSprite.run(SKAction.move(to: .zero, duration: 0.1))
    }
    
    func tapButton(in location: CGPoint, type: ButtonTap.ButtonType = .buttontap1) {
        guard isPressed else { return }

        delegate?.buttonWasTapped(self)
        ButtonTap.shared.tap(type: type)
    }

    func setText(_ text: String) {
        textNode.text = text
        textNode.updateShadow()
    }
}
