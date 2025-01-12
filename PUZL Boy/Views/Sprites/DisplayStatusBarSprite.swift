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
    private let imageNaturalSize: CGFloat = 512
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
        
        backgroundBar.fillTexture = SKTexture(image: UIImage.gradientTextureDisplayIcon)
        backgroundBar.fillColor = fillColor
        backgroundBar.lineWidth = 3
        backgroundBar.strokeColor = .white
        backgroundBar.position = .zero

        imageNode.position = CGPoint(x: -iconSize, y: 0)
        imageNode.scale(to: CGSize(width: iconSize, height: iconSize))
        imageNode.zPosition = 5
        
        textNode.fontName = UIFont.gameFont
        textNode.fontSize = UIFont.gameFontSizeSmall
        textNode.position = CGPoint(x: 0, y: -14)
        textNode.zPosition = 10
        textNode.addDropShadow()
        
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
        textNode.updateShadow()
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
    
    func animateMoves(originalMoves: Int, newMoves: Int) {
        let speed: CGFloat = min(0.8 / CGFloat(newMoves), 0.05)
        var movesToIncrement = originalMoves
        
        let incrementAction = SKAction.run { [weak self] in
            movesToIncrement += 1
            self?.textNode.text = "\(movesToIncrement)"
            self?.textNode.updateShadow()
        }
        
        let animationGroup = SKAction.group([
            incrementAction,
            SKAction.scale(to: 1.25, duration: speed),
        ])
        
        let repeatAction = SKAction.repeat(SKAction.sequence([
            SKAction.wait(forDuration: speed),
            animationGroup,
            SKAction.scale(to: 1.0, duration: speed)
        ]), count: max(newMoves, 0))
        
        textNode.run(repeatAction)
    }
    
    func illuminateNode(pointLeft: Bool) {
        zPosition = K.ZPosition.chatDimOverlay + 10
        
        let hintarrow = SKSpriteNode(imageNamed: "hintarrow")
        hintarrow.setScale(0.75)
        hintarrow.position.x = pointLeft ? width : -width - iconSize / 2
        hintarrow.name = "hintarrow"

        if !pointLeft {
            hintarrow.xScale *= -1
        }
        
        let moveDistance: CGFloat = width / 2
        let animation = SKAction.sequence([
            SKAction.moveBy(x: pointLeft ? moveDistance : -moveDistance, y: 0, duration: 0.25),
            SKAction.moveBy(x: pointLeft ? -moveDistance : moveDistance, y: 0, duration: 0.1),
            SKAction.wait(forDuration: 0.5)
        ])

        addChild(hintarrow)
        
        hintarrow.run(SKAction.repeatForever(animation))
    }
    
    func deIlluminateNode() {
        zPosition = 0
        children.filter({ $0.name == "hintarrow" }).first?.removeFromParent()
    }
}
