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
    private(set) var levelLabel: SKLabelNode
    private(set) var statusLives: DisplayLivesSprite
    private(set) var statusHealth: DisplayStatusBarSprite
    private(set) var statusMoves: DisplayStatusBarSprite
    private(set) var statusHammers: DisplayStatusBarSprite
    private(set) var statusSwords: DisplayStatusBarSprite
    
    private var heartsAtlas: SKTextureAtlas
    private var heartsTextures: [SKTexture]
    
    
    // MARK: - Initialization
    
    init(topYPosition: CGFloat, bottomYPosition: CGFloat, margin: CGFloat) {
        sprite = SKSpriteNode()
        sprite.zPosition = K.ZPosition.display
        
        statusLives = DisplayLivesSprite(icon: "Run (6)", amount: 3)
        statusLives.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - statusLives.width / 2, y: topYPosition + margin + statusLives.width + 18)
        
        statusHealth = DisplayStatusBarSprite(icon: "iconHeart", amount: 99, fillColor: .cyan)
        statusHealth.position = CGPoint(x: margin + statusHealth.width, y: topYPosition + margin + statusHealth.width / 2)

        statusMoves = DisplayStatusBarSprite(icon: "iconBoot", amount: 99, fillColor: .cyan)
        statusMoves.position = CGPoint(x: margin + statusMoves.width, y: topYPosition + margin)

        statusHammers = DisplayStatusBarSprite(icon: "iconHammer", amount: 99, fillColor: .yellow)
        statusHammers.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - statusHammers.width, y: topYPosition + margin + statusHammers.width / 2)

        statusSwords = DisplayStatusBarSprite(icon: "iconSword", amount: 99, fillColor: .yellow)
        statusSwords.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - statusSwords.width, y: topYPosition + margin)

        levelLabel = SKLabelNode(text: nil)
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.verticalAlignmentMode = .top
        levelLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - margin, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin)
        levelLabel.fontName = UIFont.gameFont
        levelLabel.fontSize = UIFont.gameFontSizeSmall
        levelLabel.fontColor = UIFont.gameFontColor
        
        heartsAtlas = SKTextureAtlas(named: "_heart")
        heartsTextures = []

        for i in 0...5 {
            heartsTextures.append(heartsAtlas.textureNamed("heart\(i)"))
        }
        
        addToScene()
    }
    
    
    // MARK: - Helper Functions
    
    func setLabels(level: String, lives: String, moves: String, health: String, inventory: Inventory) {
        levelLabel.text = "LEVEL \(level)"
        
        statusLives.updateAmount(Int(lives) ?? 99)
        statusMoves.updateAmount(Int(moves) ?? 99)
        statusHealth.updateAmount(Int(health) ?? 99)
        statusHammers.updateAmount(inventory.hammers)
        statusSwords.updateAmount(inventory.swords)
    }
    
    func drainHealth() {
        let animation = SKAction.animate(with: heartsTextures, timePerFrame: 0.1)
        let heartsNode = SKSpriteNode(texture: heartsTextures[0])
        heartsNode.zPosition = K.ZPosition.displayAnimation
        heartsNode.run(animation)
        
        statusHealth.appendNode(heartsNode)
    }

    private func addToScene() {
        sprite.addChild(levelLabel)
        
        sprite.addChild(statusLives)
        sprite.addChild(statusHealth)
        sprite.addChild(statusMoves)
        sprite.addChild(statusHammers)
        sprite.addChild(statusSwords)
    }
}
