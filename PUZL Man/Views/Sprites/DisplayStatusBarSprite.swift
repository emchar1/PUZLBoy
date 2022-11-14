//
//  DisplayStatusBarSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 11/12/22.
//

import SpriteKit

class DisplayStatusBarSprite: SKNode {
    
    // MARK: - Properties
    
    let width: CGFloat = 140
    let backgroundBar: SKShapeNode
    let imageNode: SKSpriteNode
    let textNode: SKLabelNode
    let icon: String
    var amount: Int

    
    // MARK: - Initialization
    
    init(icon: String, amount: Int, fillColor: UIColor) {
        self.backgroundBar = SKShapeNode(rectOf: CGSize(width: width, height: 40), cornerRadius: 12)
        self.imageNode = SKSpriteNode(imageNamed: icon)
        self.textNode = SKLabelNode(text: "\(amount)")
        self.icon = icon
        self.amount = amount

        super.init()
        
        
        backgroundBar.fillTexture = SKTexture(imageNamed: "displayTexture")
        backgroundBar.fillColor = fillColor
        backgroundBar.lineWidth = 6
        backgroundBar.strokeColor = .lightGray
        backgroundBar.position = .zero

        imageNode.position = CGPoint(x: -80, y: 0)
        imageNode.scale(to: CGSize(width: 80, height: 80))
        
        textNode.fontName = "AvenirNext-BoldItalic"
        textNode.fontSize = 40
        textNode.position = CGPoint(x: 0, y: -14)
        
        addChild(backgroundBar)
        addChild(imageNode)
        addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAmount(_ newAmount: Int) {
        self.amount = newAmount
        
        textNode.text = "\(newAmount)"
    }
}
