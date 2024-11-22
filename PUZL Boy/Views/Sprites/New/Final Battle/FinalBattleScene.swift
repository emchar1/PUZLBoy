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
    private var credits: [String] = []
    
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
        
        comingSoonLabel = SKLabelNode(text: "TO BE CONTINUED")
        comingSoonLabel.fontName = UIFont.gameFont
        comingSoonLabel.fontColor = .yellow.darkenColor(factor: 3)
        comingSoonLabel.fontSize = UIFont.gameFontSizeLarge
        comingSoonLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        comingSoonLabel.addHeavyDropShadow(alpha: 0.35)
        comingSoonLabel.updateShadowColor(.purple.lightenColor(factor: 9))
        comingSoonLabel.zPosition = 10
        
        credits.append("Stay tuned for the epic conclusion...")
        credits.append("Art Assets\nDeviant Art\nFlaticon\nFreepik\nGame Art 2D")
        credits.append("Created by\nEddie Char")
        credits.append("Special Thanks\nClayton Caldwell\nMichelle Rayfield\nJackson Rayfield\nAissa Char\nVirat Char\nMichel Char")
        credits.append("for\nOlivia🦄\nand Alana ")
        credits.append("Thank you for playing PUZL Boy!")
        credits.append("Don't forget to Rate and Review❤️")
        credits.append("© 2024 5Play Apps, LLC. All rights reserved.")
        
        letterbox = LetterboxSprite(color: .black, height: size.height / 3)
        tapPointerEngine = TapPointerEngine()
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(backgroundNode)
        addChild(comingSoonLabel)
        addChild(letterbox)
        
        animateScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
    }
    
    private func animateScene() {
        func getCreditsAction(index: Int, waitDuration: TimeInterval) -> SKAction {
            return SKAction.sequence([
                SKAction.wait(forDuration: waitDuration),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    animateCredits(credits: credits[index])
                }
            ])
        }
        

        AudioManager.shared.playSound(for: "bossbattle0")

        comingSoonLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.fadeOut(withDuration: 1)
        ]))
        
        run(SKAction.sequence([
            getCreditsAction(index: 0, waitDuration: 4),
            getCreditsAction(index: 1, waitDuration: 10),
            getCreditsAction(index: 2, waitDuration: 6),
            getCreditsAction(index: 3, waitDuration: 4),
            getCreditsAction(index: 4, waitDuration: 7),
            getCreditsAction(index: 5, waitDuration: 7),
            getCreditsAction(index: 6, waitDuration: 2),
            getCreditsAction(index: 7, waitDuration: 6),
            SKAction.wait(forDuration: 20)
        ])) { [weak self] in
            guard let self = self else { return }
            
            let fadeDuration: TimeInterval = 4
            
            AudioManager.shared.stopSound(for: "bossbattle0", fadeDuration: fadeDuration)
            
            letterbox.close(size: size, duration: fadeDuration) {
                self.run(SKAction.wait(forDuration: fadeDuration / 2)) {
                    self.cleanup()
                    self.finalBattleDelegate?.finalBattleSceneDidFinish()
                }
            }
        }
        
        letterbox.show(duration: 2, delay: 4)
        
        backgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.colorize(with: .black.lightenColor(factor: 3), colorBlendFactor: 1, duration: 2)
        ]))
    }
    
    private func animateCredits(credits: String) {
        let attrString = NSMutableAttributedString(string: credits)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let range = NSRange(location: 0, length: credits.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.yellow.darkenColor(factor: 3),
            NSAttributedString.Key.font: UIFont(name: UIFont.chatFont, size: UIFont.chatFontSizeLarge) ?? UIFont.systemFont(ofSize: 30)
        ], range: range)

        let creditsLabel = SKLabelNode()
        creditsLabel.attributedText = attrString
        creditsLabel.position = CGPoint(x: size.width / 2, y: 0)
        creditsLabel.verticalAlignmentMode = .top
        creditsLabel.numberOfLines = 0
        creditsLabel.addDropShadow(alpha: 0.35)
        creditsLabel.updateShadowColor(.purple.lightenColor(factor: 9))
        creditsLabel.zPosition = 10
        
        addChild(creditsLabel)
        
        creditsLabel.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: size.height, duration: 20),
            SKAction.removeFromParent()
        ]))
    }
    
    
}
