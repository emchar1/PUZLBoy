//
//  ChatDecisionSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/5/24.
//

import SpriteKit

protocol ChatDecisionSpriteDelegate: AnyObject {
    func buttonWasTapped(_ node: ChatDecisionSprite)
    func buttonHasAppeared(_ node: ChatDecisionSprite)
    func buttonHasDisappeared(_ node: ChatDecisionSprite, didGetTapped: Bool)
}

class ChatDecisionSprite: SKNode {
    
    // MARK: - Properties
    
    static let tappableAreaName = "ChatDecisionSpriteTappableArea"

    private(set) var isVisible: Bool = false
    private var isPressed: Bool = false
    private var isDisabled: Bool = false
    private var text: String
    private var buttonSize: CGSize
    private var topSpriteColor: UIColor

    private(set) var tappableAreaNode: SKShapeNode!
    private var sprite: SKShapeNode!
    private var topSprite: SKShapeNode!
    private var textNode: SKLabelNode!

    weak var delegate: ChatDecisionSpriteDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, buttonSize: CGSize, color: UIColor) {
        self.text = text
        self.buttonSize = buttonSize
        self.topSpriteColor = color
        
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
        topSprite.fillColor = topSpriteColor
        topSprite.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        topSprite.strokeColor = .white
        topSprite.lineWidth = 4
        topSprite.position = .zero

        textNode = SKLabelNode(text: text)
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIFont.chatFontSizeMedium
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
        
        let spriteScaleAction = SKAction.scale(to: 0.95, duration: 0)
        spriteScaleAction.timingMode = .easeOut

        topSprite.run(spriteScaleAction)
        tappableAreaNode.run(spriteScaleAction)
    }
    
    func touchUp() {
        isPressed = false

        let spriteScaleAction = SKAction.scale(to: 1, duration: 0.1)
        spriteScaleAction.timingMode = .easeOut

        topSprite.run(spriteScaleAction)
        tappableAreaNode.run(spriteScaleAction)
    }
    
    func tapButton(in location: CGPoint, type: ButtonTap.ButtonType = .buttontap1) {
        guard !isDisabled else { return }
        guard isPressed else { return }
        
        isDisabled = true

        delegate?.buttonWasTapped(self)
        ButtonTap.shared.tap(type: type)
    }
    
    
    // MARK: - Helper Functions
    
    func setButtonColor(color topSpriteColor: UIColor) {
        self.topSpriteColor = topSpriteColor
        
        topSprite.fillColor = self.topSpriteColor
    }
    
    func setButtonText(text: String) {
        self.text = text

        textNode.text = self.text
        textNode.updateShadow()
    }
    
    func animateAppear(toNode node: SKNode) {
        alpha = 1.0
        isVisible = true
        delegate?.buttonHasAppeared(self)
        
        //Just in case it already has a parent, prevents crashing.
        removeAllActions()
        removeFromParent()
        
        node.addChild(self)

        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
        ]))
    }
    
    func animateDisappear(didGetTapped: Bool) {
        let duration: TimeInterval = 2
        
        let scaleAction = didGetTapped ? SKAction.sequence([
            SKAction.scale(to: 1.1, duration: duration * 0.125),
            SKAction.scale(to: 0.95, duration: duration * 0.1),
            
            SKAction.scale(to: 1.05, duration: duration * 0.15),
            SKAction.scale(to: 0.96, duration: duration * 0.125),
            
            SKAction.scale(to: 1.025, duration: duration * 0.175),
            SKAction.scale(to: 0.98, duration: duration * 0.15),
            
            SKAction.scale(to: 1.0, duration: duration * 0.175)
        ]) : SKAction.scale(to: 0.85, duration: duration)
        
        let fadeAction = didGetTapped ? SKAction.sequence([
            SKAction.wait(forDuration: duration * 0.95),
            SKAction.fadeOut(withDuration: duration * 0.05)
        ]) : SKAction.fadeOut(withDuration: duration)
        
        scaleAction.timingMode = .easeOut
        fadeAction.timingMode = .easeOut
        
        run(SKAction.sequence([
            SKAction.group([scaleAction, fadeAction]),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            isDisabled = false
            isVisible = false
            delegate?.buttonHasDisappeared(self, didGetTapped: didGetTapped)
        }
    }
}
