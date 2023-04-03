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
    func didTapBuy099Button()
    func didTapBuy299Button()
}

class ContinueSprite: SKNode {
    
    // MARK: - Properties
    
    static let extraLivesAd = 1
    static let extraLivesBuy099 = 25
    static let extraLivesBuy299 = 100
    
    private var disableControls: Bool = true
    private let livesRefreshLabel: SKLabelNode
    private(set) var backgroundSprite: SKShapeNode
    private(set) var watchAdButton: DecisionButtonSprite
    private(set) var skipLevelButton: DecisionButtonSprite
    private(set) var buy099Button: DecisionButtonSprite
    private(set) var buy299Button: DecisionButtonSprite
    
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
        
        livesRefreshLabel = SKLabelNode(text: "Or wait for \(LifeSpawnerModel.defaultLives) lives in: 99:99:99")
        
        watchAdButton = DecisionButtonSprite(text: "Watch Ad:      x\(ContinueSprite.extraLivesAd)",
                                             color: UIColor(red: 9 / 255, green: 132 / 255, blue: 227 / 255, alpha: 1.0),
                                             iconImageName: "Run (6)")
        watchAdButton.position = CGPoint(x: -K.ScreenDimensions.iPhoneWidth / 4, y: -K.ScreenDimensions.iPhoneWidth / 16)
        watchAdButton.name = "watchAdButton"
        
        skipLevelButton = DecisionButtonSprite(text: "Buy $1.99: Skip Level",
                                               color: UIColor(red: 227 / 255, green: 148 / 255, blue: 9 / 255, alpha: 1.0),
                                               iconImageName: nil)
        skipLevelButton.position = CGPoint(x: -K.ScreenDimensions.iPhoneWidth / 4,
                                           y: watchAdButton.position.y - K.ScreenDimensions.iPhoneWidth / 8 - 40)
        skipLevelButton.name = "skipLevelButton"
        
        buy099Button = DecisionButtonSprite(text: "Buy $0.99:      x\(ContinueSprite.extraLivesBuy099)",
                                            color: UIColor(red: 0 / 255, green: 168 / 255, blue: 86 / 255, alpha: 1.0),
                                            iconImageName: "Run (6)")
        buy099Button.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: watchAdButton.position.y)
        buy099Button.name = "buy099Button"
        
        buy299Button = DecisionButtonSprite(text: "Buy $2.99:      x\(ContinueSprite.extraLivesBuy299)",
                                            color: UIColor(red: 0 / 255, green: 168 / 255, blue: 86 / 255, alpha: 1.0),
                                            iconImageName: "Run (6)")
        buy299Button.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4,
                                        y: watchAdButton.position.y - K.ScreenDimensions.iPhoneWidth / 8 - 40)
        buy299Button.name = "buy299Button"
        
        super.init()
        
        watchAdButton.delegate = self
        skipLevelButton.delegate = self
        buy099Button.delegate = self
        buy299Button.delegate = self
        
        let continueLabel = SKLabelNode(text: "CONTINUE?")
        continueLabel.fontName = UIFont.gameFont
        continueLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeExtraLarge : UIFont.gameFontSizeMedium
        continueLabel.fontColor = UIFont.gameFontColor
        continueLabel.position = CGPoint(x: 0, y: K.ScreenDimensions.iPhoneWidth / 4)
        
        livesRefreshLabel.fontName = UIFont.chatFont
        livesRefreshLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.chatFontSize
        livesRefreshLabel.fontColor = UIFont.chatFontColor
        livesRefreshLabel.position = CGPoint(x: 0, y: continueLabel.position.y - (UIDevice.isiPad ? 200 : 100))
        
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.messagePrompt
        
        backgroundSprite.addChild(continueLabel)
        backgroundSprite.addChild(livesRefreshLabel)
        backgroundSprite.addChild(watchAdButton)
        backgroundSprite.addChild(skipLevelButton)
        backgroundSprite.addChild(buy099Button)
        backgroundSprite.addChild(buy299Button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
    
    
    // MARK: - UI Controls
    
    func touchDown(in location: CGPoint) {
        guard !disableControls else { return }
        
        for node in nodes(at: location - position) {
            guard let node = node as? DecisionButtonSprite else { continue }

            node.touchDown()
        }

    }
    
    func touchUp(in location: CGPoint) {
        guard !disableControls else { return }
        
        watchAdButton.touchUp()
        skipLevelButton.touchUp()
        buy099Button.touchUp()
        buy299Button.touchUp()
    }
    
    
    func didTapButton(in location: CGPoint) {
        guard !disableControls else { return }

        for node in nodes(at: location - position) {
            guard let node = node as? DecisionButtonSprite else { continue }
            
            node.tapButton()
        }
    }
    
    
}


// MARK: - DecisionButtonSpriteDelegate

extension ContinueSprite: DecisionButtonSpriteDelegate {
    func buttonWasTapped(_ node: DecisionButtonSprite) {
        switch node.name {
        case "watchAdButton": delegate?.didTapWatchAd()
        case "skipLevelButton": delegate?.didTapSkipLevel()
        case "buy099Button": delegate?.didTapBuy099Button()
        case "buy299Button": delegate?.didTapBuy299Button()
        default: print("Invalid button press.")
        }
    }
}
