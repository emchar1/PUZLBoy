//
//  GameEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/9/22.
//

import SpriteKit

protocol GameEngineDelegate: AnyObject {
    func gameIsSolved()
    func gameIsOver()
}

/**
 GameEngine cannot be a struct, otherwise you run into "Simultaneous accesses to xxx, but modification requires exclusive access" error due to mutliple instantiations of GameEngine(level:)
 */
class GameEngine {
    
    // MARK: - Properties
    
    private static var livesRemaining: Int = 3
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
    
    private var isExitAvailable: Bool { gemsRemaining == 0 }
    private var isSolved: Bool { isExitAvailable && level.player == level.end }
    private var isGameOver: Bool { movesRemaining <= 0 }
    
    private var gameboardSprite: GameboardSprite
    private var playerSprite: PlayerSprite
    private var displaySprite: DisplaySprite
    
    weak var delegate: GameEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(level: Int = 1) {
        guard LevelBuilder.maxLevel > 0 else {
            fatalError("Firebase records were not loaded!🙀")
        }
        
        self.level = LevelBuilder.levels[level]
        movesRemaining = self.level.moves
        gemsRemaining = self.level.gems
        
        gameboardSprite = GameboardSprite(level: self.level)
        playerSprite = PlayerSprite(position: .zero)
        displaySprite = DisplaySprite(topYPosition: gameboardSprite.yPosition + gameboardSprite.gameboardSize * gameboardSprite.spriteScale,
                                      bottomYPosition: gameboardSprite.yPosition,
                                      margin: 40)
        
        displaySprite.setLabels(level: "\(level)", lives: "\(GameEngine.livesRemaining)", moves: "\(movesRemaining)", inventory: playerSprite.inventory)
        
        setPlayerSpritePosition(shouldAnimate: false, completion: nil)
    }
    
    
    // MARK: - Setup Functions
    
    /**
     Sets the player sprite position easily.
     */
    private func setPlayerSpritePosition(toLastPanel lastPanel: LevelType? = nil, shouldAnimate animate: Bool, completion: (() -> ())?) {
        let playerLastPosition = gameboardSprite.getLocation(at: level.player)
        let panel = lastPanel == nil ? level.getLevelType(at: level.player) : lastPanel!
        let panelIsMarsh = panel == .marsh
        var animationType: PlayerSprite.Texture
        var animationDuration: TimeInterval
        
        if isGliding {
            animationType = .glide
            animationDuration = 0.5
        }
        else if isSolved {
            animationType = .win
            animationDuration = 0.75
        }
        else if panelIsMarsh {
            animationType = .marsh
            animationDuration = 1.0
        }
        else {
            animationType = .run
            animationDuration = 0.5
        }

        if animate {
            let playerMove = SKAction.move(to: playerLastPosition, duration: animationDuration)
                        
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
            consumeItem(isGem: true, shouldChangePanelToIce: false)
            
            K.audioManager.playSound(for: "gemcollect")
            completion?()
        case .gemOnIce:
            gemsRemaining -= 1
            consumeItem(isGem: true, shouldChangePanelToIce: true)

            K.audioManager.playSound(for: "gemcollect")
            completion?()
        case .hammer:
            playerSprite.inventory.hammers += 1
            consumeItem(isGem: false, shouldChangePanelToIce: false)
            
            playerSprite.startPowerUpAnimation()
            completion?()
        case .sword:
            playerSprite.inventory.swords += 1
            consumeItem(isGem: false, shouldChangePanelToIce: false)

            playerSprite.startPowerUpAnimation()
            completion?()
        case .boulder:
            guard playerSprite.inventory.hammers > 0 else { return }
            
            playerSprite.inventory.hammers -= 1
            playerSprite.startHammerAnimation(on: gameboardSprite, at: level.player) {
                self.consumeItem(isGem: false, shouldChangePanelToIce: false)
                completion?()
            }
        case .enemy:
            guard playerSprite.inventory.swords > 0 else { return }
            
            playerSprite.inventory.swords -= 1
            playerSprite.startSwordAnimation(on: gameboardSprite, at: level.player) {
                self.consumeItem(isGem: false, shouldChangePanelToIce: false)
                completion?()
            }
        default:
            completion?()
            break
        }
    }
    
    /**
     Converts a panel to grass, after consuming the item.
     */
    private func consumeItem(isGem: Bool, shouldChangePanelToIce: Bool) {
        level.setLevelType(at: level.player, levelType: shouldChangePanelToIce ? .ice : .grass)

        for child in gameboardSprite.sprite.children {
            //Exclude Player, which will have no name
            guard child.name != nil else { continue }
            
            let row = String(child.name!.prefix(upTo: child.name!.firstIndex(of: ",")!))
            let col = String(child.name!.suffix(from: child.name!.firstIndex(of: ",")!).dropFirst())
            let position: K.GameboardPosition = (row: Int(row) ?? -1, col: Int(col) ?? -1)

            //Update panel to grass
            if position == level.player, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                child.removeFromParent()
                gameboardSprite.updatePanels(at: position, with: shouldChangePanelToIce ? gameboardSprite.ice : gameboardSprite.grass)
            }
            
            //Update exitClosed panel to exitOpen
            if isGem && isExitAvailable && position == level.end, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                child.removeFromParent()
                gameboardSprite.updatePanels(at: position, with: gameboardSprite.endOpen)
                
                K.audioManager.playSound(for: "dooropen")
            }
        }
    }
    
    
    // MARK: - Controls Functions
    
    /**
     Handles player movement based on control input.
     - parameter location: Location for which comparison is to occur.
     */
    func handleControls(in location: CGPoint) {
        guard !isGameOver else { return print("Control attempted during game over animation...") }
        guard !shouldDisableControlInput else { return print("Controls disabled while player is still moving") }

        if inBounds(location: location, direction: .up) {
            movePlayerHelper(direction: .up)

            print("Up pressed")
        }
        else if inBounds(location: location, direction: .down) {
            movePlayerHelper(direction: .down)

            print("Down pressed")
        }
        else if inBounds(location: location, direction: .left) {
            playerSprite.sprite.xScale = -abs(playerSprite.sprite.xScale)
            
            movePlayerHelper(direction: .left)

            print("Left pressed")
        }
        else if inBounds(location: location, direction: .right) {
            playerSprite.sprite.xScale = abs(playerSprite.sprite.xScale)
            
            movePlayerHelper(direction: .right)

            print("Right pressed")
        }
    }
    
    
    // MARK: - Helper Functions
    
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
            K.audioManager.stopSound(for: "boyglide", fadeDuration: 0.5)
            return
        }
        
        level.updatePlayer(position: nextPanel)
        
        setPlayerSpritePosition(toLastPanel: level.getLevelType(at: lastPanel), shouldAnimate: true) {
            if self.level.getLevelType(at: nextPanel) != .ice {
                self.updateMovesRemaining()
                
                self.shouldUpdateRemainingForBoulderIfIcy = false
                self.isGliding = false

                K.audioManager.stopSound(for: "boyglide", fadeDuration: 0.5)
                
                // FIXME: - I don't like this being here...
                if self.level.getLevelType(at: nextPanel) == .marsh {
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
                
                shouldDisableControlInput = true
                playerSprite.startKnockbackAnimation(isAttacked: false, direction: direction) {
                    self.shouldDisableControlInput = false
                    print("A boulder blocks your path... \(self.shouldUpdateRemainingForBoulderIfIcy)")
                }

                return false
            }
        case .enemy:
            if playerSprite.inventory.swords <= 0 {
                updateMovesRemaining()

                shouldDisableControlInput = true
                playerSprite.startKnockbackAnimation(isAttacked: true, direction: direction) {
                    self.shouldDisableControlInput = false
                    print("Enemy attacked!!")
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
            K.audioManager.playSound(for: "wingame")
            delegate?.gameIsSolved()
            
            print("WIN!")
        }
        else if isGameOver {
            K.audioManager.stopSound(for: "overworld")
            K.audioManager.playSound(for: "gameover")

            playerSprite.startDeadAnimation {
                K.audioManager.playSound(for: "overworld")//, currentTime: 2.18)

                self.delegate?.gameIsOver()
            }
            
            GameEngine.livesRemaining -= 1
            
            print("GAME OVER")
        }
    }
        
    
    // MARK: - moveTo Functions
    
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
}
