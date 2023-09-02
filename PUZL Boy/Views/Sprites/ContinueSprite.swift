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
    func didTapBuy5MovesButton()
}

class ContinueSprite: SKNode {
    
    // MARK: - Properties
    
    static let extraLivesAd = 1
    static let extraLivesBuy25 = 25
    static let extraLivesBuy100 = 100
    static let extraLivesBuy1000 = 1000
    static let extraMovesBuy5 = 5
    
    private var disableControls: Bool = true
    private var livesRefreshLabel: SKLabelNode!
    private(set) var backgroundSprite: SKShapeNode!
    private(set) var watchAdButton: DecisionButtonSprite!
    private(set) var skipLevelButton: DecisionButtonSprite!
    private(set) var buy25LivesButton: DecisionButtonSprite!
    private(set) var buy5MovesButton: DecisionButtonSprite!
    
    weak var delegate: ContinueSpriteDelegate?

    
    // MARK: - Initialization
    
    override init() {
        super.init()
                
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.messagePrompt

        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ContinueSprite deinit")
    }
    
    private func setupSprites() {
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
                                               color: DecisionButtonSprite.colorYellow,
                                               iconImageName: nil)
        skipLevelButton.position = CGPoint(
            x: -K.ScreenDimensions.iPhoneWidth / 4,
            y: -backgroundSprite.frame.size.height / 2 + continueLabel.frame.height / (UIDevice.isiPad ? 2 : 0.5))
        skipLevelButton.delegate = self

        buy5MovesButton = DecisionButtonSprite(text: "Buy $0.99:      x\(ContinueSprite.extraMovesBuy5)",
                                               color: DecisionButtonSprite.colorBlue,
                                               iconImageName: "iconBoot")
        buy5MovesButton.position = CGPoint(
            x: -K.ScreenDimensions.iPhoneWidth / 4,
            y: skipLevelButton.position.y + skipLevelButton.buttonSize.height + continueLabel.frame.height / 2)
        buy5MovesButton.delegate = self

        watchAdButton = DecisionButtonSprite(text: "Watch Ad:      x\(ContinueSprite.extraLivesAd)",
                                             color: DecisionButtonSprite.colorGreen,
                                             iconImageName: "iconPlayer")
        watchAdButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: buy5MovesButton.position.y)
        watchAdButton.delegate = self

        buy25LivesButton = DecisionButtonSprite(text: "Buy $4.99:      x\(ContinueSprite.extraLivesBuy25)",
                                                color: DecisionButtonSprite.colorGreen,
                                            iconImageName: "iconPlayer")
        buy25LivesButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: skipLevelButton.position.y)
        buy25LivesButton.delegate = self

        livesRefreshLabel = SKLabelNode(text: "Or wait for \(LifeSpawnerModel.defaultLives) lives in: 02:00:00")
        livesRefreshLabel.fontName = UIFont.chatFont
        livesRefreshLabel.fontSize = UIDevice.isiPad ? UIFont.chatFontSizeLarge : UIFont.chatFontSizeMedium
        livesRefreshLabel.fontColor = UIFont.chatFontColor
        livesRefreshLabel.verticalAlignmentMode = .top
        livesRefreshLabel.position = CGPoint(
            x: 0,
            y: ((continueLabel.position.y - continueLabel.frame.size.height) - (watchAdButton.position.y + watchAdButton.frame.size.height)) / 2)
        livesRefreshLabel.zPosition = 10
        livesRefreshLabel.addDropShadow()
        
        addChild(backgroundSprite)
        backgroundSprite.addChild(continueLabel)
        backgroundSprite.addChild(livesRefreshLabel)
        backgroundSprite.addChild(watchAdButton)
        backgroundSprite.addChild(skipLevelButton)
        backgroundSprite.addChild(buy25LivesButton)
        backgroundSprite.addChild(buy5MovesButton)
    }
    
    
    // MARK: - Functions
    
    func animateShow(shouldDisable5Moves: Bool, completion: @escaping (() -> Void)) {
        buy5MovesButton.isDisabled = shouldDisable5Moves
        watchAdButton.isDisabled = !AdMobManager.rewardedAdIsReady
        
        if watchAdButton.isDisabled {
            AdMobManager.shared.createAndLoadRewarded()
        }

        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2),
        ])) { [unowned self] in
            disableControls = false
            completion()
        }
    }
    
    func animateHide(completion: @escaping (() -> Void)) {
        disableControls = true
        AudioManager.shared.playSound(for: "chatclose")

        run(SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ])) {
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
        buy5MovesButton.touchUp()
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
        case let decisionSprite where decisionSprite == buy5MovesButton:
            delegate?.didTapBuy5MovesButton()
        default:
            print("Invalid button press.")
        }
    }
}
