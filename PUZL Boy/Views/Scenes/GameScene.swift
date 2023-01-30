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
    
    private var continueSprite = ContinueSprite()
    private var adSprite = SKSpriteNode()
    private var user: User?
    private let keyRunTimerAction = "runTimerAction"

    private var currentLevel: Int = 1 {
        // FIXME: - Debuging purposes only!!!
        didSet {
            if currentLevel > LevelBuilder.maxLevel {
                currentLevel = 0
            }
            else if currentLevel < 0 {
                currentLevel = LevelBuilder.maxLevel
            }
        }
    }
    
    // FIXME: - Debugging purposes only!!!
    private var levelSkipEngine: LevelSkipEngine
    
    
    // MARK: - Initialization
    
    init(size: CGSize, user: User?, saveStateModel: SaveStateModel?) {
        if let saveStateModel = saveStateModel {
            currentLevel = saveStateModel.levelModel.level
            gameEngine = GameEngine(saveStateModel: saveStateModel)
            scoringEngine = ScoringEngine(elapsedTime: saveStateModel.elapsedTime,
                                          score: saveStateModel.score,
                                          totalScore: saveStateModel.totalScore)
        }
        else {
            gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)
            scoringEngine = ScoringEngine()
        }
        
        //chatEngine MUST be initialized here, and not in properties, otherwise it just refuses to show up!
        chatEngine = ChatEngine()
        self.user = user

        // FIXME: - Debugging purposes only
        levelSkipEngine = LevelSkipEngine()
        
        super.init(size: size)

        AdMobManager.shared.delegate = self
        AudioManager.shared.playSound(for: AudioManager.shared.overworldTheme)

        gameEngine.delegate = self
        continueSprite.delegate = self
        continueSprite.shouldDisableInput(true)

        // FIXME: - Debuging purposes only!!!
        levelSkipEngine.delegate = self
        
        scaleMode = .aspectFill
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func appMovedToBackground() {
        if action(forKey: keyRunTimerAction) != nil {
            //Only pause/resume time if there's an active timer going, i.e. timer is started!
            scoringEngine.timerManager.pauseTime()
        }

        saveState(didWin: false)
    }
    
    @objc private func appMovedToForeground() {
        if action(forKey: keyRunTimerAction) != nil {
            scoringEngine.timerManager.resumeTime()
        }
    }
    
    
    // MARK: - UI Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        chatEngine.fastForward(in: location)
        continueSprite.didTapButton(in: location)
        gameEngine.handleControls(in: location)
        
        // FIXME: - Debuging purposes only!!!
        levelSkipEngine.handleControls(in: location)
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        print("GameScene.didMove() called.")
        moveSprites()
        startTimer()
        playDialogue()
        
        gameEngine.shouldPlayAdOnStartup()
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    // MARK: - Helper Functions
    
    private func startTimer() {
        print("GameScene.startTimer() called!")
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run { [unowned self] in
            scoringEngine.timerManager.pollTime()
            scoringEngine.updateLabels()
        }
        let sequence = SKAction.sequence([wait, block])
        
        run(SKAction.repeatForever(sequence), withKey: keyRunTimerAction)
    }
    
    private func stopTimer() {
        print("GameScene.stopTimer() called!")
        removeAction(forKey: keyRunTimerAction)
                
        scoringEngine.updateLabels()
    }
    
    private func saveState(didWin: Bool) {
        guard let user = user, LevelBuilder.maxLevel > 0 else { return }
        
        let levelModel = gameEngine.level.getLevelModel(
            level: currentLevel,
            movesRemaining: gameEngine.movesRemaining,
            heathRemaining: gameEngine.healthRemaining)
        
        let saveStateModel = SaveStateModel(
            saveDate: Date(),
            elapsedTime: scoringEngine.timerManager.elapsedTime,
            livesRemaining: GameEngine.livesRemaining,
            usedContinue: GameEngine.usedContinue,
            score: didWin ? 0 : scoringEngine.scoringManager.score,
            totalScore: scoringEngine.scoringManager.totalScore + (didWin ? scoringEngine.scoringManager.score : 0),
            gemsRemaining: gameEngine.gemsRemaining,
            gemsCollected: gameEngine.gemsCollected,
            winStreak: GameEngine.winStreak,
            inventory: gameEngine.level.inventory,
            playerPosition: PlayerPosition(row: gameEngine.level.player.row, col: gameEngine.level.player.col),
            levelModel: levelModel,
            uid: user.uid)
        
        FIRManager.writeToFirestoreRecord(user: user, saveStateModel: saveStateModel)
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
        
        //Play interstitial ad
        if level % 100 == 0 && level >= 20 && didWin {
            prepareAd {
                AdMobManager.shared.presentInterstitial()
            }
        }
    }
    
    private func prepareAd(completion: (() -> Void)?) {
        AudioManager.shared.lowerVolume(for: AudioManager.shared.overworldTheme, fadeDuration: 1.0)

        adSprite = SKSpriteNode(color: .clear,
                                size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        adSprite.anchorPoint = .zero
        adSprite.zPosition = K.ZPosition.adScene
        addChild(adSprite)

        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)

        adSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: 1.0)) {
            completion?()
        }
    }
    
    private func continueFromAd(completion: (() -> Void)?) {
        AudioManager.shared.raiseVolume(for: AudioManager.shared.overworldTheme, fadeDuration: 1.0)

        adSprite.run(SKAction.colorize(with: .clear, colorBlendFactor: 1.0, duration: 1.0)) { [unowned self] in
            adSprite.removeFromParent()

            scoringEngine.timerManager.resumeTime()
            startTimer()
            gameEngine.shouldDisableInput(false)

            completion?()
        }
    }
    
    private func moveSprites() {
        gameEngine.moveSprites(to: self)
        scoringEngine.moveSprites(to: self)
        chatEngine.moveSprites(to: self)
        
        // FIXME: - Debuging purposes only!!!
        levelSkipEngine.moveSprites(to: self)
    }
    
    private func playDialogue() {
        // FIXME: - Turning off temporarily
        return
        
        
        
        //Only disable input on certain levels, i.e. the important ones w/ instructions.
        guard chatEngine.shouldPauseGame(level: currentLevel) else { return }
        
        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)
        
        chatEngine.dialogue(level: currentLevel) { [unowned self] in
            scoringEngine.timerManager.resumeTime()
            startTimer()
            gameEngine.shouldDisableInput(false)
        }
    }
}


// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func enemyIsKilled() {
        scoringEngine.scoringManager.addToScore(1000)
        scoringEngine.updateLabels()
    }
    
    func gameIsSolved(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool) {
        let score = scoringEngine.calculateScore(movesRemaining: movesRemaining,
                                                 itemsFound: itemsFound,
                                                 enemiesKilled: enemiesKilled,
                                                 usedContinue: usedContinue)
        scoringEngine.animateScore(usedContinue: usedContinue)
        gameEngine.updateScores()
        stopTimer()

        GameCenterManager.shared.postScoreToLeaderboard(score: score, level: currentLevel)
        
        if currentLevel >= 25 && scoringEngine.timerManager.elapsedTime <= 6 {
            GameCenterManager.shared.updateProgress(achievement: .speedDemon, shouldReportImmediately: true)
        }
        
        if currentLevel >= 25 && scoringEngine.timerManager.elapsedTime >= 15 * 60 {
            GameCenterManager.shared.updateProgress(achievement: .slowPoke, shouldReportImmediately: true)
        }
        
        currentLevel += 1
        
        gameEngine.fadeGameboard(fadeOut: true) { [unowned self] in
            scoringEngine.timerManager.resetTime()
            startTimer()
            newGame(level: currentLevel, didWin: true)

            //Write to Firestore
            saveState(didWin: true)
        }
    }
    
    func gameIsOver() {
        if !gameEngine.canContinue {
            prepareAd { [unowned self] in
                addChild(continueSprite)
                continueSprite.animateShow { [unowned self] in
                    continueSprite.shouldDisableInput(false)
                }
            }
        }
        else {
            scoringEngine.scoringManager.resetScore()
            scoringEngine.updateLabels()
            newGame(level: currentLevel, didWin: false)
        }
    }
    
    
}


// MARK: - LevelSkipEngineDelegate

extension GameScene: LevelSkipEngineDelegate {
    func fowardPressed(_ node: SKSpriteNode) {
        currentLevel += 1
        forwardReverseHelper()
    }
    
    func reversePressed(_ node: SKSpriteNode) {
        currentLevel -= 1
        forwardReverseHelper()
    }
    
    func viewAchievementsPressed(node: SKSpriteNode) {
        GameCenterManager.shared.showLeaderboard(level: currentLevel)
    }
    
    private func forwardReverseHelper() {
        scoringEngine.timerManager.resetTime()
        scoringEngine.scoringManager.resetScore()
        scoringEngine.updateLabels()
        newGame(level: currentLevel, didWin: true)
    }
}


// MARK: - AdMobManagerDelegate

extension GameScene: AdMobManagerDelegate {
    
    // MARK: - Interstitial Functions
    
    func willPresentInterstitial() {
        
    }
    
    func didDismissInterstitial() {
        resumeGame()
    }
    
    func interstitialFailed() {
        print("Interstitial failed. Now what...")
    }
    
    private func resumeGame() {
        continueFromAd { [unowned self] in
            continueSprite.shouldDisableInput(true)
            scoringEngine.timerManager.resetTime()
            startTimer()
        }
    }

    
    // MARK: - Rewarded Functions
    
    func willPresentRewarded() {
        
    }
    
    func didDismissRewarded() {
        restartLevel()
    }
    
    func rewardedFailed() {
        print("Reward failed. Now what...")
    }
    
    private func restartLevel() {
        continueSprite.animateHide { [unowned self] in
            continueFromAd { [unowned self] in
                AudioManager.shared.playSound(for: "revive")
            
                gameEngine.setLivesRemaining(lives: 3)
                scoringEngine.scoringManager.resetScore()
                scoringEngine.updateLabels()
                newGame(level: currentLevel, didWin: false)
                saveState(didWin: false)
                
                continueSprite.shouldDisableInput(true)
                continueSprite.removeFromParent()
            }
        }
    }
    
    
}


// MARK: - ContinueSpriteDelegate

extension GameScene: ContinueSpriteDelegate {
    func didTapWatchAd() {
        AdMobManager.shared.presentRewarded { (adReward) in
            // FIXME: - Why grant the reward here, when I can grant it in ad did dismiss down below???
            print("You were rewarded: \(adReward.amount) lives!!!!!")
        }
    }
    
    func didTapBuyButton() {
        print("Needs implementation")
    }
}
