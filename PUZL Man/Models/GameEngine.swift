//
//  GameEngine.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/9/22.
//

import SpriteKit

class GameEngine {
    
    // MARK: - Properties
    
    var movesUsed: Int = 0
    var movesTotal: Int
    var level: Int
    var isGameOver: Bool { movesUsed >= movesTotal }
    
    var gameboardSprite: GameboardSprite
    var controlsSprite: ControlsSprite
    var playerSprite: PlayerSprite
    
    
    // MARK: - Initialization
    
    init(movesTotal: Int, level: Int) {
        self.movesTotal = movesTotal
        self.level = level
        
        let levelBuilder = LevelBuilder.levels[1]
        
        gameboardSprite = GameboardSprite(level: levelBuilder)
        controlsSprite = ControlsSprite()
        playerSprite = PlayerSprite()

    }
    
    
    // MARK: - Helper Functions
    
    func incrementMovesUsed(by amount: Int = 1) {
        guard !isGameOver else { return print("Game Over buddy") }
        
        movesUsed += amount
    }
    
    /**
     Handles player movement based on control input.
     */
    func handleControls(in location: CGPoint) {
        let playerPosition = playerSprite.sprite.position
        let gameboardPosition = gameboardSprite.sprite.position
        let gameboardSize = gameboardSprite.sprite.size
        let gameboardPanel = gameboardSprite.panelSize
        
        guard !isGameOver else { return print("G-A-M-E O-V-E-R: \(movesUsed)/\(movesTotal)") }
        
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
}
