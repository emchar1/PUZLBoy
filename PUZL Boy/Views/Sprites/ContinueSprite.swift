//
//  ContinueSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/28/23.
//

import SpriteKit

protocol ContinueSpriteDelegate: AnyObject {
    func didTapWatchAd()
    func didTapSkipLevel()
    func didTapBuy25LivesButton()
    func didTapBuy100LivesButton()
}

class ContinueSprite: SKNode {
    
    // MARK: - Properties
    
    static let extraLivesAd = 1
    static let extraLivesBuy25 = 25
    static let extraLivesBuy100 = 100
    
    private var disableControls: Bool = true
    private let livesRefreshLabel: SKLabelNode
    private(set) var backgroundSprite: SKShapeNode
    private(set) var watchAdButton: DecisionButtonSprite
    private(set) var skipLevelButton: DecisionButtonSprite
    private(set) var buy25LivesButton: DecisionButtonSprite
    private(set) var buy100LivesButton: DecisionButtonSprite
    
    weak var delegate: ContinueSpriteDelegate?

    
    // MARK: - Initialization
    
    override init() {
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: 2 * K.ScreenDimensions.iPhoneWidth / 3),
                                       cornerRadius: 20)
        backgroundSprite.fillColor = .gray
        backgroundSprite.fillTexture = SKTexture(image: UIImage.chatGradientTexture)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(GameboardSprite.spriteScale)
        
        let continueLabel = SKLabelNode(text: "CONTINUE?")
        continueLabel.fontName = UIFont.gameFont
        continueLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeExtraLarge : UIFont.gameFontSizeMedium
        continueLabel.fontColor = UIFont.gameFontColor
        continueLabel.verticalAlignmentMode = .top
        continueLabel.position = CGPoint(x: 0, y: backgroundSprite.frame.size.height / (UIDevice.isiPad ? 1.5 : 2) - continueLabel.frame.size.height / 2)
        continueLabel.zPosition = 10
        continueLabel.addHeavyDropShadow()
        
        skipLevelButton = DecisionButtonSprite(text: "Buy $2.99: Skip Level",
                                               color: UIColor(red: 227 / 255, green: 148 / 255, blue: 9 / 255, alpha: 1.0),
                                               iconImageName: nil)
        skipLevelButton.position = CGPoint(
            x: -K.ScreenDimensions.iPhoneWidth / 4,
            y: -backgroundSprite.frame.size.height / 2 + continueLabel.frame.height / (UIDevice.isiPad ? 2 : 0.5))

        watchAdButton = DecisionButtonSprite(text: "Watch Ad:      x\(ContinueSprite.extraLivesAd)",
                                             color: UIColor(red: 9 / 255, green: 132 / 255, blue: 227 / 255, alpha: 1.0),
                                             iconImageName: "Run (6)")
        watchAdButton.position = CGPoint(
            x: -K.ScreenDimensions.iPhoneWidth / 4,
            y: skipLevelButton.position.y + skipLevelButton.buttonSize.height + continueLabel.frame.height / 2)
        
        buy100LivesButton = DecisionButtonSprite(text: "Buy $9.99:      x\(ContinueSprite.extraLivesBuy100)",
                                            color: UIColor(red: 0 / 255, green: 168 / 255, blue: 86 / 255, alpha: 1.0),
                                            iconImageName: "Run (6)")
        buy100LivesButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: skipLevelButton.position.y)

        buy25LivesButton = DecisionButtonSprite(text: "Buy $4.99:      x\(ContinueSprite.extraLivesBuy25)",
                                            color: UIColor(red: 0 / 255, green: 168 / 255, blue: 86 / 255, alpha: 1.0),
                                            iconImageName: "Run (6)")
        buy25LivesButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: watchAdButton.position.y)
                
        livesRefreshLabel = SKLabelNode(text: "Or wait for \(LifeSpawnerModel.defaultLives) lives in: 99:99:99")
        livesRefreshLabel.fontName = UIFont.chatFont
        livesRefreshLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.chatFontSize
        livesRefreshLabel.fontColor = UIFont.chatFontColor
        livesRefreshLabel.verticalAlignmentMode = .top
        livesRefreshLabel.position = CGPoint(
            x: 0,
            y: ((continueLabel.position.y - continueLabel.frame.size.height) - (watchAdButton.position.y + watchAdButton.frame.size.height)) / 2)
        livesRefreshLabel.zPosition = 10
        livesRefreshLabel.addDropShadow()
        
        super.init()
        
        watchAdButton.delegate = self
        skipLevelButton.delegate = self
        buy25LivesButton.delegate = self
        buy100LivesButton.delegate = self
        
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.messagePrompt
        
        backgroundSprite.addChild(continueLabel)
        backgroundSprite.addChild(livesRefreshLabel)
        backgroundSprite.addChild(watchAdButton)
        backgroundSprite.addChild(skipLevelButton)
        backgroundSprite.addChild(buy25LivesButton)
        backgroundSprite.addChild(buy100LivesButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ContinueSprite deinit")
    }
    
    
    // MARK: - Functions
    
    func animateShow(completion: @escaping (() -> Void)) {
        addChild(backgroundSprite)
        
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2),
        ])) {
            self.disableControls = false
            completion()
        }
    }
    
    func animateHide(completion: @escaping (() -> Void)) {
        disableControls = true
        AudioManager.shared.playSound(for: "chatclose")

        run(SKAction.scale(to: 0, duration: 0.25)) {
            self.backgroundSprite.removeFromParent()
            completion()
        }
    }
    
    func updateTimeToReplenishLives(time: TimeInterval) {
        let interval = Int(time)
        let hours = max(0, (interval / 3600))
        let minutes = max(0, (interval / 60) % 60)
        let seconds = max(0, interval % 60)

        livesRefreshLabel.text = "Or wait for \(LifeSpawnerModel.defaultLives) lives in: " + String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        livesRefreshLabel.updateShadow()
    }
    
    
    // MARK: - UI Controls
    
    func touchDown(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard node.name == DecisionButtonSprite.tappableAreaName else { continue }
            guard let decisionSprite = node.parent as? DecisionButtonSprite else { continue }
            
            decisionSprite.touchDown(in: location)
        }
    }
    
    func touchUp() {
        guard !disableControls else { return }
        
        watchAdButton.touchUp()
        skipLevelButton.touchUp()
        buy25LivesButton.touchUp()
        buy100LivesButton.touchUp()
    }
    
    
    func didTapButton(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard node.name == DecisionButtonSprite.tappableAreaName else { continue }
            guard let decisionSprite = node.parent as? DecisionButtonSprite else { continue }
            
            decisionSprite.tapButton(in: location)
        }
    }
    
    
}


// MARK: - DecisionButtonSpriteDelegate

extension ContinueSprite: DecisionButtonSpriteDelegate {
    func buttonWasTapped(_ node: DecisionButtonSprite) {
        switch node {
        case let decisionSprite where decisionSprite == watchAdButton:
            delegate?.didTapWatchAd()
        case let decisionSprite where decisionSprite == skipLevelButton:
            delegate?.didTapSkipLevel()
        case let decisionSprite where decisionSprite == buy25LivesButton:
            delegate?.didTapBuy25LivesButton()
        case let decisionSprite where decisionSprite == buy100LivesButton:
            delegate?.didTapBuy100LivesButton()
        default:
            print("Invalid button press.")
        }
    }
}
