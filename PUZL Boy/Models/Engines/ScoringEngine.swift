//
//  ScoringEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/1/22.
//

import SpriteKit

class ScoringEngine {
    
    // MARK: - Properties
    
    static let killEnemyScore = 1000
    private static let moveScore = 200
    private static let itemScore = 500
    private let maxTimeScore = 1800
    private let minTimeScore = 100
    private let reductionPerSecondScore = -1

    private var elapsedTime: TimeInterval
    private var score: Int
    private var totalScore: Int
    
    private(set) var timerManager: TimerManager!
    private(set) var scoringManager: ScoringManager!
    private(set) var sprite: SKSpriteNode!
    private var totalScoreLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var elapsedTimeLabel: SKLabelNode!
    
    enum StatusIcon: String {
        case health = "heart0", moves = "iconBoot", sword = "iconSword", hammer = "iconHammer"
    }
    
    
    // MARK: - Initialization
    
    init(elapsedTime: TimeInterval = 0, score: Int = 0, totalScore: Int = 0) {
        self.elapsedTime = max(0, elapsedTime) //BUGFIX# 240216E01
        self.score = score
        self.totalScore = totalScore
        
        setupSprites()
        updateLabels()
    }
    
    deinit {
        print("ScoringEngine deinit")
    }
    
    private func setupSprites() {
        let padding: CGFloat = 40
        
        timerManager = TimerManager(elapsedTime: elapsedTime)
        scoringManager = ScoringManager(score: score, totalScore: totalScore)

        sprite = SKSpriteNode()
        sprite.zPosition = K.ZPosition.display

        totalScoreLabel = SKLabelNode()
        totalScoreLabel.fontName = UIFont.gameFont
        totalScoreLabel.fontSize = UIFont.gameFontSizeSmall
        totalScoreLabel.fontColor = UIFont.gameFontColor
        totalScoreLabel.position = CGPoint(x: K.ScreenDimensions.lrMargin + padding, y: K.ScreenDimensions.size.height - K.ScreenDimensions.topMargin)
        totalScoreLabel.horizontalAlignmentMode = .left
        totalScoreLabel.verticalAlignmentMode = .top
        totalScoreLabel.addDropShadow()

        scoreLabel = SKLabelNode()
        scoreLabel.fontName = UIFont.gameFont
        scoreLabel.fontSize = UIFont.gameFontSizeSmall
        scoreLabel.fontColor = UIFont.gameFontColor
        scoreLabel.position = CGPoint(x: K.ScreenDimensions.lrMargin + padding, y: K.ScreenDimensions.size.height - K.ScreenDimensions.topMargin - 59)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.addDropShadow()

        elapsedTimeLabel = SKLabelNode(text: "00:00")
        elapsedTimeLabel.fontName = UIFont.gameFont
        elapsedTimeLabel.fontSize = UIFont.gameFontSizeMedium
        elapsedTimeLabel.fontColor = UIFont.gameFontColor
        elapsedTimeLabel.position = CGPoint(x: K.ScreenDimensions.size.width / 2 - elapsedTimeLabel.frame.width / 2,
                                            y: K.ScreenDimensions.topOfGameboard + 32)
        elapsedTimeLabel.horizontalAlignmentMode = .left
        elapsedTimeLabel.verticalAlignmentMode = .bottom
        elapsedTimeLabel.addDropShadow()
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
        
        scoringManager.setScore(
            (
                getTimeScore() +
                ScoringEngine.getMovesScore(from: movesRemaining) +
                ScoringEngine.getItemsFoundScore(from: itemsFound) +
                enemiesKilled * ScoringEngine.killEnemyScore
            ) * ScoringEngine.getUsedContinueMultiplier(usedContinue)
        )

        return scoringManager.score
    }
    
    func updateLabels() {
        elapsedTimeLabel.text = timerManager.formattedText
        elapsedTimeLabel.fontColor = timerManager.elapsedTime >= 60 * 60 ? UIFont.gameFontColorOutOfTime : UIFont.gameFontColor
        elapsedTimeLabel.updateShadow()
        
        updateScoreLabels()
    }

    private func getTimeScore() -> Int {
        //Penalizes user if they change system time manually to try and get a higher score.
        guard timerManager.elapsedTime > 0 else { return 0 }

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
        pointsSprite.fontSize = UIFont.gameFontSizeLarge
        pointsSprite.fontColor = .yellow
        pointsSprite.position = location
        pointsSprite.zPosition = K.ZPosition.itemsPoints
        pointsSprite.addDropShadow()
        
        originSprite.addChild(pointsSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        pointsSprite.run(SKAction.sequence([
            SKAction.group([moveUp, fadeOut]),
            SKAction.removeFromParent()
        ]))
    }
    
    /**
     Adds a floating status loss/gain animation from an originSprite and a location. Use this static method directly from ScoringEngine.
     - parameters:
        - icon: the icon to use: health, moves, sword or hammer
        - amount: Amount to adjust. If amount = 9999, it is set to +∞
        - originSprite: The sprite from which to add the nodes as a child
        - location: Location to place the containerNode
     */
    static func updateStatusIconsAnimation(icon: StatusIcon, amount: Int, originSprite: SKNode, location: CGPoint) {
        let containerSprite = SKShapeNode(rectOf: CGSize(width: 160, height: 80) / UIDevice.spriteScale)
        containerSprite.fillColor = .clear
        containerSprite.lineWidth = 0
        containerSprite.position = location
        containerSprite.zPosition = K.ZPosition.itemsPoints
        
        let amountNormal = "\(amount > 0 ? "+" : "")\(amount)"
        let amountInfinity = "+∞"
        let amountSprite = SKLabelNode(text: amount == 9999 ? amountInfinity : amountNormal)
        amountSprite.fontName = UIFont.gameFont
        amountSprite.fontSize = UIFont.gameFontSizeLarge
        amountSprite.fontColor = amount < 0 ? .red : .white
        amountSprite.horizontalAlignmentMode = .center
        amountSprite.verticalAlignmentMode = .center
        amountSprite.position = .zero
        amountSprite.zPosition = 10
        amountSprite.addDropShadow()
        
        let iconSprite = SKSpriteNode(imageNamed: icon.rawValue)
        iconSprite.scale(to: CGSize(width: 80 / UIDevice.spriteScale, height: 80 / UIDevice.spriteScale))
        iconSprite.position = CGPoint(x: 60 / UIDevice.spriteScale, y: 0)
        
        originSprite.addChild(containerSprite)
        containerSprite.addChild(amountSprite)
        containerSprite.addChild(iconSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        containerSprite.run(SKAction.group([moveUp, fadeOut])) {
            containerSprite.removeFromParent()
        }
    }
    
    ///Use this to animate the score accumulated from the level and add it to the total score in an incremented fashion.
    func animateScore(usedContinue: Bool) {
        scoreLabel.run(SKAction.sequence([
            scaleScoreAnimation(sprite: scoreLabel, fontColor: .cyan),
            SKAction.wait(forDuration: 1.0),
            incrementScoreAnimation()
        ]))
        
        ScoringEngine.addScoreAnimation(score: getTimeScore(),
                                        usedContinue: usedContinue,
                                        originSprite: elapsedTimeLabel,
                                        location: CGPoint(x: elapsedTimeLabel.frame.width / 2, y: 0))
    }

    ///Use this womp-womp animation because player skipped the level (but paid $2.99!)
    func scaleScoreLabelDidSkipLevel() {
        scoreLabel.run(scaleScoreAnimation(sprite: scoreLabel, fontColor: .red))
    }
    
    /**
     Animates the accumulated score earned from passing the level.
     - parameters:
        - sprite: The SKNode to add the score to.
        - fontColor: the color of the font to be animated.
        - shouldCenter: whether the font to be animated should be centered on the node. Default is `false`.
     - returns: SKAction of the resulting animation.
     */
    private func scaleScoreAnimation(sprite: SKNode, fontColor: UIColor, shouldCenter: Bool = false) -> SKAction {
        let scaleUpDuration: TimeInterval = 0.125
        let scaleDownDuration: TimeInterval = 0.5
        let scaleCount = 250
        let increment: CGFloat = 0.002
        
        let waitUp = SKAction.wait(forDuration: scaleUpDuration / TimeInterval(scaleCount))
        let waitDown = SKAction.wait(forDuration: scaleDownDuration / TimeInterval(scaleCount))
        
        let scaleUpAction = SKAction.run {
            sprite.setScale(sprite.yScale + increment)
        }
        
        let scaleDownAction = SKAction.run {
            sprite.setScale(sprite.yScale - increment)
        }
                
        let moveLeft = SKAction.moveBy(x: (shouldCenter ? -sprite.frame.width / 4 : 0), y: 0, duration: scaleUpDuration)
        let moveRight = SKAction.moveBy(x: (shouldCenter ? sprite.frame.width / 4 : 0), y: 0, duration: scaleDownDuration)
        
        let scaleUpRepeat = SKAction.repeat(SKAction.sequence([waitUp, scaleUpAction]), count: scaleCount)
        let scaleDownRepeat = SKAction.repeat(SKAction.sequence([waitDown, scaleDownAction]), count: scaleCount)

        let scaleUpColor = SKAction.colorize(with: fontColor, colorBlendFactor: 0.75, duration: scaleUpDuration)
        let scaleDownColor = SKAction.colorize(withColorBlendFactor: 0.0, duration: scaleDownDuration)
        
        let scaleSequence = SKAction.sequence([
            SKAction.group([scaleUpColor, scaleUpRepeat, moveLeft]),
            SKAction.wait(forDuration: 0.5),
            SKAction.group([scaleDownColor, scaleDownRepeat, moveRight])
        ])
        
        return scaleSequence
    }
    
    /**
     Animation that increments from the score earned in the level, to the total score.
     - returns: an SKAction of the resulting animation.
     */
    private func incrementScoreAnimation() -> SKAction {
        let savedScore: CGFloat = CGFloat(scoringManager.score)
        let multiplier: Int = Int(max(savedScore / 1000, 1))
        let wait = SKAction.wait(forDuration: CGFloat(multiplier) * 1 / savedScore)
        
        let incrementAction = SKAction.run { [weak self] in
            self?.scoringManager.balanceScores(step: multiplier)
            self?.updateScoreLabels()
        }
        
        let incrementRepeat = SKAction.repeat(SKAction.sequence([wait, incrementAction]), count: Int(savedScore / CGFloat(multiplier)))
        
        let incrementRemainder = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            scoringManager.balanceScores(step: scoringManager.score)
            updateScoreLabels()
        }
        
        let incrementSequence = SKAction.sequence([incrementRepeat, incrementRemainder])
        
        return incrementSequence
    }
    
    
    // MARK: - Animate Time Functions
    
    func pulseColorTimeAnimation(fontColor: UIColor) {
        elapsedTimeLabel.run(SKAction.sequence([
            SKAction.colorize(with: fontColor, colorBlendFactor: 1.0, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.5)
        ]))
    }
    
    func fadeOutTimeAnimation(duration: TimeInterval = 0.5) {
        elapsedTimeLabel.run(SKAction.fadeOut(withDuration: duration))
    }
    
    func fadeInTimeAnimation(duration: TimeInterval = 0) {
        elapsedTimeLabel.run(SKAction.fadeIn(withDuration: duration))
    }
        
    func addTimeAnimation(seconds: TimeInterval) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        let secondsFormatted = numberFormatter.string(from: NSNumber(value: seconds)) ?? "0.XX"
        
        let pointsSprite = SKLabelNode(text: "+\(secondsFormatted)")
        pointsSprite.fontName = UIFont.gameFont
        pointsSprite.fontSize = UIFont.gameFontSizeMedium
        pointsSprite.fontColor = .green
        pointsSprite.position = .zero
        pointsSprite.horizontalAlignmentMode = .left
        pointsSprite.zPosition = K.ZPosition.itemsPoints
        pointsSprite.addDropShadow()
        
        elapsedTimeLabel.addChild(pointsSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        pointsSprite.run(SKAction.group([moveUp, fadeOut])) {
            pointsSprite.removeFromParent()
        }
        
        elapsedTimeLabel.run(scaleScoreAnimation(sprite: elapsedTimeLabel, fontColor: .orange, shouldCenter: true))
    }
    
    
    // MARK: - Misc. Functions
    
    /**
     Adds  floating text animaton from an originSprite and a location. Use this static method directly from ScoringEngine.
     - parameters:
        - text: The text to display
        - textColor: The color of the text that will be displayed
        - originSprite: The sprite from which to add the label as a child
        - location: Location of the label node
     */
    static func addTextAnimation(text: String, textColor: UIColor, originSprite: SKNode, location: CGPoint) {
        let textSprite = SKLabelNode(text: text)
        textSprite.fontName = UIFont.gameFont
        textSprite.fontSize = UIFont.gameFontSizeLarge
        textSprite.fontColor = textColor
        textSprite.position = location
        textSprite.zPosition = K.ZPosition.itemsPoints
        textSprite.addDropShadow()
        
        originSprite.addChild(textSprite)

        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.75), SKAction.fadeOut(withDuration: 0.25)])
        
        textSprite.run(SKAction.group([moveUp, fadeOut])) {
            textSprite.removeFromParent()
        }
    }
        
    func showSprite(fadeDuration: TimeInterval = 0) {
        sprite.run(SKAction.fadeIn(withDuration: fadeDuration))
    }
    
    func hideSprite(fadeDuration: TimeInterval = 0) {
        sprite.run(SKAction.fadeOut(withDuration: fadeDuration))
    }
    
    
    // MARK: - Move Functions

    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene, isPartyLevel: Bool) {
        //Ensure node doesn't get added more than once.
        sprite.removeAllChildren()
        sprite.removeFromParent()
        
        superScene.addChild(sprite)
        sprite.addChild(elapsedTimeLabel)
        
        if !isPartyLevel {
            sprite.addChild(totalScoreLabel)
            sprite.addChild(scoreLabel)
        }
    }

}
