//
//  GameScene.swift
//  PUZL Man
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    var gameEngine: GameEngine
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        gameEngine = GameEngine(level: 2)

        super.init(size: size)

        scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if gameEngine.isSolved {
            
            gameEngine = GameEngine(level: 3)
            removeAllChildren()
            gameEngine.moveSprites(to: self)
            
        }
        else {
            gameEngine.handleControls(in: location)
        }
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        gameEngine.moveSprites(to: self)
        print("Called only once, at view load.")
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
}
