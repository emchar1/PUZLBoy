//
//  DisplayLivesSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/27/22.
//

import SpriteKit

class DisplayLivesSprite: SKNode {
    
    // MARK: - Properties
    
    let iconSize: CGFloat = 90
    private let imageNode: SKSpriteNode
    private let textNode: SKLabelNode
    private let icon: String
    private var amount: Int

    
    // MARK: - Initialization
    
    init(icon: String, amount: Int) {
        self.imageNode = SKSpriteNode(imageNamed: icon)
        self.textNode = SKLabelNode(text: "x\(amount)")
        self.icon = icon
        self.amount = amount

        super.init()
        

        imageNode.position = CGPoint(x: 0, y: 0)
        imageNode.scale(to: CGSize(width: iconSize, height: iconSize))
        
        textNode.fontName = UIFont.gameFont
        textNode.fontSize = UIFont.gameFontSizeSmall
        textNode.horizontalAlignmentMode = .right
        textNode.position = CGPoint(x: 50, y: -14)
        textNode.zPosition = 10
        textNode.addDropShadow()

        addChild(imageNode)
        addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper Functions
    
    func updateAmount(_ newAmount: Int) {
        self.amount = newAmount
        
        textNode.text = "x\(max(newAmount, 0))"
        textNode.updateShadow()
        adjustImageNodeXPosition()
    }
    
    private func adjustImageNodeXPosition() {
        imageNode.position.x = 20 - textNode.frame.width
    }
    
    func appendNode(_ node: SKNode) {
        imageNode.addChild(node)
    }
    
    func removeNode() {
        imageNode.removeAllChildren()
    }
    
    func pulseImage() {
        let scaleUp = SKAction.scale(to: CGSize(width: iconSize * Player.size.width / Player.size.height * 2, height: iconSize * 2), duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.2)
        let scaleDown = SKAction.scale(to: CGSize(width: iconSize * Player.size.width / Player.size.height, height: iconSize), duration: 0.3)

        imageNode.run(SKAction.sequence([scaleUp, wait, scaleDown]))
    }
    
    func animateLives(newLives: Int) {
        let speed: CGFloat = min(0.8 / CGFloat(newLives), 0.05)
        var livesToIncrement = 0
        
        let incrementAction = SKAction.run { [unowned self] in
            livesToIncrement += 1
            textNode.text = "x\(livesToIncrement)"
            textNode.updateShadow()
            adjustImageNodeXPosition()
        }
        
        let animationGroup = SKAction.group([
            incrementAction,
            SKAction.scale(to: 1.25, duration: speed),
        ])
        
        let repeatAction = SKAction.repeat(SKAction.sequence([
            SKAction.wait(forDuration: speed),
            animationGroup,
            SKAction.scale(to: 1.0, duration: speed)
        ]), count: max(newLives, 0))
        
        textNode.run(repeatAction)
    }
    
    func illuminateNode() {
        zPosition = K.ZPosition.chatDimOverlay + 10
    }
    
    func deIlluminateNode() {
        zPosition = 0
    }
}
