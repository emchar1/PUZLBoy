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
    func didTakePartyPill()
    func didGetPartyTime(_ seconds: TimeInterval)
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
    private(set) var healthRemaining: Int! {
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
    private(set) var gameboardSprite: GameboardSprite!
    private(set) var playerSprite: PlayerSprite!
    private(set) var displaySprite: DisplaySprite!

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
        guard LevelBuilder.maxLevel > 0 else {
            fatalError("Firebase records were not loaded!🙀")
        }
        
        if Level.isPartyLevel(level) {
            self.level = Level(level: Level.partyLevel, moves: 0, health: 0,
                               gameboard: LevelBuilder.buildPartyGameboard(ofSize: self.level.gameboard.count))
        }
        else {
            self.level = LevelBuilder.levels[level]
        }
        
        movesRemaining = self.level.moves
        healthRemaining = self.level.health
        gemsRemaining = self.level.gems
        
        enemiesKilled = 0
        bouldersBroken = 0
        toolsCollected = 0
        
        finishInit(shouldSpawn: shouldSpawn)
    }
    
    ///Spawns items in a party level.
    func spawnPartyItems(maxItems: Int) {
        guard Level.isPartyLevel(level.level) else { return }
        
        partyInventory = PartyInventory()
        
        let gameboardSize = self.level.gameboard.count
        var randomItem: LevelType = .partyGem
        var spawnDelayDuration: TimeInterval
        var itemWaitDuration: TimeInterval
        var counterCheck = 0
        var itemPositions: [K.GameboardPosition] = Array(repeating: (row: 0, col: 0), count: maxItems)
        var randomizePosition: K.GameboardPosition { (row: Int.random(in: 0..<gameboardSize), col: Int.random(in: 0..<gameboardSize)) }
        
        switch gameboardSize {
        case 6:
            spawnDelayDuration = 0.2
            itemWaitDuration = 3
        case 5:
            spawnDelayDuration = 0.3
            itemWaitDuration = 2.5
        case 4:
            spawnDelayDuration = 0.4
            itemWaitDuration = 2
        default: //gameboardSize = 3
            spawnDelayDuration = 0.5
            itemWaitDuration = 1.5
        }
        
        for i in 0..<maxItems {
            gameboardSprite.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: spawnDelayDuration * TimeInterval(i)),
                SKAction.run { [unowned self] in
                    while itemPositions[i] == self.level.player || self.level.getOverlayType(at: itemPositions[i]) != .boundary {
                        itemPositions[i] = randomizePosition
                        counterCheck += 1
                        
                        //Prevents infinite while loop
                        if counterCheck > gameboardSize * gameboardSize * 2 {
                            print("Too many party gems!")
                            break
                        }
                    }
                    
                    randomItem = partyInventory.getRandomItem()
                    counterCheck = 0
                    
                    gameboardSprite.spawnItem(at: itemPositions[i], with: randomItem) { }
                    self.level.setLevelType(at: itemPositions[i], with: (terrain: .partytile, overlay: randomItem))
                },
                SKAction.wait(forDuration: itemWaitDuration),
                SKAction.run { [unowned self] in
                    gameboardSprite.despawnItem(at: itemPositions[i]) {
                        self.level.setLevelType(at: itemPositions[i], with: (terrain: .partytile, overlay: .boundary))
                    }
                }
            ]))
        } //end for
    } //end spawnPartyItems()
    
    ///Stops the spawning of party items.
    func stopSpawner() {
        gameboardSprite.sprite.removeAllActions()
    }
    
    ///For when reading from Firestore.
    init(saveStateModel: SaveStateModel) {
        if saveStateModel.newLevel == saveStateModel.levelModel.level {
            //Grab the last level state w/ gameboard, level, moves and health data intact since last session...
            level = Level(level: saveStateModel.levelModel.level,
                          moves: saveStateModel.levelModel.moves,
                          health: saveStateModel.levelModel.health,
                          gameboard: LevelBuilder.buildGameboard(levelModel: saveStateModel.levelModel))
            level.inventory = saveStateModel.levelModel.inventory
            level.updatePlayer(position: (row: saveStateModel.levelModel.playerPosition.row, col: saveStateModel.levelModel.playerPosition.col))
            movesRemaining = saveStateModel.levelModel.moves
            healthRemaining = saveStateModel.levelModel.health
            gemsRemaining = saveStateModel.levelModel.gemsRemaining
            gemsCollected = saveStateModel.levelModel.gemsCollected
            
            for item in saveStateModel.levelStatsArray {
                let levelStatsItem = LevelStats(level: item.level, elapsedTime: item.elapsedTime, livesUsed: item.livesUsed, movesRemaining: item.movesRemaining, enemiesKilled: item.enemiesKilled, bouldersBroken: item.bouldersBroken, score: item.score, didWin: item.didWin, inventory: item.inventory)
                
                levelStatsArray.append(levelStatsItem)
            }
        }
        else {
            //...unless newLevel doesn't match level #, then create a new level from newLevel.
            level = Level(level: saveStateModel.newLevel,
                          moves: LevelBuilder.levels[saveStateModel.newLevel].moves,
                          health: LevelBuilder.levels[saveStateModel.newLevel].health,
                          gameboard: LevelBuilder.levels[saveStateModel.newLevel].gameboard)
            level.inventory = Inventory(hammers: 0, swords: 0)
            //level.updatePlayer(position: (row: saveStateModel.playerPosition.row, col: saveStateModel.playerPosition.col))
            movesRemaining = level.moves
            healthRemaining = level.health
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
        backgroundSprite = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(endPointY: 1.0)))
        backgroundSprite.size = CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height)
        backgroundSprite.position = .zero
        backgroundSprite.anchorPoint = .zero
        
        gameboardSprite = GameboardSprite(level: self.level)
        K.ScreenDimensions.topOfGameboard = GameboardSprite.yPosition + K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale
        playerSprite = PlayerSprite(shouldSpawn: true)
        displaySprite = DisplaySprite(topYPosition: K.ScreenDimensions.topOfGameboard, bottomYPosition: GameboardSprite.yPosition, margin: 40)

        setLabelsForDisplaySprite()
        setPlayerSpritePosition(shouldAnimate: false, completion: nil)
        justStartedDisableWarp = false
        
        if !shouldSpawn {
            fadeGameboard(fadeOut: false, completion: nil)
        }
    }
    
    deinit {
        print("deinit GameEngine")
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
        }
        else if isSolved {
            animationType = .walk
        }
        else if panel == .marsh {
            if level.inventory.hasSwords() && level.inventory.hasHammers() {
                animationType = .marshHammerSword
            }
            else if level.inventory.hasSwords() {
                animationType = .marshSword
            }
            else if level.inventory.hasHammers() {
                animationType = .marshHammer
            }
            else {
                animationType = .marsh
            }
        }
        else if panel == .sand {
            if level.inventory.hasSwords() && level.inventory.hasHammers() {
                animationType = .sandHammerSword
            }
            else if level.inventory.hasSwords() {
                animationType = .sandSword
            }
            else if level.inventory.hasHammers() {
                animationType = .sandHammer
            }
            else {
                animationType = .sand
            }
        }
        else if panel == .partytile {
            animationType = .party
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
        }

        if animate {
            let playerMove = SKAction.move(to: playerLastPosition, duration: animationType.movementSpeed)
                        
            shouldDisableControlInput = true

            playerSprite.startMoveAnimation(animationType: animationType)
            
            playerSprite.sprite.run(playerMove) { [unowned self] in
                playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
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
        switch level.getLevelType(at: level.player) {
        case .gem:
            gemsRemaining -= 1
            gemsCollected += 1
            
            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .gem) {
                self.consumeItem()
                completion?()
            }
        case .hammer:
            displaySprite.statusHammers.pulseImage()
            level.inventory.hammers += 1
            toolsCollected += 1

            setLabelsForDisplaySprite()
            consumeItem()
            
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
            consumeItem()
            
            AudioManager.shared.playSound(for: "pickupheart")
            
            ScoringEngine.updateStatusIconsAnimation(
                icon: .health,
                amount: 1,
                originSprite: gameboardSprite.sprite,
                location: CGPoint(x: playerSprite.sprite.position.x, y: playerSprite.sprite.position.y + 20))

            completion?()
        case .boulder:
            guard level.inventory.hammers > 0 else { return }
                        
            Haptics.shared.executeCustomPattern(pattern: .breakBoulder)
            bouldersBroken += 1
            level.inventory.hammers -= 1
            playerSprite.startHammerAnimation(on: gameboardSprite, at: level.player) {
                self.setLabelsForDisplaySprite()
                self.consumeItem()
                
                completion?()
            }
            playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
        case .enemy:
            guard level.inventory.swords > 0 else { return }
            
            Haptics.shared.executeCustomPattern(pattern: .killEnemy)
            enemiesKilled += 1
            level.inventory.swords -= 1
            playerSprite.startSwordAnimation(on: gameboardSprite, at: level.player) {
                self.setLabelsForDisplaySprite()
                self.consumeItem()
                self.delegate?.enemyIsKilled()
                
                completion?()
            }
            playerSprite.startIdleAnimation(hasSword: level.inventory.hasSwords(), hasHammer: level.inventory.hasHammers())
        case .warp, .warp2, .warp3:
            guard !justStartedDisableWarp, let newWarpLocation = gameboardSprite.warpTo(warpType: level.getLevelType(at: level.player), initialPosition: level.player) else {
                completion?()
                return
            }
            
            AudioManager.shared.stopSound(for: "moveglide", fadeDuration: 0.5)
            AudioManager.shared.playSound(for: "warp")
            
            let initialWarpLocation = level.player ?? newWarpLocation

            //Start marsh animation if initial warp location has marsh, regardless.
            if level.getTerrainType(at: initialWarpLocation) == .marsh {
                handleMarsh()
            }
            
            playerSprite.startWarpAnimation(shouldReverse: false, stopAnimating: false) {
                self.level.updatePlayer(position: newWarpLocation)
                self.playerSprite.sprite.position = self.gameboardSprite.getLocation(at: newWarpLocation)
                self.playerSprite.startWarpAnimation(shouldReverse: true, stopAnimating: true) {
                    
                    //But, also do marsh animation if end warp has marsh, but not initial warp; it's one or the other, not both.. clunky!
                    if self.level.getTerrainType(at: initialWarpLocation) != .marsh && self.level.getTerrainType(at: newWarpLocation) == .marsh {
                        self.handleMarsh()
                    }

                    //Deduct an additional move due to marsh
                    if self.level.getTerrainType(at: initialWarpLocation) == .marsh || self.level.getTerrainType(at: newWarpLocation) == .marsh {
                        self.movesRemaining -= 1
                    }

                    completion?()
                }
            }
        case .partyPill:
            AudioManager.shared.playSound(for: "pickupheart")
            consumeItem() //MUST be here else game freezes
            completion?()
            
            delegate?.didTakePartyPill()
        case .partyGem:
            partyInventory.gems += 1
                        
            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyGem) { [unowned self] in
                consumeItem()
                completion?()
                
                partyInventory.getStatus()
            }
        case .partyGemDouble:
            partyInventory.gemsDouble += 1
            
            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyGemDouble) { [unowned self] in
                consumeItem()
                completion?()

                partyInventory.getStatus()
            }
        case .partyGemTriple:
            partyInventory.gemsTriple += 1

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyGemTriple) { [unowned self] in
                consumeItem()
                completion?()

                partyInventory.getStatus()
            }
        case .partyLife:
            partyInventory.lives += 1

            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyLife) { [unowned self] in
                consumeItem()
                completion?()

                partyInventory.getStatus()
            }
        case .partyTime:
            delegate?.didGetPartyTime(partyInventory.timeVal)
            
            playerSprite.startItemCollectAnimation(on: gameboardSprite, at: level.player, item: .partyTime) { [unowned self] in 
                consumeItem()
                completion?()
                
                
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
            //Exclude Player, which will have no name
            guard let name = child.name else { continue }
            
            let row = String(name.prefix(upTo: name.firstIndex(of: ",")!))
            let col = String(name.suffix(from: name.firstIndex(of: ",")!).dropFirst()).replacingOccurrences(of: GameboardSprite.overlayTag, with: "")
            let isOverlay = name.contains(GameboardSprite.overlayTag)
            let position: K.GameboardPosition = (row: Int(row) ?? -1, col: Int(col) ?? -1)

            //Remove overlay object, if found
            if position == level.player && isOverlay, let child = gameboardSprite.sprite.childNode(withName: row + "," + col + GameboardSprite.overlayTag) {
                child.removeFromParent()
            }
            
            //Update exitClosed panel to exitOpen
            if isExitAvailable && position == level.end && level.getLevelType(at: position) == .endClosed, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                
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
                                health: "\(healthRemaining ?? -99)",
                                inventory: level.inventory)
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
        
        return location.x > GameboardSprite.xPosition + (CGFloat(leftBound) * panelSize) &&
        location.x < GameboardSprite.xPosition + (CGFloat(rightBound) * panelSize) &&
        location.y > GameboardSprite.yPosition + gameboardSize - (CGFloat(bottomBound) * panelSize) &&
        location.y < GameboardSprite.yPosition + gameboardSize - (CGFloat(topBound) * panelSize)
    }
    
    /**
     Helper function that moves the player.
     - parameter direction: The direction the player is moving
     */
    private func movePlayerHelper(direction: Controls) {
        ///Used when moving over certain terrain
        func updateGliding() {
            self.updateMovesRemaining()
            self.shouldUpdateRemainingForBoulderIfIcy = false
            self.isGliding = false
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
        
        guard checkPanelForPathway(position: nextPanel, direction: direction) else {
            AudioManager.shared.stopSound(for: "moveglide", fadeDuration: 0.5)
            return
        }
        
        level.updatePlayer(position: nextPanel)
        
        setPlayerSpritePosition(toLastPanel: level.getLevelType(at: lastPanel), shouldAnimate: true) {
            if self.level.getLevelType(at: lastPanel) == .sand {
                self.level.setLevelType(at: lastPanel, with: (terrain: LevelType.lava, overlay: LevelType.boundary))
                self.gameboardSprite.animateDissolveSand(position: lastPanel)
            }
            
            if self.level.getLevelType(at: nextPanel) == .lava {
                Haptics.shared.executeCustomPattern(pattern: .lava)
                self.playerSprite.startLavaEffectAnimation()
                
                ScoringEngine.updateStatusIconsAnimation(
                    icon: .health,
                    amount: -self.healthRemaining,
                    originSprite: self.gameboardSprite.sprite,
                    location: CGPoint(x: self.playerSprite.sprite.position.x, y: self.playerSprite.sprite.position.y - 20))

                self.healthRemaining = 0
                
                updateGliding()
                
                //EXIT RECURSION
                return
            }
            else if self.level.getLevelType(at: nextPanel) != .ice {
                updateGliding()
                
                //I don't like this being here...
                if self.level.getLevelType(at: nextPanel) == .marsh {
                    self.handleMarsh()
                }

                //EXIT RECURSION
                return
            }
            else {
                self.shouldUpdateRemainingForBoulderIfIcy = true
                self.isGliding = true
            }
            
            //ENTER RECURSION
            self.movePlayerHelper(direction: direction)
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
                
                GameCenterManager.shared.updateProgress(achievement: .klutz, shouldReportImmediately: false)
                
                Haptics.shared.executeCustomPattern(pattern: .boulder)
                shouldDisableControlInput = true
                playerSprite.startKnockbackAnimation(isAttacked: false, direction: direction) {
                    self.shouldDisableControlInput = false
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
//                updateMovesRemaining() //removed here...

                Haptics.shared.executeCustomPattern(pattern: .enemy)
                shouldDisableControlInput = true
                playerSprite.startKnockbackAnimation(isAttacked: true, direction: direction) {
                    self.updateMovesRemaining(enemyAttacked: true) //...added here
                    self.shouldDisableControlInput = false
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
            
            playerSprite.startDeadAnimation {
                self.delegate?.gameIsOver(firstTimeCalled: true)
            }
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
                position: CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: GameboardSprite.yPosition * 3 / 2),
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
                                          animationDuration: 0.0) {
            self.gameboardSprite.sprite.alpha = 1.0
        }
        
        gameboardSprite.colorizeGameboard(color: fadeOut ? .black : GameboardSprite.gameboardColor,
                                          blendFactor: fadeOut ? 1.0 : 0.0,
                                          animationDuration: fadeOut ? 1.0 : 0.5,
                                          completion: completion)
    }
}
