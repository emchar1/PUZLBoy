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
    private var elder0: Player!
    private var elder1: Player!
    private var elder2: Player!
    private var princess: Player!
    private var villain: Player!

    
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
        //Only need to call colorizeGameboard() IF fadeIn: true in gameboardSprite.init().
//        gameboardSprite.colorizeGameboard(fadeOut: false, isInbetween: false, completion: nil)
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboardSprite.getLocation(at: (6, 3))
        hero.sprite.setScale(Player.getGameboardScale(panelSize: size.width / CGFloat(gameboardSprite.panelCount)) * hero.scaleMultiplier)
        hero.sprite.zPosition = K.ZPosition.player
        
        elder0 = Player(type: .elder0)
        elder0.sprite.position = hero.sprite.position + CGPoint(x: -gameboardSprite.panelSize, y: 50)
        elder0.sprite.setScale(Player.getGameboardScale(panelSize: size.width / CGFloat(gameboardSprite.panelCount)) * elder0.scaleMultiplier)
        elder0.sprite.zPosition = hero.sprite.zPosition - 5
        elder0.sprite.run(Player.animateIdleLevitate(player: elder0))

        elder1 = Player(type: .elder1)
        elder1.sprite.position = hero.sprite.position + CGPoint(x: gameboardSprite.panelSize, y: 50)
        elder1.sprite.setScale(Player.getGameboardScale(panelSize: size.width / CGFloat(gameboardSprite.panelCount)) * elder1.scaleMultiplier)
        elder1.sprite.zPosition = hero.sprite.zPosition - 10
        elder1.sprite.run(Player.animateIdleLevitate(player: elder1))

        elder2 = Player(type: .elder2)
        elder2.sprite.position = hero.sprite.position + CGPoint(x: 0, y: -gameboardSprite.panelSize)
        elder2.sprite.setScale(Player.getGameboardScale(panelSize: size.width / CGFloat(gameboardSprite.panelCount)) * elder2.scaleMultiplier)
        elder2.sprite.zPosition = hero.sprite.zPosition + 5
        elder2.sprite.run(Player.animateIdleLevitate(player: elder2))

        let bossbattle1Duration = AudioManager.shared.getAudioItem(filename: "bossbattle1")?.player.duration ?? 0
        AudioManager.shared.playSound(for: "bossbattle1")
        AudioManager.shared.playSound(for: "bossbattle2", delay: bossbattle1Duration)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(gameboardSprite.sprite)
        gameboardSprite.sprite.addChild(hero.sprite)
        gameboardSprite.sprite.addChild(elder0.sprite)
        gameboardSprite.sprite.addChild(elder1.sprite)
        gameboardSprite.sprite.addChild(elder2.sprite)
    }
    
    
}
