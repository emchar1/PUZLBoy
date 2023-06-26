//
//  PartyResultsLineItemSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 6/23/23.
//

import SpriteKit

class PartyResultsLineItemSprite: SKNode {
    
    // MARK: - Properties
    
    static let iconSize: CGFloat = 400 * (UIDevice.isiPad ? 0.52 : 0.36)
    static let height: CGFloat = iconSize * 0.75
    
    private var numberFormatter: NumberFormatter
    private var iconName: String?
    private var iconDescription: String
    private var amount: Int
    
    private var amountLabel: SKLabelNode
    
    
    // MARK: - Initialization
    
    init(iconName: String?, iconDescription: String, amount: Int) {
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        
        self.iconName = iconName
        self.iconDescription = iconDescription
        self.amount = amount
        
        self.amountLabel = SKLabelNode(text: numberFormatter.string(from: NSNumber(value: amount)) ?? "XXX")
        
        super.init()
        
        let lrBorder: CGFloat = 40
        let backgroundSprite = SKSpriteNode(color: .clear, size: CGSize(width: K.ScreenDimensions.iPhoneWidth,
                                                                        height: PartyResultsLineItemSprite.height))
        backgroundSprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        backgroundSprite.position = .zero
        
        let iconNode = iconName == nil ? SKSpriteNode() : SKSpriteNode(imageNamed: iconName!)
        iconNode.scale(to: CGSize(width: PartyResultsLineItemSprite.iconSize, height: PartyResultsLineItemSprite.iconSize))
        iconNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        iconNode.position.x = lrBorder
        
        let descriptionLabel = SKLabelNode(text: "\(iconDescription.uppercased()):")
        descriptionLabel.position = CGPoint(x: lrBorder + (iconName == nil ? lrBorder : PartyResultsLineItemSprite.iconSize), y: 0)
        descriptionLabel.fontName = UIFont.gameFont
        descriptionLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        descriptionLabel.fontColor = UIFont.gameFontColor
        descriptionLabel.horizontalAlignmentMode = .left
        descriptionLabel.verticalAlignmentMode = .center
        descriptionLabel.zPosition = 10
        descriptionLabel.addDropShadow()
        
        amountLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - 2 * lrBorder, y: 0)
        amountLabel.fontName = UIFont.gameFont
        amountLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        amountLabel.fontColor = UIFont.gameFontColor
        amountLabel.horizontalAlignmentMode = .right
        amountLabel.verticalAlignmentMode = .center
        amountLabel.zPosition = 10
        amountLabel.addDropShadow()
        
        alpha = 0
        
        addChild(backgroundSprite)
        backgroundSprite.addChild(iconNode)
        backgroundSprite.addChild(descriptionLabel)
        backgroundSprite.addChild(amountLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    ///Updates the amountLabel shadow to match the new amount.
    func updateAmount(_ newAmount: Int) {
        amountLabel.text = numberFormatter.string(from: NSNumber(value: newAmount)) ?? "YYY"
        amountLabel.updateShadow()
    }
    
    ///Animates the appearance of the line item sprite in fade/grow animation.
    func animateAppear(xPosition: CGFloat, completion: @escaping () -> Void) {
        run(SKAction.group([
            SKAction.fadeIn(withDuration: 0),
            SKAction.sequence([
                SKAction.moveTo(x: xPosition * 1.1, duration: 0.25),
                SKAction.moveTo(x: xPosition * 0.95, duration: 0.2),
                SKAction.moveTo(x: xPosition, duration: 0.2)
            ]),
            SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.25),
                SKAction.scale(to: 0.95, duration: 0.2),
                SKAction.scale(to: 1, duration: 0.2)
            ])
        ]), completion: completion)
    }
    
    ///Fades out, i.e. instantaneous alpha = 0
    func animateDisappear() {
        alpha = 0
    }
    
    ///Animates the amount change with a slight size increase, decrease, scale = 1.
    func animateAmount(_ newAmount: Int, completion: @escaping () -> Void) {
        //OLD METHOD
//        updateAmount(newAmount)
//
//        amountLabel.run(SKAction.sequence([
//            SKAction.scale(to: 2, duration: 0.125),
//            SKAction.scale(to: 0.95, duration: 0.125),
//            SKAction.scale(to: 1, duration: 0.25)
//        ]))
        
        
        
        
        //NEW METHOD
        let speed: CGFloat = min(0.8 / CGFloat(newAmount), 0.05)
        
        let incrementAction = SKAction.run { [unowned self] in
            updateAmount(newAmount)
        }
        
        let groupAction = SKAction.group([
            incrementAction,
            SKAction.scale(to: 1.25, duration: speed),
        ])
        
        let sequenceAction = SKAction.sequence([
            SKAction.wait(forDuration: speed),
            groupAction,
            SKAction.scale(to: 1.0, duration: speed)
        ])
        
        amountLabel.run(sequenceAction)
    }
    
    ///Animates text in typical y-position change, then fade out.
    func addTextAnimation(_ text: String) {
        let textSprite = SKLabelNode(text: text)
        textSprite.fontName = UIFont.gameFont
        textSprite.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        textSprite.horizontalAlignmentMode = .right
        textSprite.fontColor = .yellow
        textSprite.position = .zero
        textSprite.zPosition = K.ZPosition.itemsPoints
        textSprite.addDropShadow()
        
        amountLabel.addChild(textSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        textSprite.run(SKAction.group([moveUp, fadeOut])) {
            textSprite.removeFromParent()
        }
    }
}
