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
    
    var levelLabel: SKLabelNode
    var movesRemainingLabel: SKLabelNode
    var gemsRemainingLabel: SKLabelNode
    var exitAvailableLabel: SKLabelNode
    var gameOverLabel: SKLabelNode
    
    weak var delegate: GameEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(level: Int = 1) {
        self.level = LevelBuilder.levels[level]
        self.movesRemaining = self.level.moves
        self.gemsRemaining = self.level.gems
        
        gameboardSprite = GameboardSprite(level: self.level)
        controlsSprite = ControlsSprite()
        playerSprite = PlayerSprite(position: .zero)

        levelLabel = SKLabelNode(text: "LV: \(self.level.level)")
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: K.width / 3, y: 600)
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontSize = 48
        levelLabel.fontColor = .red

        movesRemainingLabel = SKLabelNode(text: "Moves: \(self.movesRemaining)")
        movesRemainingLabel.horizontalAlignmentMode = .left
        movesRemainingLabel.position = CGPoint(x: K.width / 3, y: 540)
        movesRemainingLabel.fontName = "AvenirNext-Bold"
        movesRemainingLabel.fontSize = 48
        movesRemainingLabel.fontColor = .red

        gemsRemainingLabel = SKLabelNode(text: "Gems: \(self.gemsRemaining)")
        gemsRemainingLabel.horizontalAlignmentMode = .left
        gemsRemainingLabel.position = CGPoint(x: K.width / 3, y: 480)
        gemsRemainingLabel.fontName = "AvenirNext-Bold"
        gemsRemainingLabel.fontSize = 48
        gemsRemainingLabel.fontColor = .red

        gemsRemainingLabel = SKLabelNode(text: "Gems: \(self.gemsRemaining)")
        gemsRemainingLabel.horizontalAlignmentMode = .left
        gemsRemainingLabel.position = CGPoint(x: K.width / 3, y: 480)
        gemsRemainingLabel.fontName = "AvenirNext-Bold"
        gemsRemainingLabel.fontSize = 48
        gemsRemainingLabel.fontColor = .red

        exitAvailableLabel = SKLabelNode(text: "Exit Available: \(level == 0 ? "YES" : "NO")")
        exitAvailableLabel.horizontalAlignmentMode = .left
        exitAvailableLabel.position = CGPoint(x: K.width / 3, y: 420)
        exitAvailableLabel.fontName = "AvenirNext-Bold"
        exitAvailableLabel.fontSize = 48
        exitAvailableLabel.fontColor = .red

        gameOverLabel = SKLabelNode(text: "")
        gameOverLabel.horizontalAlignmentMode = .left
        gameOverLabel.position = CGPoint(x: K.width / 3, y: 360)
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red

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

        
        if inBounds(location: location, in: controlsSprite.up, offset: controlsSprite.offsetPosition) {
            guard level.player!.row > 0 else { return }
            
            level.updatePlayer(position: (row: level.player!.row - 1, col: level.player!.col))
            setPlayerSpritePosition()
            incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.down, offset: controlsSprite.offsetPosition) {
            guard level.player!.row < gameboardSprite.panelCount - 1 else { return }
            
            level.updatePlayer(position: (row: level.player!.row + 1, col: level.player!.col))
            setPlayerSpritePosition()
            incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.left, offset: controlsSprite.offsetPosition) {
            guard level.player!.col > 0 else { return }
            
            level.updatePlayer(position: (row: level.player!.row, col: level.player!.col - 1))
            setPlayerSpritePosition()
            incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.right, offset: controlsSprite.offsetPosition) {
            guard level.player!.col < gameboardSprite.panelCount - 1 else { return }
            
            level.updatePlayer(position: (row: level.player!.row, col: level.player!.col + 1))
            setPlayerSpritePosition()
            incrementMovesUsed()
        }
        
        if isSolved {
            delegate?.gameIsSolved()
            print("WINNNNN!")
        }
    }
    
    private func setLabels() {
        levelLabel.text = "LV: \(self.level.level)"
        movesRemainingLabel.text = "Moves: \(self.movesRemaining)"
        gemsRemainingLabel.text = "Gems: \(self.gemsRemaining)"
        exitAvailableLabel.text = "Exit Available: \(isExitAvailable ? "YES" : "NO")"
        gameOverLabel.text = isGameOver ? "OUT OF MOVES" : ""
    }
    
    /**
     Sets the player sprite position easily.
     */
    private func setPlayerSpritePosition() {
        playerSprite.sprite.position = CGPoint(x: CGFloat(level.player!.col) * gameboardSprite.panelSize,
                                               y: CGFloat(gameboardSprite.panelCount - 1 - level.player!.row) * gameboardSprite.panelSize)

        print("Player Position: \(self.level.player!), \(level.getLevelType(at: level.player))")
        
        
        
        
        
        
        
        
        //FIXME: - Remove a Gem once you step on it
        if level.getLevelType(at: level.player) == .gemOn/*, let child = gameboardSprite.sprite.childNode(withName: "gem0")*/ {
            level.setLevelType(at: level.player, levelType: .gemOff)
            gemsRemaining -= 1

            for child in gameboardSprite.sprite.children {
                //Exclude Player, which will have no name
                guard child.name != nil else { continue }
                
                let row = String(child.name!.prefix(upTo: child.name!.firstIndex(of: ",")!))
                let col = String(child.name!.suffix(from: child.name!.firstIndex(of: ",")!).dropFirst())
                let position: K.GameboardPosition = (row: Int(row) ?? -1, col: Int(col) ?? -1)

                //Update gemOn to gemOff
                if position == level.player, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                    child.removeFromParent()
                    gameboardSprite.updatePanels(at: position, with: gameboardSprite.gemOff)
                    print(position)
                }
                
                //Update exitClosed to exitOpen
                if gemsRemaining == 0 && position == level.end, let child = gameboardSprite.sprite.childNode(withName: row + "," + col) {
                    child.removeFromParent()
                    gameboardSprite.updatePanels(at: position, with: gameboardSprite.endOpen)
                }
                
            }
        }
    }
    
    /**
     Increments the moveUsed by the amount listed.
     - parameter amount: The amount to increment by
     */
    private func incrementMovesUsed(by amount: Int = 1) {
        movesRemaining -= amount
        print(movesRemaining)
        setLabels()
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
        
        superScene.addChild(levelLabel)
        superScene.addChild(movesRemainingLabel)
        superScene.addChild(gemsRemainingLabel)
        superScene.addChild(exitAvailableLabel)
        superScene.addChild(gameOverLabel)
        
        gameboardSprite.sprite.addChild(playerSprite.sprite)
    }
}
