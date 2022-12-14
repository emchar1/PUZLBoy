//
//  GameScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit
import FirebaseAuth

class GameScene: SKScene {
    
    // MARK: - Properties
    
    private var gameEngine: GameEngine
    private var scoringEngine: ScoringEngine
    private var chatEngine: ChatEngine
    
    // FIXME: - Debugging purposes only!!!
    private var levelSkipEngine: LevelSkipEngine

    private var user: User?
    private var disableInput = false
    private var pauseTimer = false

    private var currentLevel: Int = 1 {
        // FIXME: - Delete once debugging is done!
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
    
    init(size: CGSize, user: User?, saveStateModel: SaveStateModel?) {
        if let saveStateModel = saveStateModel {
            currentLevel = saveStateModel.level

            gameEngine = GameEngine(level: currentLevel, livesRemaining: saveStateModel.livesRemaining, shouldSpawn: true)
            scoringEngine = ScoringEngine(elapsedTime: saveStateModel.elapsedTime, totalScore: saveStateModel.totalScore)
        }
        else {
            gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)
            scoringEngine = ScoringEngine()
        }
        
        chatEngine = ChatEngine()
        self.user = user

        // FIXME: - Debugging purposes only
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

        chatEngine.fastForward(in: location)

        guard !disableInput else { return }

        gameEngine.handleControls(in: location)
        levelSkipEngine.handleControls(in: location)
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        moveSprites()
        startTimer()
        playDialogue()
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
        
        pauseTimer = false
    }
    
    private func stopTimer() {
        removeAction(forKey: "runTimerAction")
        
        scoringEngine.updateLabels()
        
        pauseTimer = true
    }
    
    private func newGame(level: Int, didWin: Bool) {
        removeAllChildren()
        
        gameEngine = GameEngine(level: level, shouldSpawn: !didWin)
        gameEngine.delegate = self
        
        moveSprites()
        playDialogue()
        
        if !didWin {
            AudioManager.shared.playSound(for: AudioManager.shared.overworldTheme)
        }
    }
    
    private func moveSprites() {
        gameEngine.moveSprites(to: self)
        scoringEngine.moveSprites(to: self)
        chatEngine.moveSprites(to: self)
        levelSkipEngine.moveSprites(to: self)
    }
    
    private func playDialogue() {
        //Only disable input on certain levels, i.e. the important ones w/ instructions.
        if chatEngine.shouldPauseGame(level: currentLevel) {
            scoringEngine.resetTime()
            stopTimer()
            
            disableInput = true
        }
        
        chatEngine.dialogue(level: currentLevel) { [unowned self] in
            if pauseTimer {
                scoringEngine.resetTime()
                startTimer()
            }

            disableInput = false
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

            //Write to Firestore
            if let user = user {
                let saveStateModel = SaveStateModel(elapsedTime: scoringEngine.elapsedTime,
                                                    saveDate: Date(),
                                                    level: currentLevel,
                                                    livesRemaining: GameEngine.livesRemaining,
                                                    totalScore: scoringEngine.totalScore + scoringEngine.score,
                                                    uid: user.uid)

                FIRManager.writeToFirestoreRecord(user: user, saveStateModel: saveStateModel)
            }
        }
    }
    
    func gameIsOver() {
//        guard gameEngine.canContinue else {
//            stopTimer()
            
//            let continueScene = ContinueScene(size: K.ScreenDimensions.screenSize)
//            removeAllChildren()
//            return
//        }
        
        
        
        
        chatEngine.dialogue(level: -1) { [unowned self] in
            scoringEngine.resetScore()
            scoringEngine.updateLabels()
                    
            newGame(level: currentLevel, didWin: false)
        }
        
        
        
        
        
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
