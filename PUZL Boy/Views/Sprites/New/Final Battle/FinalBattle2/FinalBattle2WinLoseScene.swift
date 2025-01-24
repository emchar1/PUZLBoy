//
//  FinalBattle2WinLoseScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/21/25.
//

import SpriteKit

protocol FinalBattle2WinLoseSceneDelegate: AnyObject {
    func didTapQuit()
    func didTapTryAgain()
}

class FinalBattle2WinLoseScene: SKScene {
    
    // MARK: - Properties
    
    private let fadeDuration: TimeInterval = 2
    
    private var backgroundNode: SKSpriteNode
    private var winLoseLabel: SKLabelNode
    private var tryAgainButton: DecisionButtonSprite
    private var quitButton: DecisionButtonSprite
    
    weak var winLoseDelegate: FinalBattle2WinLoseSceneDelegate?
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        backgroundNode = SKSpriteNode(color: .black, size: size)
        backgroundNode.anchorPoint = .zero
        
        winLoseLabel = SKLabelNode(text: "YOU WIN!")
        winLoseLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        winLoseLabel.fontName = UIFont.gameFont
        winLoseLabel.fontSize = UIFont.gameFontSizeLarge
        winLoseLabel.fontColor = .cyan.lightenColor(factor: 6)
        winLoseLabel.alpha = 0
        winLoseLabel.zPosition = 1
        winLoseLabel.addDropShadow()
        winLoseLabel.updateShadowColor(.black.lightenColor(factor: 6))
        
        tryAgainButton = DecisionButtonSprite(text: "Play Again?", color: DecisionButtonSprite.colorBlue, iconImageName: nil)
        tryAgainButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 300)
        tryAgainButton.alpha = 0
        tryAgainButton.zPosition = 2
        tryAgainButton.name = "tryAgainButton"

        quitButton = DecisionButtonSprite(text: "Quit.", color: DecisionButtonSprite.colorRed, iconImageName: nil)
        quitButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 500)
        quitButton.alpha = 0
        quitButton.zPosition = 3
        quitButton.name = "quitButton"

        super.init(size: size)
        
        tryAgainButton.delegate = self
        quitButton.delegate = self
        
        addChild(backgroundNode)
        addChild(winLoseLabel)
        addChild(tryAgainButton)
        addChild(quitButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FinalBattle2WinLose deinit")
    }
    
    
    // MARK: - Functions
    
    func animateScene(didWin: Bool) {
        let gameEndLogo: String = didWin ? "gameendwin1" : "gameendlose"
        
        winLoseLabel.text = didWin ? "YOU WIN!" : "YOU LOSE!"
        winLoseLabel.fontColor = (didWin ? UIColor.cyan : UIColor.red).lightenColor(factor: 6)
        winLoseLabel.updateShadow()
        
        winLoseLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: fadeDuration),
            SKAction.fadeIn(withDuration: fadeDuration)
        ]))
        
        tryAgainButton.run(SKAction.sequence([
            SKAction.wait(forDuration: fadeDuration * 2),
            SKAction.fadeIn(withDuration: fadeDuration / 1)
        ]))
        
        quitButton.run(SKAction.sequence([
            SKAction.wait(forDuration: fadeDuration * 2),
            SKAction.fadeIn(withDuration: fadeDuration / 1)
        ]))
        
        AudioManager.shared.playSound(for: didWin ? "villaindead" : "boydead")
        
        if didWin {
            let delay: TimeInterval = AudioManager.shared.getAudioItem(filename: "gameendwin1")?.player.duration ?? 0
            
            AudioManager.shared.playSound(for: "gameendwin1", delay: fadeDuration)
            AudioManager.shared.playSound(for: "gameendwin2", delay: fadeDuration + delay)
        }
        else {
            AudioManager.shared.playSound(for: "gameendlose", delay: fadeDuration)
        }
    }
    
    
    // MARK: - UI Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        for node in nodes(at: location) {
            if node.name == "tryAgainButton" {
                tryAgainButton.touchDown(in: location)
            }
            else if node.name == "quitButton" {
                quitButton.touchDown(in: location)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        for node in nodes(at: location) {
            if node.name == "tryAgainButton" {
                tryAgainButton.tapButton(in: location)
                quitButton.run(SKAction.fadeOut(withDuration: fadeDuration))
                backgroundNode.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration))
            }
            else if node.name == "quitButton" {
                quitButton.tapButton(in: location, type: .buttontap3)
                tryAgainButton.run(SKAction.fadeOut(withDuration: fadeDuration))
                backgroundNode.run(SKAction.colorize(with: .white, colorBlendFactor: 1, duration: fadeDuration))
            }
            
            winLoseLabel.run(SKAction.fadeOut(withDuration: fadeDuration))
        }
        
        tryAgainButton.touchUp()
        quitButton.touchUp()
    }
    
    
}


// MARK: - DecisionButtonSpriteDelegate

extension FinalBattle2WinLoseScene: DecisionButtonSpriteDelegate {
    func buttonWasTapped(_ node: DecisionButtonSprite) {
        run(SKAction.wait(forDuration: fadeDuration)) { [weak self] in
            guard let self = self else { return }
            
            //LESSON: - Identity operator (===) checks that node is the same object as tryAgainButton, i.e. they point to the same address in memory.
            if node === tryAgainButton {
                winLoseDelegate?.didTapTryAgain()
            }
            else if node === quitButton {
                winLoseDelegate?.didTapQuit()
            }
        }
        
        AudioManager.shared.stopSound(for: "gameendwin1", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "gameendwin2", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "gameendlose", fadeDuration: fadeDuration)
    }
    
    
}
