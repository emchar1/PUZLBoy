//
//  FinalBattleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/18/24.
//

import SpriteKit

protocol FinalBattleSceneDelegate: AnyObject {
    func finalBattleSceneDidFinish()
}

class FinalBattleScene: SKScene {
    
    // MARK: - Properties
    
    private var backgroundNode: SKSpriteNode!
    private var comingSoonLabel: SKLabelNode!
    private var creditsLabel: SKLabelNode!
    
    private var letterbox: LetterboxSprite!
    private var tapPointerEngine: TapPointerEngine!
    
    weak var finalBattleDelegate: FinalBattleSceneDelegate?
    
    
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
        letterbox = nil
        tapPointerEngine = nil
    }
    
    private func setupScene() {
        backgroundNode = SKSpriteNode(color: .black, size: size)
        backgroundNode.anchorPoint = .zero
        
        comingSoonLabel = SKLabelNode(text: "TO BE CONTINUED...")
        comingSoonLabel.fontName = UIFont.gameFont
        comingSoonLabel.fontColor = .yellow.darkenColor(factor: 3)
        comingSoonLabel.fontSize = UIFont.gameFontSizeLarge
        comingSoonLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        comingSoonLabel.addHeavyDropShadow(alpha: 0.35)
        comingSoonLabel.updateShadowColor(.purple.lightenColor(factor: 9))
        comingSoonLabel.zPosition = 10
        
        creditsLabel = SKLabelNode(text: "Thank you for playing PUZL Boy!\n\n\n\n\nStay tuned for the epic conclusion.\n\n\n\n\nSpecial thanks to....ME!")
        creditsLabel.position = CGPoint(x: size.width / 2, y: 0)
        creditsLabel.fontName = UIFont.chatFont
        creditsLabel.fontColor = .yellow.darkenColor(factor: 3)
        creditsLabel.fontSize = UIFont.chatFontSizeLarge
        creditsLabel.verticalAlignmentMode = .top
        creditsLabel.numberOfLines = 0
        creditsLabel.addDropShadow(alpha: 0.35)
        creditsLabel.updateShadowColor(.purple.lightenColor(factor: 9))
        creditsLabel.zPosition = 10
        
        letterbox = LetterboxSprite(color: .black, height: size.height / 3)
        tapPointerEngine = TapPointerEngine()
        
        AudioManager.shared.playSound(for: "bossbattle0")
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(backgroundNode)
        addChild(comingSoonLabel)
        addChild(creditsLabel)
        addChild(letterbox)
        
        animateScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
    }
    
    private func animateScene() {
        comingSoonLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.fadeOut(withDuration: 1)
        ]))
        
        creditsLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.moveTo(y: size.height + creditsLabel.frame.size.height, duration: 20)
        ])) { [weak self] in
            let fadeDuration: TimeInterval = 4
            
            AudioManager.shared.stopSound(for: "bossbattle0", fadeDuration: fadeDuration)
            
            self?.letterbox.show(duration: fadeDuration) {
                self?.cleanup()
                self?.finalBattleDelegate?.finalBattleSceneDidFinish()
            }
        }
        
        letterbox.show(duration: 2, delay: 4) { [weak self] in
            guard let self = self else { return }
            
            self.letterbox.setHeight(self.size.height + 40)
        }
        
        backgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.colorize(with: .black.lightenColor(factor: 3), colorBlendFactor: 1, duration: 2)
        ]))
    }
    
    
}
