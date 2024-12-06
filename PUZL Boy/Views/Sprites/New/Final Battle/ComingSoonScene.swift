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
    private var copyrightLabel: SKLabelNode!
    private var logoNode: SKSpriteNode!
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
        
        letterbox = LetterboxSprite(color: .black, height: size.height / 3)
        tapPointerEngine = TapPointerEngine()
        
        comingSoonLabel = SKLabelNode(text: "TO BE CONTINUED")
        comingSoonLabel.fontName = UIFont.gameFont
        comingSoonLabel.fontColor = textColor
        comingSoonLabel.fontSize = UIFont.gameFontSizeLarge
        comingSoonLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        comingSoonLabel.addHeavyDropShadow(alpha: shadow.alpha)
        comingSoonLabel.updateShadowColor(shadow.color)
        comingSoonLabel.zPosition = 10
        
        logoNode = SKSpriteNode(imageNamed: "5PlayAppsSM_dark")
        logoNode.position = CGPoint(x: size.width / 2, y: 0)
        logoNode.setScale(2)
        logoNode.alpha = 0
        
        credits.append("Stay tuned for the epic conclusion...")
        credits.append("Created by\nEddie Char")
        credits.append("Image Libraries\nAdobe Stock\nDeviant Art\nFlaticon\nFreepik\nGame Art 2D\nGraphic River\nIcons8\nShutterstock")
        credits.append("Sound Libraries\nAudio Jungle\nEnvato")
        credits.append("Special Thanks\nClayton Caldwell\nMichelle Rayfield\nJackson Rayfield\nAissa Char\nVirat Char\nMichel Char")
        credits.append("for\nOlivia🦄\nand Alana ")
        credits.append("Thank you for playing PUZL Boy!")
        credits.append("Visit 5playapps.com for exciting updates!")
        credits.append("Don't forget to Rate and Review! ❤️")
        
        let copyrightAttrString = getAttrString(text: "© 2024 5Play Apps, LLC. All rights reserved.")
        let copyrightShadowLabel = SKLabelNode()
        copyrightShadowLabel.attributedText = copyrightAttrString.shadow
        copyrightShadowLabel.position = CGPoint(x: -3, y: -3)
        copyrightShadowLabel.alpha = shadow.alpha
        copyrightShadowLabel.zPosition = -1

        copyrightLabel = SKLabelNode()
        copyrightLabel.attributedText = copyrightAttrString.main
        copyrightLabel.position = CGPoint(x: size.width / 2, y: size.height * 1/8)
        copyrightLabel.alpha = 0
        copyrightLabel.zPosition = letterbox.zPosition + 10
        copyrightLabel.addChild(copyrightShadowLabel)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(backgroundNode)
        addChild(comingSoonLabel)
        addChild(logoNode)
        addChild(letterbox)
        addChild(copyrightLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
    }
    
    func animateScene() {
        let combinedCreditsDuration: TimeInterval = 4 + 11 + 4 + 9 + 5 + 8 + 11 + 1 + 1
        let creditsScrollSpeed: TimeInterval = 28
        
        func getCreditsAction(index: Int, waitDuration: TimeInterval) -> SKAction {
            return SKAction.sequence([
                SKAction.wait(forDuration: waitDuration),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    animateCredits(credits: credits[index], creditsScrollSpeed: creditsScrollSpeed)
                }
            ])
        }
        
        AudioManager.shared.playSound(for: "bossbattle0")
        letterbox.show(duration: 2, delay: 4)
        
        comingSoonLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.fadeOut(withDuration: 1)
        ]))
        
        run(SKAction.sequence([
            getCreditsAction(index: 0, waitDuration: 4),
            getCreditsAction(index: 1, waitDuration: 11),
            getCreditsAction(index: 2, waitDuration: 4),
            getCreditsAction(index: 3, waitDuration: 9),
            getCreditsAction(index: 4, waitDuration: 5),
            getCreditsAction(index: 5, waitDuration: 8),
            getCreditsAction(index: 6, waitDuration: 11),
            getCreditsAction(index: 7, waitDuration: 1),
            getCreditsAction(index: 8, waitDuration: 1)
        ]))
        
        logoNode.run(SKAction.sequence([
            SKAction.wait(forDuration: combinedCreditsDuration + 10),
            SKAction.fadeIn(withDuration: 0),
            SKAction.moveTo(y: size.height / 2, duration: creditsScrollSpeed / 2.5),
            SKAction.run {
                AudioManager.shared.stopSound(for: "bossbattle0", fadeDuration: 6)
            },
            SKAction.wait(forDuration: 4),
            SKAction.fadeOut(withDuration: 2),
            SKAction.wait(forDuration: 2)
        ])) { [weak self] in
            self?.cleanup()
            self?.comingSoonDelegate?.comingSoonSceneDidFinish()
        }
        
        copyrightLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: combinedCreditsDuration + 10 + creditsScrollSpeed / 2.5),
            SKAction.fadeIn(withDuration: 2),
            SKAction.wait(forDuration: 2),
            SKAction.fadeOut(withDuration: 2)
        ]))
        
        backgroundNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.colorize(with: .black.lightenColor(factor: 3), colorBlendFactor: 1, duration: 2),
            SKAction.wait(forDuration: combinedCreditsDuration + 10 - 4 - 2),
            SKAction.colorize(with: .black, colorBlendFactor: 1, duration: creditsScrollSpeed / 2.5)
        ]))
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Animates a line of credits.
     - parameters:
        - credits: the credit text string
        - creditsScrollSpeed: vertical speed of credit as it scrolls by
     */
    private func animateCredits(credits: String, creditsScrollSpeed: TimeInterval) {
        let attrString = getAttrString(text: credits)
        
        let creditsLabel = SKLabelNode()
        creditsLabel.attributedText = attrString.main
        creditsLabel.position = CGPoint(x: size.width / 2, y: 0)
        creditsLabel.verticalAlignmentMode = .top
        creditsLabel.numberOfLines = 0
        creditsLabel.zPosition = 10
        
        let shadowLabel = SKLabelNode()
        shadowLabel.attributedText = attrString.shadow
        shadowLabel.position = creditsLabel.position - CGPoint(x: 3, y: 3)
        shadowLabel.verticalAlignmentMode = creditsLabel.verticalAlignmentMode
        shadowLabel.numberOfLines = creditsLabel.numberOfLines
        shadowLabel.zPosition = creditsLabel.zPosition - 1
        shadowLabel.alpha = shadow.alpha
        
        addChild(creditsLabel)
        addChild(shadowLabel)
        
        let creditsAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: size.height * 1.25, duration: creditsScrollSpeed),
            SKAction.removeFromParent()
        ])
        
        creditsLabel.run(creditsAction)
        shadowLabel.run(creditsAction)
    }
    
    /**
     Helper function that returns an NSAttributedString for both, the main text and its shadow counterpart.
     - parameter text: the text in question
     - returns: a tuple of the main text and its shadow counterpart
     */
    private func getAttrString(text: String) -> (main: NSAttributedString, shadow: NSAttributedString) {
        let font = UIFont(name: UIFont.chatFont, size: UIFont.chatFontSizeLarge) ?? UIFont.systemFont(ofSize: 30)
        let range = NSRange(location: 0, length: text.count)
        let rangeTitle = NSRange(location: 0, length: text.distance(from: text.startIndex,
                                                                    to: text.firstIndex(of: "\n") ?? text.startIndex))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorAlt, range: range)
        attrString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attrString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeTitle)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: rangeTitle)
        
        let attrShadow = NSMutableAttributedString(string: text)
        attrShadow.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrShadow.addAttribute(NSAttributedString.Key.foregroundColor, value: shadow.color, range: range)
        attrShadow.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attrShadow.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeTitle)
        
        return (attrString, attrShadow)
    }
    
    
}
