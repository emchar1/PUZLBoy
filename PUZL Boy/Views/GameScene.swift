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
    private var audioManager: AudioManager

    private var currentLevel: Int = 9 {
        didSet {
            if currentLevel > LevelBuilder.maxLevel {
                currentLevel = 0
            }
        }
    }
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        gameEngine = GameEngine(level: currentLevel)
        audioManager = AudioManager()
        audioManager.playSound(for: "overworld")

        super.init(size: size)

        gameEngine.delegate = self
        scaleMode = .aspectFill
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
    
    private func resetGameEngine(level: Int) {
        removeAllChildren()
        gameEngine = GameEngine(level: level)
        gameEngine.delegate = self
        gameEngine.moveSprites(to: self)
    }
    
}


// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func gameIsSolved() {
        currentLevel += 1
        resetGameEngine(level: currentLevel)
    }
    
    func gameIsOver() {
        resetGameEngine(level: currentLevel)
        audioManager.stopSound(for: "overworld")
        audioManager.playSound(for: "gameover")
    }
}
