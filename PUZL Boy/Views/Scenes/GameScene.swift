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
    private var scoringEngine: ScoringEngine

    private var currentLevel: Int = 1 {
        didSet {
            if currentLevel > LevelBuilder.maxLevel {
                currentLevel = 0
            }
        }
    }
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        gameEngine = GameEngine(level: currentLevel, shouldSpawn: true)
        scoringEngine = ScoringEngine()

        super.init(size: size)

        gameEngine.delegate = self
        scaleMode = .aspectFill

        K.Audio.audioManager.playSound(for: K.Audio.overworldTheme)
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
        scoringEngine.moveSprites(to: self)
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    // MARK: - Helper Functions
    
    private func newGame(level: Int, didWin: Bool) {
        removeAllChildren()
        gameEngine = GameEngine(level: level, shouldSpawn: !didWin)
        gameEngine.delegate = self
        gameEngine.moveSprites(to: self)
        scoringEngine.moveSprites(to: self)
        
        // FIXME: - Score should animate before resetting...
        //scoringEngine.resetScore()
    }
    
}


// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func gameIsSolved(movesRemaining: Int, itemsFound: Int, enemiesKilled: Int, usedContinue: Bool) {
        currentLevel += 1

        gameEngine.fadeGameboard(fadeOut: true) {
            self.scoringEngine.updateScore(movesRemaining: movesRemaining, itemsFound: itemsFound, enemiesKilled: enemiesKilled, usedContinue: usedContinue)
            self.scoringEngine.resetTime()

            self.newGame(level: self.currentLevel, didWin: true)
        }
    }
    
    func gameIsOver() {
//        guard gameEngine.canContinue else {
//            let continueScene = ContinueScene(size: K.ScreenDimensions.screenSize)
//            removeAllChildren()
            
//            return
//        }
        scoringEngine.resetScore()
        
        newGame(level: currentLevel, didWin: false)
    }
}
