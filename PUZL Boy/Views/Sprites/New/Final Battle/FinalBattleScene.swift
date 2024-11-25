//
//  FinalBattleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/24.
//

import SpriteKit

class FinalBattleScene: SKScene {
    
    // MARK: - Properties
    
    private var gameboardSprite: GameboardSprite!
    private var hero: Player!
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FinalBattleSceen deinit")
    }
    
    private func setupScene() {
        backgroundColor = .black
        
        gameboardSprite = GameboardSprite(level: LevelBuilder.levels[Level.finalLevel + 1], fadeIn: true)
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboardSprite.getLocation(at: (0, 4))
        hero.sprite.setScale(Player.getGameboardScale(panelSize: size.width / 7) * hero.scaleMultiplier)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(gameboardSprite.sprite)
    }
    
    
}
