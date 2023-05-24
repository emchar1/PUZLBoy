//
//  PurchaseTapButton.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/22/23.
//

import SpriteKit

protocol PurchaseTapButtonDelegate: AnyObject {
    func didTapButton(_ buttonNode: PurchaseTapButton)
}

class PurchaseTapButton: SKNode {
    
    // MARK: - Properties
    
    static let buttonSize = CGSize(
        width: K.ScreenDimensions.iPhoneWidth / 2 - 1.5 * PurchasePage.padding,
        height: K.ScreenDimensions.iPhoneWidth / 3.5
    )
    
    private var nodeName: String { "PurchaseTapButton" + text }
    private var positionOrig: CGPoint {
        CGPoint(x: PurchaseTapButton.buttonSize.width / 2 + shadowOffset, y: -PurchaseTapButton.buttonSize.height / 2)
    }

    private let shadowOffset: CGFloat = 10
    private let backgroundColor: UIColor = UIColor(red: 0 / 255, green: 168 / 255, blue: 86 / 255, alpha: 1.0)
    private let backgroundShadowColor: UIColor = .darkGray

    private var text: String
    private var isAnimating = false
    private var isPressed = true
        
    private(set) var tappableAreaNode: SKShapeNode!
    private var sprite: SKShapeNode!
    
    weak var delegate: PurchaseTapButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(price: Double, text: String, image: String, imageScale: CGFloat = 1) {
        self.text = text
                
        super.init()
        
        let cornerRadius: CGFloat = 20
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency

        tappableAreaNode = SKShapeNode(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius)
        tappableAreaNode.position = positionOrig
        tappableAreaNode.fillColor = backgroundColor
        tappableAreaNode.fillTexture = SKTexture(image: UIImage.purchaseButtonGradientTexture)
        tappableAreaNode.strokeColor = .clear
        tappableAreaNode.lineWidth = 0
        tappableAreaNode.zPosition = 10
        tappableAreaNode.name = nodeName

        sprite = SKShapeNode(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius)
        sprite.position = positionOrig
        sprite.fillColor = backgroundColor
        sprite.fillTexture = SKTexture(image: UIImage.menuGradientTexture)
        sprite.strokeColor = .clear
        sprite.lineWidth = 0
        sprite.addDropShadow(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius, shadowOffset: shadowOffset)
                
        
        let maskNode = SKShapeNode(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius)
        maskNode.fillColor = .orange
        maskNode.strokeColor = .white
        maskNode.lineWidth = 0

        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.zPosition = 20
        
        let cropNodeFade = SKCropNode()
        cropNodeFade.maskNode = maskNode
        
        let priceBackground = SKShapeNode(rectOf: CGSize(width: PurchaseTapButton.buttonSize.width, height: UIDevice.isiPad ? 120 : 80))
        priceBackground.position = positionOrig * CGPoint(x: -1, y: -1) + CGPoint(x: priceBackground.frame.size.width / 6, y: -priceBackground.frame.size.height * 2 / 3)
        priceBackground.fillColor = .red
        priceBackground.strokeColor = .white
        priceBackground.lineWidth = 0
        priceBackground.zRotation = .pi / 6
        
        let priceLabel = SKLabelNode(text: currencyFormatter.string(from: NSNumber(value: price)))
        priceLabel.verticalAlignmentMode = .center
        priceLabel.horizontalAlignmentMode = .center
        priceLabel.fontName = UIFont.chatFont
        priceLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        priceLabel.fontColor = UIFont.chatFontColor
        priceLabel.addDropShadow()

        let imageNode = SKSpriteNode(imageNamed: image)
        imageNode.anchorPoint = CGPoint(x: 0.3, y: 0.5)
        imageNode.setScale(imageScale)

        let buttonLabelNode = SKLabelNode(text: text.uppercased())
        buttonLabelNode.position = CGPoint(x: 0, y: -PurchaseTapButton.buttonSize.height / 2 + 20)
        buttonLabelNode.verticalAlignmentMode = .bottom
        buttonLabelNode.horizontalAlignmentMode = .center
        buttonLabelNode.fontName = UIFont.gameFont
        buttonLabelNode.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        buttonLabelNode.fontColor = UIFont.gameFontColor
        buttonLabelNode.addDropShadow()
        
        addChild(tappableAreaNode)
        addChild(sprite)
        sprite.addChild(cropNode)
        sprite.addChild(cropNodeFade)
        cropNode.addChild(buttonLabelNode)
        cropNode.addChild(priceBackground)
        cropNodeFade.addChild(imageNode)
        priceBackground.addChild(priceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isAnimating else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        isPressed = true
        
        tappableAreaNode.run(SKAction.move(to: tappableAreaNode.position + CGPoint(x: -shadowOffset, y: -shadowOffset), duration: 0))
        sprite.run(SKAction.group([
            SKAction.move(to: sprite.position + CGPoint(x: -shadowOffset, y: -shadowOffset), duration: 0),
            SKAction.run {
                self.sprite.hideShadow(animationDuration: 0, completion: nil)
            }
        ]))
    }
    
    func touchUp() {
        guard isPressed else { return }
        
        isAnimating = true
        isPressed = false
        
        tappableAreaNode.run(SKAction.move(to: positionOrig, duration: 0.2))
        sprite.run(SKAction.group([
            SKAction.move(to: positionOrig, duration: 0.2),
            SKAction.run {
                self.sprite.showShadow(shadowOffset: self.shadowOffset, animationDuration: 0.2, completion: nil)
            }
        ])) {
            self.isAnimating = false
        }
    }
    
    func tapButton(in location: CGPoint) {
        guard isPressed else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        ButtonTap.shared.tap(type: .buttontap1)
        self.delegate?.didTapButton(self)
    }
}
