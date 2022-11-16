//
//  DisplaySprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/22/22.
//

import SpriteKit

class DisplaySprite {
    
    // MARK: - Properties
    
    private(set) var sprite: SKSpriteNode
    private var levelLabel: SKLabelNode
    private var statusLives: DisplayStatusBarSprite
    private var statusMoves: DisplayStatusBarSprite
    private var statusHammers: DisplayStatusBarSprite
    private var statusSwords: DisplayStatusBarSprite
    
    
    // MARK: - Initialization
    
    init(topYPosition: CGFloat, bottomYPosition: CGFloat, margin: CGFloat) {
        sprite = SKSpriteNode()
        sprite.zPosition = K.ZPosition.display
        
        statusLives = DisplayStatusBarSprite(icon: "iconHeart", amount: 99, fillColor: .cyan)
        statusLives.position = CGPoint(x: K.iPhoneWidth - statusLives.width, y: topYPosition + margin + statusLives.width / 2)

        statusMoves = DisplayStatusBarSprite(icon: "iconBoot", amount: 99, fillColor: .cyan)
        statusMoves.position = CGPoint(x: K.iPhoneWidth - statusMoves.width, y: topYPosition + margin)
        
        statusHammers = DisplayStatusBarSprite(icon: "iconHammer", amount: 99, fillColor: .yellow)
        statusHammers.position = CGPoint(x: margin + statusHammers.width, y: bottomYPosition - margin)
        
        statusSwords = DisplayStatusBarSprite(icon: "iconSword", amount: 99, fillColor: .yellow)
        statusSwords.position = CGPoint(x: K.iPhoneWidth - statusMoves.width, y: bottomYPosition - margin)
        
        levelLabel = SKLabelNode(text: nil)
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: margin, y: topYPosition + margin)
        levelLabel.fontName = "AvenirNext-BoldItalic"
        levelLabel.fontSize = 75
        levelLabel.fontColor = .white
        
        addToScene()
    }
    
    
    // MARK: - Helper Functions
    
    func setLabels(level: String, lives: String, moves: String, inventory: Inventory) {
        levelLabel.text = "LEVEL \(level)"
        
        statusLives.updateAmount(Int(lives) ?? 99)
        statusMoves.updateAmount(Int(moves) ?? 99)
        statusHammers.updateAmount(inventory.hammers)
        statusSwords.updateAmount(inventory.swords)
    }

    private func addToScene() {
        sprite.addChild(levelLabel)
        
        sprite.addChild(statusLives)
        sprite.addChild(statusMoves)
        sprite.addChild(statusHammers)
        sprite.addChild(statusSwords)
    }
}
