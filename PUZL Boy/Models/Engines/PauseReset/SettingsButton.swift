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
    
    private let iconSize: CGFloat = UIDevice.isiPad ? 80 : 60
    private let colorFactor: CGFloat = 3
    
    var buttonSize: CGSize
    private(set) var isPressed: Bool = false
    private(set) var shadowSize: CGPoint = CGPoint(x: -10, y: -10)
    private(set) var type: SettingsButtonType
    
    private var buttonSprite: SKShapeNode!
    private var shadowSprite: SKShapeNode!
    private var iconSprite: SKSpriteNode!
    
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
        
        iconSprite = SKSpriteNode(texture: SKTexture(imageNamed: "tab\(type.rawValue.replacingOccurrences(of: " ", with: ""))"))
        iconSprite.color = PauseResetEngine.backgroundShadowColor.lightenColor(factor: colorFactor)
        iconSprite.colorBlendFactor = 1
        iconSprite.size = CGSize(width: iconSize, height: iconSize)
        iconSprite.zPosition = 10

        addChild(buttonSprite)
        buttonSprite.addChild(shadowSprite)
        buttonSprite.addChild(iconSprite)
    }
    
    // MARK: - Functions
    
    func touchDown() {
        isPressed = true
        
        iconSprite.color = PauseResetEngine.backgroundColor.darkenColor(factor: colorFactor)
        buttonSprite.fillColor = PauseResetEngine.backgroundShadowColor
        buttonSprite.run(SKAction.move(to: shadowSize, duration: 0))
        shadowSprite.run(SKAction.move(to: .zero, duration: 0))
    }
    
    func touchUp() {
        isPressed = false
        
        let animationDuration: CGFloat = 0.2
        
        iconSprite.color = PauseResetEngine.backgroundShadowColor.lightenColor(factor: colorFactor)
        buttonSprite.fillColor = PauseResetEngine.backgroundColor
        buttonSprite.run(SKAction.move(to: .zero, duration: animationDuration))
        shadowSprite.run(SKAction.move(to: shadowSize, duration: animationDuration))
    }
    
    func tapButton(tapQuietly: Bool = false) {
        guard isPressed else { return }
        
        delegate?.didTapButton(self)
        
        if !tapQuietly {
            ButtonTap.shared.tap(type: .buttontap2, hapticStyle: .medium)
        }
    }
    
    func updateColors() {
        if type == .button1 || type == .button3 {
            buttonSprite.fillColor = PauseResetEngine.backgroundColor
        }
        else {
            iconSprite.color = isPressed ? PauseResetEngine.backgroundColor.darkenColor(factor: colorFactor) : PauseResetEngine.backgroundShadowColor.lightenColor(factor: colorFactor)
            buttonSprite.fillColor = isPressed ? PauseResetEngine.backgroundShadowColor : PauseResetEngine.backgroundColor
        }
        
        buttonSprite.fillTexture = SKTexture(image: UIImage.menuGradientTexture)
        shadowSprite.fillColor = PauseResetEngine.backgroundShadowColor
    }
}
