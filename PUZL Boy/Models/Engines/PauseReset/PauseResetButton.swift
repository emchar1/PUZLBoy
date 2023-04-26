//
//  PauseResetButton.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/22/23.
//

import SpriteKit

protocol PauseResetButtonDelegate: AnyObject {
    func didTapButton(_ node: PauseResetButton)
}

class PauseResetButton: SKNode {
    
    // MARK: - Properties
    
    var buttonSize: CGSize
    private(set) var isPressed: Bool = false
    private(set) var shadowSize: CGPoint = CGPoint(x: -10, y: -10)
    private var buttonSprite: SKShapeNode
    private var shadowSprite: SKShapeNode
    private var labelSprite: SKLabelNode
    
    private var backgroundColor: UIColor { (DayTheme.skyColor.bottom.isLight() ?? true) ? DayTheme.skyColor.top : DayTheme.skyColor.bottom }
    private var backgroundShadowColor: UIColor { DayTheme.skyColor.bottom.triadic.first }

    
    weak var delegate: PauseResetButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, position: CGPoint, size: CGSize) {
        buttonSize = size
        
        buttonSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: 20)
        buttonSprite.strokeColor = .white
        buttonSprite.lineWidth = 0
        buttonSprite.zPosition = 10
        
        shadowSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: 20)
        shadowSprite.position = shadowSize
        shadowSprite.strokeColor = .white
        shadowSprite.lineWidth = 0
        shadowSprite.alpha = 0.75
        shadowSprite.zPosition = -1
        
        labelSprite = SKLabelNode(text: text)
        labelSprite.fontColor = .white
        labelSprite.fontName = UIFont.chatFont
        labelSprite.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeMedium : UIFont.gameFontSizeSmall
        labelSprite.verticalAlignmentMode = .center
        labelSprite.horizontalAlignmentMode = .center
        labelSprite.alpha = 0.5
        labelSprite.zPosition = 10
        labelSprite.addDropShadow()
        
        super.init()

        self.position = position
        self.name = text
        buttonSprite.fillColor = backgroundColor
        shadowSprite.fillColor = backgroundShadowColor
        shadowSprite.alpha = 0.75

        addChild(buttonSprite)
        buttonSprite.addChild(shadowSprite)
        buttonSprite.addChild(labelSprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func touchDown() {
        isPressed = true
        
        labelSprite.alpha = 1.0
        buttonSprite.fillColor = backgroundShadowColor
        buttonSprite.run(SKAction.move(to: shadowSize, duration: 0))
        shadowSprite.run(SKAction.move(to: .zero, duration: 0))
    }
    
    func touchUp() {
        isPressed = false
        
        let animationDuration: CGFloat = 0.1
        
        labelSprite.alpha = 0.5
        buttonSprite.fillColor = backgroundColor
        buttonSprite.run(SKAction.move(to: .zero, duration: animationDuration))
        shadowSprite.run(SKAction.move(to: shadowSize, duration: animationDuration))
    }
    
    func tapButton() {
        guard isPressed else { return }
        
        delegate?.didTapButton(self)
        K.ButtonTaps.tap2()
    }
}
