//
//  ConfirmSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/26/23.
//

import SpriteKit

protocol ConfirmSpriteDelegate: AnyObject {
    func didTapConfirm()
    func didTapCancel()
}

class ConfirmSprite: SKNode {
    
    // MARK: - Properties
        
    private var disableControls: Bool = true
    private let messageLabel: SKLabelNode
    private(set) var backgroundSprite: SKShapeNode
    private(set) var confirmButton: DecisionButtonSprite
    private(set) var cancelButton: DecisionButtonSprite
    
    weak var delegate: ConfirmSpriteDelegate?

    
    // MARK: - Initialization
    
    init(title: String, message: String, confirm: String, cancel: String) {
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth / 2),
                                       cornerRadius: 20)
        backgroundSprite.fillColor = .gray
        backgroundSprite.fillTexture = SKTexture(image: UIImage.chatGradientTexture)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(GameboardSprite.spriteScale)
        
        let titleLabel = SKLabelNode(text: title.uppercased())
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeExtraLarge : UIFont.gameFontSizeMedium
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.position = CGPoint(x: 0, y: backgroundSprite.frame.size.height / (UIDevice.isiPad ? 1.5 : 2) - titleLabel.frame.size.height / 2)
        titleLabel.verticalAlignmentMode = .top
        titleLabel.zPosition = 10
        titleLabel.addHeavyDropShadow()
        
        confirmButton = DecisionButtonSprite(text: confirm,
                                             color: UIColor(red: 227 / 255, green: 32 / 255, blue: 9 / 255, alpha: 1.0),
                                             iconImageName: nil)
        confirmButton.position = CGPoint(x: -K.ScreenDimensions.iPhoneWidth / 4,
                                         y: -backgroundSprite.frame.size.height / 2 + titleLabel.frame.height / (UIDevice.isiPad ? 2 : 0.5))
        confirmButton.name = "confirmButton"
        
        cancelButton = DecisionButtonSprite(text: cancel,
                                            color: UIColor(red: 9 / 255, green: 132 / 255, blue: 227 / 255, alpha: 1.0),
                                            iconImageName: nil)
        cancelButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: confirmButton.position.y)
        cancelButton.name = "cancelButton"
        
        messageLabel = SKLabelNode(text: message)
        messageLabel.fontName = UIFont.chatFont
        messageLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.chatFontSize
        messageLabel.fontColor = UIFont.chatFontColor
        messageLabel.position = CGPoint(
            x: 0,
            y: ((titleLabel.position.y - titleLabel.frame.size.height) - (confirmButton.position.y + confirmButton.frame.size.height)) / 3
        )
        messageLabel.preferredMaxLayoutWidth = K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale
        messageLabel.verticalAlignmentMode = .top
        messageLabel.numberOfLines = 0
        messageLabel.zPosition = 10
        messageLabel.addDropShadow()

        
        super.init()
        
        confirmButton.delegate = self
        cancelButton.delegate = self
        
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.messagePrompt
        
        backgroundSprite.addChild(titleLabel)
        backgroundSprite.addChild(messageLabel)
        backgroundSprite.addChild(confirmButton)
        backgroundSprite.addChild(cancelButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func animateShow(completion: @escaping (() -> Void)) {
        backgroundSprite.removeFromParent()
        
        addChild(backgroundSprite)
        
        Haptics.shared.addHapticFeedback(withStyle: .heavy)
        
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2),
        ])) {
            self.disableControls = false
            completion()
        }
    }
    
    func animateHide(completion: @escaping (() -> Void)) {
        disableControls = true

        run(SKAction.scale(to: 0, duration: 0.25)) {
            self.backgroundSprite.removeFromParent()
            completion()
        }
    }
        
    
    // MARK: - UI Controls
    
    func touchDown(in location: CGPoint) {
        guard !disableControls else { return }
        
        for node in nodes(at: location - position) {
            guard let node = node as? DecisionButtonSprite else { continue }

            node.touchDown()
        }

    }
    
    func touchUp() {
        confirmButton.touchUp()
        cancelButton.touchUp()
    }
    
    
    func didTapButton(in location: CGPoint) {
        guard !disableControls else { return }

        for node in nodes(at: location - position) {
            guard let node = node as? DecisionButtonSprite else { continue }
            
            node.tapButton()
        }
    }
    
    
}


// MARK: - DecisionButtonSpriteDelegate

extension ConfirmSprite: DecisionButtonSpriteDelegate {
    func buttonWasTapped(_ node: DecisionButtonSprite) {
        switch node.name {
        case "confirmButton":
            delegate?.didTapConfirm()
        case "cancelButton":
            delegate?.didTapCancel()
        default:
            print("Invalid button press.")
        }
    }
}
