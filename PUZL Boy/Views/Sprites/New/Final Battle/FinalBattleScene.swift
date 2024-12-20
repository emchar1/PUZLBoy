//
//  FinalBattleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/24.
//

import SpriteKit

class FinalBattleScene: SKScene {
    
    // MARK: - Properties
    
    private var backgroundSprite: SKSpriteNode!
    private var finalBattle2Engine: FinalBattle2Engine!
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
        AudioManager.shared.stopSound(for: "bossbattle3", fadeDuration: 2)
    }
    
    private func setupScene() {
        backgroundColor = .black

        finalBattle2Engine = FinalBattle2Engine()
        
        //These should go AFTER initializing gameboardSprite.
        let gameboardSpriteSize: CGSize = finalBattle2Engine.gameEngine.gameboardSprite.sprite.size / finalBattle2Engine.gameEngine.gameboardSprite.sprite.xScale
        let gameboardSpritePosition: CGPoint = finalBattle2Engine.gameEngine.gameboardSprite.sprite.position
        let gameboardSpriteScale: CGFloat = finalBattle2Engine.gameEngine.gameboardSprite.sprite.xScale
        let playerScale: CGFloat = Player.getGameboardScale(panelSize: size.width / CGFloat(finalBattle2Engine.gameEngine.gameboardSprite.panelCount))

        backgroundSprite = SKSpriteNode(color: .clear, size: gameboardSpriteSize)
        backgroundSprite.position = gameboardSpritePosition
        backgroundSprite.setScale(gameboardSpriteScale)
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.alpha = 1
        backgroundSprite.zPosition = finalBattle2Engine.gameEngine.gameboardSprite.sprite.zPosition + K.ZPosition.overlay + 5
        
        villain = Player(type: .villain)
        villain.sprite.position = finalBattle2Engine.gameEngine.gameboardSprite.getLocation(at: (3, 3)) + CGPoint(x: 0, y: 50)
        villain.sprite.setScale(playerScale * villain.scaleMultiplier)
        villain.sprite.zPosition = K.ZPosition.player
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(backgroundSprite)
        finalBattle2Engine.moveSprites(to: self)
        
        backgroundSprite.addChild(villain.sprite)
    }
    
    
    // MARK: - Other Functions
    
    func animateScene() {
//        let bossbattle1Duration = AudioManager.shared.getAudioItem(filename: "bossbattle1")?.player.duration ?? 0
//        AudioManager.shared.playSound(for: "bossbattle1")
//        AudioManager.shared.playSound(for: "bossbattle2", delay: bossbattle1Duration)
        AudioManager.shared.playSound(for: "bossbattle3")
        
        villain.sprite.run(Player.animateIdleLevitate(player: villain))
    }
}
