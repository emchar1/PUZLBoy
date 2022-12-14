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
        
        let gradient: UIImage = UIImage.gradientImage(withBounds: CGRect(x: 0, y: 0,
                                                                         width: K.ScreenDimensions.iPhoneWidth,
                                                                         height: K.ScreenDimensions.height),
                                                      startPoint: CGPoint(x: 0.5, y: 0.5),
                                                      endPoint: CGPoint(x: 0.5, y: 1),
                                                      colors: [UIColor(red: 150 / 255, green: 150 / 255, blue: 150 / 255, alpha: 1).cgColor,
                                                               UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor])
        
        backgroundBar.fillTexture = SKTexture(image: gradient)
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
}
