//
//  GameScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit
import FirebaseAuth
import StoreKit

protocol GameSceneDelegate: AnyObject {
    func confirmQuitTapped()
}


class GameScene: SKScene {
    
    // MARK: - Properties
    
    private var gameEngine: GameEngine
    private var scoringEngine: ScoringEngine
    private var chatEngine: ChatEngine
    private var pauseResetEngine: PauseResetEngine
    private var resetConfirmSprite: ConfirmSprite
    private var hintConfirmSprite: ConfirmSprite
    private var offlinePlaySprite: OfflinePlaySprite
    private var levelStatsArray: [LevelStats]
    
    private var continueSprite = ContinueSprite()
    private var activityIndicator = ActivityIndicatorSprite()
    private var adSprite = SKSpriteNode()
    private var user: User?
    private var replenishLivesTimerOffset: Date?
    private let keyRunGameTimerAction = "runGameTimerAction"
    private let keyRunReplenishLivesTimerAction = "runReplenishLivesTimerAction"
    
    private var lastCurrentLevel: Int?
    private var currentLevel: Int = 1 {
        // FIXME: - Debugging purposes only!!!
        didSet {
            guard !Level.isPartyLevel(currentLevel) else { return }
            
            if currentLevel > LevelBuilder.maxLevel {
                currentLevel = 1
            }
            else if currentLevel < 1 {
                currentLevel = LevelBuilder.maxLevel
            }
        }
    }
    
    // FIXME: - Debugging purposes only!!!
    private var levelSkipEngine: LevelSkipEngine
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    
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
        
        //chatEngine MUST be initialized here, and not in properties, otherwise it just refuses to show up! Because K.ScreenDimensions.topOfGameboard is set in the gameEngine(). Is there a better way to do this??
        chatEngine = ChatEngine()
        pauseResetEngine = PauseResetEngine(user: user, level: currentLevel)
        resetConfirmSprite = ConfirmSprite(title: "FEELING STUCK?",
                                           message: "Tap Restart Level to start over. You'll lose a life in the process.",
                                           confirm: "Restart Level",
                                           cancel: "Cancel")
        
        hintConfirmSprite = ConfirmSprite(title: "NEED A HINT?",
                                          message: "The hint feature is not yet available, but will be soon. Maybe in the next version... Stay tuned!",
                                          confirm: "OK",
                                          cancel: "OK, but in blue")
        
        self.user = user
        
        // FIXME: - Debugging purposes only!!!
        levelSkipEngine = LevelSkipEngine(user: user)
        
        super.init(size: size)
        
        gameEngine.delegate = self
        continueSprite.delegate = self
        chatEngine.delegate = self
        pauseResetEngine.delegate = self
        resetConfirmSprite.delegate = self
        hintConfirmSprite.delegate = self
        
        // FIXME: - Debugging purposes only!!!
        levelSkipEngine.delegate = self
                
        backgroundColor = .systemBlue
        scaleMode = .aspectFill
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit GameScene")
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
        
        //Disable saving in a party level
        if !Level.isPartyLevel(currentLevel) {
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        }
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
            if !gameEngine.disableInputFromOutside {
                pauseResetEngine.touchDown(for: touches)
            }
        }

        guard !pauseResetEngine.isPaused else { return }
        
        gameEngine.handleControls(in: location)
        chatEngine.touchDown(in: location)
        
        if !activityIndicator.isShowing {
            continueSprite.touchDown(in: location)
            resetConfirmSprite.touchDown(in: location)
            hintConfirmSprite.touchDown(in: location)
        }
        
        // FIXME: - Debugging purposes only!!!
        levelSkipEngine.handleControls(in: location)
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if !activityIndicator.isShowing {
            continueSprite.didTapButton(in: location)
            continueSprite.touchUp()
            resetConfirmSprite.didTapButton(in: location)
            resetConfirmSprite.touchUp()
            hintConfirmSprite.didTapButton(in: location)
            hintConfirmSprite.touchUp()
            chatEngine.touchUp()
        }

        
        guard gameEngine.checkControlGuardsIfPassed(includeDisableInputFromOutside: false) else { return }
        
        if !gameEngine.disableInputFromOutside {
            //MUST run these separately!! Can't combine handleControls() and touchUp(for:) in one closure.
            pauseResetEngine.touch(for: touches) { touches in
                pauseResetEngine.handleControls(for: touches)
            }
            
            pauseResetEngine.touch(for: touches) { _ in
                pauseResetEngine.touchUp()
            }            
        }
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        moveSprites()
        
        //These alway need to go in THIS order!
        scoringEngine.timerManager.resumeTime()
        startTimer()
        
        playDialogue()
        
        AudioManager.shared.stopSound(for: "continueloop")
        AudioManager.shared.playSound(for: AudioManager.shared.currentTheme)

        gameEngine.checkIfGameOverOnStartup()
    }
    
    override func willMove(from view: SKView) {
        AudioManager.shared.stopSound(for: AudioManager.shared.currentTheme)
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    // MARK: - Helper Functions
    
    ///Starts the timer, used for scoring in the game.
    private func startTimer() {
        let wait = SKAction.wait(forDuration: Level.isPartyLevel(currentLevel) ? 0.1 : 1.0)
        let block = SKAction.run { [unowned self] in
            scoringEngine.timerManager.pollTime()
            scoringEngine.updateLabels()
            
            if currentLevel == Level.partyLevel && scoringEngine.timerManager.elapsedTime <= 0 {
                prepareForParty()
            }
        }
        let sequence = SKAction.sequence([wait, block])
        
        run(SKAction.repeatForever(sequence), withKey: keyRunGameTimerAction)
    }
    
    //Stops the timer when gameplay has been paused.
    private func stopTimer() {
        removeAction(forKey: keyRunGameTimerAction)
                
        scoringEngine.updateLabels()
    }
    
    ///Used in startTimer() block
    // FIXME: - Can this be reused? I see other parts of the code that is similar
    private func prepareForParty() {
        removeAction(forKey: keyRunGameTimerAction)
        
        guard let lastCurrentLevel = lastCurrentLevel else { return }

        currentLevel = lastCurrentLevel
        self.lastCurrentLevel = nil
        
        gameEngine.shouldDisableInput(true)
        
        gameEngine.fadeGameboard(fadeOut: true) { [unowned self] in
            scoringEngine.timerManager.resetTime()
            startTimer()
            newGame(level: currentLevel, didWin: true)
            
            gameEngine.shouldDisableInput(false)
            
            //Write to Firestore, MUST come after newGame()
            let levelStatsItem = getLevelStatsItem(level: currentLevel, didWin: true)
            saveState(levelStatsItem: levelStatsItem)
        }
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
        
        gameEngine.newGame(level: Level.isPartyLevel(level) ? Level.partyLevel : level, shouldSpawn: !didWin)
        
        if Level.isPartyLevel(level) {
            if !PartyModeSprite.shared.isPartying {
                PartyModeSprite.shared.setIsPartying(true)
                PartyModeSprite.shared.startParty(to: self, partyBoy: gameEngine.playerSprite,
                                                  hasSword: gameEngine.level.inventory.hasSwords(), hasHammer: gameEngine.level.inventory.hasHammers())
                scoringEngine.timerManager.setIsParty(true)
            }
        }
        else {
            if PartyModeSprite.shared.isPartying {
                PartyModeSprite.shared.setIsPartying(false)
                PartyModeSprite.shared.stopParty(partyBoy: gameEngine.playerSprite,
                                                 hasSword: gameEngine.level.inventory.hasSwords(), hasHammer: gameEngine.level.inventory.hasHammers())
                scoringEngine.timerManager.setIsParty(false)
            }
        }
        
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
        
        //Play interstitial ad
//        if level % 100 == 0 && level >= 20 && didWin {
//            prepareAd {
//                AdMobManager.shared.presentInterstitial()
//            }
//        }
    }
    
    private func prepareAd(completion: (() -> Void)?) {
        AudioManager.shared.lowerVolume(for: AudioManager.shared.currentTheme, fadeDuration: 1.0)

        adSprite = SKSpriteNode(color: .clear, size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
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
        scoringEngine.moveSprites(to: self, isPartyLevel: Level.isPartyLevel(currentLevel))
        chatEngine.moveSprites(to: self)

        pauseResetEngine.moveSprites(to: self, level: currentLevel)
        pauseResetEngine.registerHowToPlayTableView()
        
        offlinePlaySprite.refreshStatus()
        addChild(offlinePlaySprite)
        
        // FIXME: - Debugging purposes only!!!
        if let user = user,
           !Level.isPartyLevel(currentLevel),
            user.uid == "3SeIWmlATmbav7jwCDjXyiA0TgA3" ||   //Eddie
            user.uid == "NB9OLr2X8kRLJ7S0G8W3800qo8U2" ||   //Michel
            user.uid == "jnsBD8RFVDMN9cSN8yDnFDoVJp32"      //Mom
        {
            levelSkipEngine.moveSprites(to: self)
        }
    }
    
    private func playDialogue() {
        guard !Level.isPartyLevel(currentLevel) || (lastCurrentLevel != nil && lastCurrentLevel! <= (Level.partyMinLevelRequired + 1)) else { return }
        guard chatEngine.shouldPauseGame(level: currentLevel) else { return }
        guard gameEngine.canContinue else { return }

        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)
        pauseResetEngine.shouldDisable(true)

        chatEngine.dialogue(level: currentLevel) { [unowned self] in
            scoringEngine.timerManager.resumeTime()
            startTimer()
            gameEngine.shouldDisableInput(false)
            pauseResetEngine.shouldDisable(false)
        }
    }
}


// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func gameIsPaused(isPaused: Bool) {
        if isPaused {
            scoringEngine.timerManager.pauseTime()
            stopTimer()
            print("Pausing game")
        }
        else {
            scoringEngine.timerManager.resumeTime()
            startTimer()
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
        
        if currentLevel >= AchievementSpeedDemon.levelRequirement && scoringEngine.timerManager.elapsedTime <= AchievementSpeedDemon.timeRequirement {
            GameCenterManager.shared.updateProgress(achievement: .speedDemon, shouldReportImmediately: true)
        }
        
        if currentLevel >= AchievementSlowPoke.levelRequirement && scoringEngine.timerManager.elapsedTime >= AchievementSlowPoke.timeRequirement {
            GameCenterManager.shared.updateProgress(achievement: .slowPoke, shouldReportImmediately: true)
        }
        
        currentLevel += 1
        
        gameEngine.fadeGameboard(fadeOut: true) { [unowned self] in
            scoringEngine.timerManager.resetTime()
            startTimer()
            newGame(level: currentLevel, didWin: true)
            
            //Write to Firestore, MUST come after newGame()
            if !Level.isPartyLevel(currentLevel) {
                saveState(levelStatsItem: levelStatsItem)
            }
        }
    }
    
    func gameIsOver(firstTimeCalled: Bool) {
        if !gameEngine.canContinue {
            prepareAd { [unowned self] in
                addChild(continueSprite)
                
                pauseResetEngine.shouldDisable(true)

                continueSprite.animateShow(shouldDisable5Moves: gameEngine.healthRemaining <= 0) {
                    IAPManager.shared.delegate = self
                    AdMobManager.shared.delegate = self

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
    
    func didTakePartyPill() {
        lastCurrentLevel = currentLevel
        currentLevel = Level.partyLevel
    }
}


// MARK: - LevelSkipEngineDelegate

extension GameScene: LevelSkipEngineDelegate {
    func forwardPressed(_ node: SKSpriteNode) {
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
        GameCenterManager.shared.showLeaderboard(level: currentLevel, completion: nil)
    }
    
    func partyModePressed(_ node: SKSpriteNode) {
        PartyModeSprite.shared.toggleIsPartying()
        checkForParty()
    }
    
    private func checkForParty() {
        if PartyModeSprite.shared.isPartying {
            PartyModeSprite.shared.startParty(to: self, partyBoy: gameEngine.playerSprite,
                                              hasSword: gameEngine.level.inventory.hasSwords(), hasHammer: gameEngine.level.inventory.hasHammers())
        }
        else {
            PartyModeSprite.shared.stopParty(partyBoy: gameEngine.playerSprite,
                                             hasSword: gameEngine.level.inventory.hasSwords(), hasHammer: gameEngine.level.inventory.hasHammers())
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
        func restartHelper() {
            newGame(level: currentLevel, didWin: false)
            
            gameEngine.animateLives(originalLives: 0, newLives: lives)
            gameEngine.setLivesRemaining(lives: lives)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
            
            continueSprite.removeFromParent()
            
            LifeSpawnerModel.shared.removeTimer()
            LifeSpawnerModel.shared.removeAllNotifications()
        }
        
        
        AudioManager.shared.stopSound(for: "continueloop")
        
        continueSprite.animateHide { [unowned self] in
            continueFromAd { [unowned self] in
                AudioManager.shared.playSound(for: "revive")
            
                scoringEngine.scoringManager.resetScore()
                scoringEngine.updateLabels()
                
                pauseResetEngine.shouldDisable(false)
                
                //Make sure to save current state, and increment currentLevel if skipping ahead
                if shouldSkipLevel {
                    saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))

                    currentLevel += 1
                    
                    scoringEngine.scaleScoreLabelDidSkipLevel()
                    scoringEngine.timerManager.resetTime()
                    
                    gameEngine.fadeGameboard(fadeOut: true) {
                        restartHelper()
                    }
                }
                else {
                    restartHelper()
                }
            }
        }
    }
    
    private func continueLevel(moves: Int) {
        continueSprite.animateHide { [unowned self] in
            continueFromAd { [unowned self] in
                AudioManager.shared.playSound(for: "revive")
                AudioManager.shared.stopSound(for: "continueloop")
                AudioManager.shared.playSound(for: AudioManager.shared.currentTheme)
                
                checkForParty()

                pauseResetEngine.shouldDisable(false)
                gameEngine.continueGame()

                gameEngine.animateMoves(originalMoves: gameEngine.movesRemaining, newMoves: moves)
                gameEngine.incrementMovesRemaining(moves: moves)
                gameEngine.setLivesRemaining(lives: 0)
                
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
            //Why grant the reward here, when I can grant it in ad did dismiss down below???
            print("You were rewarded: \(adReward.amount) lives!")
        }
    }
    
    func didTapSkipLevel() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.skipLevel }) else {
            print("Unable to find IAP: Skip Level ($2.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
    
    func didTapBuy25LivesButton() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives25 }) else {
            print("Unable to find IAP: 25 Lives ($4.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
    
    func didTapBuy100LivesButton() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives100 }) else {
            print("Unable to find IAP: 100 Lives ($9.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
    
    func didTapBuy5MovesButton() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.moves5 }) else {
            print("Unable to find IAP: 5 Moves ($0.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
}


// MARK: - IAPManagerDelegate

extension GameScene: IAPManagerDelegate {
    func didCompletePurchase(transaction: SKPaymentTransaction) {
        switch transaction.payment.productIdentifier {
        case IAPManager.lives25:        restartLevel(lives: ContinueSprite.extraLivesBuy25)
        case IAPManager.lives100:       restartLevel(lives: ContinueSprite.extraLivesBuy100)
        case IAPManager.moves5:         continueLevel(moves: ContinueSprite.extraMovesBuy5)
        case IAPManager.skipLevel:      restartLevel(shouldSkip: true, lives: LifeSpawnerModel.defaultLives)
        default:                        print("Unknown purchase transaction identifier")
        }
        
        activityIndicator.removeFromParent()
        pendingLivesReplenishmentTimerOffset()
    }
    
    func purchaseDidFail(transaction: SKPaymentTransaction) {
        activityIndicator.removeFromParent()
        pendingLivesReplenishmentTimerOffset()
    }
    
    func isPurchasing(transaction: SKPaymentTransaction) {
        activityIndicator = ActivityIndicatorSprite()
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
        }
        else {
            scoringEngine.timerManager.resumeTime()
            startTimer()
        }
    }
    
    func didTapReset() {
        showConfirmSprite(resetConfirmSprite)
    }
    
    func didTapHint() {
        showConfirmSprite(hintConfirmSprite)
    }
    
    func confirmQuitTapped() {
        removeAllActions()
        removeAllChildren()
        removeFromParent()
        
        saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        
        gameSceneDelegate?.confirmQuitTapped()
    }
    
    func didTapHowToPlay(_ tableView: HowToPlayTableView) {
        tableView.currentLevel = currentLevel
        
        scene?.view?.addSubview(tableView)
        tableView.reloadData()
    }
    
    func didCompletePurchase(_ currentButton: PurchaseTapButton) {
        switch currentButton.type {
        case .add5Moves:
            AudioManager.shared.playSound(for: "revive")

            gameEngine.animateMoves(originalMoves: gameEngine.movesRemaining, newMoves: ContinueSprite.extraMovesBuy5)
            gameEngine.incrementMovesRemaining(moves: ContinueSprite.extraMovesBuy5)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .add1Life:
            AudioManager.shared.playSound(for: "revive")

            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: ContinueSprite.extraLivesAd)
            gameEngine.incrementLivesRemaining(lives: ContinueSprite.extraLivesAd)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .skipLevel:
            AudioManager.shared.playSound(for: "revive")

            currentLevel += 1
                        
            scoringEngine.scoringManager.resetScore()
            scoringEngine.updateLabels()
            
            scoringEngine.scaleScoreLabelDidSkipLevel()
            scoringEngine.timerManager.resetTime()

            gameEngine.fadeGameboard(fadeOut: true) { [unowned self] in
                newGame(level: currentLevel, didWin: true)
                
                if GameEngine.livesRemaining < LifeSpawnerModel.defaultLives {
                    let livesToAdd = LifeSpawnerModel.defaultLives - GameEngine.livesRemaining
                    
                    gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: livesToAdd)
                    gameEngine.setLivesRemaining(lives: LifeSpawnerModel.defaultLives)
                }
                
                saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
            }
        case .add25Lives:
            AudioManager.shared.playSound(for: "revive")

            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: ContinueSprite.extraLivesBuy25)
            gameEngine.incrementLivesRemaining(lives: ContinueSprite.extraLivesBuy25)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .add100Lives:
            AudioManager.shared.playSound(for: "revive")

            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: ContinueSprite.extraLivesBuy100)
            gameEngine.incrementLivesRemaining(lives: ContinueSprite.extraLivesBuy100)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .add1000Lives:
            AudioManager.shared.playSound(for: "revive")

            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: ContinueSprite.extraLivesBuy1000)
            gameEngine.incrementLivesRemaining(lives: ContinueSprite.extraLivesBuy1000)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        }
    }
}


// MARK: - ConfirmSpriteDelegate

extension GameScene: ConfirmSpriteDelegate {
    func didTapConfirm(_ confirmSprite: ConfirmSprite) {
        hideConfirmSprite(confirmSprite)
        
        if confirmSprite == resetConfirmSprite {
            gameEngine.killAndReset()
            Haptics.shared.executeCustomPattern(pattern: .enemy)
        }
    }
    
    func didTapCancel(_ confirmSprite: ConfirmSprite) {
        hideConfirmSprite(confirmSprite)
    }
    
    func shake() {
        guard !pauseResetEngine.isPaused else { return }

        showConfirmSprite(resetConfirmSprite)
    }
    
    private func showConfirmSprite(_ confirmSprite: ConfirmSprite) {
        guard confirmSprite.parent == nil else { return }
        guard gameEngine.canContinue else { return }
        guard !gameEngine.playerSprite.isAnimating else { return }
        guard !chatEngine.isChatting else { return }
        
        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)

        addChild(confirmSprite)
        
        let resetConfirmMessage = GameEngine.livesRemaining <= 0 ? "Tap Restart Level to start over. Careful! You have 0 lives left, so it'll be GAME OVER." : "Tap Restart Level to start over. You'll lose a life in the process."
        
        confirmSprite.animateShow(newMessage: confirmSprite == resetConfirmSprite ? resetConfirmMessage : nil) { }
    }
    
    private func hideConfirmSprite(_ confirmSprite: ConfirmSprite) {
        confirmSprite.animateHide { [unowned self] in
            scoringEngine.timerManager.resumeTime()
            startTimer()
            gameEngine.shouldDisableInput(false)
            confirmSprite.removeFromParent()
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