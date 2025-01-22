//
//  FinalBattle2WinLoseScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/21/25.
//

import SpriteKit

class FinalBattle2WinLoseScene: SKScene {
    
    // MARK: - Properties
    
    private var winLoseLabel: SKLabelNode
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        winLoseLabel = SKLabelNode(text: "YOU WIN!")
        winLoseLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        winLoseLabel.fontName = UIFont.gameFont
        winLoseLabel.fontSize = UIFont.gameFontSizeLarge
        winLoseLabel.fontColor = .cyan.lightenColor(factor: 6)
        winLoseLabel.alpha = 0
        winLoseLabel.addDropShadow()

        super.init(size: size)
        
        backgroundColor = .black
        addChild(winLoseLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FinalBattle2WinLose deinit")
    }
    
    
    // MARK: - Functions
    
    func animateScene(didWin: Bool, completion: @escaping () -> Void) {
        let gameEndLogo: String = didWin ? "gameendwin" : "gameendlose"
        let gameEndDuration: TimeInterval = AudioManager.shared.getAudioItem(filename: gameEndLogo)?.player.duration ?? 0
        
        winLoseLabel.text = didWin ? "YOU WIN!" : "YOU LOSE!"
        winLoseLabel.fontColor = didWin ? .cyan.lightenColor(factor: 6) : .red.darkenColor(factor: 3)
        winLoseLabel.updateShadow()
        
        winLoseLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.fadeIn(withDuration: 3),
            SKAction.wait(forDuration: 3),
            SKAction.fadeOut(withDuration: 2),
            SKAction.wait(forDuration: gameEndDuration - 10)
        ]), completion: completion)
        
        AudioManager.shared.playSound(for: gameEndLogo)
    }
    
    
}
