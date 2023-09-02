//
//  SettingsButton.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/22/23.
//

import SpriteKit

protocol SettingsButtonDelegate: AnyObject {
    func didTapButton(_ node: SettingsButton)
}

class SettingsButton: SKNode {
    
    // MARK: - Properties
    
    var buttonSize: CGSize
    private(set) var isPressed: Bool = false
    private(set) var shadowSize: CGPoint = CGPoint(x: -10, y: -10)
    private(set) var type: SettingsButtonType
    
    private var buttonSprite: SKShapeNode!
    private var shadowSprite: SKShapeNode!
    private var labelSprite: SKLabelNode!
    
    weak var delegate: SettingsButtonDelegate?
    
    enum SettingsButtonType: String {
        case button1 = "Home", button2 = "Shop", button3 = "Leaderboard", button4 = "How To Play", button5 = "Settings"
    }
    
    // MARK: - Initialization
    
    init(type: SettingsButtonType, position: CGPoint, size: CGSize) {
        self.type = type
        self.buttonSize = size

        super.init()

        self.position = position
        self.name = type.rawValue

        setupSprites()
        updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
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
        
        labelSprite = SKLabelNode(text: type.rawValue)
        labelSprite.fontColor = .white
        labelSprite.fontName = UIFont.chatFont
        labelSprite.fontSize = UIFont.pauseTabsFontSize
        labelSprite.verticalAlignmentMode = .center
        labelSprite.horizontalAlignmentMode = .center
        labelSprite.alpha = 0.75
        labelSprite.zPosition = 10
        labelSprite.addDropShadow()

        addChild(buttonSprite)
        buttonSprite.addChild(shadowSprite)
        buttonSprite.addChild(labelSprite)
    }
    
    // MARK: - Functions
    
    func touchDown() {
        isPressed = true
        
        labelSprite.alpha = 1.0
        buttonSprite.fillColor = PauseResetEngine.backgroundShadowColor
        buttonSprite.run(SKAction.move(to: shadowSize, duration: 0))
        shadowSprite.run(SKAction.move(to: .zero, duration: 0))
    }
    
    func touchUp() {
        isPressed = false
        
        let animationDuration: CGFloat = 0.2
        
        labelSprite.alpha = 0.75
        buttonSprite.fillColor = PauseResetEngine.backgroundColor
        buttonSprite.run(SKAction.move(to: .zero, duration: animationDuration))
        shadowSprite.run(SKAction.move(to: shadowSize, duration: animationDuration))
    }
    
    func tapButton(tapQuietly: Bool = false) {
        guard isPressed else { return }
        
        delegate?.didTapButton(self)
        
        if !tapQuietly {
            ButtonTap.shared.tap(type: .buttontap2)
        }
    }
    
    func updateColors() {
        if type == .button1 || type == .button3 {
            buttonSprite.fillColor = PauseResetEngine.backgroundColor
        }
        else {
            buttonSprite.fillColor = isPressed ? PauseResetEngine.backgroundShadowColor : PauseResetEngine.backgroundColor
        }
        
        buttonSprite.fillTexture = SKTexture(image: UIImage.menuGradientTexture)
        shadowSprite.fillColor = PauseResetEngine.backgroundShadowColor
    }
}
