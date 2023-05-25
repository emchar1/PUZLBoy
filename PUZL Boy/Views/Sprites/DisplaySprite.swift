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
    
    enum DisplayStatusName: String {
        case lives, health, moves, hammers, swords
    }
    
    
    // MARK: - Initialization
    
    init(topYPosition: CGFloat, bottomYPosition: CGFloat, margin: CGFloat) {
        sprite = SKSpriteNode()
        sprite.zPosition = K.ZPosition.display
        
        statusLives = DisplayLivesSprite(icon: "iconPlayer", amount: 3)
        statusLives.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - K.ScreenDimensions.lrMargin - statusLives.iconSize,
                                       y: topYPosition + margin + 172)
        statusLives.name = DisplayStatusName.lives.rawValue
        
        statusHealth = DisplayStatusBarSprite(icon: "iconHeart", amount: 99, fillColor: .cyan)
        statusHealth.position = CGPoint(x: margin + statusHealth.width + K.ScreenDimensions.lrMargin,
                                        y: topYPosition + margin + statusHealth.width / 2 + 14)
        statusHealth.name = DisplayStatusName.health.rawValue
        
        statusMoves = DisplayStatusBarSprite(icon: "iconBoot", amount: 99, fillColor: .cyan)
        statusMoves.position = CGPoint(x: margin + statusMoves.width + K.ScreenDimensions.lrMargin,
                                       y: topYPosition + margin + 14)
        statusMoves.name = DisplayStatusName.moves.rawValue

        statusHammers = DisplayStatusBarSprite(icon: "iconHammer", amount: 99, fillColor: .yellow)
        statusHammers.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - K.ScreenDimensions.lrMargin - statusHammers.width,
                                         y: topYPosition + margin + statusHammers.width / 2 + 14)
        statusHammers.name = DisplayStatusName.hammers.rawValue

        statusSwords = DisplayStatusBarSprite(icon: "iconSword", amount: 99, fillColor: .yellow)
        statusSwords.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - K.ScreenDimensions.lrMargin - statusSwords.width,
                                        y: topYPosition + margin + 14)
        statusSwords.name = DisplayStatusName.swords.rawValue

        levelLabel = SKLabelNode(text: nil)
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.verticalAlignmentMode = .top
        levelLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - K.ScreenDimensions.lrMargin - margin,
                                      y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin)
        levelLabel.fontName = UIFont.gameFont
        levelLabel.fontSize = UIFont.gameFontSizeSmall
        levelLabel.fontColor = UIFont.gameFontColor
        levelLabel.zPosition = 10
        levelLabel.addDropShadow()
        
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
        levelLabel.updateShadow()
        
        statusLives.updateAmount(Int(lives) ?? 99)
        statusMoves.updateAmount(Int(moves) ?? 99)
        statusHealth.updateAmount(Int(health) ?? 99)
        statusHammers.updateAmount(inventory.hammers)
        statusSwords.updateAmount(inventory.swords)
    }
    
    func animateScores(movesScore: Int, inventoryScore: Int, usedContinue: Bool) {
        if inventoryScore > 0 {
            ScoringEngine.addScoreAnimation(score: inventoryScore,
                                            usedContinue: usedContinue,
                                            originSprite: statusSwords,
                                            location: CGPoint(x: statusSwords.frame.width / 2, y: 30))
        }
        
        if movesScore > 0 {
            ScoringEngine.addScoreAnimation(score: movesScore,
                                            usedContinue: usedContinue,
                                            originSprite: statusMoves,
                                            location: CGPoint(x: statusMoves.frame.width / 2, y: 0))
        }
    }
    
    func drainHealth() {
        let animation = SKAction.animate(with: heartsTextures, timePerFrame: 0.1)
        let heartsNode = SKSpriteNode(texture: heartsTextures[0])
        heartsNode.zPosition = 50 //Actually 450 because parent node is at 400, and the 50 gets added to it.
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
