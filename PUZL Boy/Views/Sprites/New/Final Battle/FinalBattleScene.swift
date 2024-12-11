//
//  FinalBattleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/24.
//

import SpriteKit

class FinalBattleScene: SKScene {
    
    // MARK: - Properties
    
    private var hero: Player!
    private var elder0: Player!
    private var elder1: Player!
    private var elder2: Player!
    private var princess: Player!
    private var villain: Player!

    private var gameboardSprite: GameboardSprite!
    private var backgroundSprite: SKSpriteNode!

    
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
        
        AudioManager.shared.stopSound(for: "bossbattle1", fadeDuration: 2)
        AudioManager.shared.stopSound(for: "bossbattle2", fadeDuration: 2)
    }
    
    private func setupScene() {
        backgroundColor = .black

        gameboardSprite = GameboardSprite(level: LevelBuilder.levels[Level.finalLevel + 1], fadeIn: false)
        
        //These should go AFTER initializing gameboardSprite.
        let gameboardSpriteSize: CGSize = gameboardSprite.sprite.size / gameboardSprite.sprite.xScale
        let gameboardSpritePosition: CGPoint = gameboardSprite.sprite.position
        let gameboardSpriteScale: CGFloat = gameboardSprite.sprite.xScale
        let playerScale: CGFloat = Player.getGameboardScale(panelSize: size.width / CGFloat(gameboardSprite.panelCount))

        backgroundSprite = SKSpriteNode(color: .green, size: gameboardSpriteSize)
        backgroundSprite.position = gameboardSpritePosition
        backgroundSprite.setScale(gameboardSpriteScale)
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.alpha = 0.5
        backgroundSprite.zPosition = gameboardSprite.sprite.zPosition + K.ZPosition.overlay + 5
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboardSprite.getLocation(at: (6, 3))
        hero.sprite.setScale(playerScale * hero.scaleMultiplier)
        hero.sprite.zPosition = K.ZPosition.player

        elder0 = Player(type: .elder0)
        elder0.sprite.position = hero.sprite.position + CGPoint(x: -gameboardSprite.panelSize, y: 50)
        elder0.sprite.setScale(playerScale * elder0.scaleMultiplier)
        elder0.sprite.zPosition = K.ZPosition.player - 5

        elder1 = Player(type: .elder1)
        elder1.sprite.position = hero.sprite.position + CGPoint(x: gameboardSprite.panelSize, y: 50)
        elder1.sprite.setScale(playerScale * elder1.scaleMultiplier)
        elder1.sprite.zPosition = K.ZPosition.player - 10

        elder2 = Player(type: .elder2)
        elder2.sprite.position = hero.sprite.position + CGPoint(x: 0, y: -gameboardSprite.panelSize)
        elder2.sprite.setScale(playerScale * elder2.scaleMultiplier)
        elder2.sprite.zPosition = K.ZPosition.player + 5
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(gameboardSprite.sprite)
        addChild(backgroundSprite)
        
        backgroundSprite.addChild(hero.sprite)
        backgroundSprite.addChild(elder0.sprite)
        backgroundSprite.addChild(elder1.sprite)
        backgroundSprite.addChild(elder2.sprite)
    }
    
    
    // MARK: - Other Functions
    
    func animateScene() {
        let bossbattle1Duration = AudioManager.shared.getAudioItem(filename: "bossbattle1")?.player.duration ?? 0
        AudioManager.shared.playSound(for: "bossbattle1")
        AudioManager.shared.playSound(for: "bossbattle2", delay: bossbattle1Duration)
        
        hero.sprite.run(Player.animate(player: hero, type: .idle))
        elder0.sprite.run(Player.animateIdleLevitate(player: elder0))
        elder1.sprite.run(Player.animateIdleLevitate(player: elder1))
        elder2.sprite.run(Player.animateIdleLevitate(player: elder2))
        
//        backgroundSprite.run(SKAction.colorize(with: .clear, colorBlendFactor: 1, duration: 4))
    }
}
