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

    var totalScoreLabel: SKLabelNode
    var scoreLabel: SKLabelNode
    var elapsedTimeLabel: SKLabelNode
    var statsLabel: SKLabelNode //temporary
    
    
    // MARK: - Initialization
    
    init() {
        let padding: CGFloat = 40
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        totalScoreLabel = SKLabelNode()
        totalScoreLabel.fontName = UIFont.gameFont
        totalScoreLabel.fontSize = UIFont.gameFontSizeSmall
        totalScoreLabel.fontColor = UIFont.gameFontColor
        totalScoreLabel.position = CGPoint(x: padding, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - 30)
        totalScoreLabel.horizontalAlignmentMode = .left
        totalScoreLabel.verticalAlignmentMode = .baseline
        totalScoreLabel.zPosition = K.ZPosition.display

        scoreLabel = SKLabelNode()
        scoreLabel.fontName = UIFont.gameFont
        scoreLabel.fontSize = UIFont.gameFontSizeSmall
        scoreLabel.fontColor = UIFont.gameFontColor
        scoreLabel.position = CGPoint(x: padding, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - 90)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .baseline
        scoreLabel.zPosition = K.ZPosition.display

        elapsedTimeLabel = SKLabelNode(text: "00:00")
        elapsedTimeLabel.fontName = UIFont.gameFont
        elapsedTimeLabel.fontSize = UIFont.gameFontSizeMedium
        elapsedTimeLabel.fontColor = UIFont.gameFontColor
        elapsedTimeLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2 - elapsedTimeLabel.frame.width / 2,
                                            y: K.ScreenDimensions.topOfGameboard + 18)
        elapsedTimeLabel.horizontalAlignmentMode = .left
        elapsedTimeLabel.verticalAlignmentMode = .bottom
        elapsedTimeLabel.zPosition = K.ZPosition.display

        statsLabel = SKLabelNode()
        statsLabel.fontName = UIFont.gameFont
        statsLabel.fontSize = UIFont.gameFontSizeTiny
        statsLabel.fontColor = UIFont.gameFontColor
        statsLabel.position = CGPoint(x: padding, y: K.ScreenDimensions.bottomMargin + 200)
        statsLabel.horizontalAlignmentMode = .left
        statsLabel.verticalAlignmentMode = .top
        statsLabel.zPosition = K.ZPosition.display
        statsLabel.numberOfLines = 0

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
        
        animateScore()
        
        statsLabel.text = "Elapsed Time: \(Int(elapsedTime))\nMoves Remaining: \(movesRemaining)\nItems Found: \(itemsFound)\nEnemies Killed: \(enemiesKilled)\nContinue Used? \(usedContinue)"
    }
    
    func updateLabels() {
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        elapsedTimeLabel.text = String(format: "%02i:%02i", minutes, seconds)

        updateScoreLabels()
    }
    
    private func updateScoreLabels() {
        totalScoreLabel.text = "TOTAL: " + (numberFormatter.string(from: NSNumber(value: totalScore)) ?? "-9999")
        scoreLabel.text = "SCORE: " + (numberFormatter.string(from: NSNumber(value: score)) ?? "-9999")
    }
    
    
    // MARK: - Animate Score Helper
    
    private func animateScore() {
        scoreLabel.run(SKAction.sequence([scaleScoreAnimation(), SKAction.wait(forDuration: 1.0), incrementScoreAnimation()]))
    }
    
    private func scaleScoreAnimation() -> SKAction {
        let scaleUpDuration: TimeInterval = 0.125
        let scaleDownDuration: TimeInterval = 0.5
        let scaleCount = 250
        let increment: CGFloat = 0.002
        
        let waitUp = SKAction.wait(forDuration: scaleUpDuration / TimeInterval(scaleCount))
        let waitDown = SKAction.wait(forDuration: scaleDownDuration / TimeInterval(scaleCount))
        
        let scaleUpAction = SKAction.run { [unowned self] in
            scoreLabel.setScale(scoreLabel.yScale + increment)
        }
        
        let scaleDownAction = SKAction.run { [unowned self] in
            scoreLabel.setScale(scoreLabel.yScale - increment)
        }
        
        let scaleUpRepeat = SKAction.repeat(SKAction.sequence([waitUp, scaleUpAction]), count: scaleCount)
        let scaleDownRepeat = SKAction.repeat(SKAction.sequence([waitDown, scaleDownAction]), count: scaleCount)

        let scaleUpColor = SKAction.colorize(with: .cyan, colorBlendFactor: 0.75, duration: scaleUpDuration)
        let scaleDownColor = SKAction.colorize(withColorBlendFactor: 0.0, duration: scaleDownDuration)
        
        let scaleSequence = SKAction.sequence([
            SKAction.group([scaleUpColor, scaleUpRepeat]),
            SKAction.wait(forDuration: 0.5),
            SKAction.group([scaleDownColor, scaleDownRepeat])
        ])
        
        return scaleSequence
    }
    
    private func incrementScoreAnimation() -> SKAction {
        let savedScore: CGFloat = CGFloat(score)
        let wait = SKAction.wait(forDuration: 1 / savedScore)
        
        let incrementAction = SKAction.run { [unowned self] in
            score -= 1
            totalScore += 1
            
            updateScoreLabels()
        }
        
        let incrementRepeat = SKAction.repeat(SKAction.sequence([wait, incrementAction]), count: Int(savedScore))
        
        return incrementRepeat
    }
    

    // MARK: - Move Functions

    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(totalScoreLabel)
        superScene.addChild(scoreLabel)
        superScene.addChild(elapsedTimeLabel)
//        superScene.addChild(statsLabel)
    }

}
