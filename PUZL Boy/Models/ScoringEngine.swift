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
    private var timeInitial = Date()
    private var timeFinal = Date()
    private var score = 0
    private var totalScore = 0
    private var numberFormatter = NumberFormatter()
    
    var scoreLabel: SKLabelNode
    var totalScoreLabel: SKLabelNode
    var elapsedTimeLabel: SKLabelNode
    var statsLabel: SKLabelNode
    
    private var elapsedTime: TimeInterval {
        TimeInterval(timeFinal.timeIntervalSince1970 - timeInitial.timeIntervalSince1970)
    }
    
    
    // MARK: - Initialization
    
    init() {
        let fontName = "AvenirNext-BoldItalic"
        let fontSize: CGFloat = 48
        let fontColor: UIColor = .white
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        scoreLabel = SKLabelNode()
        scoreLabel.fontName = fontName
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = fontColor
        scoreLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height - 200)

        totalScoreLabel = SKLabelNode()
        totalScoreLabel.fontName = fontName
        totalScoreLabel.fontSize = fontSize
        totalScoreLabel.fontColor = fontColor
        totalScoreLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height - 260)

        elapsedTimeLabel = SKLabelNode()
        elapsedTimeLabel.fontName = fontName
        elapsedTimeLabel.fontSize = fontSize
        elapsedTimeLabel.fontColor = fontColor
        elapsedTimeLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height - 320)

        statsLabel = SKLabelNode()
        statsLabel.fontName = fontName
        statsLabel.fontSize = 18
        statsLabel.fontColor = fontColor
        statsLabel.position = CGPoint(x: 80, y: K.ScreenDimensions.height - 380)
        statsLabel.horizontalAlignmentMode = .left

        resetAllScores()
    }
    
    private func resetAllScores() {
        totalScore = 0
        
        resetScore()
        resetTime()
    }

    
    // MARK: - Functions
    
    func resetScore() {
        //DON'T CHANGE THIS ORDER!!!
        score = 0
        statsLabel.text = "blank"

        updateLabels()
    }
    
    func resetTime() {
        timeInitial = Date()
        timeFinal = Date()
    }

        
    func updateScore(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool) {
        //DON'T CHANGE THIS ORDER!!!
        startStopTime()
        
        score = (max(0, maxTimeScore + Int(elapsedTime.rounded()) * reductionPerSecondScore) + movesRemaining * moveScore + itemsFound * itemScore + enemiesKilled * killEnemyScore) * (usedContinue ? 1 : 2)
        
        totalScore += score

        statsLabel.text = "elapsed time: \(Int(elapsedTime.rounded())), moves remaining: \(movesRemaining), items found: \(itemsFound), enemiesKilled: \(enemiesKilled), continue used: \(usedContinue)"
        
        updateLabels()
    }
        
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
    
    
    // MARK: - Helper Functions


    private func startStopTime() {
        timeFinal = Date()
    }
    
    private func updateLabels() {
        scoreLabel.text = numberFormatter.string(from: NSNumber(value: score))
        totalScoreLabel.text = numberFormatter.string(from: NSNumber(value: totalScore))
        elapsedTimeLabel.text = numberFormatter.string(from: NSNumber(value: elapsedTime))
    }
}
