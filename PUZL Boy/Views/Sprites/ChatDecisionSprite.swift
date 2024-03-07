//
//  ChatDecisionSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/5/24.
//

import SpriteKit

protocol ChatDecisionSpriteDelegate: AnyObject {
    func buttonWasTapped(_ node: ChatDecisionSprite)
}

class ChatDecisionSprite: SKNode {
    
    // MARK: - Properties
    
    static let tappableAreaName = "ChatDecisionSpriteTappableArea"

    let shadowOffset = CGPoint(x: -8, y: -8)
    
    private var isPressed: Bool = false
    private var isDisabled: Bool = false
    private var text: String
    private var buttonSize: CGSize

    private(set) var tappableAreaNode: SKShapeNode!
    private var sprite: SKShapeNode!
    private var topSprite: SKShapeNode!
    private var textNode: SKLabelNode!

    weak var delegate: ChatDecisionSpriteDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, buttonSize: CGSize) {
        self.text = text
        self.buttonSize = buttonSize
        
        super.init()
        
        setupSprites()
    }
            
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit ChatDecisionSprite: \(name ?? "")")
    }
    
    private func setupSprites() {
        let cornerRadius: CGFloat = 16
        
        tappableAreaNode = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        tappableAreaNode.fillColor = .clear
        tappableAreaNode.strokeColor = .white
        tappableAreaNode.lineWidth = 4
        tappableAreaNode.zPosition = 10
        tappableAreaNode.name = ChatDecisionSprite.tappableAreaName

        sprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        sprite.fillColor = .clear
        sprite.lineWidth = 0
        
        topSprite = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        topSprite.fillColor = .cyan
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
                
        addChild(tappableAreaNode)
        addChild(sprite)
        sprite.addChild(shadowSprite)
        sprite.addChild(topSprite)
        topSprite.addChild(textNode)
    }
    

    // MARK: - Touch Functions
    
    func touchDown(in location: CGPoint) {
        guard !isDisabled else { return }
        
        isPressed = true
        
        topSprite.position = shadowOffset
        tappableAreaNode.position = shadowOffset
    }
    
    func touchUp() {
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
    
    
    // MARK: - Helper Functions
    
    func animateAppear(toNode node: SKNode) {
        alpha = 1.0
        
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
        ]))
        
        //Just in case it already has a parent, prevents crashing.
        removeAllActions()
        removeFromParent()
        
        node.addChild(self)
    }
    
    func animateDisappear(didGetTapped: Bool) {
        let duration: TimeInterval = 2
        let scaleAction = SKAction.scale(to: didGetTapped ? 1.15 : 0.85, duration: duration)
        let fadeAction = didGetTapped ? SKAction.sequence([
            SKAction.wait(forDuration: duration * 0.9),
            SKAction.fadeOut(withDuration: duration * 0.1)
        ]) : SKAction.fadeOut(withDuration: duration)
        
        scaleAction.timingMode = .easeOut
        fadeAction.timingMode = .easeOut
        
        run(SKAction.sequence([
            SKAction.group([scaleAction, fadeAction]),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            isDisabled = false
        }
        
        isDisabled = true
    }
}
