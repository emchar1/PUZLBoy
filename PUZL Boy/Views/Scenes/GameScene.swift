//
//  GameScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    private var gameEngine: GameEngine

    private var currentLevel: Int = 6 {
        didSet {
            if currentLevel > LevelBuilder.maxLevel {
                currentLevel = 0
            }
        }
    }
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)

        super.init(size: size)

        gameEngine.delegate = self
        scaleMode = .aspectFill

        K.audioManager.playSound(for: K.overworldTheme)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        gameEngine.handleControls(in: location)
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        gameEngine.moveSprites(to: self)
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    // MARK: - Helper Functions
    
    private func resetGameEngine(level: Int, fromGameOver: Bool) {
        removeAllChildren()
        gameEngine = GameEngine(level: level, shouldSpawn: fromGameOver)
        gameEngine.delegate = self
        gameEngine.moveSprites(to: self)
    }
    
}


// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func gameIsSolved() {
        currentLevel += 1

        gameEngine.fadeGameboard(fadeOut: true) {
            self.resetGameEngine(level: self.currentLevel, fromGameOver: false)
        }
    }
    
    func gameIsOver() {
        resetGameEngine(level: currentLevel, fromGameOver: true)
    }
}
