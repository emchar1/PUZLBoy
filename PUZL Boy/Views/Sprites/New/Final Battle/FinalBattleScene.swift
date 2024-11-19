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
    private var comingSoonLabel: SKLabelNode!
    private var tapPointerEngine: TapPointerEngine!
    
    
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
    
    private func cleanup() {
        tapPointerEngine = nil
    }
    
    private func setupScene() {
        backgroundNode = SKSpriteNode(color: .magenta, size: size)
        backgroundNode.anchorPoint = .zero
        
        comingSoonLabel = SKLabelNode(text: "FINAL BATTLE COMING SOON...")
        comingSoonLabel.fontName = UIFont.gameFont
        comingSoonLabel.fontColor = .yellow
        comingSoonLabel.fontSize = UIFont.gameFontSizeLarge
        comingSoonLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        comingSoonLabel.addHeavyDropShadow()
        comingSoonLabel.zPosition = 10
        
        tapPointerEngine = TapPointerEngine()
        
        AudioManager.shared.playSound(for: "bossbattle1")
        AudioManager.shared.playSound(for: "bossbattle2", delay: AudioManager.shared.getAudioItem(filename: "bossbattle1")?.player.duration)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(backgroundNode)
        addChild(comingSoonLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))")
        Haptics.shared.addHapticFeedback(withStyle: .heavy)
    }
    
    
}
