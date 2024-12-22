//
//  FinalBattleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/24.
//

import SpriteKit

class FinalBattleScene: SKScene {
    
    // MARK: - Properties
    
    private var finalBattle2Engine: FinalBattle2Engine!
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
        
//        AudioManager.shared.stopSound(for: "bossbattle1", fadeDuration: 2)
//        AudioManager.shared.stopSound(for: "bossbattle2", fadeDuration: 2)
        AudioManager.shared.stopSound(for: "bossbattle3", fadeDuration: 2)
    }
    
    private func setupScene() {
        backgroundColor = .black
        
        finalBattle2Engine = FinalBattle2Engine(size: self.size)
        
        backgroundSprite = SKSpriteNode(color: .clear, size: finalBattle2Engine.gameboard.sprite.size / finalBattle2Engine.gameboard.sprite.xScale)
        backgroundSprite.position = finalBattle2Engine.gameboard.sprite.position
        backgroundSprite.setScale(finalBattle2Engine.gameboard.sprite.xScale)
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.alpha = 1
        backgroundSprite.zPosition = finalBattle2Engine.gameboard.sprite.zPosition + K.ZPosition.overlay + 5
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(backgroundSprite)
        finalBattle2Engine.moveSprites(to: self)
    }
    
    
    // MARK: - Touch Functions
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        finalBattle2Engine.handleControls(in: location)
    }
    
    
    // MARK: - Functions
    
    func animateScene() {
//        let bossbattle1Duration = AudioManager.shared.getAudioItem(filename: "bossbattle1")?.player.duration ?? 0
//        AudioManager.shared.playSound(for: "bossbattle1")
//        AudioManager.shared.playSound(for: "bossbattle2", delay: bossbattle1Duration)
        AudioManager.shared.playSound(for: "bossbattle3")
        
        finalBattle2Engine.animateSprites()
    }
    
    
}
