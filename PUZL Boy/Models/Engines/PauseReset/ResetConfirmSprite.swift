//
//  ResetConfirmSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/18/23.
//

import SpriteKit

protocol ResetConfirmSpriteDelegate: AnyObject {
    func didTapConfirm()
    func didTapCancel()
}

class ResetConfirmSprite: SKNode {
    
    // MARK: - Properties
        
    private var disableControls: Bool = true
    private let messageLabel: SKLabelNode
    private(set) var backgroundSprite: SKShapeNode
    private(set) var confirmButton: DecisionButtonSprite
    private(set) var cancelButton: DecisionButtonSprite
    
    weak var delegate: ResetConfirmSpriteDelegate?

    
    // MARK: - Initialization
    
    override init() {
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth / 2),
                                       cornerRadius: 20)
        backgroundSprite.fillColor = .gray
        backgroundSprite.fillTexture = SKTexture(image: UIImage.chatGradientTexture)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(GameboardSprite.spriteScale)
        
        let titleLabel = SKLabelNode(text: "FEELING STUCK?")
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeExtraLarge : UIFont.gameFontSizeMedium
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.position = CGPoint(x: 0, y: backgroundSprite.frame.size.height / (UIDevice.isiPad ? 1.5 : 2) - titleLabel.frame.size.height / 2)
        titleLabel.verticalAlignmentMode = .top
        
        confirmButton = DecisionButtonSprite(text: "Restart",
                                             color: UIColor(red: 227 / 255, green: 32 / 255, blue: 9 / 255, alpha: 1.0),
                                             iconImageName: nil)
        confirmButton.position = CGPoint(x: -K.ScreenDimensions.iPhoneWidth / 4,
                                         y: -backgroundSprite.frame.size.height / 2 + titleLabel.frame.height / (UIDevice.isiPad ? 2 : 0.5))
        confirmButton.name = "confirmButton"
        
        cancelButton = DecisionButtonSprite(text: "Go Back",
                                            color: UIColor(red: 9 / 255, green: 132 / 255, blue: 227 / 255, alpha: 1.0),
                                            iconImageName: nil)
        cancelButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: confirmButton.position.y)
        cancelButton.name = "cancelButton"
        
        messageLabel = SKLabelNode(text: "Tap Restart to start over. You'll lose a life in the process.")
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
    
    func animateShow(livesRemaining: Int, completion: @escaping (() -> Void)) {
        backgroundSprite.removeFromParent()
        
        messageLabel.text = "Tap Restart to start over. Be warned: \(livesRemaining <= 0 ? "you have 0 lives left, so it'll be GAME OVER." : "you'll lose a life in the process.")"

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
    
    func touchUp(in location: CGPoint) {
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

extension ResetConfirmSprite: DecisionButtonSpriteDelegate {
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
