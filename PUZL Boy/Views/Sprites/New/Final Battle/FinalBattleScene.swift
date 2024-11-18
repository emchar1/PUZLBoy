//
//  FinalBattleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/18/24.
//

import SpriteKit

class FinalBattleScene: SKScene {
    
    // MARK: - Properties
    
    private var backgroundNode: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FinalBattleScene deinit")
    }
    
    private func setupScene() {
        backgroundNode = SKSpriteNode(color: .magenta, size: size)
        backgroundNode.anchorPoint = .zero
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(backgroundNode)
    }
    
    
}
