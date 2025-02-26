//
//  CircularProgressBar.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/26/25.
//

import SpriteKit

class CircularProgressBar: SKNode {
    
    // MARK: - Properties
    
    private var radius: CGFloat = 100
    private var width: CGFloat = 24
    private var circleNode: SKShapeNode
    private var swordImage: SKSpriteNode
    private var multiplierLabel: SKLabelNode
    private var multiplier: Int = 2
    
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
    
    override init() {
        circleNode = SKShapeNode(circleOfRadius: 0)
        circleNode.lineWidth = width
        circleNode.lineCap = .round
        circleNode.strokeColor = .green
        circleNode.zPosition = 0
        
        swordImage = SKSpriteNode(imageNamed: "sword")
        swordImage.zPosition = 5
        
        multiplierLabel = SKLabelNode(text: "\(multiplier)X")
        multiplierLabel.fontName = UIFont.gameFont
        multiplierLabel.fontSize = UIFont.gameFontSizeExtraLarge
        multiplierLabel.fontColor = .yellow
        multiplierLabel.zPosition = 10
        multiplierLabel.verticalAlignmentMode = .center
        multiplierLabel.setScale(0)
        multiplierLabel.addHeavyDropShadow()
        
        super.init()
        
        let circlePath = SKShapeNode(circleOfRadius: radius)
        circlePath.lineWidth = width
        circlePath.alpha = 0.2
        
        circleNode.addChild(circlePath)
        
        addChild(circleNode)
        addChild(swordImage)
        addChild(multiplierLabel)
        
        alpha = 0.25
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func setRemainingTime(_ remainingTime: TimeInterval) {
        if self.remainingTime <= 0 && remainingTime > 0 {
            run(SKAction.fadeIn(withDuration: 0.25))
            
            didAdjustMultiplier()
        }
        else if self.remainingTime > 0 && remainingTime <= 0 {
            run(SKAction.fadeAlpha(to: 0.25, duration: 0.25))

            didAdjustMultiplier(scaleTo: 0)
        }
        
        self.remainingTime = remainingTime
    }
    
    func setMultiplier(_ multiplier: Int) {
        guard multiplier >= 2 && multiplier <= 3, self.multiplier != multiplier else { return }
        
        if multiplier == 2 {
            multiplierLabel.text = "2X"
            multiplierLabel.fontColor = .yellow
        }
        else if multiplier == 3 {
            multiplierLabel.text = "3X"
            multiplierLabel.fontColor = .cyan
        }
        
        didAdjustMultiplier()
        
        self.multiplier = multiplier
    }
    
    
    // MARK: - Helper Functions
    
    private func didAdjustMultiplier(scaleTo: CGFloat = 1) {
        multiplierLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.scale(to: scaleTo, duration: 0.25)
        ]))
    }
    
    
}
