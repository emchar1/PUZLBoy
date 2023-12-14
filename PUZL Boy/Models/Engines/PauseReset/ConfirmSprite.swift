//
//  ConfirmSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/26/23.
//

import SpriteKit

protocol ConfirmSpriteDelegate: AnyObject {
    func didTapConfirm(_ confirmSprite: ConfirmSprite)
    func didTapCancel(_ confirmSprite: ConfirmSprite)
}

class ConfirmSprite: SKNode {
    
    // MARK: - Properties
        
    private var disableControls: Bool = true
    private var title: String
    private var message: String
    private var confirm: String
    private var cancel: String
    
    private var messageLabel: SKLabelNode!
    private var backgroundSprite: SKShapeNode!
    private var confirmButton: DecisionButtonSprite!
    private var cancelButton: DecisionButtonSprite!
    
    weak var delegate: ConfirmSpriteDelegate?

    
    // MARK: - Initialization
    
    init(title: String, message: String, confirm: String, cancel: String) {
        self.title = title
        self.message = message
        self.confirm = confirm
        self.cancel = cancel
        
        super.init()
        
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
        zPosition = K.ZPosition.messagePrompt
        
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit ConfirmSprite")
    }
    
    private func setupSprites() {
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.size.width, height: K.ScreenDimensions.size.width / 2),
                                       cornerRadius: 20)
        backgroundSprite.fillColor = .gray
        backgroundSprite.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(UIDevice.spriteScale)
        
        let titleLabel = SKLabelNode(text: title.uppercased())
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeLarge
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.position = CGPoint(x: 0, y: (backgroundSprite.frame.height - titleLabel.frame.height) / (2 * UIDevice.spriteScale))
        titleLabel.verticalAlignmentMode = .top
        titleLabel.zPosition = 10
        titleLabel.addHeavyDropShadow()
        
        confirmButton = DecisionButtonSprite(text: confirm, color: DecisionButtonSprite.colorRed, iconImageName: nil)
        confirmButton.position = CGPoint(
            x: -K.ScreenDimensions.size.width / 4,
            y: (-backgroundSprite.frame.height + confirmButton.buttonSize.height + titleLabel.frame.height) / (2 * UIDevice.spriteScale))
        confirmButton.name = "confirmButton"
        confirmButton.delegate = self

        cancelButton = DecisionButtonSprite(text: cancel, color: DecisionButtonSprite.colorBlue, iconImageName: nil)
        cancelButton.position = CGPoint(x: K.ScreenDimensions.size.width / 4, y: confirmButton.position.y)
        cancelButton.name = "cancelButton"
        cancelButton.delegate = self

        messageLabel = SKLabelNode(text: message)
        messageLabel.fontName = UIFont.chatFont
        messageLabel.fontSize = UIFont.chatFontSizeLarge
        messageLabel.fontColor = UIFont.chatFontColor
        messageLabel.position = CGPoint(
            x: 0,
            y: ((titleLabel.position.y - titleLabel.frame.size.height) - (confirmButton.position.y + confirmButton.frame.size.height)) / 3
        )
        messageLabel.preferredMaxLayoutWidth = K.ScreenDimensions.size.width * UIDevice.spriteScale
        messageLabel.verticalAlignmentMode = .top
        messageLabel.numberOfLines = 0
        messageLabel.zPosition = 10
        messageLabel.addDropShadow()

        addChild(backgroundSprite)
        backgroundSprite.addChild(titleLabel)
        backgroundSprite.addChild(messageLabel)
        backgroundSprite.addChild(confirmButton)
        backgroundSprite.addChild(cancelButton)
    }
    
    
    // MARK: - Functions
    
    func animateShow(newMessage: String? = nil, completion: @escaping (() -> Void)) {
        if let newMessage = newMessage {
            messageLabel.text = newMessage
            messageLabel.updateShadow()
        }
        
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2),
        ])) { [unowned self] in
            disableControls = false
            completion()
        }
    }
    
    func animateHide(completion: @escaping (() -> Void)) {
        disableControls = true

        run(SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ])) {
            completion()
        }
    }
        
    
    // MARK: - UI Controls
    
    func touchDown(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard node.name == DecisionButtonSprite.tappableAreaName else { continue }
            guard let decisionSprite = node.parent as? DecisionButtonSprite else { continue }
            
            decisionSprite.touchDown(in: location)
        }
    }
    
    func touchUp() {
        confirmButton.touchUp()
        cancelButton.touchUp()
    }
    
    
    func didTapButton(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard node.name == DecisionButtonSprite.tappableAreaName else { continue }
            guard let decisionSprite = node.parent as? DecisionButtonSprite else { continue }
            
            let buttonType: ButtonTap.ButtonType = decisionSprite == cancelButton ? .buttontap6 : .buttontap1
            
            decisionSprite.tapButton(in: location, type: buttonType)
        }
    }
    
    
}


// MARK: - DecisionButtonSpriteDelegate

extension ConfirmSprite: DecisionButtonSpriteDelegate {
    func buttonWasTapped(_ node: DecisionButtonSprite) {
        switch node {
        case let decisionSprite where decisionSprite == confirmButton:
            delegate?.didTapConfirm(self)
        case let decisionSprite where decisionSprite == cancelButton:
            delegate?.didTapCancel(self)
        default:
            print("Invalid button press.")
        }
    }
}
