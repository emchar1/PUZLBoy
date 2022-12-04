//
//  ScoringEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/1/22.
//

import SpriteKit

class ScoringEngine {
    
    
    // MARK: - Properties
    
    private let maxTimeScore = 1000
    private let reductionPerSecondScore = -5
    private let moveScore = 2000
    private let itemScore = 500
    private let killEnemyScore = 1000

    private var score = 0
    private var totalScore = 0

    private var numberFormatter = NumberFormatter()
    private var timeInitial = Date()
    private var timeFinal = Date()
    private var elapsedTime: TimeInterval {
        TimeInterval(timeFinal.timeIntervalSince1970 - timeInitial.timeIntervalSince1970)
    }

    var scoreLabel: SKLabelNode
    var totalScoreLabel: SKLabelNode
    var elapsedTimeLabel: SKLabelNode
    var statsLabel: SKLabelNode //temporary
    
    
    // MARK: - Initialization
    
    init() {
        let fontName = "AvenirNext-BoldItalic"
        let fontSize: CGFloat = 38
        let fontColor: UIColor = .white
        let padding: CGFloat = 40
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        scoreLabel = SKLabelNode()
        scoreLabel.fontName = fontName
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = fontColor
        scoreLabel.position = CGPoint(x: padding, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = K.ZPosition.display

        totalScoreLabel = SKLabelNode()
        totalScoreLabel.fontName = fontName
        totalScoreLabel.fontSize = fontSize
        totalScoreLabel.fontColor = fontColor
        totalScoreLabel.position = CGPoint(x: padding, y: K.ScreenDimensions.height - 260)
        totalScoreLabel.horizontalAlignmentMode = .left
        totalScoreLabel.verticalAlignmentMode = .top
        totalScoreLabel.zPosition = K.ZPosition.display

        elapsedTimeLabel = SKLabelNode()
        elapsedTimeLabel.fontName = fontName
        elapsedTimeLabel.fontSize = fontSize
        elapsedTimeLabel.fontColor = fontColor
        elapsedTimeLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2,
                                            y: K.ScreenDimensions.height - 360)
        elapsedTimeLabel.horizontalAlignmentMode = .center
        elapsedTimeLabel.verticalAlignmentMode = .top
        elapsedTimeLabel.zPosition = K.ZPosition.display

        statsLabel = SKLabelNode()
        statsLabel.fontName = "AvenirNext-Regular"
        statsLabel.fontSize = 18
        statsLabel.fontColor = fontColor
        statsLabel.position = CGPoint(x: padding, y: K.ScreenDimensions.height - 380)
        statsLabel.horizontalAlignmentMode = .left
        statsLabel.verticalAlignmentMode = .top
        statsLabel.zPosition = K.ZPosition.display

        resetAllScores()
        updateLabels()
    }
    
    private func resetAllScores() {
        totalScore = 0
        
        resetScore()
        resetTime()
    }

    
    // MARK: - Helper Functions
    
    func resetScore() {
        score = 0
        statsLabel.text = "blank"
    }
    
    func resetTime() {
        timeInitial = Date()
        timeFinal = Date()
    }

    func pollTime() {
        timeFinal = Date()
    }
    
    func updateScore(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool) {
        //DON'T CHANGE THIS ORDER!!!
        pollTime()
        
        score = (max(0, maxTimeScore + Int(elapsedTime) * reductionPerSecondScore) + movesRemaining * moveScore + itemsFound * itemScore + enemiesKilled * killEnemyScore) * (usedContinue ? 1 : 2)
        
        totalScore += score

        statsLabel.text = "elapsed time: \(Int(elapsedTime)), moves remaining: \(movesRemaining), items found: \(itemsFound), enemiesKilled: \(enemiesKilled), continue used: \(usedContinue)"
    }
    
    func updateLabels() {
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        scoreLabel.text = "SCORE: " + (numberFormatter.string(from: NSNumber(value: score)) ?? "-9999")
        totalScoreLabel.text = "TOTAL: " + (numberFormatter.string(from: NSNumber(value: totalScore)) ?? "-9999")
        elapsedTimeLabel.text = String(format: "%02i:%02i", minutes, seconds)
    }
    

    // MARK: - Move Functions

    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(scoreLabel)
        superScene.addChild(totalScoreLabel)
        superScene.addChild(elapsedTimeLabel)
        superScene.addChild(statsLabel)
    }

}
