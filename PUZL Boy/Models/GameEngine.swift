//
//  GameEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/9/22.
//

import SpriteKit

protocol GameEngineDelegate: AnyObject {
    func gameIsSolved(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool)
    func gameIsOver()
}

/**
 GameEngine cannot be a struct, otherwise you run into "Simultaneous accesses to xxx, but modification requires exclusive access" error due to mutliple instantiations of GameEngine(level:)
 */
class GameEngine {
    
    // MARK: - Properties
    
    private static var livesRemaining: Int = 3
    private static var usedContinue: Bool = false
    private var level: Level
    private var gemsRemaining: Int
    private var movesRemaining: Int {
        didSet {
            if movesRemaining < 0 {
                movesRemaining = 0
            }
        }
    }
    
    // FIXME: - These properties seem to make the code messy...
    private var shouldDisableControlInput = false
    private var shouldUpdateRemainingForBoulderIfIcy = false
    private var isGliding = false
    private var enemiesKilled: Int = 0
    
    private var isExitAvailable: Bool { gemsRemaining == 0 }
    private var isSolved: Bool { isExitAvailable && level.player == level.end }
    private var isGameOver: Bool { movesRemaining <= 0 }
    var canContinue: Bool { return GameEngine.livesRemaining >= 0 }
    
    private var gameboardSprite: GameboardSprite
    private var playerSprite: PlayerSprite
    private var displaySprite: DisplaySprite
    
    weak var delegate: GameEngineDelegate?
    
    
    // MARK: - Initialization
    
    /**
     Initializes a Game Engine with the given level and animation sequence.
     - parameters:
        - level: The initial level to load
        - shouldSpawn: determines whether should fade gameboard, i.e. if shouldSpawn is false
     */
    init(level: Int = 1, shouldSpawn: Bool) {
        guard LevelBuilder.maxLevel > 0 else {
            fatalError("Firebase records were not loaded!🙀")
        }
        
        self.level = LevelBuilder.levels[level]
        movesRemaining = self.level.moves
        gemsRemaining = self.level.gems

        gameboardSprite = GameboardSprite(level: self.level)
        K.ScreenDimensions.topOfGameboard = gameboardSprite.yPosition + gameboardSprite.gameboardSize * gameboardSprite.spriteScale
        playerSprite = PlayerSprite(shouldSpawn: true)
        displaySprite = DisplaySprite(topYPosition: K.ScreenDimensions.topOfGameboard, bottomYPosition: gameboardSprite.yPosition, margin: 40)
        displaySprite.setLabels(level: "\(level)", lives: "\(GameEngine.livesRemaining)", moves: "\(movesRemaining)", inventory: playerSprite.inventory)
        
        setPlayerSpritePosition(shouldAnimate: false, completion: nil)
        
        if !shouldSpawn {
            fadeGameboard(fadeOut: false, completion: nil)
        }
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
        let panelIsMarsh = panel == .marsh
        var animationType: PlayerSprite.Texture
        
        if isGliding {
            animationType = .glide
        }
        else if isSolved {
            animationType = .win
        }
        else if panelIsMarsh {
            animationType = .marsh
        }
        else {
            animationType = .run
        }

        if animate {
            let playerMove = SKAction.move(to: playerLastPosition, duration: animationType.animationSpeed)
                        
            shouldDisableControlInput = true

            playerSprite.startMoveAnimation(animationType: animationType)
            
            playerSprite.sprite.run(playerMove) {
                self.playerSprite.startIdleAnimation()
                self.checkSpecialPanel {
                    self.shouldDisableControlInput = false
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
    // FIXME: - Not sure if adding a completion here was the best idea??
    private func checkSpecialPanel(completion: (() -> ())?) {
        switch level.getLevelType(at: level.player) {
        case .gem:
            gemsRemaining -= 1
            consumeItem()
            
            AudioManager.shared.playSound(for: "gemcollect")
            completion?()
        case .hammer:
            displaySprite.statusHammers.pulseImage()
            playerSprite.inventory.hammers += 1
            consumeItem()
            
            playerSprite.startPowerUpAnimation()
            completion?()
        case .sword:
            displaySprite.statusSwords.pulseImage()
            playerSprite.inventory.swords += 1
            consumeItem()

            playerSprite.startPowerUpAnimation()
            completion?()
        case .boulder:
            guard playerSprite.inventory.hammers > 0 else { return }
            
            Haptics.shared.executeCustomPattern(pattern: .breakBoulder)
            playerSprite.inventory.hammers -= 1
            playerSprite.startHammerAnimation(on: gameboardSprite, at: level.player) {
                self.consumeItem()
                completion?()
            }
        case .enemy:
            guard playerSprite.inventory.swords > 0 else { return }
            
            Haptics.shared.executeCustomPattern(pattern: .killEnemy)
            enemiesKilled += 1
            playerSprite.inventory.swords -= 1
            playerSprite.startSwordAnimation(on: gameboardSprite, at: level.player) {
                self.consumeItem()
                completion?()
            }
        case .warp:
            guard let newWarpLocation = gameboardSprite.warpTo(from: level.player) else {
                completion?()
                return
            }
            
            AudioManager.shared.playSound(for: "warp")
            
            playerSprite.startWarpAnimation(shouldReverse: false) {
                self.level.updatePlayer(position: newWarpLocation)
                self.playerSprite.sprite.position = self.gameboardSprite.getLocation(at: newWarpLocation)
                self.playerSprite.startWarpAnimation(shouldReverse: true) {
                    completion?()
                }
                
            }
        default:
            completion?()
            break
        }
    }
    
    /**
     Converts a panel to grass, after consuming the item.
     */
    private func consumeItem() {
        level.removeOverlayObject(at: level.player)

        for child in gameboardSprite.sprite.children {
            //Exclude Player, which will have no name
            guard let name = child.name else { continue }
            
            let row = String(name.prefix(upTo: name.firstIndex(of: ",")!))
            let col = String(name.suffix(from: name.firstIndex(of: ",")!).dropFirst()).replacingOccurrences(of: gameboardSprite.overlayTag, with: "")
            let isOverlay = name.contains(gameboardSprite.overlayTag)
            let position: K.GameboardPosition = (row: Int(row) ?? -1, col: Int(col) ?? -1)

            //Remove overlay object, if found
            if position == level.player && isOverlay, let child = gameboardSprite.sprite.childNode(withName: row + "," + col + gameboardSprite.overlayTag) {
                child.removeFromParent()
            }
            
            //Update exitClosed panel to exitOpen
            if isExitAvailable && position == level.end && level.getLevelType(at: position) == .endClosed, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                
                let endOpen: K.GameboardPanel = (terrain: LevelType.endOpen, overlay: LevelType.boundary)
                
                child.removeFromParent()
                gameboardSprite.updatePanels(at: position, with: endOpen)
                level.setLevelType(at: position, with: endOpen)
                                
                AudioManager.shared.playSound(for: "dooropen")
            }
        }
    }
    
    
    // MARK: - Controls Functions
    
    /**
     Handles player movement based on control input.
     - parameter location: Location for which comparison is to occur.
     */
    func handleControls(in location: CGPoint) {
        guard !isGameOver else { return }
        guard !shouldDisableControlInput else { return }

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
    
    
    // MARK: - Controls Helper Functions
    
    /**
     Takes a tap location and compares it to the player's next position.
     - parameters:
        - location: Location of the tap
        - controls: The player's next position, either up, down, left, or right
     */
    private func inBounds(location: CGPoint, direction: Controls) -> Bool {
        let maxDistance = gameboardSprite.panelCount
        let panelSize = gameboardSprite.panelSize * gameboardSprite.spriteScale
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
        
        return location.x > gameboardSprite.xPosition + (CGFloat(leftBound) * panelSize) &&
        location.x < gameboardSprite.xPosition + (CGFloat(rightBound) * panelSize) &&
        location.y > gameboardSprite.yPosition + gameboardSize - (CGFloat(bottomBound) * panelSize) &&
        location.y < gameboardSprite.yPosition + gameboardSize - (CGFloat(topBound) * panelSize)
    }
    
    /**
     Helper function that moves the player.
     - parameter direction: The direction the player is moving
     */
    private func movePlayerHelper(direction: Controls) {
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
            if self.level.getLevelType(at: nextPanel) != .ice {
                self.updateMovesRemaining()
                
                self.shouldUpdateRemainingForBoulderIfIcy = false
                self.isGliding = false

                AudioManager.shared.stopSound(for: "moveglide", fadeDuration: 0.5)
                
                // FIXME: - I don't like this being here...
                if self.level.getLevelType(at: nextPanel) == .marsh {
                    Haptics.shared.executeCustomPattern(pattern: .marsh)
                    self.playerSprite.startMarshEffectAnimation()
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
            if playerSprite.inventory.hammers <= 0 {
                if shouldUpdateRemainingForBoulderIfIcy {
                    updateMovesRemaining()
                    shouldUpdateRemainingForBoulderIfIcy = false
                }
                
                Haptics.shared.executeCustomPattern(pattern: .boulder)
                shouldDisableControlInput = true
                playerSprite.startKnockbackAnimation(isAttacked: false, direction: direction) {
                    self.shouldDisableControlInput = false
                }

                return false
            }
        case .enemy:
            if playerSprite.inventory.swords <= 0 {
                // FIXME: - This is ugly!!! All to make sliding from ice to enemy hit twice!
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
                    self.updateMovesRemaining() //...added here
                    self.shouldDisableControlInput = false
                }
                                
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
    private func updateMovesRemaining() {
        movesRemaining -= level.getLevelType(at: level.player) == .marsh ? 2 : 1
        displaySprite.setLabels(level: "\(level.level)", lives: "\(GameEngine.livesRemaining)", moves: "\(movesRemaining)", inventory: playerSprite.inventory)
        
        if isSolved {
            AudioManager.shared.playSound(for: "winlevel")
            delegate?.gameIsSolved(movesRemaining: movesRemaining, itemsFound: playerSprite.inventory.getItemCount(), enemiesKilled: enemiesKilled, usedContinue: GameEngine.usedContinue)
            
            GameEngine.usedContinue = false
        }
        else if isGameOver {
            AudioManager.shared.stopSound(for: K.Audio.overworldTheme)
            AudioManager.shared.playSound(for: "gameover")

            displaySprite.drainLives()
            GameEngine.livesRemaining -= 1
            GameEngine.usedContinue = true

            playerSprite.startDeadAnimation {
                self.delegate?.gameIsOver()
            }
        }
    }
        
    
    // MARK: - Other Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(gameboardSprite.sprite)
        superScene.addChild(displaySprite.sprite)
        
        playerSprite.setScale(panelSize: gameboardSprite.panelSize)
        gameboardSprite.sprite.addChild(playerSprite.sprite)
    }
    
    /**
     Fades the gameboard by calling colorizeGameboard in GameboardSprite, by applying a clear color and using 0 to 1 blendFactor.
     - parameters:
        - fadeOut: true if you want to fade to empty, false if fade from empty
        - completion: completion handler called at the end of the animation
     */
    func fadeGameboard(fadeOut: Bool, completion: (() -> ())?) {
        gameboardSprite.sprite.alpha = fadeOut ? 1.0 : 0.0
        gameboardSprite.colorizeGameboard(color: .clear, blendFactor: fadeOut ? 0.0 : 1.0, animationDuration: 0.0) {
            self.gameboardSprite.sprite.alpha = 1.0
        }
        
        gameboardSprite.colorizeGameboard(color: .clear, blendFactor: fadeOut ? 1.0 : 0.0, animationDuration: 0.5, completion: completion)
    }
}
