//
//  ContinueSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/28/23.
//

import SpriteKit

protocol ContinueSpriteDelegate: AnyObject {
    func didTapWatchAd()
    func didTapBuy5MovesButton()
    func didTapSkipLevel()
    func didTapBuy25LivesButton()
}

class ContinueSprite: SKNode {
    
    // MARK: - Properties
        
    private var disableControls: Bool = true
    private var livesRefreshLabel: SKLabelNode!
    private(set) var backgroundSprite: SKShapeNode!
    private(set) var watchAdButton: DecisionButtonSprite!
    private(set) var buy5MovesButton: DecisionButtonSprite!
    private(set) var skipLevelButton: DecisionButtonSprite!
    private(set) var buy25LivesButton: DecisionButtonSprite!
    
    weak var delegate: ContinueSpriteDelegate?

    
    // MARK: - Initialization
    
    override init() {
        super.init()
                
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
        zPosition = K.ZPosition.messagePrompt

        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit ContinueSprite")
    }
    
    private func setupSprites() {
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.size.width, height: 2 * K.ScreenDimensions.size.width / 3),
                                       cornerRadius: 20)
        backgroundSprite.fillColor = .gray
        backgroundSprite.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(GameboardSprite.spriteScale)
        
        let continueLabel = SKLabelNode(text: "CONTINUE?")
        continueLabel.fontName = UIFont.gameFont
        continueLabel.fontSize = UIFont.gameFontSizeLarge
        continueLabel.fontColor = UIFont.gameFontColor
        continueLabel.verticalAlignmentMode = .top
        continueLabel.position = CGPoint(x: 0, y: backgroundSprite.frame.size.height / (UIDevice.isiPad ? 1.5 : 2) - continueLabel.frame.size.height / 2)
        continueLabel.zPosition = 10
        continueLabel.addHeavyDropShadow()
        
        skipLevelButton = DecisionButtonSprite(text: "Buy $2.99: Skip Level",
                                               color: DecisionButtonSprite.colorYellow,
                                               iconImageName: nil)
        skipLevelButton.position = CGPoint(
            x: -K.ScreenDimensions.size.width / 4,
            y: -backgroundSprite.frame.size.height / 2 + continueLabel.frame.height / (UIDevice.isiPad ? 2 : 0.5))
        skipLevelButton.delegate = self

        buy5MovesButton = DecisionButtonSprite(text: "Buy $0.99:      x\(IAPManager.rewardAmountMovesBuy5)",
                                               color: DecisionButtonSprite.colorBlue,
                                               iconImageName: "iconBoot")
        buy5MovesButton.position = CGPoint(
            x: -K.ScreenDimensions.size.width / 4,
            y: skipLevelButton.position.y + skipLevelButton.buttonSize.height + continueLabel.frame.height / 2)
        buy5MovesButton.delegate = self

        watchAdButton = DecisionButtonSprite(text: "Watch Ad:      x\(IAPManager.rewardAmountLivesAd)",
                                             color: DecisionButtonSprite.colorGreen,
                                             iconImageName: "iconPlayer")
        watchAdButton.position = CGPoint(
            x: K.ScreenDimensions.size.width / 4,
            y: buy5MovesButton.position.y)
        watchAdButton.delegate = self

        buy25LivesButton = DecisionButtonSprite(text: "Buy $4.99:      x\(IAPManager.rewardAmountLivesBuy25)",
                                                color: DecisionButtonSprite.colorGreen,
                                                iconImageName: "iconPlayer")
        buy25LivesButton.position = CGPoint(
            x: K.ScreenDimensions.size.width / 4,
            y: skipLevelButton.position.y)
        buy25LivesButton.delegate = self

        livesRefreshLabel = SKLabelNode(text: "Or wait for \(LifeSpawnerModel.defaultLives) lives in: 02:00:00")
        livesRefreshLabel.fontName = UIFont.chatFont
        livesRefreshLabel.fontSize = UIFont.chatFontSizeLarge
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
        buy5MovesButton.touchUp()
        skipLevelButton.touchUp()
        buy25LivesButton.touchUp()
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
        case let decisionSprite where decisionSprite == buy5MovesButton:
            delegate?.didTapBuy5MovesButton()
        case let decisionSprite where decisionSprite == skipLevelButton:
            delegate?.didTapSkipLevel()
        case let decisionSprite where decisionSprite == buy25LivesButton:
            delegate?.didTapBuy25LivesButton()
        default:
            print("Invalid button press.")
        }
    }
}
