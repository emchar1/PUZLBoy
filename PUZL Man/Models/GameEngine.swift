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
    
    var isExitAvailable: Bool { gemsRemaining == 0 }
    var isSolved: Bool { isExitAvailable && level.player == level.end }
    var isGameOver: Bool { movesRemaining <= 0 }
    
    var gameboardSprite: GameboardSprite
    var controlsSprite: ControlsSprite
    var playerSprite: PlayerSprite
    var displaySprite: DisplaySprite
    
    weak var delegate: GameEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(level: Int = 1) {
        self.level = LevelBuilder.levels[level]
        self.movesRemaining = self.level.moves
        self.gemsRemaining = self.level.gems
        
        gameboardSprite = GameboardSprite(level: self.level)
        controlsSprite = ControlsSprite()
        playerSprite = PlayerSprite(position: .zero)
        displaySprite = DisplaySprite()
        displaySprite.setLabels(level: "\(self.level.level)",
                                moves: "\(movesRemaining)",
                                gems: "\(gemsRemaining)",
                                exit: isExitAvailable ? "YES" : "NO",
                                gameOver: isGameOver ? "OUT OF MOVES" : "")
        
        setPlayerSpritePosition()
    }
    
    
    // MARK: - Control Functions
    
    /**
     Handles player movement based on control input.
     - parameter location: Location for which comparison is to occur.
     */
    func handleControls(in location: CGPoint) {
        guard !isSolved else { return print("You win!") }
        guard !isGameOver else { return print("Game Over!") }
        
        // FIXME: - Can these be expressed in more succinct terms, like if .upPressed, else if .downPressed, etc.?
        if inBounds(location: location, in: controlsSprite.up, offset: controlsSprite.offsetPosition) {
            movePlayerHelper(useRow: true, useGreaterThan: true, comparisonValue: 0, increment: -1)
        }
        else if inBounds(location: location, in: controlsSprite.down, offset: controlsSprite.offsetPosition) {
            movePlayerHelper(useRow: true, useGreaterThan: false, comparisonValue: gameboardSprite.panelCount - 1, increment: 1)
        }
        else if inBounds(location: location, in: controlsSprite.left, offset: controlsSprite.offsetPosition) {
            movePlayerHelper(useRow: false, useGreaterThan: true, comparisonValue: 0, increment: -1)
        }
        else if inBounds(location: location, in: controlsSprite.right, offset: controlsSprite.offsetPosition) {
            movePlayerHelper(useRow: false, useGreaterThan: false, comparisonValue: gameboardSprite.panelCount - 1, increment: 1)
        }
        
        if isSolved {
            delegate?.gameIsSolved()
            print("WINNNNN!")
        }
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
        
        guard level.getLevelType(at: nextPanel) != .boulder else { return print("A boulder blocks your path...") }
        guard comparator(useRow ? level.player!.row : level.player!.col, comparisonValue) else { return }
        
        repeat {
            //I hate how this needs to be called twice, but here we are...
            nextPanel = (row: level.player!.row + (useRow ? increment : 0), col: level.player!.col + (useRow ? 0 : increment))
            guard level.getLevelType(at: nextPanel) != .boulder else { print("A boulder blocks your path......"); break }
            guard comparator(useRow ? level.player!.row : level.player!.col, comparisonValue) else { break }
            
            level.updatePlayer(position: nextPanel)
            setPlayerSpritePosition()
        } while level.getLevelType(at: level.player) == .ice
        

        //Increment moves used
        movesRemaining -= level.getLevelType(at: level.player) == .marsh ? 2 : 1
        displaySprite.setLabels(level: "\(level.level)",
                                moves: "\(movesRemaining)",
                                gems: "\(gemsRemaining)",
                                exit: isExitAvailable ? "YES" : "NO",
                                gameOver: isGameOver ? "OUT OF MOVES" : "")
    }
    
    /**
     Sets the player sprite position easily.
     */
    private func setPlayerSpritePosition() {
        playerSprite.sprite.position = CGPoint(x: gameboardSprite.panelSize * (CGFloat(level.player!.col) + 0.5),
                                               y: gameboardSprite.panelSize * (CGFloat(gameboardSprite.panelCount - 1 - level.player!.row) + 0.5))

//        print("Player Position: \(self.level.player!), \(level.getLevelType(at: level.player))")

        
        //Check Gem or Exit
        if level.getLevelType(at: level.player) == .gemOn/*, let child = gameboardSprite.sprite.childNode(withName: "gem0")*/ {
            level.setLevelType(at: level.player, levelType: .gemOff)
            gemsRemaining -= 1

            for child in gameboardSprite.sprite.children {
                //Exclude Player, which will have no name
                guard child.name != nil else { continue }
                
                let row = String(child.name!.prefix(upTo: child.name!.firstIndex(of: ",")!))
                let col = String(child.name!.suffix(from: child.name!.firstIndex(of: ",")!).dropFirst())
                let position: K.GameboardPosition = (row: Int(row) ?? -1, col: Int(col) ?? -1)

                //Update gemOn panel to gemOff
                if position == level.player, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                    child.removeFromParent()
                    gameboardSprite.updatePanels(at: position, with: gameboardSprite.gemOff)
                }
                
                //Update exitClosed panel to exitOpen
                if isExitAvailable && position == level.end, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                    child.removeFromParent()
                    gameboardSprite.updatePanels(at: position, with: gameboardSprite.endOpen)
                }
            }
        }//end if        
    }
    
    /**
     Helper function that takes the tap location within a SpriteNode and returns true if the tap is within the sprite bounds.
     - parameters:
        - location: Location of the tap
        - sprite: SpriteNode in question for where bounds checking will occur
        - offset: Offset position of the SpriteNode, if any
     */
    private func inBounds(location: CGPoint, in sprite: SKSpriteNode, offset: CGPoint = .zero) -> Bool {
        return location.x > offset.x + sprite.position.x &&
        location.x < offset.x + sprite.position.x + sprite.size.width &&
        location.y > offset.y + sprite.position.y &&
        location.y < offset.y + sprite.position.y + sprite.size.height
    }
    
    
    // MARK: - moveTo Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(gameboardSprite.sprite)
        superScene.addChild(controlsSprite.sprite)
        superScene.addChild(displaySprite.sprite)
        
        gameboardSprite.sprite.addChild(playerSprite.sprite)
    }
}
