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
    private var pauseResetEngine: PauseResetEngine
    private var offlinePlaySprite: OfflinePlaySprite
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
            offlinePlaySprite = OfflinePlaySprite(shouldShowOfflinePlay: false)
            levelStatsArray = saveStateModel.levelStatsArray
        }
        else {
            gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)
            scoringEngine = ScoringEngine()
            offlinePlaySprite = OfflinePlaySprite(shouldShowOfflinePlay: true)
            levelStatsArray = []
        }
        
        // FIXME: - chatEngine MUST be initialized here, and not in properties, otherwise it just refuses to show up! Because K.ScreenDimensions.topOfGameboard is set in the gameEngine(). Is there a better way to do this??
        chatEngine = ChatEngine()
        pauseResetEngine = PauseResetEngine()
        self.user = user
        
        // FIXME: - Debugging purposes only
        levelSkipEngine = LevelSkipEngine(user: user)
        
        super.init(size: size)
        
        AdMobManager.shared.delegate = self
        IAPManager.shared.delegate = self
        gameEngine.delegate = self
        continueSprite.delegate = self
        chatEngine.delegate = self
        pauseResetEngine.delegate = self
        
        // FIXME: - Debuging purposes only!!!
        levelSkipEngine.delegate = self
        
        AudioManager.shared.stopSound(for: "continueloop")
        AudioManager.shared.playSound(for: AudioManager.shared.currentTheme)
        
        backgroundColor = .systemBlue
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
                    
                    self.restartLevel(lives: LifeSpawnerModel.defaultLives)
                }
                
                self.continueSprite.updateTimeToReplenishLives(time: timeToReplenishLives)
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
        
        if gameEngine.checkControlGuardsIfPassed(includeDisableInputFromOutside: false) {
            // FIXME: - Too many if/else to handle disabled from outside BUT special function is enabled...
            if !gameEngine.disableInputFromOutside || pauseResetEngine.specialFunctionEnabled {
                pauseResetEngine.touchDown(in: location, resetCompletion: { [unowned self] in
                    gameEngine.killAndReset()
                })
            }
        }

        guard !pauseResetEngine.isPaused else { return print("Game is paused. quitting.") }
        
        gameEngine.handleControls(in: location)
        
        if !activityIndicator.isShowing {
            continueSprite.didTapButton(in: location)
        }
        
        // FIXME: - Debuging purposes only!!!
        levelSkipEngine.handleControls(in: location)
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard gameEngine.checkControlGuardsIfPassed(includeDisableInputFromOutside: false) else { return }
        
        // FIXME: - Too many if/else to handle disabled from outside BUT special function is enabled...
        if !gameEngine.disableInputFromOutside || pauseResetEngine.specialFunctionEnabled {
            pauseResetEngine.touch(in: location, function: pauseResetEngine.handleControls)
            pauseResetEngine.touch(in: nil, function: pauseResetEngine.touchUp)
        }
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
        for child in children {
            //don't kill the party.....
            if !(child is PartyModeSprite) {
                child.removeFromParent()
            }
        }
        
        gameEngine.newGame(level: level, shouldSpawn: !didWin)
        
        //DO NOT CREATE NEW INSTANCES EVERY TIME!!! THIS CAUSES MEMORY LEAKS! 3/30/23
//        gameEngine = GameEngine(level: level, shouldSpawn: !didWin)
//        gameEngine.delegate = self
        
        moveSprites()
        playDialogue()
        
        if !didWin {
            AudioManager.shared.stopSound(for: "continueloop")
            AudioManager.shared.playSound(for: AudioManager.shared.currentTheme)

            checkForParty()
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
        AudioManager.shared.lowerVolume(for: AudioManager.shared.currentTheme, fadeDuration: 1.0)

        adSprite = SKSpriteNode(color: .clear,
                                size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        adSprite.anchorPoint = .zero
        adSprite.zPosition = K.ZPosition.adSceneBlackout
        addChild(adSprite)

        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)

        adSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: 1.0)) {
            completion?()
        }
    }
    
    private func continueFromAd(completion: (() -> Void)?) {
        AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme, fadeDuration: 1.0)

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
        pauseResetEngine.moveSprites(to: self)
        
        offlinePlaySprite.refreshStatus()
        addChild(offlinePlaySprite)
        
        // FIXME: - Debuging purposes only!!!
        if let user = user, user.uid == "3SeIWmlATmbav7jwCDjXyiA0TgA3" || user.uid == "NB9OLr2X8kRLJ7S0G8W3800qo8U2" || user.uid == "jnsBD8RFVDMN9cSN8yDnFDoVJp32" {
            levelSkipEngine.moveSprites(to: self)
        }
    }
    
    private func playDialogue() {
        //Only disable input on certain levels, i.e. the important ones w/ instructions.
        guard chatEngine.shouldPauseGame(level: currentLevel) else { return }

        //Prevents chat dialogue from appearing if user dies on a level with instructions and continue message prompt is showing.
        guard gameEngine.canContinue else { return }

        scoringEngine.timerManager.pauseTime()
        stopTimer()
        pauseResetEngine.specialFunctionEnabled = true
        gameEngine.shouldDisableInput(true)

        chatEngine.dialogue(level: currentLevel) { [unowned self] in
            scoringEngine.timerManager.resumeTime()
            startTimer()
            pauseResetEngine.specialFunctionEnabled = false
            gameEngine.shouldDisableInput(false)
        }
    }
}


// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func gameIsPaused(isPaused: Bool) {
        if isPaused {
            scoringEngine.timerManager.pauseTime()
            stopTimer()
            AudioManager.shared.adjustVolume(to: 0.1, for: AudioManager.shared.currentTheme, fadeDuration: 0.25)
            print("Pausing game")
        }
        else {
            scoringEngine.timerManager.resumeTime()
            startTimer()
            AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme, fadeDuration: 0.25)
            print("Unpausing game")
        }
    }
    
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
        
        if currentLevel >= 80 && scoringEngine.timerManager.elapsedTime <= 6 {
            GameCenterManager.shared.updateProgress(achievement: .speedDemon, shouldReportImmediately: true)
        }
        
        if currentLevel >= 80 && scoringEngine.timerManager.elapsedTime >= 15 * 60 {
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

                continueSprite.animateShow {
                    AudioManager.shared.playSound(for: "continueloop")
                }
            }
                
            if firstTimeCalled || LifeSpawnerModel.shared.setTimerIfNotSet() {
                LifeSpawnerModel.shared.removeAllNotifications()
                LifeSpawnerModel.shared.scheduleNotification(title: "\(LifeSpawnerModel.defaultLives) Lives Granted!",
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
    
    private func forwardReverseHelper() {
        scoringEngine.timerManager.resetTime()
        scoringEngine.scoringManager.resetScore()
        scoringEngine.updateLabels()
        newGame(level: currentLevel, didWin: true)
    }
    
    func viewAchievementsPressed(_ node: SKSpriteNode) {
        GameCenterManager.shared.showLeaderboard(level: currentLevel)
    }
    
    func partyModePressed(_ node: SKSpriteNode) {
        PartyModeSprite.shared.toggleIsPartying()
        checkForParty()
    }
    
    private func checkForParty() {
        if PartyModeSprite.shared.isPartying {
            PartyModeSprite.shared.startParty(to: self, partyBoy: gameEngine.playerSprite)
        }
        else {
            PartyModeSprite.shared.stopParty(partyBoy: gameEngine.playerSprite)
        }
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
        AudioManager.shared.stopSound(for: "continueloop", fadeDuration: 0.5)
    }
    
    func didDismissRewarded() {
        pendingLivesReplenishmentTimerOffset()
        
        restartLevel(lives: ContinueSprite.extraLivesAd)
    }
    
    func rewardedFailed() {
        print("Reward failed. Now what...")
    }
    
    private func restartLevel(shouldSkip shouldSkipLevel: Bool = false, lives: Int) {
        AudioManager.shared.stopSound(for: "continueloop")
        
        continueSprite.animateHide { [unowned self] in
            continueFromAd { [unowned self] in
                AudioManager.shared.playSound(for: "revive")
            
                scoringEngine.scoringManager.resetScore()
                scoringEngine.updateLabels()
                
                //Make sure to save current state, and increment currentLevel if skipping ahead
                if shouldSkipLevel {
                    saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))

                    currentLevel += 1
                    
                    scoringEngine.scaleScoreLabelDidSkipLevel()
                    scoringEngine.timerManager.resetTime()
                }
                
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
    
    func didTapSkipLevel() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.skipLevel }) else {
            print("Unable to find IAP: Skip Level ($1.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
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
        else if transaction.payment.productIdentifier == IAPManager.skipLevel {
            restartLevel(shouldSkip: true, lives: LifeSpawnerModel.defaultLives)
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


// MARK: - PauseResetEngineDelegate

extension GameScene: PauseResetEngineDelegate {
    func didTapPause(isPaused: Bool) {
        if isPaused {
            scoringEngine.timerManager.pauseTime()
            stopTimer()
            AudioManager.shared.adjustVolume(to: 0.1, for: AudioManager.shared.currentTheme, fadeDuration: 0.25)
        }
        else {
            scoringEngine.timerManager.resumeTime()
            startTimer()
            AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme, fadeDuration: 0.25)
        }
    }
    
    func didTapButtonSpecial() {
        if chatEngine.fastForward() {
            //Putting these here so that I can only have it execute if fastForward is successful. Prevents spamming the button
            AudioManager.shared.playSound(for: "buttontap2")
            Haptics.shared.addHapticFeedback(withStyle: .soft)
        }
    }
    
    
}


// MARK: - ChatEngineDelegate

extension GameScene: ChatEngineDelegate {
    func illuminatePanel(at panelName: (row: Int, col: Int), useOverlay: Bool) {
        gameEngine.gameboardSprite.illuminatePanel(at: panelName, useOverlay: useOverlay)
    }
    
    func deIlluminatePanel(at panelName: (row: Int, col: Int), useOverlay: Bool) {
        gameEngine.gameboardSprite.deIlluminatePanel(at: panelName, useOverlay: useOverlay)
    }
    
    func illuminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName) {
        switch displayType {
        case .lives:    gameEngine.displaySprite.statusLives.illuminateNode()
        case .health:   gameEngine.displaySprite.statusHealth.illuminateNode(pointLeft: true)
        case .moves:    gameEngine.displaySprite.statusMoves.illuminateNode(pointLeft: true)
        case .hammers:  gameEngine.displaySprite.statusHammers.illuminateNode(pointLeft: false)
        case .swords:   gameEngine.displaySprite.statusSwords.illuminateNode(pointLeft: false)
        }
    }
    
    func deIlluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName) {
        switch displayType {
        case .lives:    gameEngine.displaySprite.statusLives.deIlluminateNode()
        case .health:   gameEngine.displaySprite.statusHealth.deIlluminateNode()
        case .moves:    gameEngine.displaySprite.statusMoves.deIlluminateNode()
        case .hammers:  gameEngine.displaySprite.statusHammers.deIlluminateNode()
        case .swords:   gameEngine.displaySprite.statusSwords.deIlluminateNode()
        }
    }
}
