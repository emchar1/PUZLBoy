//
//  GameScene.swift
//  PUZL Man
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    var gameboardSprite: GameboardSprite
    var controlsSprite: ControlsSprite
    var playerSprite: PlayerSprite
    var gameEngine: GameEngine
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        let levelBuilder = LevelBuilder.levels[1]
        
        gameboardSprite = GameboardSprite(level: levelBuilder)
        controlsSprite = ControlsSprite()
        playerSprite = PlayerSprite()
        gameEngine = GameEngine(movesTotal: levelBuilder.moves, level: levelBuilder.level)

        super.init(size: size)

        scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        let playerPosition = playerSprite.sprite.position
        let gameboardPosition = gameboardSprite.sprite.position
        let gameboardSize = gameboardSprite.sprite.size
        let gameboardPanel = gameboardSprite.panelSize
        
        guard !gameEngine.isGameOver else { return print("again, game over")}
        
        if inBounds(location: location, in: controlsSprite.up, offset: controlsSprite.offsetPosition) {
            guard playerPosition.y + gameboardPanel <= gameboardSize.height else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x, y: playerPosition.y + gameboardPanel)
            gameEngine.incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.down, offset: controlsSprite.offsetPosition) {
            guard playerPosition.y - gameboardPanel >= 0 else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x, y: playerPosition.y - gameboardPanel)
            gameEngine.incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.left, offset: controlsSprite.offsetPosition) {
            guard playerPosition.x - gameboardPanel >= 0 else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x - gameboardPanel, y: playerPosition.y)
            gameEngine.incrementMovesUsed()
        }
        else if inBounds(location: location, in: controlsSprite.right, offset: controlsSprite.offsetPosition) {
            guard playerPosition.x + gameboardPanel <= gameboardSize.width else { return }
            
            playerSprite.sprite.position = CGPoint(x: playerPosition.x + gameboardPanel, y: playerPosition.y)
            gameEngine.incrementMovesUsed()
        }
        
        print("\(playerPosition)")
        print("   \(gameboardPosition)")
        print("   \(gameboardSize)")
    }
    
    private func inBounds(location: CGPoint, in sprite: SKSpriteNode, offset: CGPoint = .zero) -> Bool {
        return location.x > offset.x + sprite.position.x &&
        location.x < offset.x + sprite.position.x + sprite.size.width &&
        location.y > offset.y + sprite.position.y &&
        location.y < offset.y + sprite.position.y + sprite.size.height
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        addChild(gameboardSprite.sprite)
        addChild(controlsSprite.sprite)
        gameboardSprite.sprite.addChild(playerSprite.sprite)
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
}
