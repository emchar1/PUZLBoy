//
//  DisplayLivesSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/27/22.
//

import SpriteKit

class DisplayLivesSprite: SKNode {
    
    // MARK: - Properties
    
    let width: CGFloat = 140
    private let iconSize: CGFloat = 90
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
        

        imageNode.position = CGPoint(x: -iconSize + 20, y: 0)
        imageNode.scale(to: CGSize(width: iconSize * 946 / 564, height: iconSize))
        
        textNode.fontName = UIFont.gameFont
        textNode.fontSize = UIFont.gameFontSizeSmall
        textNode.position = CGPoint(x: 0, y: -14)
        
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
    }
    
    func appendNode(_ node: SKNode) {
        imageNode.addChild(node)
    }
    
    func pulseImage() {
        let scaleUp = SKAction.scale(to: CGSize(width: iconSize * 2, height: iconSize * 2), duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.2)
        let scaleDown = SKAction.scale(to: CGSize(width: iconSize, height: iconSize), duration: 0.3)
        
        imageNode.run(SKAction.sequence([scaleUp, wait, scaleDown]))
    }
    
    func removeNode() {
        imageNode.removeAllChildren()
    }
}
