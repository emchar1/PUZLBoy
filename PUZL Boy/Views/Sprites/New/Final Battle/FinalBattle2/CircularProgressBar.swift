//
//  CircularProgressBar.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/26/25.
//

import SpriteKit

class CircularProgressBar: SKNode {
    
    // MARK: - Properties
    
    private let radius: CGFloat = 100
    private let lineWidth: CGFloat = 24
    private var multiplier: Int = 1
    
    private var circleNode: SKShapeNode
    private var swordImage: SKSpriteNode
    private var multiplierLabel: SKLabelNode
    
    private var remainingTime: TimeInterval = 0 {
        didSet {
            circleNode.path = UIBezierPath(arcCenter: .zero,
                                           radius: radius,
                                           startAngle: .pi / 2,
                                           endAngle: .pi / 2 - 2 * .pi * remainingTime,
                                           clockwise: false).cgPath
        }
    }
    
    
    // MARK: - Initialization
    
    init(chosenSword: ChosenSword) {
        circleNode = SKShapeNode(circleOfRadius: 0)
        circleNode.lineWidth = lineWidth
        circleNode.lineCap = .round
        circleNode.strokeColor = .green
        circleNode.alpha = 0
        circleNode.zPosition = 0
        
        swordImage = SKSpriteNode(imageNamed: chosenSword.imageName)
        swordImage.alpha = 0
        swordImage.zPosition = 5
        
        multiplierLabel = SKLabelNode(text: "1X")
        multiplierLabel.fontName = UIFont.gameFont
        multiplierLabel.fontSize = UIFont.gameFontSizeExtraLarge
        multiplierLabel.fontColor = UIFont.gameFontColor
        multiplierLabel.verticalAlignmentMode = .center
        multiplierLabel.setScale(0)
        multiplierLabel.zPosition = 10
        multiplierLabel.addHeavyDropShadow()
        
        super.init()
        
        zPosition = K.ZPosition.itemsPoints
        
        let circlePath = SKShapeNode(circleOfRadius: radius)
        circlePath.lineWidth = lineWidth
        circlePath.alpha = 0.2
        circlePath.zPosition = -5
        
        circleNode.addChild(circlePath)
        
        addChild(circleNode)
        addChild(swordImage)
        addChild(multiplierLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func setRemainingTime(_ percentage: TimeInterval) {
        if self.remainingTime <= 0 && percentage > 0 {
            didAdjustAlpha(1)
            didAdjustMultiplier(scaleTo: 1)
        }
        else if self.remainingTime > 0 && percentage <= 0 {
            didAdjustAlpha(0.25)
            didAdjustMultiplier(scaleTo: 0)
        }
        
        circleNode.strokeColor = getColor(from: percentage)
        
        self.remainingTime = percentage
    }
    
    func setMultiplier(_ multiplier: Int) {
        guard multiplier >= 2 && multiplier <= 3, self.multiplier != multiplier else { return }
        
        var fontColor: UIColor? = nil
        
        if multiplier == 2 {
            multiplierLabel.text = "2X"
            fontColor = .yellow
        }
        else if multiplier == 3 {
            multiplierLabel.text = "3X"
            fontColor = .cyan
        }
        
        multiplierLabel.updateShadow()
        
        didAdjustMultiplier(scaleTo: 1, color: fontColor)
        
        self.multiplier = multiplier
    }
    
    
    // MARK: - Helper Functions
    
    private func didAdjustAlpha(_ alpha: CGFloat) {
        let fadeDuration: TimeInterval = 0.25
        
        circleNode.run(SKAction.fadeAlpha(to: alpha, duration: fadeDuration))
        swordImage.run(SKAction.fadeAlpha(to: alpha, duration: fadeDuration))
    }
    
    private func didAdjustMultiplier(scaleTo: CGFloat, color: UIColor? = nil) {
        let scaleDuration: TimeInterval = 0.25
        let colorAction: SKAction = color != nil ? SKAction.colorize(with: color!, colorBlendFactor: 1, duration: 2 * scaleDuration) : SKAction.wait(forDuration: 2 * scaleDuration)
        
        multiplierLabel.run(SKAction.group([
            colorAction,
            SKAction.sequence([
                SKAction.scale(to: 2, duration: scaleDuration),
                SKAction.scale(to: scaleTo, duration: scaleDuration)
            ])
        ]))
    }
    
    /**
     Gets the bar color based on the percentage. Copied from StatusBarSprite.
     */
    private func getColor(from percentage: CGFloat) -> UIColor {
        return UIColor(red: percentage > 0.5 ? 2 * (1 - percentage) : 1, green: percentage < 0.5 ? 2 * percentage : 1, blue: 0, alpha: 1)
    }
    
    
}
