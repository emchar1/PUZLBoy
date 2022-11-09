//
//  GameEngine.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/9/22.
//

import SpriteKit

protocol GameEngineDelegate: AnyObject {
    func gameIsSolved()
}

/**
 GameEngine cannot be a struct, otherwise you run into "Simultaneous accesses to xxx, but modification requires exclusive access" error due to mutliple instantiations of GameEngine(level:)
 */
class GameEngine {
    
    // MARK: - Properties
    
    var level: Level
    var movesRemaining: Int
    var gemsRemaining: Int
    
    var playerIsMoving = false
    var playerIsFacingLeft = false
    var playerSwitchOffset: CGFloat = 75
    
    var isExitAvailable: Bool { gemsRemaining == 0 }
    var isSolved: Bool { isExitAvailable && level.player == level.end }
    var isGameOver: Bool { movesRemaining <= 0 }
    
    var gameboardSprite: GameboardSprite
    var playerSprite: PlayerSprite
    var displaySprite: DisplaySprite
    
    weak var delegate: GameEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(level: Int = 1) {
        self.level = LevelBuilder.levels[level]
        self.movesRemaining = self.level.moves
        self.gemsRemaining = self.level.gems
        
        gameboardSprite = GameboardSprite(level: self.level)
        playerSprite = PlayerSprite(position: .zero)
        displaySprite = DisplaySprite()
        
        displaySprite.setLabels(level: "\(self.level.level)",
                                moves: "\(movesRemaining)",
                                gems: "\(gemsRemaining)",
                                inventory: playerSprite.inventory,
                                exit: isExitAvailable ? "YES" : "NO",
                                gameOver: isGameOver ? "LOSE!" : "")
        
        setPlayerSpritePosition(animate: false, completion: nil)
    }
    
    
    // MARK: - Setup Functions
    
    /**
     Sets the player sprite position easily.
     */
    func setPlayerSpritePosition(animate: Bool, completion: (() -> ())?) {
        //Check Gem or Exit
        switch level.getLevelType(at: level.player) {
        case .gem:
            gemsRemaining -= 1
            consumeItem()
        case .hammer:
            consumeItem()
            playerSprite.inventory.hammers += 1
        case .sword:
            consumeItem()
            playerSprite.inventory.swords += 1
        case .boulder:
            guard playerSprite.inventory.hammers > 0 else { return }
            
            consumeItem()
            playerSprite.inventory.hammers -= 1
        case .enemy:
            guard playerSprite.inventory.swords > 0 else { return }
            
            consumeItem()
            playerSprite.inventory.swords -= 1
        default: break
        }
        
        let playerLastPosition = CGPoint(x: gameboardSprite.panelSize * (CGFloat(level.player!.col) + 0.5) + playerSwitchOffset * (playerIsFacingLeft ? -1 : 1),
                                         y: gameboardSprite.panelSize * (CGFloat(gameboardSprite.panelCount - 1 - level.player!.row) + 0.5))

        if animate {
            let playerMove = SKAction.move(to: playerLastPosition, duration: isSolved ? 0.75 : 0.5)
                        
            playerIsMoving = true
            playerSprite.startMoveAnimation(didWin: isSolved)
            playerSprite.sprite.run(playerMove) {
                self.playerIsMoving = false
                self.playerSprite.startIdleAnimation()
                completion?()
            }
        }
        else {
            playerSprite.sprite.position = playerLastPosition
            completion?()
        }
    }
    
    /**
     Converts a panel to grass, after consuming the item.
     */
    private func consumeItem() {
        level.setLevelType(at: level.player, levelType: .grass)

        for child in gameboardSprite.sprite.children {
            //Exclude Player, which will have no name
            guard child.name != nil else { continue }
            
            let row = String(child.name!.prefix(upTo: child.name!.firstIndex(of: ",")!))
            let col = String(child.name!.suffix(from: child.name!.firstIndex(of: ",")!).dropFirst())
            let position: K.GameboardPosition = (row: Int(row) ?? -1, col: Int(col) ?? -1)

            //Update panel to grass
            if position == level.player, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                child.removeFromParent()
                gameboardSprite.updatePanels(at: position, with: gameboardSprite.grass)
            }
            
            //Update exitClosed panel to exitOpen
            if isExitAvailable && position == level.end, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                child.removeFromParent()
                gameboardSprite.updatePanels(at: position, with: gameboardSprite.endOpen)
            }
        }
    }
    
    
    // MARK: - Controls Functions
    
    /**
     Handles player movement based on control input.
     - parameter location: Location for which comparison is to occur.
     */
    func handleControls(in location: CGPoint) {
        guard !isSolved else { return print("You win!") }
        guard !isGameOver else {
            //FIXME: - Animate Game Over..
            
            return print("Game Over!")
        }
        
        if inBounds(location: location, direction: .up) {
            movePlayerHelper(useRow: true, useGreaterThan: true, comparisonValue: 0, increment: -1)

            print("Up pressed")
        }
        else if inBounds(location: location, direction: .down) {
            movePlayerHelper(useRow: true, useGreaterThan: false, comparisonValue: gameboardSprite.panelCount - 1, increment: 1)

            print("Down pressed")
        }
        else if inBounds(location: location, direction: .left) {
            //Need to adjust offset because the OG sprite has a gap on the right
            if !playerIsFacingLeft {
                playerSprite.sprite.position = CGPoint(x: playerSprite.sprite.position.x - playerSwitchOffset, y: playerSprite.sprite.position.y)
            }
            
            playerIsFacingLeft = true
            playerSprite.sprite.xScale = -abs(playerSprite.sprite.xScale)
            
            movePlayerHelper(useRow: false, useGreaterThan: true, comparisonValue: 0, increment: -1)

            print("Left pressed")
        }
        else if inBounds(location: location, direction: .right) {
            if playerIsFacingLeft {
                playerSprite.sprite.position = CGPoint(x: playerSprite.sprite.position.x + playerSwitchOffset, y: playerSprite.sprite.position.y)
            }
            
            playerIsFacingLeft = false
            playerSprite.sprite.xScale = abs(playerSprite.sprite.xScale)
            
            movePlayerHelper(useRow: false, useGreaterThan: false, comparisonValue: gameboardSprite.panelCount - 1, increment: 1)

            print("Right pressed")
        }
        
        if isSolved {
            delegate?.gameIsSolved()
            print("WINNNNN!")
        }
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Helper function that takes a tap location and compares it to the player's next position.
     - parameters:
        - location: Location of the tap
        - controls: The player's next position, either up, down, left, or right
     */
    private func inBounds(location: CGPoint, direction: Controls) -> Bool {
        let maxDistance = gameboardSprite.panelCount
        let panelSize = gameboardSprite.panelSize * gameboardSprite.spriteScale
        
        var upBound = level.player!.row { didSet { if upBound < 0 { upBound = 0 }}}
        var downBound = level.player!.row + 1
        var leftBound = level.player!.col { didSet { if leftBound < 0 { leftBound = 0 }}}
        var rightBound = level.player!.col + 1
        
        switch direction {
        case .up:
            upBound = -maxDistance
            downBound -= 1
        case .down:
            upBound += 1
            downBound = maxDistance
        case .left:
            leftBound = -maxDistance
            rightBound -= 1
        case .right:
            leftBound += 1
            rightBound = maxDistance
        }
        
        return location.x > gameboardSprite.xPosition + (CGFloat(leftBound) * panelSize) &&
        location.x < gameboardSprite.xPosition + (CGFloat(rightBound) * panelSize) &&
        location.y > gameboardSprite.yPosition - (CGFloat(downBound) * panelSize) &&
        location.y < gameboardSprite.yPosition - (CGFloat(upBound) * panelSize)
    }
    
    /**
     Helper function that moves the player.
     - parameters:
        - useRow: determines if player's row or col is used in the guard check
        - useGreaterThan: determines if comparison used should be greater than or less than
        - comparisonValue: value to compare against player row (or col)
        - increment: amount to move the player up or down (if rowCheck) or left or right (if !rowCheck)
     */
    private func movePlayerHelper(useRow: Bool, useGreaterThan: Bool, comparisonValue: Int, increment: Int) {
        let comparator: (Int, Int) -> Bool = useGreaterThan ? (>) : (<)
        var nextPanel: K.GameboardPosition = (row: level.player!.row + (useRow ? increment : 0), col: level.player!.col + (useRow ? 0 : increment))
        
        guard checkPanel(position: nextPanel) else { return }
        guard comparator(useRow ? level.player!.row : level.player!.col, comparisonValue) else { return }
        
        repeat {
            //I hate how this needs to be called twice, but here we are...
            nextPanel = (row: level.player!.row + (useRow ? increment : 0), col: level.player!.col + (useRow ? 0 : increment))
            
            guard checkPanel(position: nextPanel) else { break }
            guard comparator(useRow ? level.player!.row : level.player!.col, comparisonValue) else { break }
            
            level.updatePlayer(position: nextPanel)
            setPlayerSpritePosition(animate: true, completion: nil)
        } while level.getLevelType(at: level.player) == .ice
        
        updateMovesRemaining()
    }
    
    /**
     Runs a switch on the panel the player is on.
     - parameter position: the row, column that the player is on.
     - returns: true if the panel is an enemy, i.e. handle differently
     */
    private func checkPanel(position: K.GameboardPosition) -> Bool {
        switch level.getLevelType(at: position) {
        case .boulder:
            if playerSprite.inventory.hammers <= 0 {
                print("A boulder blocks your path...")
                return false
            }
        case .enemy:
            if playerSprite.inventory.swords <= 0 {
                updateMovesRemaining()
                print("Enemy attacks you!")
                return false
            }
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
        displaySprite.setLabels(level: "\(level.level)",
                                moves: "\(movesRemaining)",
                                gems: "\(gemsRemaining)",
                                inventory: playerSprite.inventory,
                                exit: isExitAvailable ? "YES" : "NO",
                                gameOver: isGameOver ? "LOSE!" : "")
    }
    
    private func animateGameOver() {
        
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
