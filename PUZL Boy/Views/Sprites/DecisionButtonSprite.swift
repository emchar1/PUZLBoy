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
    static let colorBlue = UIColor(red: 9 / 255, green: 132 / 255, blue: 227 / 255, alpha: 1.0)
    static let colorYellow = UIColor(red: 227 / 255, green: 148 / 255, blue: 9 / 255, alpha: 1.0)
    static let colorRed = UIColor(red: 227 / 255, green: 32 / 255, blue: 9 / 255, alpha: 1.0)
    static let colorGreen = UIColor(red: 0 / 255, green: 168 / 255, blue: 86 / 255, alpha: 1.0)

    let buttonSize = CGSize(width: K.ScreenDimensions.size.width * (4 / 9), height: K.ScreenDimensions.size.width / 8)
    let shadowOffset = CGPoint(x: -8, y: -8)
    let iconScale: CGFloat = UIDevice.isiPad ? 120 : 90

    var isDisabled: Bool = false {
        didSet {
            sprite.alpha = isDisabled ? 0.25 : 1
        }
    }
    
    private var isPressed: Bool = false
    private var text: String
    private var color: UIColor
    private var iconImageName: String?
    
    private(set) var tappableAreaNode: SKShapeNode!
    private var sprite: SKShapeNode!
    private var topSprite: SKShapeNode!
    private var textNode: SKLabelNode!

    weak var delegate: DecisionButtonSpriteDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, color: UIColor, iconImageName: String?) {
        self.text = text
        self.color = color
        self.iconImageName = iconImageName
        
        super.init()
        
        setupSprites()
    }
            
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit DecisionButtonSprite: \(name ?? "")")
    }
    
    private func setupSprites() {
        let cornerRadius: CGFloat = 16
        
        tappableAreaNode = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        tappableAreaNode.fillColor = .clear
        tappableAreaNode.strokeColor = .white
        tappableAreaNode.lineWidth = 4
        tappableAreaNode.zPosition = 10
        tappableAreaNode.name = DecisionButtonSprite.tappableAreaName

        sprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        sprite.fillColor = .clear
        sprite.lineWidth = 0
        
        topSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        topSprite.fillColor = color
        topSprite.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        topSprite.strokeColor = .white
        topSprite.lineWidth = 4
        topSprite.position = .zero

        textNode = SKLabelNode(text: text)
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIFont.chatFontSizeLarge
        textNode.fontColor = UIFont.chatFontColor
        textNode.position = CGPoint(x: 0, y: -18)
        textNode.zPosition = 10
        textNode.addDropShadow()
                
        let shadowSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        shadowSprite.fillColor = .black
        shadowSprite.lineWidth = 0
        shadowSprite.alpha = 0.05
                
        if let iconImageName = iconImageName {
            let iconNode = SKSpriteNode(imageNamed: iconImageName)
            iconNode.scale(to: CGSize(width: iconScale, height: iconScale))
            iconNode.position = CGPoint(x: UIDevice.isiPad ? 120 : 78, y: 0)
        
            topSprite.addChild(iconNode)
        }
                
        addChild(tappableAreaNode)
        addChild(sprite)
        sprite.addChild(shadowSprite)
        sprite.addChild(topSprite)
        topSprite.addChild(textNode)
    }
    

    // MARK: - Touches
    
    func touchDown(in location: CGPoint) {
        guard !isDisabled else {
            ButtonTap.shared.tap(type: .buttontap6)
            return
        }

        isPressed = true
                
        topSprite.position = shadowOffset
        tappableAreaNode.position = shadowOffset
    }
    
    func touchUp() {
        guard !isDisabled else { return }

        isPressed = false

        topSprite.run(SKAction.move(to: .zero, duration: 0.1))
        tappableAreaNode.run(SKAction.move(to: .zero, duration: 0.1))
    }
    
    func tapButton(in location: CGPoint, type: ButtonTap.ButtonType = .buttontap1) {
        guard !isDisabled else { return }
        guard isPressed else { return }

        delegate?.buttonWasTapped(self)
        ButtonTap.shared.tap(type: type)
    }

    func setText(_ text: String) {
        textNode.text = text
        textNode.updateShadow()
    }
    
    func animateAppear() {
        alpha = 1.0
        
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
        ]))
    }
}
