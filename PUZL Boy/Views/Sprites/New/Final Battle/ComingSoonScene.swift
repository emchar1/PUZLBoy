//
//  ComingSoonScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/18/24.
//

import SpriteKit

protocol ComingSoonSceneDelegate: AnyObject {
    func comingSoonSceneDidFinish()
}

class ComingSoonScene: SKScene {
    
    // MARK: - Properties
    
    private let textColor: UIColor = .yellow.darkenColor(factor: 3)
    private let textColorAlt: UIColor = .white
    private let shadow: (color: UIColor, alpha: CGFloat) = (.purple.lightenColor(factor: 9), 0.35)

    private var backgroundNode: SKSpriteNode!
    private var comingSoonLabel: SKLabelNode!
    private var credits: [String] = []
    
    private var letterbox: LetterboxSprite!
    private var tapPointerEngine: TapPointerEngine!
    
    weak var comingSoonDelegate: ComingSoonSceneDelegate?
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ComingSoonScene deinit")
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
        comingSoonLabel.fontColor = textColor
        comingSoonLabel.fontSize = UIFont.gameFontSizeLarge
        comingSoonLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        comingSoonLabel.addHeavyDropShadow(alpha: shadow.alpha)
        comingSoonLabel.updateShadowColor(shadow.color)
        comingSoonLabel.zPosition = 10
        
        credits.append("Stay tuned for the epic conclusion...")
        credits.append("Created by\nEddie Char")
        credits.append("Art Assets\nDeviant Art\nFlaticon\nFreepik\nGame Art 2D\nGraphic River\nIcons8\nAdobe Stock\nShutterstock")
        credits.append("Music & Sound\nAudio Jungle\nEnvato")
        credits.append("Special Thanks\nClayton Caldwell\nMichelle Rayfield\nJackson Rayfield\nAissa Char\nVirat Char\nMichel Char")
        credits.append("for\nOlivia🦄\nand Alana ")
        credits.append("Thank you for playing PUZL Boy!")
        credits.append("Don't forget to Rate and Review ❤️")
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
            getCreditsAction(index: 1, waitDuration: 11),
            getCreditsAction(index: 2, waitDuration: 4),
            getCreditsAction(index: 3, waitDuration: 8),
            getCreditsAction(index: 4, waitDuration: 5),
            getCreditsAction(index: 5, waitDuration: 7),
            getCreditsAction(index: 6, waitDuration: 7),
            getCreditsAction(index: 7, waitDuration: 2),
            getCreditsAction(index: 8, waitDuration: 6),
            SKAction.wait(forDuration: 20)
        ])) { [weak self] in
            guard let self = self else { return }
            
            let fadeDuration: TimeInterval = 4
            
            AudioManager.shared.stopSound(for: "bossbattle0", fadeDuration: fadeDuration)
            
            backgroundNode.run(SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: fadeDuration))
            letterbox.close(size: size, duration: fadeDuration) {
                self.run(SKAction.wait(forDuration: fadeDuration / 2)) {
                    self.cleanup()
                    self.comingSoonDelegate?.comingSoonSceneDidFinish()
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
        let font = UIFont(name: UIFont.chatFont, size: UIFont.chatFontSizeLarge) ?? UIFont.systemFont(ofSize: 30)
        let range = NSRange(location: 0, length: credits.count)
        let rangeTitle = NSRange(location: 0, length: credits.distance(from: credits.startIndex,
                                                                       to: credits.firstIndex(of: "\n") ?? credits.startIndex))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attrString = NSMutableAttributedString(string: credits)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorAlt, range: range)
        attrString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attrString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeTitle)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: rangeTitle)

        let attrShadow = NSMutableAttributedString(string: credits)
        attrShadow.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrShadow.addAttribute(NSAttributedString.Key.foregroundColor, value: shadow.color, range: range)
        attrShadow.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attrShadow.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeTitle)

        let creditsLabel = SKLabelNode()
        creditsLabel.attributedText = attrString
        creditsLabel.position = CGPoint(x: size.width / 2, y: 0)
        creditsLabel.verticalAlignmentMode = .top
        creditsLabel.numberOfLines = 0
        creditsLabel.zPosition = 10
        
        let shadowLabel = SKLabelNode()
        shadowLabel.attributedText = attrShadow
        shadowLabel.position = creditsLabel.position - CGPoint(x: 3, y: 3)
        shadowLabel.verticalAlignmentMode = creditsLabel.verticalAlignmentMode
        shadowLabel.numberOfLines = creditsLabel.numberOfLines
        shadowLabel.zPosition = creditsLabel.zPosition - 1
        shadowLabel.alpha = shadow.alpha
        
        addChild(creditsLabel)
        addChild(shadowLabel)
        
        let creditsAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: size.height * 1.25, duration: 28),
            SKAction.removeFromParent()
        ])
        
        creditsLabel.run(creditsAction)
        shadowLabel.run(creditsAction)
    }
    
    
}
