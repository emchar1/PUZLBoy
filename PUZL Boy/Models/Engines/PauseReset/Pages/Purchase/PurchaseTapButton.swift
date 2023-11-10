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
        width: K.ScreenDimensions.size.width / 2 - 1.5 * PurchasePage.padding,
        height: K.ScreenDimensions.size.width / 3.5
    )
    
    private var nodeName: String { "PurchaseTapButton" + text }
    private var positionOrig: CGPoint {
        CGPoint(x: PurchaseTapButton.buttonSize.width / 2 + shadowOffset, y: -PurchaseTapButton.buttonSize.height / 2)
    }

    private let shadowOffset: CGFloat = 10
    private let backgroundColor: UIColor
    private var shadowColor: UIColor { backgroundColor.lightenColor(factor: 6) }

    private var price: Double
    private var text: String
    private(set) var type: TapButtonType
    private var image: String
    private var imageScale: CGFloat
    private var isAnimating = false
    private var isPressed = true
    var isDisabled = false {
        didSet {
            disabledOverlayNode.alpha = isDisabled ? 0.8 : 0
        }
    }
        
    private(set) var tappableAreaNode: SKShapeNode!
    private var sprite: SKShapeNode!
    private var disabledOverlayNode: SKShapeNode!
    
    weak var delegate: PurchaseTapButtonDelegate?
    
    enum TapButtonType {
        case add5Moves, skipLevel, add1Life, add25Lives, add100Lives, add1000Lives
    }
    
    
    // MARK: - Initialization
    
    init(price: Double, text: String, type: TapButtonType, color: UIColor, image: String, imageScale: CGFloat = 1) {
        self.price = price
        self.text = text
        self.type = type
        self.backgroundColor = color
        self.image = image
        self.imageScale = imageScale
        
        super.init()
        
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        let cornerRadius: CGFloat = 20
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency

        tappableAreaNode = SKShapeNode(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius)
        tappableAreaNode.position = positionOrig
        tappableAreaNode.fillColor = backgroundColor
        tappableAreaNode.fillTexture = SKTexture(image: UIImage.gradientTexturePurchaseButton)
        tappableAreaNode.strokeColor = .clear
        tappableAreaNode.lineWidth = 0
        tappableAreaNode.zPosition = 10
        tappableAreaNode.name = nodeName

        sprite = SKShapeNode(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius)
        sprite.position = positionOrig
        sprite.fillColor = backgroundColor
        sprite.fillTexture = SKTexture(image: UIImage.gradientTextureMenu)
        sprite.strokeColor = .clear
        sprite.lineWidth = 0
        sprite.addDropShadow(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius, shadowOffset: shadowOffset, shadowColor: shadowColor)
        
        disabledOverlayNode = SKShapeNode(rectOf: PurchaseTapButton.buttonSize, cornerRadius: cornerRadius)
        disabledOverlayNode.position = .zero
        disabledOverlayNode.fillColor = .systemGray
        disabledOverlayNode.strokeColor = .clear
        disabledOverlayNode.alpha = isDisabled ? 0.8 : 0
        disabledOverlayNode.zPosition = 30
                
        
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
        
        let priceLabel = SKLabelNode(text: price == 0 ? "FREE!" : currencyFormatter.string(from: NSNumber(value: price)))
        priceLabel.verticalAlignmentMode = .center
        priceLabel.horizontalAlignmentMode = .center
        priceLabel.fontName = UIFont.chatFont
        priceLabel.fontSize = UIFont.chatFontSizeLarge
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
        buttonLabelNode.fontSize = UIFont.gameFontSizeLarge
        buttonLabelNode.fontColor = UIFont.gameFontColor
        buttonLabelNode.addDropShadow()
        
        addChild(tappableAreaNode)
        addChild(sprite)
        sprite.addChild(disabledOverlayNode)
        sprite.addChild(cropNode)
        sprite.addChild(cropNodeFade)
        cropNode.addChild(buttonLabelNode)
        cropNode.addChild(priceBackground)
        cropNodeFade.addChild(imageNode)
        priceBackground.addChild(priceLabel)
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isDisabled else {
            ButtonTap.shared.tap(type: .buttontap6)
            return
        }
        
        guard !isAnimating else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        isPressed = true
        
        tappableAreaNode.run(SKAction.move(to: tappableAreaNode.position + CGPoint(x: -shadowOffset, y: -shadowOffset), duration: 0))
        sprite.run(SKAction.group([
            SKAction.move(to: sprite.position + CGPoint(x: -shadowOffset, y: -shadowOffset), duration: 0),
            SKAction.run { [unowned self] in
                sprite.hideShadow(animationDuration: 0, completion: nil)
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
            SKAction.run { [unowned self] in
                sprite.showShadow(shadowOffset: shadowOffset, animationDuration: 0.2, completion: nil)
            }
        ])) { [unowned self] in
            isAnimating = false
        }
    }
    
    func tapButton(in location: CGPoint) {
        guard isPressed else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        ButtonTap.shared.tap(type: .buttontap1, hapticStyle: .heavy)
        delegate?.didTapButton(self)
    }
}
