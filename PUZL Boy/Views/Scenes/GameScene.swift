//
//  GameScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit
import FirebaseAuth
import StoreKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    private var gameEngine: GameEngine
    private var scoringEngine: ScoringEngine
    private var chatEngine: ChatEngine
    private var levelStatsArray: [LevelStats]

    private var continueSprite = ContinueSprite()
    private var activityIndicator = ActivityIndicatorSprite()
    private var adSprite = SKSpriteNode()
    private var user: User?
    private var replenishLivesTimerOffset: Date?
    private let keyRunGameTimerAction = "runGameTimerAction"
    private let keyRunReplenishLivesTimerAction = "runReplenishLivesTimerAction"

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
            currentLevel = saveStateModel.newLevel //ALWAYS go with newLevel, because it takes precedence over levelModel.level
            gameEngine = GameEngine(saveStateModel: saveStateModel)
            scoringEngine = ScoringEngine(elapsedTime: saveStateModel.elapsedTime,
                                          score: saveStateModel.score,
                                          totalScore: saveStateModel.totalScore)
            levelStatsArray = saveStateModel.levelStatsArray
        }
        else {
            gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)
            scoringEngine = ScoringEngine()
            levelStatsArray = []
        }
        
        //chatEngine MUST be initialized here, and not in properties, otherwise it just refuses to show up!
        chatEngine = ChatEngine()
        self.user = user

        // FIXME: - Debugging purposes only
        levelSkipEngine = LevelSkipEngine()
        
        super.init(size: size)

        AdMobManager.shared.delegate = self
        IAPManager.shared.delegate = self
        gameEngine.delegate = self
        continueSprite.delegate = self

        // FIXME: - Debuging purposes only!!!
        levelSkipEngine.delegate = self
        
        AudioManager.shared.playSound(for: AudioManager.shared.overworldTheme)

        scaleMode = .aspectFill
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Notification Center Functions
    
    //Save Level/Gameboard state
    @objc private func appMovedToBackground() {
        if action(forKey: keyRunGameTimerAction) != nil {
            //Only pause/resume time if there's an active timer going, i.e. timer is started!
            scoringEngine.timerManager.pauseTime()
        }

        if gameEngine.canContinue {
            LifeSpawnerModel.shared.removeAllNotifications()
            LifeSpawnerModel.shared.scheduleNotification(title: "Play Again?", duration: LifeSpawnerModel.durationReminder, repeats: true)
        }
        
        saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
    }
    
    @objc private func appMovedToForeground() {
        if action(forKey: keyRunGameTimerAction) != nil {
            scoringEngine.timerManager.resumeTime()
        }
        
        if !gameEngine.canContinue && replenishLivesTimerOffset == nil {
            runReplenishLivesTimer()
        }
    }
    
    private func runReplenishLivesTimer() {
        guard action(forKey: keyRunReplenishLivesTimerAction) == nil else {
            print("keyRunReplenishLivesTimerAction already active! Returning...")
            return
        }
        
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run {
            do {
                let timeToReplenishLives = try LifeSpawnerModel.shared.getTimeToFinish(finishTime: LifeSpawnerModel.durationMoreLives)
                
                if timeToReplenishLives <= 0 {
                    self.removeAction(forKey: self.keyRunReplenishLivesTimerAction)
                    
                    self.restartLevel(lives: LifeSpawnerModel.lives)
                }
                
                self.continueSprite.updateTimeToReplenishLives(time: timeToReplenishLives)
                print("Time to replenish: \(timeToReplenishLives)")
            }
            catch {
                self.removeAction(forKey: self.keyRunReplenishLivesTimerAction)
                print("runReplenishLivesTimer() error: \(error.localizedDescription)")
            }
        }
        let sequence = SKAction.sequence([wait, block])
        
        run(SKAction.repeatForever(sequence), withKey: keyRunReplenishLivesTimerAction)
    }
    
    
    // MARK: - UI Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        chatEngine.fastForward(in: location)
        gameEngine.handleControls(in: location)
        
        if !activityIndicator.isShowing {
            continueSprite.didTapButton(touches)
        }
        
        // FIXME: - Debuging purposes only!!!
        levelSkipEngine.handleControls(in: location)
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        moveSprites()
        startTimer()
        playDialogue()
        
        gameEngine.checkIfGameOverOnStartup()
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    // MARK: - Helper Functions
    
    ///Starts the timer, used for scoring in the game.
    private func startTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run { [unowned self] in
            scoringEngine.timerManager.pollTime()
            scoringEngine.updateLabels()
        }
        let sequence = SKAction.sequence([wait, block])
        
        run(SKAction.repeatForever(sequence), withKey: keyRunGameTimerAction)
    }
    
    //Stops the timer when gameplay has been paused.
    private func stopTimer() {
        removeAction(forKey: keyRunGameTimerAction)
                
        scoringEngine.updateLabels()
    }
    
    /**
     Saves the state of the gameplay, including elapsed time, current gameboard state, lives remaining, and player position.
     - parameters:
        - didWin: returns true if the level has been beat
        - levelStatsItem: the current level stats to save to Firebase
     */
    private func saveState(levelStatsItem: LevelStats) {
        guard let user = user, LevelBuilder.maxLevel > 0 else { return }
        
        if levelStatsArray.filter({ $0 == levelStatsItem }).first != nil {
            if let indexFound = levelStatsArray.firstIndex(where: { $0 == levelStatsItem }) {
                print("Level \(levelStatsItem.level) already exists. Updating...")
                
                levelStatsArray[indexFound] = levelStatsItem
            }
        }
        else {
            print("Level \(levelStatsItem.level) is new. Adding...")
            levelStatsArray.append(levelStatsItem)
        }
        
        let levelModel = gameEngine.level.getLevelModel(
            level: currentLevel,
            movesRemaining: gameEngine.movesRemaining,
            heathRemaining: gameEngine.healthRemaining,
            gemsCollected: gameEngine.gemsCollected,
            gemsRemaining: gameEngine.gemsRemaining,
            playerPosition: PlayerPosition(row: gameEngine.level.player.row, col: gameEngine.level.player.col),
            inventory: gameEngine.level.inventory)
        
        let saveStateModel = SaveStateModel(
            saveDate: Date(),
            elapsedTime: scoringEngine.timerManager.elapsedTime,
            livesRemaining: GameEngine.livesRemaining,
            usedContinue: GameEngine.usedContinue,
            score: levelStatsItem.didWin ? 0 : scoringEngine.scoringManager.score,
            totalScore: scoringEngine.scoringManager.totalScore + (levelStatsItem.didWin ? scoringEngine.scoringManager.score : 0),
            winStreak: GameEngine.winStreak,
            levelStatsArray: levelStatsArray,
            levelModel: levelModel,
            newLevel: levelModel.level,
            uid: user.uid)
        
        FIRManager.writeToFirestoreRecord(user: user, saveStateModel: saveStateModel)
    }
    
    ///Creates and returns a Level Stat object, used in the saveState method.
    private func getLevelStatsItem(level: Int, didWin: Bool) -> LevelStats {
        return LevelStats(level: level, elapsedTime: scoringEngine.timerManager.elapsedTime, livesUsed: GameEngine.livesUsed, movesRemaining: gameEngine.movesRemaining, enemiesKilled: gameEngine.enemiesKilled, bouldersBroken: gameEngine.bouldersBroken, score: !didWin ? 0 : scoringEngine.scoringManager.score, didWin: didWin, inventory: gameEngine.level.inventory)
    }
    
    ///Creates a new Game Engine and sets up the appropriate properties.
    private func newGame(level: Int, didWin: Bool) {
        removeAllChildren()
        
        gameEngine = GameEngine(level: level, shouldSpawn: !didWin)
        gameEngine.delegate = self
        
        moveSprites()
        playDialogue()
        
        if !didWin {
            AudioManager.shared.playSound(for: AudioManager.shared.overworldTheme)
        }
        
        // FIXME: - Do I need Interstitial Ads in my game?
        //Play interstitial ad
//        if level % 100 == 0 && level >= 20 && didWin {
//            prepareAd {
//                AdMobManager.shared.presentInterstitial()
//            }
//        }
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
//        //Only disable input on certain levels, i.e. the important ones w/ instructions.
//        guard chatEngine.shouldPauseGame(level: currentLevel) else { return }
//        
//        scoringEngine.timerManager.pauseTime()
//        stopTimer()
//        gameEngine.shouldDisableInput(true)
//        
//        chatEngine.dialogue(level: currentLevel) { [unowned self] in
//            scoringEngine.timerManager.resumeTime()
//            startTimer()
//            gameEngine.shouldDisableInput(false)
//        }
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
        
        //Need to preserve game states before restarting the level but after setting score, so it can save them to Firestore down below.
        let levelStatsItem = getLevelStatsItem(level: currentLevel, didWin: true)

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
            
            //Write to Firestore, MUST come after newGame()
            saveState(levelStatsItem: levelStatsItem)
        }
    }
    
    func gameIsOver(firstTimeCalled: Bool) {
        if !gameEngine.canContinue {
            prepareAd { [unowned self] in
                addChild(continueSprite)
                continueSprite.animateShow {}
            }
                
            if firstTimeCalled {
                LifeSpawnerModel.shared.removeAllNotifications()
                LifeSpawnerModel.shared.scheduleNotification(title: "\(LifeSpawnerModel.lives) Lives Granted!",
                                                             duration: LifeSpawnerModel.durationMoreLives, repeats: false)
                
                LifeSpawnerModel.shared.setTimer()
            }
            
            runReplenishLivesTimer()
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
            scoringEngine.timerManager.resetTime()
            startTimer()
        }
    }

    
    // MARK: - Rewarded Functions
    
    func willPresentRewarded() {
        replenishLivesTimerOffset = Date()
        removeAction(forKey: keyRunReplenishLivesTimerAction)
    }
    
    func didDismissRewarded() {
        pendingLivesReplenishmentTimerOffset()
        
        restartLevel(lives: ContinueSprite.extraLivesAd)
    }
    
    func rewardedFailed() {
        print("Reward failed. Now what...")
    }
    
    private func restartLevel(lives: Int) {
        continueSprite.animateHide { [unowned self] in
            continueFromAd { [unowned self] in
                AudioManager.shared.playSound(for: "revive")
            
                scoringEngine.scoringManager.resetScore()
                scoringEngine.updateLabels()

                newGame(level: currentLevel, didWin: false)

                gameEngine.animateLives(newLives: lives)
                gameEngine.setLivesRemaining(lives: lives)

                saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
                
                continueSprite.removeFromParent()
                
                LifeSpawnerModel.shared.removeTimer()
                LifeSpawnerModel.shared.removeAllNotifications()
            }
        }
    }
    
    
}


// MARK: - ContinueSpriteDelegate

extension GameScene: ContinueSpriteDelegate {
    func didTapWatchAd() {
        AdMobManager.shared.presentRewarded { (adReward) in
            // FIXME: - Why grant the reward here, when I can grant it in ad did dismiss down below???
            print("You were rewarded: \(adReward.amount) lives!")
        }
    }
    
    func didTapFinishInstantly() {
        print("Not yet implemented...")
    }
    
    func didTapBuy099Button() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives25 }) else {
            print("Unable to find IAP: 25 Lives ($0.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
    
    func didTapBuy299Button() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives100 }) else {
            print("Unable to find IAP: 100 Lives ($2.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
}


// MARK: - IAPManagerDelegate

extension GameScene: IAPManagerDelegate {
    func didCompletePurchase(transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier == IAPManager.lives25 {
            restartLevel(lives: ContinueSprite.extraLivesBuy099)
        }
        else if transaction.payment.productIdentifier == IAPManager.lives100 {
            restartLevel(lives: ContinueSprite.extraLivesBuy299)
        }
        
        activityIndicator.removeFromParent()
        
        pendingLivesReplenishmentTimerOffset()
    }
    
    func purchaseDidFail(transaction: SKPaymentTransaction) {
        activityIndicator.removeFromParent()

        pendingLivesReplenishmentTimerOffset()
    }
    
    func isPurchasing(transaction: SKPaymentTransaction) {
        activityIndicator.move(toParent: self)
        
        replenishLivesTimerOffset = Date()
        removeAction(forKey: keyRunReplenishLivesTimerAction)
    }
    
    private func pendingLivesReplenishmentTimerOffset() {
        guard let replenishLivesTimerOffset = replenishLivesTimerOffset else { return }

        let newTimerOffset = Date()

        LifeSpawnerModel.shared.updateTimer(add: newTimerOffset.timeIntervalSinceReferenceDate - replenishLivesTimerOffset.timeIntervalSinceReferenceDate)
        
        self.replenishLivesTimerOffset = nil

        runReplenishLivesTimer()
    }
    
    
}
