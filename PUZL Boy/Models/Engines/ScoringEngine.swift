//
//  ScoringEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/1/22.
//

import SpriteKit

class ScoringEngine {
    
    // MARK: - Properties
    
    private static let moveScore = 2000
    private static let itemScore = 500
    private let maxTimeScore = 1000
    private let minTimeScore = 100
    private let reductionPerSecondScore = -5
    private let killEnemyScore = 1000

    private(set) var timerManager: TimerManager
    private(set) var scoringManager: ScoringManager

    var totalScoreLabel: SKLabelNode
    var scoreLabel: SKLabelNode
    var elapsedTimeLabel: SKLabelNode
    
    
    // MARK: - Initialization
    
    init(elapsedTime: TimeInterval = 0, totalScore: Int = 0) {
        let padding: CGFloat = 40
        
        timerManager = TimerManager(elapsedTime: elapsedTime)
        scoringManager = ScoringManager(totalScore: totalScore)

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

        scoringManager.resetScore()
        updateLabels()
    }
    
    
    // MARK: - Scoring Multipliers

    static func getMovesScore(from movesRemaining: Int) -> Int {
        return moveScore * movesRemaining
    }
    
    static func getItemsFoundScore(from itemsFound: Int) -> Int {
        return itemScore * itemsFound
    }
    
    static func getUsedContinueMultiplier(_ usedContinue: Bool) -> Int {
        return usedContinue ? 1 : 2
    }

    
    // MARK: - Scoring Functions
    
    func calculateScore(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool) -> Int {
        timerManager.pollTime()
        
        scoringManager.setScore((getTimeScore() + ScoringEngine.getMovesScore(from: movesRemaining) + ScoringEngine.getItemsFoundScore(from: itemsFound) + enemiesKilled * killEnemyScore) * ScoringEngine.getUsedContinueMultiplier(usedContinue))

        return scoringManager.score
    }
    
    func updateLabels() {
        let minutes = Int(timerManager.elapsedTime) / 60 % 60
        let seconds = Int(timerManager.elapsedTime) % 60
        
        elapsedTimeLabel.text = String(format: "%02i:%02i", minutes, seconds)
        elapsedTimeLabel.fontColor = timerManager.elapsedTime >= 60 * 60 ? UIFont.gameFontColorOutOfTime : UIFont.gameFontColor
        
        updateScoreLabels()
    }

    private func getTimeScore() -> Int {
        max(minTimeScore, maxTimeScore + Int(timerManager.elapsedTime) * reductionPerSecondScore)
    }
    
    private func updateScoreLabels() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        totalScoreLabel.text = "TOTAL: " + (numberFormatter.string(from: NSNumber(value: scoringManager.totalScore)) ?? "-9999")
        scoreLabel.text = "SCORE: " + (numberFormatter.string(from: NSNumber(value: scoringManager.score)) ?? "-9999")
    }
    
    
    // MARK: - Animate Score Helper
    
    /**
     Adds a floating score animaton from an originSprite and a location. Use this static method directly from ScoringEngine.
     - parameters:
        - score: The Int score to display
        - usedContinue: Determines the multiplier, i.e. if false = 2, else = 1
        - originSprite: The sprite from which to add the label as a child
        - location: Location of the label node
     */
    static func addScoreAnimation(score: Int, usedContinue: Bool?, originSprite: SKNode, location: CGPoint) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let score = numberFormatter.string(from: NSNumber(value: score * getUsedContinueMultiplier(usedContinue ?? true)))
        
        let pointsSprite = SKLabelNode(text: "+" + (score ?? "0"))
        pointsSprite.fontName = UIFont.gameFont
        pointsSprite.fontSize = UIFont.gameFontSizeMedium
        pointsSprite.fontColor = .yellow
        pointsSprite.position = location
        pointsSprite.zPosition = K.ZPosition.items
        
        originSprite.addChild(pointsSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        pointsSprite.run(SKAction.group([moveUp, fadeOut])) {
            pointsSprite.removeFromParent()
        }
    }
    
    func animateScore(usedContinue: Bool) {
        scoreLabel.run(SKAction.sequence([scaleScoreAnimation(), SKAction.wait(forDuration: 1.0), incrementScoreAnimation()]))
        
        ScoringEngine.addScoreAnimation(score: getTimeScore(),
                                        usedContinue: usedContinue,
                                        originSprite: elapsedTimeLabel,
                                        location: CGPoint(x: elapsedTimeLabel.frame.width / 2, y: 0))
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
        let savedScore: CGFloat = CGFloat(scoringManager.score)
        let wait = SKAction.wait(forDuration: 1 / savedScore)
        
        let incrementAction = SKAction.run { [unowned self] in
            scoringManager.balanceScores()
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
    }

}
