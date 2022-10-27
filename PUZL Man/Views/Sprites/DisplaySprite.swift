//
//  DisplaySprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/22/22.
//

import SpriteKit

class DisplaySprite {
    
    // MARK: - Properties
    
    var sprite: SKSpriteNode
    var levelLabel: SKLabelNode
    var movesRemainingLabel: SKLabelNode
    var gemsRemainingLabel: SKLabelNode
    var exitAvailableLabel: SKLabelNode
    var gameOverLabel: SKLabelNode
    
    
    // MARK: - Initialization
    
    init() {
        sprite = SKSpriteNode()
        
        levelLabel = SKLabelNode(text: "LV: ")
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: K.width / 3, y: 600)
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontSize = 48
        levelLabel.fontColor = .red

        movesRemainingLabel = SKLabelNode(text: "Moves: ")
        movesRemainingLabel.horizontalAlignmentMode = .left
        movesRemainingLabel.position = CGPoint(x: K.width / 3, y: 540)
        movesRemainingLabel.fontName = "AvenirNext-Bold"
        movesRemainingLabel.fontSize = 48
        movesRemainingLabel.fontColor = .red

        gemsRemainingLabel = SKLabelNode(text: "Gems: ")
        gemsRemainingLabel.horizontalAlignmentMode = .left
        gemsRemainingLabel.position = CGPoint(x: K.width / 3, y: 480)
        gemsRemainingLabel.fontName = "AvenirNext-Bold"
        gemsRemainingLabel.fontSize = 48
        gemsRemainingLabel.fontColor = .red

        exitAvailableLabel = SKLabelNode(text: "Exit Available: ")
        exitAvailableLabel.horizontalAlignmentMode = .left
        exitAvailableLabel.position = CGPoint(x: K.width / 3, y: 420)
        exitAvailableLabel.fontName = "AvenirNext-Bold"
        exitAvailableLabel.fontSize = 48
        exitAvailableLabel.fontColor = .red

        gameOverLabel = SKLabelNode(text: "")
        gameOverLabel.horizontalAlignmentMode = .left
        gameOverLabel.position = CGPoint(x: K.width / 3, y: 360)
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        
        addToScene()
    }
    
    
    // MARK: - Helper Functions
    
    func setLabels(level: String, moves: String, gems: String, exit: String, gameOver: String) {
        levelLabel.text = "LV: \(level)"
        movesRemainingLabel.text = "Moves: \(moves)"
        gemsRemainingLabel.text = "Gems: \(gems)"
        exitAvailableLabel.text = "Exit Available: \(exit)"
        gameOverLabel.text = gameOver
    }

    private func addToScene() {
        sprite.addChild(levelLabel)
        sprite.addChild(movesRemainingLabel)
        sprite.addChild(gemsRemainingLabel)
        sprite.addChild(exitAvailableLabel)
        sprite.addChild(gameOverLabel)
    }
}
