//
//  GameEngine.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/9/22.
//

import SpriteKit

class GameEngine {
    
    // MARK: - Properties
    
    var level: Level
    var movesUsed: Int = 0
    var isGameOver: Bool { movesUsed >= level.moves }
    
    var gameboardSprite: GameboardSprite
    var controlsSprite: ControlsSprite
    var playerSprite: PlayerSprite
    
    
    // MARK: - Initialization
    
    init(level: Int = 1) {
        self.level = LevelBuilder.levels[level]
        
        gameboardSprite = GameboardSprite(level: self.level)
        controlsSprite = ControlsSprite()
        playerSprite = PlayerSprite()
    }
    
    
    // MARK: - Control Functions
    
    /**
     Handles player movement based on control input.
     - parameter location: Location for which comparison is to occur.
     */
    func handleControls(in location: CGPoint) {
        guard !isGameOver else { return print("Game Over: \(movesUsed)/\(level.moves)") }


        let playerPosition = playerSprite.sprite.position
        let gameboardPosition = gameboardSprite.sprite.position
        let gameboardSize = gameboardSprite.sprite.size
        let gameboardPanel = gameboardSprite.panelSize
        
        if inBounds(location: location, in: controlsSprite.up, offset: controlsSprite.offsetPosition) {
            guard playerPosition.y + gameboardPanel <= gameboardSize.height else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x, y: playerPosition.y + gameboardPanel)
            incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.down, offset: controlsSprite.offsetPosition) {
            guard playerPosition.y - gameboardPanel >= 0 else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x, y: playerPosition.y - gameboardPanel)
            incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.left, offset: controlsSprite.offsetPosition) {
            guard playerPosition.x - gameboardPanel >= 0 else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x - gameboardPanel, y: playerPosition.y)
            incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.right, offset: controlsSprite.offsetPosition) {
            guard playerPosition.x + gameboardPanel <= gameboardSize.width else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x + gameboardPanel, y: playerPosition.y)
            incrementMovesUsed()
        }
        
        print("\(playerPosition)")
        print("   \(gameboardPosition)")
        print("   \(gameboardSize)")
    }
    
    /**
     Increments the moveUsed by the amount listed.
     - parameter amount: The amount to increment by
     */
    private func incrementMovesUsed(by amount: Int = 1) {
        guard !isGameOver else { return print("Game Over - shouldn't be called") }
        
        movesUsed += amount
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
        
        gameboardSprite.sprite.addChild(playerSprite.sprite)
    }
}
