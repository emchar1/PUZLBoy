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
    
    enum StatusIcon: String {
        case health = "heart0", moves = "iconBoot", sword = "iconSword", hammer = "iconHammer"
    }
    
    
    // MARK: - Initialization
    
    init(elapsedTime: TimeInterval = 0, score: Int = 0, totalScore: Int = 0) {
        let padding: CGFloat = 40
        
        timerManager = TimerManager(elapsedTime: elapsedTime)
        scoringManager = ScoringManager(score: score, totalScore: totalScore)

        totalScoreLabel = SKLabelNode()
        totalScoreLabel.fontName = UIFont.gameFont
        totalScoreLabel.fontSize = UIFont.gameFontSizeSmall
        totalScoreLabel.fontColor = UIFont.gameFontColor
        totalScoreLabel.position = CGPoint(x: K.ScreenDimensions.lrMargin + padding, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin)
        totalScoreLabel.horizontalAlignmentMode = .left
        totalScoreLabel.verticalAlignmentMode = .top
        totalScoreLabel.zPosition = K.ZPosition.display
        totalScoreLabel.addDropShadow()

        scoreLabel = SKLabelNode()
        scoreLabel.fontName = UIFont.gameFont
        scoreLabel.fontSize = UIFont.gameFontSizeSmall
        scoreLabel.fontColor = UIFont.gameFontColor
        scoreLabel.position = CGPoint(x: K.ScreenDimensions.lrMargin + padding, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - 59)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = K.ZPosition.display
        scoreLabel.addDropShadow()

        elapsedTimeLabel = SKLabelNode(text: "00:00")
        elapsedTimeLabel.fontName = UIFont.gameFont
        elapsedTimeLabel.fontSize = UIFont.gameFontSizeMedium
        elapsedTimeLabel.fontColor = UIFont.gameFontColor
        elapsedTimeLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2 - elapsedTimeLabel.frame.width / 2,
                                            y: K.ScreenDimensions.topOfGameboard + 32)
        elapsedTimeLabel.horizontalAlignmentMode = .left
        elapsedTimeLabel.verticalAlignmentMode = .bottom
        elapsedTimeLabel.zPosition = K.ZPosition.display
        elapsedTimeLabel.addDropShadow()

        updateLabels()
    }
    
    deinit {
        print("ScoringEngine deinit")
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
        elapsedTimeLabel.updateShadow()
        
        updateScoreLabels()
    }

    private func getTimeScore() -> Int {
        //Penalizes user if they change system time manually to try and get a higher score.
        guard timerManager.elapsedTime >= 0 else { return 0 }

        return max(minTimeScore, maxTimeScore + Int(timerManager.elapsedTime) * reductionPerSecondScore)
    }
    
    private func updateScoreLabels() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        totalScoreLabel.text = "TOTAL: " + (numberFormatter.string(from: NSNumber(value: scoringManager.totalScore)) ?? "-9999")
        totalScoreLabel.updateShadow()
        scoreLabel.text = "SCORE: " + (numberFormatter.string(from: NSNumber(value: scoringManager.score)) ?? "-9999")
        scoreLabel.updateShadow()
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
        pointsSprite.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        pointsSprite.fontColor = .yellow
        pointsSprite.position = location
        pointsSprite.zPosition = K.ZPosition.itemsPoints
        pointsSprite.addDropShadow()
        
        originSprite.addChild(pointsSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        pointsSprite.run(SKAction.group([moveUp, fadeOut])) {
            pointsSprite.removeFromParent()
        }
    }
    
    /**
     Adds a floating status loss/gain animaton from an originSprite and a location. Use this static method directly from ScoringEngine.
     - parameters:
        - icon: the icon to use: health, moves, sword or hammer
        - amount: Amount to adjust
        - originSprite: The sprite from which to add the nodes as a child
        - location: Location to place the containerNode
     */
    static func updateStatusIconsAnimation(icon: StatusIcon, amount: Int, originSprite: SKNode, location: CGPoint) {
        let containerSprite = SKShapeNode(rectOf: UIDevice.isiPad ? CGSize(width: 240, height: 120) : CGSize(width: 160, height: 80))
        containerSprite.fillColor = .clear
        containerSprite.lineWidth = 0
        containerSprite.position = location
        containerSprite.zPosition = K.ZPosition.itemsPoints
        
        let amountSprite = SKLabelNode(text: "\(amount > 0 ? "+" : "")\(amount)")
        amountSprite.fontName = UIFont.gameFont
        amountSprite.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        amountSprite.fontColor = amount < 0 ? .red : .white
        amountSprite.horizontalAlignmentMode = .center
        amountSprite.verticalAlignmentMode = .center
        amountSprite.position = .zero
        amountSprite.zPosition = 10
        amountSprite.addDropShadow()
        
        let iconSprite = SKSpriteNode(imageNamed: icon.rawValue)
        iconSprite.scale(to: UIDevice.isiPad ? CGSize(width: 120, height: 120) : CGSize(width: 80, height: 80))
        iconSprite.position = CGPoint(x: UIDevice.isiPad ? 80 : 60, y: 0)
        
        originSprite.addChild(containerSprite)
        containerSprite.addChild(amountSprite)
        containerSprite.addChild(iconSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        containerSprite.run(SKAction.group([moveUp, fadeOut])) {
            containerSprite.removeFromParent()
        }
    }
    
    func animateScore(usedContinue: Bool) {
        scoreLabel.run(SKAction.sequence([
            scaleScoreAnimation(fontColor: .cyan),
            SKAction.wait(forDuration: 1.0),
            incrementScoreAnimation()
        ]))
        
        ScoringEngine.addScoreAnimation(score: getTimeScore(),
                                        usedContinue: usedContinue,
                                        originSprite: elapsedTimeLabel,
                                        location: CGPoint(x: elapsedTimeLabel.frame.width / 2, y: 0))
    }

    ///Use this womp-womp animation because player skipped the level (but paid $1.99!)
    func scaleScoreLabelDidSkipLevel() {
        scoreLabel.run(scaleScoreAnimation(fontColor: .red))
    }
    
    private func scaleScoreAnimation(fontColor: UIColor) -> SKAction {
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

        let scaleUpColor = SKAction.colorize(with: fontColor, colorBlendFactor: 0.75, duration: scaleUpDuration)
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
        let multiplier: Int = Int(max(savedScore / 1000, 1))
        let wait = SKAction.wait(forDuration: CGFloat(multiplier) * 1 / savedScore)
        
        let incrementAction = SKAction.run { [unowned self] in
            scoringManager.balanceScores(step: multiplier)
            updateScoreLabels()
        }
        
        let incrementRepeat = SKAction.repeat(SKAction.sequence([wait, incrementAction]), count: Int(savedScore / CGFloat(multiplier)))
        
        let incrementRemainder = SKAction.run { [unowned self] in
            scoringManager.balanceScores(step: scoringManager.score)
            updateScoreLabels()
        }
        
        let incrementSequence = SKAction.sequence([incrementRepeat, incrementRemainder])
        
        return incrementSequence
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
