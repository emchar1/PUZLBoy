//
//  DisplayStatusBarSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/12/22.
//

import SpriteKit

class DisplayStatusBarSprite: SKNode {
    
    // MARK: - Properties
    
    let width: CGFloat = 140
    private let iconSize: CGFloat = 80
    private let backgroundBar: SKShapeNode
    private let imageNode: SKSpriteNode
    private let textNode: SKLabelNode
    private let icon: String
    private var amount: Int

    
    // MARK: - Initialization
    
    init(icon: String, amount: Int, fillColor: UIColor) {
        self.backgroundBar = SKShapeNode(rectOf: CGSize(width: width, height: 40), cornerRadius: 12)
        self.imageNode = SKSpriteNode(imageNamed: icon)
        self.textNode = SKLabelNode(text: "\(amount)")
        self.icon = icon
        self.amount = amount

        super.init()
        
        let customGradient: UIImage = UIImage.createGradientImage(startPoint: CGPoint(x: 0.5, y: 0.5), endPoint: CGPoint(x: 0.5, y: 1), topColorWhiteValue: 150, bottomColorWhiteValue: 200)
        
        backgroundBar.fillTexture = SKTexture(image: customGradient)
        backgroundBar.fillColor = fillColor
        backgroundBar.lineWidth = 3
        backgroundBar.strokeColor = .white
        backgroundBar.position = .zero

        imageNode.position = CGPoint(x: -iconSize, y: 0)
        imageNode.scale(to: CGSize(width: iconSize, height: iconSize))
        
        textNode.fontName = UIFont.gameFont
        textNode.fontSize = UIFont.gameFontSizeSmall
        textNode.position = CGPoint(x: 0, y: -14)
        
        addChild(backgroundBar)
        addChild(imageNode)
        addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper Functions
    
    func updateAmount(_ newAmount: Int) {
        self.amount = newAmount
        
        textNode.text = "\(newAmount)"
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
    
    func illuminateNode(pointLeft: Bool) {
        zPosition = K.ZPosition.chatDimOverlay + 10
        
        let goldArrow = SKSpriteNode(imageNamed: "goldarrow")
        goldArrow.setScale(width / 518 * 3 / 4)
        goldArrow.position.x = pointLeft ? width : -width - iconSize / 2
        goldArrow.name = "goldarrow"

        if !pointLeft {
            goldArrow.xScale *= -1
        }
        
        let moveDistance: CGFloat = width / 2
        let animation = SKAction.sequence([
            SKAction.moveBy(x: pointLeft ? moveDistance : -moveDistance, y: 0, duration: 0.25),
            SKAction.moveBy(x: pointLeft ? -moveDistance : moveDistance, y: 0, duration: 0.1),
            SKAction.wait(forDuration: 0.5)
        ])

        addChild(goldArrow)
        
        goldArrow.run(SKAction.repeatForever(animation))
    }
    
    func deIlluminateNode() {
        zPosition = 0
        
        for goldArrow in children {
            if goldArrow.name == "goldarrow" {
                goldArrow.removeFromParent()
            }
        }
    }
}
