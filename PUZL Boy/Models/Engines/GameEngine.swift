//
//  GameEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/9/22.
//

import SpriteKit

protocol GameEngineDelegate: AnyObject {
    func gameIsSolved(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool)
    func gameIsOver(firstTimeCalled: Bool)
    func enemyIsKilled()
    func gameIsPaused(isPaused: Bool)

    //Party Functions
    func didTakePartyPill()
    func didGetPartyTime(_ seconds: TimeInterval)
    func didGetPartyBomb()
}

/**
 GameEngine cannot be a struct, otherwise you run into "Simultaneous accesses to xxx, but modification requires exclusive access" error due to mutliple instantiations of GameEngine(level:)
 */
class GameEngine {
    
    // MARK: - Properties
    
    private(set) static var livesRemaining: Int = LifeSpawnerModel.defaultLives
    private(set) static var usedContinue: Bool = false
    private(set) static var livesUsed: Int = 0
    private(set) static var winStreak: Int = 0 {
        didSet {
            switch winStreak {
            case 20: GameCenterManager.shared.updateProgress(achievement: .hotToTrot, shouldReportImmediately: true)
            case 40: GameCenterManager.shared.updateProgress(achievement: .onFire, shouldReportImmediately: true)
            case 80: GameCenterManager.shared.updateProgress(achievement: .nuclear, shouldReportImmediately: true)
            default: break
            }
        }
    }

    private(set) var level: Level!
    private(set) var levelStatsArray: [LevelStats] = []
    private(set) var gemsRemaining: Int!
    private(set) var gemsCollected: Int = 0
    private(set) var partyInventory: PartyInventory = PartyInventory()
    private(set) var healthRemaining: Int = 1 {
        didSet {
            healthRemaining = max(0, healthRemaining)
        }
    }
    private(set) var movesRemaining: Int! {
        didSet {
            movesRemaining = max(0, movesRemaining)
        }
    }
    
    private(set) var disableInputFromOutside = false
    private var shouldDisableControlInput = false
    private var justStartedDisableWarp = true
    private var shouldUpdateRemainingForBoulderIfIcy = false
    private var isGliding = false
    
    private(set) var enemiesKilled: Int = 0
    private(set) var bouldersBroken: Int = 0
    private var toolsCollected: Int = 0
    
    var isExitAvailable: Bool { gemsRemaining == 0 }
    var isSolved: Bool { isExitAvailable && level.player == level.end }

    ///Returns true if there are 0 moves left and health is 0.
    var isGameOver: Bool { movesRemaining <= 0 || healthRemaining <= 0 }
    
    ///Returns true if there are 0 lives remaining.
    var canContinue: Bool { return GameEngine.livesRemaining >= 0 }

    private var backgroundSprite: SKSpriteNode!
    private var bloodOverlay: SKSpriteNode!
    private var bloodOverlayAlpha: CGFloat { 0.25 * CGFloat(level.level) / CGFloat(Level.finalLevel) }
    private(set) var gameboardSprite: GameboardSprite!
    private(set) var playerSprite: PlayerSprite!
    private(set) var displaySprite: DisplaySprite!
    
    // FIXME: - SolutionEngine Debug
    private var solutionEngine: SolutionEngine!

    weak var delegate: GameEngineDelegate?
    
    
    // MARK: - Initialization
    
    /**
     Initializes a Game Engine with the given level and animation sequence.
     - parameters:
        - level: The initial level to load
        - shouldSpawn: determines whether should fade gameboard, i.e. if shouldSpawn is false
     */
    init(level: Int = 1, shouldSpawn: Bool) {
        newGame(level: level, shouldSpawn: shouldSpawn)
    }
    
    ///This function replaces having to keep initializing a new GameEngines in newGame in GameScene, which was causing huge memory spikes and app crashing for lower level devices.
    func newGame(level: Int, shouldSpawn: Bool) {
        guard LevelBuilder.levelsSize > 0 else {
            fatalError("Firebase records were not loaded!🙀")
        }
        
        if Level.isPartyLevel(level) {
            self.level = Level(level: Level.partyLevel, moves: 0, health: 0, solution: "D,E,F",
                               gameboard: LevelBuilder.buildPartyGameboard(ofSize: self.level.gameboard.count))
        }
        else {
            self.level = LevelBuilder.levels[level]
        }
        
        movesRemaining = self.level.moves
        healthRemaining = 1
        gemsRemaining = self.level.gems
        
        //BUGFIX# 231114E01 Is it necessary to reset gemsCollected because otherwise it accumulates ad infinitum???
        gemsCollected = 0
        
        enemiesKilled = 0
        bouldersBroken = 0
        toolsCollected = 0
        
        finishInit(shouldSpawn: shouldSpawn)
    }
    
    /**
     For when reading from Firestore.
     - parameters:
        - saveStateModel: the Firestore record model in a nutshell
        - levelSelectNewLevel: optional new level which would have come from LevelSelect in the TitleScene.
     */
    init(saveStateModel: SaveStateModel, levelSelectNewLevel: Int?) {
        let newLevel = levelSelectNewLevel ?? saveStateModel.newLevel
        
        if newLevel == saveStateModel.levelModel.level {
            //Grab the last level state w/ gameboard, level, moves and health data intact since last session...
            level = Level(level: saveStateModel.levelModel.level,
                          moves: saveStateModel.levelModel.moves,
                          health: saveStateModel.levelModel.health,
                          solution: saveStateModel.levelModel.solution,
                          gameboard: LevelBuilder.buildGameboard(levelModel: saveStateModel.levelModel))
            level.inventory = saveStateModel.levelModel.inventory
            level.updatePlayer(position: (row: saveStateModel.levelModel.playerPosition.row, col: saveStateModel.levelModel.playerPosition.col))
            movesRemaining = saveStateModel.levelModel.moves
            gemsRemaining = saveStateModel.levelModel.gemsRemaining
            gemsCollected = saveStateModel.levelModel.gemsCollected
            
            for item in saveStateModel.levelStatsArray {
                let levelStatsItem = LevelStats(level: item.level, elapsedTime: item.elapsedTime, livesUsed: item.livesUsed, movesRemaining: item.movesRemaining, enemiesKilled: item.enemiesKilled, bouldersBroken: item.bouldersBroken, score: item.score, didWin: item.didWin, inventory: item.inventory)
                
                levelStatsArray.append(levelStatsItem)
            }
        }
        else {
            //...unless newLevel doesn't match level #, then create a new level from newLevel.
            level = Level(level: newLevel,
                          moves: LevelBuilder.levels[newLevel].moves,
                          health: LevelBuilder.levels[newLevel].health,
                          solution: LevelBuilder.levels[newLevel].solution,
                          gameboard: LevelBuilder.levels[newLevel].gameboard)
            level.inventory = Inventory(hammers: 0, swords: 0)
            //level.updatePlayer(position: (row: saveStateModel.playerPosition.row, col: saveStateModel.playerPosition.col))
            movesRemaining = level.moves
            gemsRemaining = level.gems
            gemsCollected = 0
        }
        
        GameEngine.livesRemaining = saveStateModel.livesRemaining
        GameEngine.usedContinue = saveStateModel.usedContinue
        GameEngine.livesUsed = saveStateModel.levelStatsArray.filter({ $0.level == level.level }).first?.livesUsed ?? GameEngine.livesUsed
        GameEngine.winStreak = saveStateModel.winStreak
        
        finishInit(shouldSpawn: true)
    }
    
    private func finishInit(shouldSpawn: Bool) {
        backgroundSprite = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        backgroundSprite.size = K.ScreenDimensions.size
        backgroundSprite.anchorPoint = .zero
        
        bloodOverlay = SKSpriteNode(color: .red, size: K.ScreenDimensions.size)
        bloodOverlay.anchorPoint = .zero
        bloodOverlay.alpha = bloodOverlayAlpha
        bloodOverlay.zPosition = K.ZPosition.partyForegroundOverlay
        
        gameboardSprite = GameboardSprite(level: self.level)
        K.ScreenDimensions.topOfGameboard = GameboardSprite.offsetPosition.y + K.ScreenDimensions.size.width * GameboardSprite.spriteScale
        playerSprite = PlayerSprite(shouldSpawn: true)
        displaySprite = DisplaySprite(topYPosition: K.ScreenDimensions.topOfGameboard, bottomYPosition: GameboardSprite.offsetPosition.y, margin: 40)
        
        //Explicitly add additional hearts from the princess, at the start of the level if healthRemaining > 1
        if level.health > 1 {
            displaySprite.sprite.run(SKAction.repeat(SKAction.sequence([
                SKAction.run { [unowned self] in
                    // FIXME: - Is this a retain cycle???
                    displaySprite.statusHealth.pulseImage()
                    
                    //Level 51 is the dragon level, and it's annoying to hear pickupheart 10 times...
                    if level.level > 51 {
                        AudioManager.shared.playSound(for: "pickupheart")
                        
                        ScoringEngine.updateStatusIconsAnimation(
                            icon: .health,
                            amount: 1,
                            originSprite: gameboardSprite.sprite,
                            location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y + 20))
                    }
                    
                    healthRemaining += 1
                    setLabelsForDisplaySprite()
                },
                SKAction.wait(forDuration: 0.5)
            ]), count: level.health - 1))
        }

        setLabelsForDisplaySprite()
        setPlayerSpritePosition(shouldAnimate: false, completion: nil)
        justStartedDisableWarp = false
        isGliding = false //Need this here otherwise when you die while gliding, it doesn't get reset and you start out gliding BUGFIX# 230924E01
        
        if !shouldSpawn {
            fadeGameboard(fadeOut: false, completion: nil)
        }
        
        // FIXME: - Theoretically can delete these two lines; shouldn't be a problem once LevelSkipEngine is removed when shipping this game.
        AudioManager.shared.stopSound(for: "magicdoomloop", fadeDuration: 0.5)
        AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme, fadeDuration: 0.5)
        
        // FIXME: - SolutionEngine Debug
        solutionEngine = SolutionEngine(solution: level.solution, yPos: gameboardSprite.sprite.position.y)
        if let user = FIRManager.user, user.uid == FIRManager.userEddie {
            backgroundSprite.addChild(solutionEngine.sprite)
        }
    }
    
    deinit {
        print("GameEngine deinit")
    }
    
    
    // MARK: - Setup Functions
    
    /**
     Sets the player sprite position easily.
     - parameters:
        - toLastPanel: text
        - shouldAnimate: animate the player's movement if `true`
        - completion: completion handler after block executes
     */
    private func setPlayerSpritePosition(toLastPanel lastPanel: LevelType? = nil, shouldAnimate animate: Bool, completion: (() -> ())?) {
        let playerLastPosition = gameboardSprite.getLocation(at: level.player)
        let panel = lastPanel == nil ? level.getLevelType(at: level.player) : lastPanel!
        var animationType: Player.Texture
        var soundFXTypeAndMovementSpeed: Player.Texture
        
        if isGliding {
            if level.inventory.hasSwords() && level.inventory.hasHammers() {
                animationType = .glideHammerSword
            }
            else if level.inventory.hasSwords() {
                animationType = .glideSword
            }
            else if level.inventory.hasHammers() {
                animationType = .glideHammer
            }
            else {
                animationType = .glide
            }
            
            soundFXTypeAndMovementSpeed = .glide
        }
        else if isSolved {
            animationType = .walk
            soundFXTypeAndMovementSpeed = .walk
        }
        else {
            if level.inventory.hasSwords() && level.inventory.hasHammers() {
                animationType = .runHammerSword
            }
            else if level.inventory.hasSwords() {
                animationType = .runSword
            }
            else if level.inventory.hasHammers() {
                animationType = .runHammer
            }
            else {
                animationType = .run
            }
            
            switch panel {
            case .marsh:                                        
                soundFXTypeAndMovementSpeed = .marsh
            case .sand:                                         
                soundFXTypeAndMovementSpeed = .sand
            case .partytile, .start, .endClosed, .endOpen:      
                soundFXTypeAndMovementSpeed = .party
            default:                                            
                soundFXTypeAndMovementSpeed = .run
            }
        }

        if animate {
            let playerMove = SKAction.move(to: playerLastPosition, duration: soundFXTypeAndMovementSpeed.movementSpeed)
                        
            shouldDisableControlInput = true

            playerSprite.startMoveAnimation(animationType: animationType, soundFXType: soundFXTypeAndMovementSpeed)
            
            playerSprite.sprite.run(playerMove) { [unowned self] in
                // FIXME: - Is this a retain cycle???
                playerSprite.startIdleAnimation(hasSword: !isSolved && level.inventory.hasSwords(), hasHammer: !isSolved && level.inventory.hasHammers())
                checkSpecialPanel { [unowned self] in
                    shouldDisableControlInput = false
                    completion?()
                }
            }
        }
        else {
            playerSprite.sprite.position = playerLastPosition
            checkSpecialPanel(completion: nil)
            completion?()
        }
    }
    
    /**
     Checks for a special panel.
     */
    private func checkSpecialPanel(completion: (() -> ())?) {
        func animateParticles(type: ParticleEngine.ParticleType, duration: TimeInterval = 2) {
            ParticleEngine.shared.animateParticles(type: type,
                                                   toNode: gameboardSprite.sprite,
                                                   position: gameboardSprite.getLocation(at: level.player),
                                                   scale: 3 / CGFloat(gameboardSprite.panelCount),
                                                   duration: duration)
        }
        
        
        switch level.getLevelType(at: level.player) {
        case .gem:
            gemsRemaining -= 1
            gemsCollected += 1
            
            Haptics.shared.addHapticFeedback(withStyle: .light)
            animateParticles(type: .gemCollect)
            animateParticles(type: .gemSparkle)

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .gem) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .hammer:
            displaySprite.statusHammers.pulseImage()
            level.inventory.hammers += 1
            toolsCollected += 1

            setLabelsForDisplaySprite()
            consumeItem()
            
            Haptics.shared.addHapticFeedback(withStyle: .rigid)
            animateParticles(type: .itemPickup)
            
            playerSprite.startPowerUpAnimation()
            playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
            
            ScoringEngine.updateStatusIconsAnimation(
                icon: .hammer,
                amount: 1,
                originSprite: gameboardSprite.sprite,
                location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y + 20))
            
            completion?()
        case .sword:
            displaySprite.statusSwords.pulseImage()
            level.inventory.swords += 1
            toolsCollected += 1

            setLabelsForDisplaySprite()
            consumeItem()

            Haptics.shared.addHapticFeedback(withStyle: .rigid)
            animateParticles(type: .itemPickup)
            
            playerSprite.startPowerUpAnimation()
            playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
            
            ScoringEngine.updateStatusIconsAnimation(
                icon: .sword,
                amount: 1,
                originSprite: gameboardSprite.sprite,
                location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y + 20))

            completion?()
        case .heart:
            displaySprite.statusHealth.pulseImage()
            healthRemaining += 1

            setLabelsForDisplaySprite()
            
            Haptics.shared.addHapticFeedback(withStyle: .soft)
            animateParticles(type: .hearts)
            
            ScoringEngine.updateStatusIconsAnimation(
                icon: .health,
                amount: 1,
                originSprite: gameboardSprite.sprite,
                location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y + 20))

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .heart, sound: .heart) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .boulder:
            guard level.inventory.hammers > 0 else { return }
                        
            Haptics.shared.executeCustomPattern(pattern: .breakBoulder)
            bouldersBroken += 1
            level.inventory.hammers -= 1
            
            playerSprite.startHammerAnimation(on: gameboardSprite, at: level.player) { [unowned self] in
                animateParticles(type: .boulderCrush, duration: 5)
                
                setLabelsForDisplaySprite()
                consumeItem()
                
                completion?()
            }

            playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
        case .enemy:
            guard level.inventory.swords > 0 else { return }
            
            Haptics.shared.executeCustomPattern(pattern: .killEnemy)
            enemiesKilled += 1
            level.inventory.swords -= 1
            
            playerSprite.startSwordAnimation(on: gameboardSprite, at: level.player) { [unowned self] in
                setLabelsForDisplaySprite()
                consumeItem()
                delegate?.enemyIsKilled()
                
                completion?()
            }
            
            playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
        case .warp, .warp2, .warp3:
            guard !justStartedDisableWarp, let newWarpLocation = gameboardSprite.warpTo(warpType: level.getLevelType(at: level.player), initialPosition: level.player) else {
                completion?()
                return
            }
            
            Haptics.shared.executeCustomPattern(pattern: .warp)
            AudioManager.shared.stopSound(for: "moveglide", fadeDuration: 0.5)
            AudioManager.shared.playSound(for: "warp")
            
            let initialWarpLocation = level.player ?? newWarpLocation

            //Start marsh animation if initial warp location has marsh, regardless.
            if level.getTerrainType(at: initialWarpLocation) == .marsh {
                handleMarsh()
            }
            
            animateParticles(type: .warp)
            
            playerSprite.startWarpAnimation(shouldReverse: false, stopAnimating: false) { [unowned self] in
                level.updatePlayer(position: newWarpLocation)
                
                // FIXME: - Is this a retain cycle???
                playerSprite.sprite.position = gameboardSprite.getLocation(at: newWarpLocation)
                playerSprite.startWarpAnimation(shouldReverse: true, stopAnimating: true) { [unowned self] in
                    
                    //But, also do marsh animation if end warp has marsh, but not initial warp; it's one or the other, not both.. clunky!
                    if level.getTerrainType(at: initialWarpLocation) != .marsh && level.getTerrainType(at: newWarpLocation) == .marsh {
                        handleMarsh()
                    }

                    //Deduct an additional move due to marsh
                    if level.getTerrainType(at: initialWarpLocation) == .marsh || level.getTerrainType(at: newWarpLocation) == .marsh {
                        movesRemaining -= 1
                    }

                    completion?()
                }
            }
        case .partyPill:
            consumeItem() //MUST be here else game freezes
            completion?()
            
            delegate?.didTakePartyPill()
        case .partyGem:
            partyInventory.gems += 1
            
            Haptics.shared.addHapticFeedback(withStyle: .medium)
            animateParticles(type: .partyGem)
            animateParticles(type: .gemSparkle)

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyGem, sound: .partyGem) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .partyGemDouble:
            partyInventory.gemsDouble += 1

            Haptics.shared.addHapticFeedback(withStyle: .medium)
            animateParticles(type: .partyGem)
            animateParticles(type: .gemSparkle)

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyGemDouble, sound: .partyGemDouble) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .partyGemTriple:
            partyInventory.gemsTriple += 1

            Haptics.shared.addHapticFeedback(withStyle: .medium)
            animateParticles(type: .partyGem)
            animateParticles(type: .gemSparkle)

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyGemTriple, sound: .partyGemTriple) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .partyLife:
            partyInventory.lives += 1

            Haptics.shared.addHapticFeedback(withStyle: .medium)

            ScoringEngine.addTextAnimation(text: "1-UP", textColor: .yellow, originSprite: gameboardSprite.sprite, location: gameboardSprite.getLocation(at: level.player))

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyLife, sound: .partyLife) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .partyTime:
            partyInventory.time += 1

            Haptics.shared.addHapticFeedback(withStyle: .medium)

            delegate?.didGetPartyTime(PartyInventory.timeIncrement)
            
            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyTime, sound: .partyTime) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .partyFast:
            let maxReached = PartyModeSprite.shared.multiplierMaxReached
            
            partyInventory.speedUp += 1
            PartyModeSprite.shared.increaseSpeedMultiplier(shouldDecrease: false)

            Haptics.shared.addHapticFeedback(withStyle: .medium)

            if !maxReached {
                ScoringEngine.addTextAnimation(text: "SPEED+", textColor: .cyan, originSprite: gameboardSprite.sprite, location: gameboardSprite.getLocation(at: level.player))
            }

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyFast, sound: maxReached ? .boundary : .partyFast) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .partySlow:
            let minReached = PartyModeSprite.shared.multiplierMinReached
            
            partyInventory.speedDown += 1
            PartyModeSprite.shared.increaseSpeedMultiplier(shouldDecrease: true)

            Haptics.shared.addHapticFeedback(withStyle: .medium)

            if !minReached {
                ScoringEngine.addTextAnimation(text: "SPEED-", textColor: .magenta, originSprite: gameboardSprite.sprite, location: gameboardSprite.getLocation(at: level.player))
            }
                
            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partySlow, sound: minReached ? .boundary : .partySlow) { [unowned self] in
                consumeItem()
                completion?()
            }
        case .partyBomb:
            disableInputFromOutside = true
            
            Haptics.shared.executeCustomPattern(pattern: .lava)
            
            playerSprite.animateExplosion(on: gameboardSprite, at: level.player, scale: 2) { }
            
            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyBoom, sound: .partyBomb) { [unowned self] in
                consumeItem()
                completion?()

                delegate?.didGetPartyBomb()
            }
        default:
            completion?()
            break
        }
    }
    
    private func handleMarsh() {
        Haptics.shared.executeCustomPattern(pattern: .marsh)
        playerSprite.startMarshEffectAnimation()
        
        ScoringEngine.updateStatusIconsAnimation(
            icon: .moves,
            amount: -2,
            originSprite: gameboardSprite.sprite,
            location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y - 20))
    }
    
    /**
     Removes the overlay from the terrain tile, after consuming the item.
     */
    private func consumeItem() {
        level.removeOverlayObject(at: level.player)

        for child in gameboardSprite.sprite.children {
            //Exclude Player, which will have no name, AND any Particle Emitter nodes!!
            guard let name = child.name, name != ParticleEngine.nodeName, name.contains(GameboardSprite.delimiter) else { continue }
            
            let row = String(name.prefix(upTo: name.firstIndex(of: Character(GameboardSprite.delimiter))!))
            let col = String(name.suffix(from: name.firstIndex(of: Character(GameboardSprite.delimiter))!).dropFirst()).replacingOccurrences(of: GameboardSprite.overlayTag, with: "")
            let isOverlay = name.contains(GameboardSprite.overlayTag)
            let position: K.GameboardPosition = (row: Int(row) ?? -1, col: Int(col) ?? -1)

            //Remove overlay object, if found
            if position == level.player && isOverlay, let child = gameboardSprite.sprite.childNode(withName: GameboardSprite.getNodeName(row: Int(row) ?? 0, col: Int(col) ?? 0, includeOverlayTag: true)) {
                child.removeFromParent()
            }
            
            //Update exitClosed panel to exitOpen
            if isExitAvailable && position == level.end && level.getLevelType(at: position) == .endClosed, let child = gameboardSprite.sprite.childNode(withName: GameboardSprite.getNodeName(row: Int(row) ?? 0, col: Int(col) ?? 0)) {
                
                let endOpen: K.GameboardPanel = (terrain: .endOpen, overlay: Level.shouldProvidePill(level.level) ? .partyPill : .boundary)
                
                child.removeFromParent()
                gameboardSprite.updatePanels(at: position, with: endOpen)
                level.setLevelType(at: position, with: endOpen)
                                
                AudioManager.shared.playSound(for: "dooropen")
                
                if Level.shouldProvidePill(level.level) {
                    AudioManager.shared.playSound(for: "partypill")
                }
                
            }
        } //end for
    } //end consumeItem()
    
    private func setLabelsForDisplaySprite() {
        displaySprite.setLabels(level: "\(level.level)",
                                lives: "\(GameEngine.livesRemaining)",
                                moves: "\(movesRemaining ?? -99)",
                                health: "\(healthRemaining)",
                                inventory: level.inventory)
    }
    
    
    // MARK: - Spawn Functions
    
    ///Spawns items in a party level.
    // FIXME: - Party items spawned especially in panel(0,0) seem to disappear instantly, especially with 3x3 size grids. BUGFIX# 230914E01
    func spawnPartyItems(maxItems: Int) {
        guard Level.isPartyLevel(level.level) else { return }
                
        var itemPositions: [K.GameboardPosition] = Array(repeating: (row: 0, col: 0), count: maxItems)

        partyInventory = PartyInventory(panelCount: level.gameboard.count)

        for i in 0..<maxItems {
            let spawnAction = SKAction.run { [unowned self] in
                let randomItem: LevelType = partyInventory.getRandomItem()
                var counterCheck = 0

                while itemPositions[i] == level.player || level.getOverlayType(at: itemPositions[i]) != .boundary {
                    itemPositions[i] = partyInventory.randomizePosition
                    counterCheck += 1
                    
                    //Prevents infinite while loop
                    if counterCheck > 2 * level.gameboard.count * level.gameboard.count {
                        print("Too many party gems!")
                        break
                    }
                }
                
                counterCheck = 0
                
                gameboardSprite.spawnItem(at: itemPositions[i], with: randomItem) { }
                level.setLevelType(at: itemPositions[i], with: (terrain: .partytile, overlay: randomItem))
            }
            
            let despawnAction = SKAction.run { [unowned self] in
                gameboardSprite.despawnItem(at: itemPositions[i]) { [unowned self] in
                    level.setLevelType(at: itemPositions[i], with: (terrain: .partytile, overlay: .boundary))
                }
            }
            
            gameboardSprite.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: partyInventory.spawnDelayDuration * TimeInterval(i)),
                spawnAction,
                SKAction.wait(forDuration: partyInventory.itemWaitDuration),
                despawnAction
            ]))
        } //end for
    } //end spawnPartyItems()
    
    ///Stops the spawning of party items.
    func stopSpawner() {
        gameboardSprite.sprite.removeAllActions()
    }
    
    
    // MARK: - Controls Functions
    
    /**
     Handles player movement based on control input.
     - parameter location: Location for which comparison is to occur.
     */
    func handleControls(in location: CGPoint) {
        guard checkControlGuardsIfPassed(includeDisableInputFromOutside: true) else { return }

        
        //NOW you may proceed... if you pass all the above guards.
        if inBounds(location: location, direction: .up) {
            movePlayerHelper(direction: .up)
        }
        else if inBounds(location: location, direction: .down) {
            movePlayerHelper(direction: .down)
        }
        else if inBounds(location: location, direction: .left) {
            playerSprite.sprite.xScale = -abs(playerSprite.sprite.xScale)
            
            movePlayerHelper(direction: .left)
        }
        else if inBounds(location: location, direction: .right) {
            playerSprite.sprite.xScale = abs(playerSprite.sprite.xScale)
            
            movePlayerHelper(direction: .right)
        }
//        else {
//            guard let tappedPanel = gameboardSprite.getPanel(at: location) else { return }
//            gameboardSprite.highlightPanel(color: .red, at: tappedPanel)
//
//            Haptics.shared.addHapticFeedback(withStyle: .rigid)
//        }
    }
    
    func checkControlGuardsIfPassed(includeDisableInputFromOutside: Bool) -> Bool {
        guard !isSolved else { return false }
        guard !isGameOver else { return false }
        guard !shouldDisableControlInput else { return false }
        
        if includeDisableInputFromOutside {
            guard !disableInputFromOutside else { return false }
        }
        
        return true
    }
    
    
    // MARK: - Controls Helper Functions
    
    /**
     Takes a tap location and compares it to the player's next position.
     - parameters:
        - location: Location of the tap
        - controls: The player's next position, either up, down, left, or right
     */
    private func inBounds(location: CGPoint, direction: Controls) -> Bool {
        let maxDistance = gameboardSprite.panelCount
        let panelSize = gameboardSprite.panelSize * GameboardSprite.spriteScale
        let gameboardSize = panelSize * CGFloat(maxDistance)
        
        var bottomBound = level.player.row + 1
        var rightBound = level.player.col + 1
        var topBound = level.player.row {
            didSet {
                if topBound < 0 {
                    topBound = 0
                }
            }
        }
        var leftBound = level.player.col {
            didSet {
                if leftBound < 0 {
                    leftBound = 0
                }
            }
        }
        
        switch direction {
        case .up:
            topBound = -maxDistance
            bottomBound -= 1
        case .down:
            topBound += 1
            bottomBound = maxDistance
        case .left:
            leftBound = -maxDistance
            rightBound -= 1
        case .right:
            leftBound += 1
            rightBound = maxDistance
        }
        
        return location.x > GameboardSprite.offsetPosition.x + (CGFloat(leftBound) * panelSize) &&
        location.x < GameboardSprite.offsetPosition.x + (CGFloat(rightBound) * panelSize) &&
        location.y > GameboardSprite.offsetPosition.y + gameboardSize - (CGFloat(bottomBound) * panelSize) &&
        location.y < GameboardSprite.offsetPosition.y + gameboardSize - (CGFloat(topBound) * panelSize)
    }
    
    /**
     Helper function that moves the player.
     - parameter direction: The direction the player is moving
     */
    private func movePlayerHelper(direction: Controls) {
        ///Used when moving over certain terrain
        func updateGliding() {
            updateMovesRemaining()
            shouldUpdateRemainingForBoulderIfIcy = false
            isGliding = false
            AudioManager.shared.stopSound(for: "moveglide", fadeDuration: 0.5)
        }
        
        let lastPanel: K.GameboardPosition = level.player
        var nextPanel: K.GameboardPosition
        
        switch direction {
        case .up:
            nextPanel = (row: level.player.row - 1, col: level.player.col)
        case .down:
            nextPanel = (row: level.player.row + 1, col: level.player.col)
        case .left:
            nextPanel = (row: level.player.row, col: level.player.col - 1)
        case .right:
            nextPanel = (row: level.player.row, col: level.player.col + 1)
        }

        // FIXME: - SolutionEngine Debug
        solutionEngine.appendDirection(direction)
        
        guard checkPanelForPathway(position: nextPanel, direction: direction) else {
//            gameboardSprite.highlightPanel(color: .red, at: nextPanel)
            AudioManager.shared.stopSound(for: "moveglide", fadeDuration: 0.5)
            return
        }
        
//        gameboardSprite.highlightPanel(color: .green, at: nextPanel)
        
        level.updatePlayer(position: nextPanel)
        
        setPlayerSpritePosition(toLastPanel: level.getLevelType(at: lastPanel), shouldAnimate: true) { [unowned self] in
            if level.getLevelType(at: lastPanel) == .sand {
                level.setLevelType(at: lastPanel, with: (terrain: LevelType.lava, overlay: LevelType.boundary))
                gameboardSprite.animateDissolveSand(position: lastPanel)
            }
            
            if level.getLevelType(at: nextPanel) == .lava {
                Haptics.shared.executeCustomPattern(pattern: .lava)

                // FIXME: - Is this a retain cycle???
                playerSprite.startLavaEffectAnimation()
                
                ScoringEngine.updateStatusIconsAnimation(
                    icon: .health,
                    amount: -healthRemaining,
                    originSprite: gameboardSprite.sprite,
                    location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y - 20))

                healthRemaining = 0
                
                updateGliding()
                
                //EXIT RECURSION
                return
            }
            else if level.getLevelType(at: nextPanel) != .ice {
                updateGliding()
                
                //I don't like this being here...
                if level.getLevelType(at: nextPanel) == .marsh {
                    handleMarsh()
                }

                //EXIT RECURSION
                return
            }
            else {
                shouldUpdateRemainingForBoulderIfIcy = true
                isGliding = true
                
                // FIXME: - SolutionEngine Debug
                solutionEngine.dropLastDirection()
            }
            
            //ENTER RECURSION
            movePlayerHelper(direction: direction)
        }
    }
    
    /**
     Checks to make sure panel doesn't have an "obstructed" (i.e. a boulder, enemy or boundary).
     - parameter position: the row, column that the player is on.
     - returns: true if the panel is an enemy, i.e. handle differently
     */
    private func checkPanelForPathway(position: K.GameboardPosition, direction: Controls) -> Bool {
        switch level.getLevelType(at: position) {
        case .boulder:
            if level.inventory.hammers <= 0 {
                if shouldUpdateRemainingForBoulderIfIcy {
                    updateMovesRemaining()
                    shouldUpdateRemainingForBoulderIfIcy = false
                }

                // FIXME: - SolutionEngine Debug
                else {
                    solutionEngine.dropLastDirection()
                }
                
                GameCenterManager.shared.updateProgress(achievement: .klutz, shouldReportImmediately: false)
                
                shouldDisableControlInput = true
                playerSprite.startKnockbackAnimation(on: gameboardSprite, at: level.player, isAttacked: false, direction: direction) { [unowned self] in
                    shouldDisableControlInput = false
                }

                return false
            }
        case .enemy:
            if level.inventory.swords <= 0 {
                if shouldUpdateRemainingForBoulderIfIcy {
                    updateMovesRemaining()
                    shouldUpdateRemainingForBoulderIfIcy = false
                    
                    // ...but exit early if already gameover so you don't get 2 dying animations... ugly!!
                    if isGameOver {
                        return false
                    }
                }
                
                // FIXME: - SolutionEngine Debug
                else {
                    solutionEngine.dropLastDirection()
                }
//                updateMovesRemaining() //removed here...

                shouldDisableControlInput = true
                playerSprite.startKnockbackAnimation(on: gameboardSprite, at: level.player, isAttacked: true, direction: direction) { [unowned self] in
                    // FIXME: - Is this a retain cycle??? (because updateMovesRemaining calls playerSprite.startDeadAnimation())
                    updateMovesRemaining(enemyAttacked: true) //...added here
                    shouldDisableControlInput = false
                }
                
                ScoringEngine.updateStatusIconsAnimation(
                    icon: .health,
                    amount: -1,
                    originSprite: gameboardSprite.sprite,
                    location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y - 20))
                                
                return false
            }
        case .boundary:
            if shouldUpdateRemainingForBoulderIfIcy {
                updateMovesRemaining()
                shouldUpdateRemainingForBoulderIfIcy = false
            }
            
            return false
        default:
            break
        }
        
        return true
    }
    
    /**
     Updates the moveRemaining property.
     */
    private func updateMovesRemaining(enemyAttacked: Bool = false) {
        if enemyAttacked {
            healthRemaining -= 1
        }
        else {
            movesRemaining -= level.getLevelType(at: level.player) == .marsh ? 2 : 1
        }
        
        setLabelsForDisplaySprite()
        
        if isSolved {
            playerSprite.startPlayerExitAnimation()
            
            AudioManager.shared.playSound(for: "winlevel")
            delegate?.gameIsSolved(movesRemaining: movesRemaining,
                                   itemsFound: level.inventory.getItemCount(),
                                   enemiesKilled: enemiesKilled,
                                   usedContinue: GameEngine.usedContinue)
            
            GameEngine.usedContinue = false
            GameEngine.livesUsed = 0
            GameEngine.winStreak += 1
            
            updateAchievements()
            
            StoreReviewManager.shared.incrementCount()

            print("Win streak: \(GameEngine.winStreak), Level: \(level.level)")
            
            // FIXME: - SolutionEngine Debug
            solutionEngine.checkForMatch()
        }
        else if isGameOver {
            AudioManager.shared.stopSound(for: AudioManager.shared.currentTheme)
            AudioManager.shared.playSound(for: "gameover")

            if healthRemaining <= 0 {
                displaySprite.drainHealth()
            }
            
            GameEngine.livesRemaining -= 1
            GameEngine.usedContinue = true
            GameEngine.livesUsed += 1
            GameEngine.winStreak = 0
            
            GameCenterManager.shared.updateProgress(achievement: .reckless, shouldReportImmediately: true)

            //NEW 2/21/23 Don't increment the count if the player is losing. This might make them give a negative review...
//            StoreReviewManager.shared.incrementCount()

            //Run this BEFORE startDeadAnimation!!
            PartyModeSprite.shared.stopParty(partyBoy: playerSprite,
                                             hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
            
            playerSprite.startDeadAnimation { [unowned self] in
                delegate?.gameIsOver(firstTimeCalled: true)
            }
            
            // FIXME: - SolutionEngine Debug
            solutionEngine.clearAttempt()
        }
    }
    
    private func updateAchievements() {
        GameCenterManager.shared.updateProgress(achievement: .gemCollector, increment: Double(gemsCollected))
        GameCenterManager.shared.updateProgress(achievement: .jewelConnoisseur, increment: Double(gemsCollected))
        GameCenterManager.shared.updateProgress(achievement: .myPreciouses, increment: Double(gemsCollected))
        
        GameCenterManager.shared.updateProgress(achievement: .stoneCutter, increment: Double(bouldersBroken))
        GameCenterManager.shared.updateProgress(achievement: .boulderBreaker, increment: Double(bouldersBroken))
        GameCenterManager.shared.updateProgress(achievement: .rockNRoller, increment: Double(bouldersBroken))

        GameCenterManager.shared.updateProgress(achievement: .exterminator, increment: Double(enemiesKilled))
        GameCenterManager.shared.updateProgress(achievement: .dragonSlayer, increment: Double(enemiesKilled))
        GameCenterManager.shared.updateProgress(achievement: .beastMaster, increment: Double(enemiesKilled))

        GameCenterManager.shared.updateProgress(achievement: .scavenger, increment: Double(toolsCollected))
        GameCenterManager.shared.updateProgress(achievement: .itemWielder, increment: Double(toolsCollected))
        GameCenterManager.shared.updateProgress(achievement: .hoarder, increment: Double(level.inventory.getItemCount()))
        
        GameCenterManager.shared.updateProgress(achievement: .superEfficient, increment: Double(movesRemaining))

        switch level.level {
        case 100:   GameCenterManager.shared.updateProgress(achievement: .braniac)
        case 250:   GameCenterManager.shared.updateProgress(achievement: .enigmatologist)
        case 500:   GameCenterManager.shared.updateProgress(achievement: .puzlGuru)
        default: break
        }
        
        let allAchievements = Achievement.achievements.map { $0.1 }
        GameCenterManager.shared.report(achievements: allAchievements)

        print("=========================")
        print("| GameEngine Properties |")
        print("| gemsCollected: \(gemsCollected)")
        print("| bouldersBroken: \(bouldersBroken)")
        print("| enemiesKilled: \(enemiesKilled)")
        print("| toolsCollected: \(toolsCollected)")
        print("| toolsRemaining: \(level.inventory.getItemCount())")
        print("| movesRemaining: \(movesRemaining ?? -9999)")
        print("=========================")        
    }
        
    
    // MARK: - Other Functions
    
    ///Use this when resuming from 0 moves, for example.
    func continueGame() {
        playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
    }
    
    ///Resets the level and reduces one life.
    func killAndReset() {        
        healthRemaining = 0
        updateMovesRemaining(enemyAttacked: true)
    }
    
    ///Just what it says. It increments livesRemaining.
    func incrementLivesRemaining(lives: Int = 1) {
        GameEngine.livesRemaining += lives
    }
    
    /**
     Sets livesRemaining to the specified # of lives.
     - parameter lives: number of lives to set to
     */
    func setLivesRemaining(lives: Int) {
        GameEngine.livesRemaining = lives
    }
    
    ///Call this upon continuing after 0 lives, i.e. thru an ad, purchase, or time lapse.
    func animateLives(originalLives: Int, newLives: Int) {
        displaySprite.statusLives.animateLives(originalLives: originalLives, newLives: newLives)
    }
    
    ///Increment movesRemaining with moves.
    func incrementMovesRemaining(moves: Int) {
        movesRemaining += moves
    }
    
    func animateMoves(originalMoves: Int, newMoves: Int) {
        displaySprite.statusMoves.animateMoves(originalMoves: originalMoves, newMoves: newMoves)
    }
    
    func checkIfGameOverOnStartup() {
        if !canContinue || isGameOver {
            print("Can't continue from GameEngine.shouldPlayAdOnStartup()... running delegate?.gameIsOver()...")
            AudioManager.shared.stopSound(for: AudioManager.shared.currentTheme)
            delegate?.gameIsOver(firstTimeCalled: false)
        }
    }
    
    func updateScores() {
        displaySprite.animateScores(movesScore: ScoringEngine.getMovesScore(from: movesRemaining),
                                    inventoryScore: ScoringEngine.getItemsFoundScore(from: level.inventory.getItemCount()),
                                    usedContinue: GameEngine.usedContinue)
    }
    
    func shouldDisableInput(_ disableInput: Bool) {
        disableInputFromOutside = disableInput
    }
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(backgroundSprite)
        superScene.addChild(bloodOverlay)
        superScene.addChild(gameboardSprite.sprite)
        
        if !Level.isPartyLevel(level.level) {
            superScene.addChild(displaySprite.sprite)
        }

        playerSprite.sprite.removeFromParent() //This is needed, otherwise gameboardSprite keeps adding it, below
        playerSprite.setScale(panelSize: gameboardSprite.panelSize)
        gameboardSprite.sprite.addChild(playerSprite.sprite)

        if !isGameOver {
            let numMovesSprite = NumMovesSprite(
                numMoves: self.level.moves,
                position: CGPoint(x: K.ScreenDimensions.size.width / 2, y: GameboardSprite.offsetPosition.y * 3 / 2),
                isPartyLevel: Level.isPartyLevel(level.level))
            
            superScene.addChild(numMovesSprite)
            
            numMovesSprite.play {
                numMovesSprite.removeFromParent()
            }
        }
    }
    
    /**
     Fades the gameboard by calling colorizeGameboard in GameboardSprite, by applying a clear color and using 0 to 1 blendFactor.
     - parameters:
        - fadeOut: true if you want to fade to empty, false if fade from empty
        - completion: completion handler called at the end of the animation
     */
    func fadeGameboard(fadeOut: Bool, completion: (() -> ())?) {
        gameboardSprite.sprite.alpha = fadeOut ? 1.0 : 0.0
        
        gameboardSprite.colorizeGameboard(color: fadeOut ? GameboardSprite.gameboardColor : .black,
                                          blendFactor: fadeOut ? 0.0 : 1.0,
                                          animationDuration: 0.0) { [weak gameboardSprite] in
            gameboardSprite?.sprite.alpha = 1.0
        }
        
        gameboardSprite.colorizeGameboard(color: fadeOut ? .black : GameboardSprite.gameboardColor,
                                          blendFactor: fadeOut ? 1.0 : 0.0,
                                          animationDuration: fadeOut ? 1.0 : 0.5,
                                          completion: completion)
    }
    
    func fadeBloodOverlay(shouldFadeOut: Bool, duration: TimeInterval) {
        if shouldFadeOut {
            bloodOverlay.run(SKAction.fadeOut(withDuration: duration))
        }
        else {
            bloodOverlay.run(SKAction.fadeAlpha(to: bloodOverlayAlpha, duration: duration))
        }
    }
    
    func removeParticles() {
        ParticleEngine.shared.removeParticles(fromNode: gameboardSprite.sprite)
    }
    
    func hideParticles() {
        ParticleEngine.shared.hideParticles(fromNode: gameboardSprite.sprite)
    }
    
    func showParticles() {
        ParticleEngine.shared.showParticles(fromNode: gameboardSprite.sprite)
    }
}
