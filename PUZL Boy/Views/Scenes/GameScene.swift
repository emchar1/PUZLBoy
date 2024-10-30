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
    func presentChatDialogueCutscene(level: Int, cutscene: Cutscene)
}


class GameScene: SKScene {
    
    // MARK: - Properties: Engines
    
    private var gameEngine: GameEngine!
    private var scoringEngine: ScoringEngine!
    private(set) var chatEngine: ChatEngine!
    private var pauseResetEngine: PauseResetEngine!
    private var levelSkipEngine: LevelSkipEngine!
    private var tapPointerEngine: TapPointerEngine!

    // MARK: - Properties: Sprites
    
    private var resetConfirmSprite: ConfirmSprite?
    private var hintConfirmSprite: ConfirmSprite?
    private var partyResultsSprite: PartyResultsSprite?
    private var continueSprite: ContinueSprite?
    private var activityIndicator: ActivityIndicatorSprite?
    private var offlinePlaySprite: OfflinePlaySprite?
    private var adSprite: SKSpriteNode?
    
    // MARK: - Properties: Game Logic
    
    private var screenSize: CGSize
    private var replenishLivesTimerOffset: Date?
    private let keyRunGameTimerAction = "runGameTimerAction"
    private let keyRunReplenishLivesTimerAction = "runReplenishLivesTimerAction"

    private var levelStatsArray: [LevelStats]
    private var lastCurrentLevel: Int?
    private var levelStatsItemGlobal: LevelStats?

    private var currentLevel: Int = 1 {
        // FIXME: - DEBUG: Debugging purposes only!!!
        didSet {
            guard !Level.isPartyLevel(currentLevel) else { return }
            
            if currentLevel > LevelBuilder.levelsSize { //Should this be Level.finalLevel???
                currentLevel = 101
            }
            else if currentLevel < 1 {
                currentLevel = LevelBuilder.levelsSize
            }
        }
    }
    
    // MARK: - Properties: Class Delegate
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    
    // MARK: - Initialization
    
    init(size: CGSize, hasInternet: Bool, levelSelectNewLevel: Int?) {
        self.screenSize = size
        
        if let saveStateModel = FIRManager.saveStateModel {
            //BUGFIX# 240216E02 - Fixed!
            let newLevel = levelSelectNewLevel ?? saveStateModel.newLevel
            
            currentLevel = saveStateModel.newLevel
            levelStatsArray = saveStateModel.levelStatsArray
            gameEngine = GameEngine(saveStateModel: saveStateModel, levelSelectNewLevel: levelSelectNewLevel)
            
            if currentLevel == newLevel {
                //If currentLevel and newLevel match, carry over elapsed time and score...
                scoringEngine = ScoringEngine(elapsedTime: saveStateModel.elapsedTime,
                                              score: saveStateModel.score,
                                              totalScore: saveStateModel.totalScore)
            }
            else {
                //...otherwise, reset elapsed time and score, and set currentLevel to newLevel.
                currentLevel = newLevel
                scoringEngine = ScoringEngine(elapsedTime: 0,
                                              score: 0,
                                              totalScore: saveStateModel.totalScore)
            }
        }
        else {
            levelStatsArray = []
            gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)
            scoringEngine = ScoringEngine()
        }
        
        //chatEngine MUST be initialized here, and not in properties, otherwise it just refuses to show up! Because K.ScreenDimensions.topOfGameboard is set in the gameEngine(). Is there a better way to do this??
        //As of 10/22/24, K.ScreenDimensions.topOfGameboard is now a computed property, so setting ChatEngine() anywhere shoud be fine? Let's see.
        chatEngine = ChatEngine()
        pauseResetEngine = PauseResetEngine(level: currentLevel)
        levelSkipEngine = LevelSkipEngine()
        tapPointerEngine = TapPointerEngine()

        // FIXME: - DEBUG: Uncomment to test/debug.
        offlinePlaySprite = (hasInternet && FIRManager.user != nil) ? nil : OfflinePlaySprite()
        
        super.init(size: size)
        
        gameEngine.delegate = self
        chatEngine.delegate = self
        pauseResetEngine.delegate = self
        levelSkipEngine.delegate = self
                
        backgroundColor = .white
        scaleMode = .aspectFill
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cancelLeaderboardsLoading), name: .shouldCancelLoadingLeaderboards, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("GameScene deinit")
    }
    
    
    // MARK: - Notification Center Functions
    
    /**
     Gets called in the NotificationCenter observer when the app moves to the background, i.e. UIApplication.willResignActiveNotification.
     */
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
    
    /**
     Gets called in the NotificationCenter observer when the app moves to the foreground, i.e. UIApplication.didBecomeActiveNotification.
     */
    @objc private func appMovedToForeground() {
        if action(forKey: keyRunGameTimerAction) != nil {
            scoringEngine.timerManager.resumeTime()
        }
        
        if !gameEngine.canContinue && replenishLivesTimerOffset == nil {
            runReplenishLivesTimer()
        }
    }
    
    /**
     Initializes the lives replenishment timer and updates the timer every second, like a clock.
     */
    private func runReplenishLivesTimer() {
        guard action(forKey: keyRunReplenishLivesTimerAction) == nil else {
            print("keyRunReplenishLivesTimerAction already active! Returning...")
            return
        }
        
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            do {
                let timeToReplenishLives = try LifeSpawnerModel.shared.getTimeToFinishUntilMoreLives()
                
                if timeToReplenishLives <= 0 {
                    removeAction(forKey: keyRunReplenishLivesTimerAction)
                    
                    restartLevel(lives: LifeSpawnerModel.defaultLives)
                }
                
                continueSprite?.updateTimeToReplenishLives(time: timeToReplenishLives)
            }
            catch {
                removeAction(forKey: keyRunReplenishLivesTimerAction)
                print("runReplenishLivesTimer() error: \(error.localizedDescription)")
            }
        }
        let sequence = SKAction.sequence([wait, block])
        
        run(SKAction.repeatForever(sequence), withKey: keyRunReplenishLivesTimerAction)
    }
    
    
    // MARK: - UI Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        tapPointerEngine.move(to: self, at: location, particleType: currentLevel == Level.partyLevel ? .pointerRainbow : .pointer)
        gameEngine.handleMagmoorCreepyMinionTouches(scene: self, touches: touches)

        if gameEngine.checkControlGuardsIfPassed(includeDisableInputFromOutside: false) {
            if !gameEngine.disableInputFromOutside {
                pauseResetEngine.touchDown(for: touches)
            }
        }

        guard !PauseResetEngine.pauseResetEngineIsPaused else { return }
        
        if activityIndicator == nil || !activityIndicator!.isShowing {
            continueSprite?.touchDown(in: location)
            resetConfirmSprite?.touchDown(in: location)
            hintConfirmSprite?.touchDown(in: location)
            partyResultsSprite?.touchDown(in: location)
            chatEngine.touchDown(in: location)
        }
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if activityIndicator == nil || !activityIndicator!.isShowing {
            continueSprite?.didTapButton(in: location)
            continueSprite?.touchUp()
            resetConfirmSprite?.didTapButton(in: location)
            resetConfirmSprite?.touchUp()
            hintConfirmSprite?.didTapButton(in: location)
            hintConfirmSprite?.touchUp()
            partyResultsSprite?.didTapButton(in: location)
            partyResultsSprite?.touchUp()
            chatEngine.didTapButton(in: location)
            chatEngine.touchUp()
        }

        
        guard gameEngine.checkControlGuardsIfPassed(includeDisableInputFromOutside: false) else { return }
        
        if !gameEngine.disableInputFromOutside {
            pauseResetEngine.touchHandler(for: touches)
            pauseResetEngine.touchUp()
        }
        
        
        //Move handleControls to touchesEnded so you can consider if you want to move there.
        guard !PauseResetEngine.pauseResetEngineIsPaused else { return }
        
        gameEngine.handleControls(in: location)
        pauseResetEngine.shouldDisableHintButton(!gameEngine.hintEngine.hintAvailable)
        
        if !chatEngine.isChatting {
            levelSkipEngine.handleControls(in: location)
        }
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        //First, set the audio...
        AudioManager.shared.stopSound(for: "continueloop")
        AudioManager.shared.playSound(for: AudioManager.shared.currentTheme.overworld)
        
        //...then call the remaining functions.
        moveSprites()
        
        //These alway need to go in THIS order!
        scoringEngine.timerManager.resumeTime()
        startTimer()
        
        playDialogue()
        gameEngine.checkIfGameOverOnStartup()
    }
    
    override func willMove(from view: SKView) {
        AudioManager.shared.stopSound(for: AudioManager.shared.currentTheme.overworld)
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    // MARK: - Helper Functions
    
    ///Starts the timer, used for scoring in the game.
    private func startTimer() {
        //The 0.1 seconds for Party Levels is important for rounding so that the seconds rounds to 00 instead of some weird non-zero number.
        let wait = SKAction.wait(forDuration: Level.isPartyLevel(currentLevel) ? 0.1 : 1.0)
        let block = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            scoringEngine.timerManager.pollTime()
            scoringEngine.updateLabels()
            
            if currentLevel == Level.partyLevel && scoringEngine.timerManager.elapsedTime <= 0 {
                stopParty()
                
                AudioManager.shared.stopSound(for: "clocktick")
            }
            
            if currentLevel == Level.partyLevel && scoringEngine.timerManager.elapsedTime > 11 {
                AudioManager.shared.stopSound(for: "clocktick")
            }
            
            // FIXME: - Countdown - why are edges 11 and 1 (not 10 and 0)
            if currentLevel == Level.partyLevel && scoringEngine.timerManager.elapsedTime <= 11 && scoringEngine.timerManager.elapsedTime > 1 && scoringEngine.timerManager.milliseconds <= 0 {
                scoringEngine.pulseColorTimeAnimation(fontColor: .red)
                
                AudioManager.shared.playSound(for: "clocktick", interruptPlayback: false)
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
    
    ///Used in startTimer() block. (Can this be reused? I see other parts of the code that is similar.)
    private func stopParty() {
        removeAction(forKey: keyRunGameTimerAction)
        
        scoringEngine.fadeOutTimeAnimation()
        gameEngine.stopSpawner()
        gameEngine.shouldDisableInput(true)
        pauseResetEngine.shouldDisable(true)
        
        let fadeGameboardAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            gameEngine.fadeGameboard(fadeOut: true) {
                self.partyResultsSprite = PartyResultsSprite()
                self.partyResultsSprite!.delegate = self

                self.addChild(self.partyResultsSprite!)
                
                self.partyResultsSprite!.updateAmounts(gems: self.gameEngine.partyInventory.gems,
                                                       gemsDouble: self.gameEngine.partyInventory.gemsDouble,
                                                       gemsTriple: self.gameEngine.partyInventory.gemsTriple,
                                                       hints: self.gameEngine.partyInventory.hints,
                                                       lives: self.gameEngine.partyInventory.lives)
                
                self.partyResultsSprite!.animateShow(totalGems: self.gameEngine.partyInventory.getTotalGems(),
                                                     lives: self.gameEngine.partyInventory.lives,
                                                     totalLives: self.gameEngine.partyInventory.getTotalLives()) { }
            }
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            fadeGameboardAction
        ]))
    }
    
    /**
     Saves the state of the gameplay, including elapsed time, current gameboard state, lives remaining, and player position.
     - parameters:
        - didWin: returns true if the level has been beat
        - levelStatsItem: the current level stats to save to Firebase
     */
    private func saveState(levelStatsItem: LevelStats) {
        guard LevelBuilder.levelsSize > 0 else { return print("GameScene.saveState(): levelSize less than 0") }
        
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
            hintsAttempt: gameEngine.hintEngine.arrayToString(gameEngine.hintEngine.attemptArray),
            hintsBought: gameEngine.hintEngine.arrayToString(gameEngine.hintEngine.boughtArray),
            hintsSolution: gameEngine.level.hintsSolution,
            gemsCollected: gameEngine.gemsCollected,
            gemsRemaining: gameEngine.gemsRemaining,
            playerPosition: PlayerPosition(row: gameEngine.level.player.row, col: gameEngine.level.player.col),
            inventory: gameEngine.level.inventory)
        
        let saveStateModel = SaveStateModel(
            aorAgeOfRuin: GameEngine.ageOfRuin,
            aorBravery: 0, //Doesn't matter what goes here, it'll also get overwritten by the static property in FIRManager
            aorDecisionLeftButton0: true, //Doesn't matter what goes here, it'll also get overwritten by the static property in FIRManager
            aorDecisionLeftButton1: true, //Doesn't matter what goes here, it'll also get overwritten by the static property in FIRManager
            aorDecisionLeftButton2: true, //Doesn't matter what goes here, it'll also get overwritten by the static property in FIRManager
            aorDecisionLeftButton3: true, //Doesn't matter what goes here, it'll also get overwritten by the static property in FIRManager
            aorHasFeather: true, //Doesn't matter what goes here, it'll also get overwritten by the static property in FIRManager
            aorGotGift: true, //Doesn't matter what goes here, it'll also get overwritten by the static property in FIRManager
            elapsedTime: scoringEngine.timerManager.elapsedTime,
            gameCompleted: GameEngine.gameCompleted,
            hintAvailable: gameEngine.hintEngine.hintAvailable,
            hintCountRemaining: HintEngine.hintCount,
            levelModel: levelModel,
            levelStatsArray: levelStatsArray,
            livesRemaining: GameEngine.livesRemaining,
            newLevel: lastCurrentLevel ?? currentLevel, //prevents saving within a party level, i.e. fast fwd to next level
            saveDate: Date(),
            score: levelStatsItem.didWin ? 0 : scoringEngine.scoringManager.score,
            totalScore: scoringEngine.scoringManager.totalScore + (levelStatsItem.didWin ? scoringEngine.scoringManager.score : 0),
            uid: FIRManager.uid ?? "placeholderUIDValueThatShouldNotBeUsed",
            usedContinue: GameEngine.usedContinue,
            winStreak: GameEngine.winStreak)
        
        FIRManager.writeToFirestoreRecord(saveStateModel: saveStateModel)
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
        
        if Level.isPartyLevel(level) {
            if !PartyModeSprite.shared.isPartying {
                PartyModeSprite.shared.setIsPartying(true)
                PartyModeSprite.shared.startParty(to: self,
                                                  partyBoy: gameEngine.playerSprite,
                                                  hasSword: gameEngine.level.inventory.hasSwords(),
                                                  hasHammer: gameEngine.level.inventory.hasHammers())
                scoringEngine.timerManager.setIsParty(true)
            }
        }
        else {
            if PartyModeSprite.shared.isPartying {
                PartyModeSprite.shared.setIsPartying(false)
                PartyModeSprite.shared.stopParty(partyBoy: gameEngine.playerSprite,
                                                 hasSword: gameEngine.level.inventory.hasSwords(),
                                                 hasHammer: gameEngine.level.inventory.hasHammers())
                scoringEngine.timerManager.setIsParty(false)
            }
        }
        
        gameEngine.newGame(level: Level.isPartyLevel(level) ? Level.partyLevel : level, shouldSpawn: !didWin)
        gameEngine.hintEngine.setHintAvailable(HintEngine.hintCount > 0)
        pauseResetEngine.shouldDisableHintButton(!gameEngine.hintEngine.hintAvailable)
                
        moveSprites()
        playDialogue()
        
        AudioManager.shared.stopSound(for: "continueloop")
        
        if !didWin {
            AudioManager.shared.playSound(for: AudioManager.shared.currentTheme.overworld)
        }
        
        
        //DO NOT CREATE NEW INSTANCES EVERY TIME!!! THIS CAUSES MEMORY LEAKS! 3/30/23
//        gameEngine = GameEngine(level: level, shouldSpawn: !didWin)
//        gameEngine.delegate = self
    }
    
    private func prepareAd(completion: (() -> Void)?) {
        let fadeDuration: TimeInterval = 1.0
        
        AudioManager.shared.lowerVolume(for: AudioManager.shared.currentTheme.overworld, fadeDuration: fadeDuration)

        adSprite = SKSpriteNode(color: .clear, size: screenSize)
        adSprite!.anchorPoint = .zero
        adSprite!.zPosition = K.ZPosition.adSceneBlackout
        addChild(adSprite!)

        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)
        gameEngine.fadeBloodOverlay(shouldFadeOut: true, duration: fadeDuration)

        adSprite!.run(SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: fadeDuration)) {
            completion?()
        }
    }
    
    private func continueFromAd(shouldFade: Bool, completion: (() -> Void)?) {
        func resetTimer() {
            scoringEngine.timerManager.resetTime()
            startTimer()
            gameEngine.shouldDisableInput(false)
            
            completion?()
        }
        
        let fadeDuration: TimeInterval = 1.0
        
        AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme.overworld, fadeDuration: 3)
        gameEngine.fadeBloodOverlay(shouldFadeOut: false, duration: fadeDuration)

        if shouldFade {
            adSprite?.run(SKAction.sequence([
                SKAction.colorize(with: .clear, colorBlendFactor: 1.0, duration: fadeDuration),
                SKAction.removeFromParent()
            ])) { [weak self] in
                self?.adSprite = nil

                resetTimer()
            }
        }
        else {
            adSprite?.removeFromParent()
            adSprite = nil
            
            resetTimer()
        }
    }
    
    private func moveSprites() {
        gameEngine.moveSprites(to: self)
        scoringEngine.moveSprites(to: self, isPartyLevel: Level.isPartyLevel(currentLevel))
        chatEngine.moveSprites(to: self)
        levelSkipEngine.moveSprites(to: self, level: currentLevel)

        pauseResetEngine.moveSprites(to: self, level: currentLevel)
        pauseResetEngine.registerHowToPlayTableView()
        pauseResetEngine.registerLeaderboardsTableView()
        pauseResetEngine.registerAchievementsTableView()
        
        if let offlinePlaySprite = offlinePlaySprite {
            offlinePlaySprite.removeAllActions()
            offlinePlaySprite.removeFromParent()
            
            addChild(offlinePlaySprite)
            offlinePlaySprite.animateSprite()
        }        
    }
    
    private func playDialogue() {
        
        // FIXME: - Party Levels is 998 items enough??? Don't want to run out of spawning items...
        let maxSpawnedItemsForParty = 998
        
        let numMovesSprite = NumMovesSprite(numMoves: gameEngine.level.moves,
                                            position: CGPoint(x: K.ScreenDimensions.size.width / 2, y: GameboardSprite.offsetPosition.y * 3 / 2),
                                            isPartyLevel: Level.isPartyLevel(currentLevel))
        
        guard !Level.isPartyLevel(currentLevel) || (lastCurrentLevel != nil && lastCurrentLevel! <= (Level.partyMinLevelRequired + 1)) else {
            gameEngine.spawnPartyItems(maxItems: maxSpawnedItemsForParty)
            numMovesSprite.play(superScene: self, completion: nil)

            return
        }
        guard chatEngine.shouldPauseGame(level: currentLevel) else {
            numMovesSprite.play(superScene: self, completion: nil)

            return
        }
        guard gameEngine.canContinue else { return }
        guard gameEngine.playerIsOnStartPosition() else { return }

        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)
        pauseResetEngine.shouldDisable(true)

        chatEngine.playDialogue(level: currentLevel) { [weak self] cutscene in
            guard let self = self else { return }
            
            if let cutscene = cutscene {
                let fadeDuration: TimeInterval = 1.0
                let fadeNode = SKSpriteNode(color: .white, size: screenSize)
                fadeNode.anchorPoint = .zero
                fadeNode.alpha = 0
                fadeNode.zPosition = K.ZPosition.messagePrompt
                addChild(fadeNode)
                
                AudioManager.shared.stopSound(for: AudioManager.shared.currentTheme.overworld, fadeDuration: fadeDuration)
                
                fadeNode.run(SKAction.fadeIn(withDuration: fadeDuration)) {
                    self.cleanupScene(shouldSaveState: false)
                    self.gameSceneDelegate?.presentChatDialogueCutscene(level: self.currentLevel, cutscene: cutscene)
                }
            }
            else {
                scoringEngine.timerManager.resumeTime()
                startTimer()
                gameEngine.shouldDisableInput(false)
                gameEngine.spawnPartyItems(maxItems: maxSpawnedItemsForParty)
                pauseResetEngine.shouldDisable(false)
                numMovesSprite.play(superScene: self, completion: nil)
            }
        }
    }
    
    private func playDialogueForStatueTapped() {
        gameEngine.shouldDisableInput(true)
        pauseResetEngine.shouldDisable(true)
        
        chatEngine.playDialogue(level: currentLevel, statueTapped: true) { [weak self] _ in
            self?.gameEngine.shouldDisableInput(false)
            self?.pauseResetEngine.shouldDisable(false)
        }
    }
    
    ///Shakes the screen. Use effect for certain cataclysmic event
    func shakeScreen(duration totalDuration: TimeInterval, shouldPlaySFX: Bool, completion: (() -> Void)?) {
        let shakeMagnitude: CGFloat = 12
        let shakeDuration: TimeInterval = 0.06
        
        let shakeAction = SKAction.repeat(SKAction.sequence([
            SKAction.moveBy(x: shakeMagnitude, y: shakeMagnitude, duration: shakeDuration),
            SKAction.moveBy(x: -shakeMagnitude, y: -shakeMagnitude, duration: shakeDuration)
        ]), count: Int(totalDuration / (shakeDuration * 2)))
        
        scoringEngine.sprite.run(shakeAction)
        gameEngine.displaySprite.sprite.run(shakeAction)
        gameEngine.gameboardSprite.sprite.run(shakeAction) {
            if shouldPlaySFX {
                AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme.overworld, fadeDuration: 5)
            }
            
            Haptics.shared.stopHapticEngine()
            Haptics.shared.startHapticEngine(shouldInitialize: false)

            completion?()
        }

        if shouldPlaySFX {
            AudioManager.shared.playSound(for: "magicelderexplosion")
            AudioManager.shared.adjustVolume(to: 0.1, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 1)
        }

        AudioManager.shared.playSoundThenStop(for: "thunderrumble", currentTime: 5, playForDuration: totalDuration + 1, fadeOut: 4)
        Haptics.shared.executeCustomPattern(pattern: .thunder)
    }
    
    /**
     Prepares the GameScene for exit transition.
     - parameter shouldSaveState: saves the game state, if true.
     */
    private func cleanupScene(shouldSaveState: Bool) {
        removeAllActions()
        removeAllChildren()
        removeFromParent()
        
        //DON'T FORGET TO REMOVE THESE OBSERVERS!!!
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.removeObserver(self, name: .shouldCancelLoadingLeaderboards, object: nil)

        if shouldSaveState {
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        }
        
        //IMPORTANT!! Make these nil so GameScene gets deinitialized properly!!!
        gameEngine = nil
        scoringEngine = nil
        chatEngine = nil
        pauseResetEngine = nil
        levelSkipEngine = nil
        tapPointerEngine = nil
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
        scoringEngine.scoringManager.addToScore(ScoringEngine.killEnemyScore)
        scoringEngine.updateLabels()
    }
    
    func gameIsSolved(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool, didCompleteGame: Bool) {
        let score = scoringEngine.calculateScore(movesRemaining: movesRemaining,
                                                 itemsFound: itemsFound,
                                                 enemiesKilled: enemiesKilled,
                                                 usedContinue: usedContinue)
        scoringEngine.animateScore(usedContinue: usedContinue)
        gameEngine.updateScores()
        gameEngine.hideParticles()
        stopTimer()
        
        //Need to preserve game states before restarting the level but after setting score, so it can save them to Firestore down below.
        self.levelStatsItemGlobal = getLevelStatsItem(level: currentLevel, didWin: true)

        GameCenterManager.shared.postScoreToLeaderboard(score: score, level: currentLevel)
        
        if currentLevel >= AchievementSpeedDemon.levelRequirement && scoringEngine.timerManager.elapsedTime <= AchievementSpeedDemon.timeRequirement {
            GameCenterManager.shared.updateProgress(achievement: .speedDemon, shouldReportImmediately: true)
        }
        
        if currentLevel >= AchievementSlowPoke.levelRequirement && scoringEngine.timerManager.elapsedTime >= AchievementSlowPoke.timeRequirement {
            GameCenterManager.shared.updateProgress(achievement: .slowPoke, shouldReportImmediately: true)
        }
        
        currentLevel += 1
        
        gameEngine.fadeGameboard(fadeOut: true) { [weak self] in
            guard let self = self else { return }
            
            //Increment or reset interstitial counter
            if didCompleteGame {
                AdMobManager.shared.resetInterstitialCounter()
            }
            else {
                AdMobManager.shared.incrementInterstitialCounter()
            }

            //Check if interstitial ad count met
            if AdMobManager.shared.checkInterstitialMet() {
                prepareAd {
                    AdMobManager.shared.delegate = self
                    AdMobManager.shared.presentInterstitial()
                }
                
                //handleWinLevel() will be called upon dismissing the interstitial ad!
            }
            else {
                handleWinLevel(levelStatsItem: self.levelStatsItemGlobal, didCompleteGame: didCompleteGame)
            }
        }
    }
    
    ///Helper function to finish cleanup upon beating a level
    private func handleWinLevel(levelStatsItem: LevelStats?, didCompleteGame: Bool) {
        guard let levelStatsItem = levelStatsItem else { fatalError("GameScene.handleWinLevel() levelStatsItem was nil. Time to debug!!") }
        
        scoringEngine.timerManager.resetTime()
        startTimer()
        
        if didCompleteGame {
            //IMPORTANT: Write to Firestore, MUST come first, if completing the game
            saveState(levelStatsItem: levelStatsItem)
            
            // TODO: - 10/7/24 Add end game level, cutscene, credits, title+
            cleanupScene(shouldSaveState: false)
            gameSceneDelegate?.confirmQuitTapped()
        }
        else {
            newGame(level: currentLevel, didWin: true)
            
            //IMPORTANT: In this case, write to Firestore, MUST come last, after calling newGame()
            if !Level.isPartyLevel(currentLevel) {
                saveState(levelStatsItem: levelStatsItem)
            }
        }
    }
    
    func gameIsOver(firstTimeCalled: Bool) {
        if !gameEngine.canContinue {
            continueSprite = ContinueSprite()
            continueSprite!.delegate = self
            
            prepareAd { [weak self] in
                guard let self = self else { return }
                
                pauseResetEngine.shouldDisable(true)
                gameEngine.hideParticles()

                addChild(continueSprite!)

                continueSprite!.animateShow(shouldDisable5Moves: gameEngine.healthRemaining <= 0) {
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
            gameEngine.displaySprite.statusLives.decrementLives(originalLives: GameEngine.livesRemaining)
        }
    }
    
    func didTakePartyPill() {
        lastCurrentLevel = currentLevel
        currentLevel = Level.partyLevel
    }
    
    func didGetPartyTime(_ seconds: TimeInterval) {
        scoringEngine.timerManager.addTime(seconds)
        scoringEngine.addTimeAnimation(seconds: seconds)
    }
    
    func didGetPartyBomb() {
        scoringEngine.timerManager.killTime()
    }
    
    func didTouchStatue() {
        playDialogueForStatueTapped()
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
}


// MARK: - AdMobManagerDelegate

extension GameScene: AdMobManagerDelegate {
    
    // MARK: - Interstitial Functions
    
    func willPresentInterstitial() {
        
    }
    
    func didDismissInterstitial() {
        continueFromAd(shouldFade: false) { [weak self] in
            guard let self = self else { return }
            
            if Level.isPartyLevel(currentLevel) {
                handlePartyLevelCleanUp()
            }
            else {
                handleWinLevel(levelStatsItem: self.levelStatsItemGlobal, didCompleteGame: false)
            }
        }
    }
    
    func interstitialFailed() {
        print("Interstitial failed. Now what...")
    }
    
    private func handlePartyLevelCleanUp() {
        guard let lastCurrentLevel = lastCurrentLevel else { fatalError("lastCurrentLevel is nil, which shouldn't happen after a party level") }

        currentLevel = lastCurrentLevel
        self.lastCurrentLevel = nil
        
        scoringEngine.timerManager.resetTime()
        scoringEngine.fadeInTimeAnimation()
        startTimer()

        gameEngine.shouldDisableInput(false)
        pauseResetEngine.shouldDisable(false)
        
        //This should come AFTER calling the above functions, otherwise the game won't pause if there's a dialogue right after a party level!
        newGame(level: currentLevel, didWin: true)

        //Animate lives earned from party
        let livesEarned = gameEngine.partyInventory.getTotalLives()
        
        if livesEarned > 0 {
            AudioManager.shared.playSound(for: "revive")
            
            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: livesEarned)
            gameEngine.incrementLivesRemaining(lives: livesEarned)
        }
        
        // TODO: - Animate hints earned from party
        if gameEngine.partyInventory.hints > 0 {
            gameEngine.hintEngine.addToHintCount(valueToAdd: gameEngine.partyInventory.hints)
            gameEngine.hintEngine.updateBools(didPurchaseHints: true)
            pauseResetEngine.shouldDisableHintButton(!gameEngine.hintEngine.hintAvailable)
            pauseResetEngine.updateHintBadgeAndCount()
        }
        
        //Write to Firestore, MUST come after newGame()
        let levelStatsItem = getLevelStatsItem(level: currentLevel, didWin: true)
        saveState(levelStatsItem: levelStatsItem)
        
        partyResultsSprite?.removeFromParent()
        partyResultsSprite = nil
    }

    
    // MARK: - Rewarded Functions
    
    func willPresentRewarded() {
        replenishLivesTimerOffset = Date()
        removeAction(forKey: keyRunReplenishLivesTimerAction)
        AudioManager.shared.stopSound(for: "continueloop", fadeDuration: 0.5)
    }
    
    func didDismissRewarded() {
        pendingLivesReplenishmentTimerOffset()
        
        restartLevel(lives: IAPManager.rewardAmountLivesAd)
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
                        
            LifeSpawnerModel.shared.removeTimer()
            LifeSpawnerModel.shared.removeAllNotifications()
        }
        
        
        AudioManager.shared.stopSound(for: "continueloop")
        
        continueSprite?.animateHide { [weak self] in
            guard let self = self else { return }
            
            continueFromAd(shouldFade: true) {
                AudioManager.shared.playSound(for: "revive")
            
                self.scoringEngine.scoringManager.resetScore()
                self.scoringEngine.updateLabels()
                
                self.pauseResetEngine.shouldDisable(false)
                
                //Make sure to save current state, and increment currentLevel if skipping ahead
                if shouldSkipLevel {
                    self.saveState(levelStatsItem: self.getLevelStatsItem(level: self.currentLevel, didWin: false))

                    self.currentLevel += 1
                    
                    self.scoringEngine.scaleScoreLabelDidSkipLevel()
                    self.scoringEngine.timerManager.resetTime()
                    
                    self.gameEngine.fadeGameboard(fadeOut: true) {
                        restartHelper()
                    }
                }
                else {
                    restartHelper()
                }

                self.continueSprite = nil
            }
        }
    }
    
    private func continueLevel(moves: Int) {
        continueSprite?.animateHide { [weak self] in
            guard let self = self else { return }
            
            continueFromAd(shouldFade: true) {
                AudioManager.shared.playSound(for: "revive")
                AudioManager.shared.stopSound(for: "continueloop")
                AudioManager.shared.playSound(for: AudioManager.shared.currentTheme.overworld)
                
                self.pauseResetEngine.shouldDisable(false)
                self.gameEngine.continueGame()
                self.gameEngine.showParticles()

                self.gameEngine.animateMoves(originalMoves: self.gameEngine.movesRemaining, newMoves: moves)
                self.gameEngine.incrementMovesRemaining(moves: moves)
                self.gameEngine.setLivesRemaining(lives: 0)
                
                self.saveState(levelStatsItem: self.getLevelStatsItem(level: self.currentLevel, didWin: false))
                
                LifeSpawnerModel.shared.removeTimer()
                LifeSpawnerModel.shared.removeAllNotifications()

                self.continueSprite = nil
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
    
    func didTapBuy5MovesButton() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idMoves5 }) else {
            print("Unable to find IAP: 5 Moves ($0.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
    
    func didTapSkipLevel() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idSkipLevel }) else {
            print("Unable to find IAP: Skip Level ($2.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
    
    func didTapBuy25LivesButton() {
        guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idLives25 }) else {
            print("Unable to find IAP: 25 Lives ($4.99)")
            return
        }
        
        IAPManager.shared.buyProduct(productToPurchase)
    }
}


// MARK: - IAPManagerDelegate

extension GameScene: IAPManagerDelegate {
    func didCompletePurchase(transaction: SKPaymentTransaction) {
        switch transaction.payment.productIdentifier {
        case IAPManager.idMoves5:       continueLevel(moves: IAPManager.rewardAmountMovesBuy5)
        case IAPManager.idSkipLevel:    restartLevel(shouldSkip: true, lives: LifeSpawnerModel.defaultLives)
        case IAPManager.idLives25:      restartLevel(lives: IAPManager.rewardAmountLivesBuy25)
        case IAPManager.idLives100:     restartLevel(lives: IAPManager.rewardAmountLivesBuy100) //Not needed? Used in ContinueSprite it seems...
        default:                        print("Unknown purchase transaction identifier: \(transaction.payment.productIdentifier)")
        }
        
        activityIndicator?.removeFromParent()
        activityIndicator = nil

        pendingLivesReplenishmentTimerOffset()
    }
    
    func purchaseDidFail(transaction: SKPaymentTransaction) {
        activityIndicator?.removeFromParent()
        activityIndicator = nil
        
        pendingLivesReplenishmentTimerOffset()
    }
    
    func isPurchasing(transaction: SKPaymentTransaction) {
        activityIndicator = ActivityIndicatorSprite()
        activityIndicator!.move(toParent: self)
        
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
        resetConfirmSprite = ConfirmSprite(title: "FEELING STUCK?",
                                           message: "Tap Restart Level to start over. You'll lose a life in the process.",
                                           confirm: "Restart Level",
                                           cancel: "Cancel")
        resetConfirmSprite!.delegate = self

        addChild(resetConfirmSprite!)
        showConfirmSprite(resetConfirmSprite!)
    }
    
    func didTapHint() {
        guard let playerPosition = gameEngine.level.player else { return }
                
        if gameEngine.hintEngine.canAddToBought {
            gameEngine.hintEngine.reduceHintCount()
            pauseResetEngine.updateHintBadgeAndCount()
        }

        gameEngine.hintEngine.getHint(gameboardSprite: gameEngine.gameboardSprite, playerPosition: playerPosition) {
            print("Hint arrow is done animating.")
        }        
    }
    
    func confirmQuitTapped() {
        cleanupScene(shouldSaveState: true)
        gameSceneDelegate?.confirmQuitTapped()
    }
    
    func didTapHowToPlay(_ tableView: HowToPlayTableView) {
        tableView.currentLevel = currentLevel
        
        scene?.view?.addSubview(tableView)
        tableView.reloadData()
    }
    
    func didTapLeaderboards(_ tableView: LeaderboardsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: Bool) {
        guard ignoreShouldCancelLoadingLeaderboardsObserver || !GameCenterManager.shared.shouldCancelLeaderboards else { return }
        
        scene?.view?.addSubview(tableView)
    }

    func didTapAchievements(_ tableView: AchievementsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: Bool) {
        guard ignoreShouldCancelLoadingLeaderboardsObserver || !GameCenterManager.shared.shouldCancelLeaderboards else { return }
        
        scene?.view?.addSubview(tableView)
    }

    @objc private func cancelLeaderboardsLoading() {
        GameCenterManager.shared.shouldCancelLeaderboards = true
    }
    
    func didCompletePurchase(_ currentButton: PurchaseTapButton) {
        AudioManager.shared.playSound(for: "revive")

        switch currentButton.type {
        case .add1Life:
            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: IAPManager.rewardAmountLivesAd)
            gameEngine.incrementLivesRemaining(lives: IAPManager.rewardAmountLivesAd)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .add5Moves:
            gameEngine.animateMoves(originalMoves: gameEngine.movesRemaining, newMoves: IAPManager.rewardAmountMovesBuy5)
            gameEngine.incrementMovesRemaining(moves: IAPManager.rewardAmountMovesBuy5)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .add10Hints:
            // FIXME: - Need better animation to indicate 10 hints were added.
            gameEngine.hintEngine.addToHintCount(valueToAdd: IAPManager.rewardAmountHintsBuy10)
            gameEngine.hintEngine.updateBools(didPurchaseHints: true)
            pauseResetEngine.shouldDisableHintButton(!gameEngine.hintEngine.hintAvailable)
            pauseResetEngine.updateHintBadgeAndCount()
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .skipLevel:
            currentLevel += 1
                        
            scoringEngine.scoringManager.resetScore()
            scoringEngine.updateLabels()
            
            scoringEngine.scaleScoreLabelDidSkipLevel()
            scoringEngine.timerManager.resetTime()

            gameEngine.fadeGameboard(fadeOut: true) { [weak self] in
                guard let self = self else { return }
                
                newGame(level: currentLevel, didWin: true)
                
                if GameEngine.livesRemaining < LifeSpawnerModel.defaultLives {
                    let livesToAdd = LifeSpawnerModel.defaultLives - GameEngine.livesRemaining
                    
                    gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: livesToAdd)
                    gameEngine.setLivesRemaining(lives: LifeSpawnerModel.defaultLives)
                }
                
                saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
            }
        case .add25Lives:
            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: IAPManager.rewardAmountLivesBuy25)
            gameEngine.incrementLivesRemaining(lives: IAPManager.rewardAmountLivesBuy25)
            
            saveState(levelStatsItem: getLevelStatsItem(level: currentLevel, didWin: false))
        case .add100Lives:
            gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: IAPManager.rewardAmountLivesBuy100)
            gameEngine.incrementLivesRemaining(lives: IAPManager.rewardAmountLivesBuy100)
            
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
    
    //Disable shake to reset for now...
//    func shake() {
//        guard !PauseResetEngine.pauseResetEngineIsPaused && !Level.isPartyLevel(currentLevel) else { return }
//
//        showConfirmSprite(resetConfirmSprite)
//    }
    
    private func showConfirmSprite(_ confirmSprite: ConfirmSprite) {
        guard gameEngine.canContinue else { return }
        guard !gameEngine.playerSprite.isAnimating else { return }
        guard !chatEngine.isChatting else { return }
        
        scoringEngine.timerManager.pauseTime()
        stopTimer()
        gameEngine.shouldDisableInput(true)
        
        var confirmMessage: String?
        
        if confirmSprite == resetConfirmSprite {
            confirmMessage = GameEngine.livesRemaining <= 0 ? "Tap Restart Level to start over. Careful! You have 0 lives left, so it'll be GAME OVER." : "Tap Restart Level to start over. You'll lose a life in the process."
        }
                
        confirmSprite.animateShow(newMessage: confirmMessage) { }
    }
    
    private func hideConfirmSprite(_ confirmSprite: ConfirmSprite) {
        confirmSprite.animateHide { [weak self] in
            self?.scoringEngine.timerManager.resumeTime()
            self?.startTimer()
            self?.gameEngine.shouldDisableInput(false)
            
            //VERY IMPORTANT to release memory!!!
            if confirmSprite == self?.resetConfirmSprite {
                self?.resetConfirmSprite = nil
            }
            else if confirmSprite == self?.hintConfirmSprite {
                self?.hintConfirmSprite = nil
            }
        }
    }
}


// MARK: - PartyResultsSpriteDelegate

extension GameScene: PartyResultsSpriteDelegate {
    func didTapConfirm() {
        partyResultsSprite?.animateHide { [weak self] in
            self?.prepareAd {
                self?.resumeGameFromPartyLevel()
            }
        }
        
        gameEngine.playerSprite.hidePlayer()
        pauseResetEngine.hideDiscoball()
    }
    
    ///Used before the interstitial ad plays after a Party Level is completed. Should not be used anywhere else because of the proprietary code!!!
    private func resumeGameFromPartyLevel() {
        let villainChatLevel = (lastCurrentLevel ?? 1) - 1

        PartyModeSprite.shared.stopParty(partyBoy: gameEngine.playerSprite,
                                         hasSword: gameEngine.level.inventory.hasSwords(),
                                         hasHammer: gameEngine.level.inventory.hasHammers())

        chatEngine.playDialogue(level: -villainChatLevel) { [weak self] _ in
            guard AdMobManager.interstitialAdIsReady else {
                AdMobManager.shared.createAndLoadInterstitial() //...and try loading the ad again for future calls
                self?.didDismissInterstitial()
                
                return
            }
            
            AdMobManager.shared.delegate = self
            AdMobManager.shared.presentInterstitial()
        }
    }
    

}


// MARK: - ChatEngineDelegate

extension GameScene: ChatEngineDelegate {
    
    // MARK: - Tutorial
    
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {
        gameEngine.gameboardSprite.illuminatePanel(at: position, useOverlay: useOverlay)
    }
    
    func deilluminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {
        gameEngine.gameboardSprite.deIlluminatePanel(at: position, useOverlay: useOverlay)
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
    
    func deilluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName) {
        switch displayType {
        case .lives:    gameEngine.displaySprite.statusLives.deIlluminateNode()
        case .health:   gameEngine.displaySprite.statusHealth.deIlluminateNode()
        case .moves:    gameEngine.displaySprite.statusMoves.deIlluminateNode()
        case .hammers:  gameEngine.displaySprite.statusHammers.deIlluminateNode()
        case .swords:   gameEngine.displaySprite.statusSwords.deIlluminateNode()
        }
    }
    
    func illuminateMinorButton(for button: PauseResetEngine.MinorButton) {
        pauseResetEngine.flashMinorButton(for: button)
    }
    
    func deilluminateMinorButton(for button: PauseResetEngine.MinorButton) {
        pauseResetEngine.unflashMinorButton(for: button)
    }
    
    
    // MARK: - Trainer
    
    func spawnTrainer(at position: K.GameboardPosition, to direction: Controls) {
        gameEngine.gameboardSprite.spawnTrainer(at: position, to: direction)
    }
    
    func despawnTrainer(to position: K.GameboardPosition) {
        gameEngine.gameboardSprite.despawnTrainer(to: position)
    }
    
    func spawnTrainerWithExit(at position: K.GameboardPosition, to direction: Controls) {
        gameEngine.gameboardSprite.spawnTrainerWithExit(at: position, to: direction)
    }
    
    func despawnTrainerWithExit(moves: [K.GameboardPosition]) {
        gameEngine.gameboardSprite.despawnTrainerWithExit(moves: moves)
    }
    
    
    // MARK: - Magmoor/Princess Capture
    
    func spawnPrincessCapture(at position: K.GameboardPosition, shouldAnimateWarp: Bool, completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.spawnPrincessCapture(at: position, shouldAnimateWarp: shouldAnimateWarp, completion: completion)
    }
    
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.despawnPrincessCapture(at: position, completion: completion)
    }
    
    func flashPrincess(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.flashPrincess(at: position, completion: completion)
    }
    
    func inbetweenRealmEnter(levelInt: Int, mergeHalfway: Bool, moves: [K.GameboardPosition]) {
        scoringEngine.hideSprite()
        gameEngine.playerSprite.resetRespawnAnimation()
        gameEngine.inbetweenRealmEnter(to: self)
        gameEngine.gameboardSprite.spawnInbetween(level: LevelBuilder.levels[levelInt], mergeHalfway: mergeHalfway, moves: moves)
    }
    
    func inbetweenFlashPlayer(playerType: Player.PlayerType, position: K.GameboardPosition, persistPresence: Bool) {
        gameEngine.gameboardSprite.inbetweenFlashPlayer(playerType: playerType, position: position, persistPresence: persistPresence)
    }
    
    func inbetweenRealmExit(persistPresence: Bool, completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.despawnInbetween(persistPresence: persistPresence)
        gameEngine.inbetweenRealmExit { [weak self] in
            self?.gameEngine.playerSprite.startRespawnAnimation()
            self?.scoringEngine.showSprite(fadeDuration: 1)
            completion()
        }
    }
    
    func empowerPrincess(powerDisplayDuration: TimeInterval) {
        gameEngine.gameboardSprite.empowerPrincess(duration: powerDisplayDuration)
        shakeScreen(duration: powerDisplayDuration, shouldPlaySFX: false, completion: nil)

    }
    
    func encagePrincess() {
        gameEngine.gameboardSprite.encagePrincess()
    }
    

    // MARK: - Daemon the Destroyer
    
    func peekMinion(at position: K.GameboardPosition, duration: TimeInterval, completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.peekMagmoorMinion(at: position, duration: duration, completion: completion)
    }

    func spawnDaemon(at position: K.GameboardPosition) {
        gameEngine.gameboardSprite.spawnDaemon(at: position)
    }
    
    func spawnMagmoorMinion(at position: K.GameboardPosition, chatDelay: TimeInterval) {
        gameEngine.gameboardSprite.spawnMagmoorMinion(at: position)
        gameEngine.magmoorSpawnEnter(to: self, delay: chatDelay)
    }
    
    func despawnMagmoorMinion(at position: K.GameboardPosition, fadeDuration: TimeInterval) {
        gameEngine.gameboardSprite.despawnMagmoorMinion(at: position, fadeDuration: fadeDuration)
        gameEngine.magmoorSpawnExit(fadeDuration: fadeDuration)
    }
    
    func minionAttack(duration: TimeInterval, completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.minionAttackSeries(duration: duration, completion: completion)
    }
    
    func spawnElder(minionPosition: K.GameboardPosition, positions: [K.GameboardPosition], completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.spawnElder(minionPosition: minionPosition, positions: positions, completion: completion)
        gameEngine.elderSpawnEnter()
    }
    
    func despawnElders(to position: K.GameboardPosition, completion: @escaping () -> Void) {
        gameEngine.gameboardSprite.despawnElders(to: position, completion: completion)
    }
    
    
    // MARK: - Gift
    
    ///Update livesRemaining with Trudee's gift - in Firestore and in the GameEngine UI.
    func getGift(lives: Int) {
        gameEngine.animateLives(originalLives: GameEngine.livesRemaining, newLives: lives)
        gameEngine.incrementLivesRemaining(lives: lives)

        //MUST come after call to gameEngine.incrementLivesRemaining()!!
        FIRManager.updateFirestoreRecordLivesRemaining(lives: GameEngine.livesRemaining)
        AudioManager.shared.playSound(for: "revive")
    }
    
    
}
