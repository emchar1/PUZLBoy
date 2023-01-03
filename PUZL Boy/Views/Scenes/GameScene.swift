//
//  GameScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    private var gameEngine: GameEngine
    private var scoringEngine: ScoringEngine
    
    // FIXME: - Debugging purposes only!!!
    private var levelSkipEngine: LevelSkipEngine

    // FIXME: - Should read from Firebase "saved state"
    private var currentLevel: Int = LevelBuilder.maxLevel - 5 {
        didSet {
            if currentLevel > LevelBuilder.maxLevel {
                currentLevel = 0
            }
            else if currentLevel < 0 {
                currentLevel = LevelBuilder.maxLevel
            }
        }
    }
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)
        scoringEngine = ScoringEngine()
        levelSkipEngine = LevelSkipEngine()
        
        super.init(size: size)

        gameEngine.delegate = self
        levelSkipEngine.delegate = self
        scaleMode = .aspectFill

        AudioManager.shared.playSound(for: AudioManager.shared.overworldTheme)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        gameEngine.handleControls(in: location)
        levelSkipEngine.handleControls(in: location)
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        gameEngine.moveSprites(to: self)
        scoringEngine.moveSprites(to: self)
        levelSkipEngine.moveSprites(to: self)
        
        startTimer()
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    // MARK: - Helper Functions
    
    // FIXME: - Is this the best way to represent a timer?
    private func startTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run { [unowned self] in
            scoringEngine.pollTime()
            scoringEngine.updateLabels()
        }
        let sequence = SKAction.sequence([wait, block])
        
        run(SKAction.repeatForever(sequence), withKey: "runTimerAction")
    }
    
    private func stopTimer() {
        removeAction(forKey: "runTimerAction")
    }
    
    private func newGame(level: Int, didWin: Bool) {
        removeAllChildren()
        
        gameEngine = GameEngine(level: level, shouldSpawn: !didWin)
        gameEngine.delegate = self
        gameEngine.moveSprites(to: self)
        scoringEngine.moveSprites(to: self)
        levelSkipEngine.moveSprites(to: self)
        
        if !didWin {
            AudioManager.shared.playSound(for: AudioManager.shared.overworldTheme)
        }
    }
}


// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func gameIsSolved(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool) {
        let score = scoringEngine.updateScore(movesRemaining: movesRemaining,
                                              itemsFound: itemsFound,
                                              enemiesKilled: enemiesKilled,
                                              usedContinue: usedContinue)
        scoringEngine.updateLabels()
        removeAction(forKey: "runTimerAction")

        GameCenterManager.shared.postScoreToLeaderboard(score: score, level: currentLevel)
        
        if currentLevel >= 25 && scoringEngine.elapsedTime <= 6 {
            GameCenterManager.shared.updateProgress(achievement: .speedDemon, shouldReportImmediately: true)
        }
        
        if currentLevel >= 25 && scoringEngine.elapsedTime >= 15 * 60 {
            GameCenterManager.shared.updateProgress(achievement: .slowPoke, shouldReportImmediately: true)
        }
        
        currentLevel += 1
        
        gameEngine.fadeGameboard(fadeOut: true) { [unowned self] in
            scoringEngine.resetTime()
            startTimer()

            newGame(level: currentLevel, didWin: true)
        }
    }
    
    func gameIsOver() {
//        guard gameEngine.canContinue else {
//            stopTimer()
            
//            let continueScene = ContinueScene(size: K.ScreenDimensions.screenSize)
//            removeAllChildren()
//            return
//        }
        
        scoringEngine.resetScore()
        scoringEngine.updateLabels()
                
        newGame(level: currentLevel, didWin: false)
    }
}


// MARK: - LevelSkipEngineDelegate

extension GameScene: LevelSkipEngineDelegate {
    func fowardPressed(_ node: SKSpriteNode) {
        currentLevel += 1
        scoringEngine.resetTime()
        newGame(level: currentLevel, didWin: false)
    }
    
    func reversePressed(_ node: SKSpriteNode) {
        currentLevel -= 1
        scoringEngine.resetTime()
        newGame(level: currentLevel, didWin: false)
    }
    
}
