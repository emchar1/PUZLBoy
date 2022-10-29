//
//  DisplaySprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/22/22.
//

import SpriteKit

class DisplaySprite {
    
    // MARK: - Properties
    
    let fontSpacing: CGFloat = 80
    let fontSize: CGFloat = 60
    let fontName = "AvenirNext-Bold"
    let fontColor: UIColor = .white
    
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
        levelLabel.position = CGPoint(x: K.width / 2.5, y: K.height / 3.5)
        levelLabel.fontName = fontName
        levelLabel.fontSize = fontSize
        levelLabel.fontColor = fontColor

        movesRemainingLabel = SKLabelNode(text: "Moves: ")
        movesRemainingLabel.horizontalAlignmentMode = .left
        movesRemainingLabel.position = CGPoint(x: K.width / 2.5, y: K.height / 3.5 - fontSpacing)
        movesRemainingLabel.fontName = fontName
        movesRemainingLabel.fontSize = fontSize
        movesRemainingLabel.fontColor = fontColor

        gemsRemainingLabel = SKLabelNode(text: "Gems: ")
        gemsRemainingLabel.horizontalAlignmentMode = .left
        gemsRemainingLabel.position = CGPoint(x: K.width / 2.5, y: K.height / 3.5 - 2 * fontSpacing)
        gemsRemainingLabel.fontName = fontName
        gemsRemainingLabel.fontSize = fontSize
        gemsRemainingLabel.fontColor = fontColor

        exitAvailableLabel = SKLabelNode(text: "Exit: ")
        exitAvailableLabel.horizontalAlignmentMode = .left
        exitAvailableLabel.position = CGPoint(x: K.width / 2.5, y: K.height / 3.5 - 3 * fontSpacing)
        exitAvailableLabel.fontName = fontName
        exitAvailableLabel.fontSize = fontSize
        exitAvailableLabel.fontColor = fontColor

        gameOverLabel = SKLabelNode(text: "")
        gameOverLabel.horizontalAlignmentMode = .left
        gameOverLabel.position = CGPoint(x: K.width / 2.5, y: K.height / 3.5 - 4 * fontSpacing)
        gameOverLabel.fontName = fontName
        gameOverLabel.fontSize = fontSize
        gameOverLabel.fontColor = fontColor
        
        addToScene()
    }
    
    
    // MARK: - Helper Functions
    
    func setLabels(level: String, moves: String, gems: String, exit: String, gameOver: String) {
        levelLabel.text = "LV: \(level)"
        movesRemainingLabel.text = "Moves: \(moves)"
        gemsRemainingLabel.text = "Gems: \(gems)"
        exitAvailableLabel.text = "Exit: \(exit)"
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
