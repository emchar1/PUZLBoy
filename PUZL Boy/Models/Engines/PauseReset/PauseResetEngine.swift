//
//  PauseResetEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/12/23.
//

import SpriteKit

protocol PauseResetEngineDelegate: AnyObject {
    func didTapPause(isPaused: Bool)
    func didTapButtonSpecial()
    func confirmQuitTapped()
}


class PauseResetEngine {
    
    // MARK: - Properties
    
    private let pauseResetName = "pauseresetbutton"
    private let buttonSize: CGFloat = 180
    private let settingsButtonHeight: CGFloat = 80
    private var position: CGPoint {
        CGPoint(x: (K.ScreenDimensions.iPhoneWidth - buttonSize) / 2, y: K.ScreenDimensions.bottomMargin)
    }
    
    private let nameTitle = "Title"
    private let namePurchase = "Purchase"
    private let nameLeaderboard = "Leaderboard"
    private let nameHowToPlay = "How to Play"
    private let nameSettings = "Settings"
    
    private let resetAnimationKey = "resetAnimationKey"
    private let resetThreshold: Int = 3
    private let resetTimerSpeed: TimeInterval = 2
    private var resetInitial = Date()
    private var resetFinal = Date()
    private var resetElapsed: TimeInterval {
        TimeInterval(resetFinal.timeIntervalSinceNow - resetInitial.timeIntervalSinceNow) * resetTimerSpeed
    }
    
    private var buttonSprite: SKSpriteNode
    private var foregroundSprite: SKShapeNode
    private var backgroundSprite: SKShapeNode
    private var comingSoonLabel: SKLabelNode
    private var countdownLabel: SKLabelNode
    private var superScene: SKScene?
    
    private var titleButton: PauseResetButton
    private var purchaseButton: PauseResetButton
    private var leaderboardButton: PauseResetButton
    private var howToPlayButton: PauseResetButton
    private var settingsButton: PauseResetButton
    private var confirmSprite: ConfirmSprite

    private var backgroundColor: UIColor { (DayTheme.skyColor.bottom.isLight() ?? true) ? DayTheme.skyColor.top : DayTheme.skyColor.bottom }
    private var backgroundShadowColor: UIColor { DayTheme.skyColor.bottom.triadic.first }
    
    private var isPressed: Bool = false
    private var isAnimating: Bool = false
    private var currentLevel: Int = 1

    var specialFunctionEnabled: Bool = false {
        didSet {
            buttonSprite.texture = SKTexture(imageNamed: specialFunctionEnabled ? "\(pauseResetName)3" : (isPaused ? "\(pauseResetName)2" : pauseResetName))
        }
    }
    var isPaused: Bool = false {
        didSet {
            buttonSprite.texture = SKTexture(imageNamed: isPaused ? "\(pauseResetName)2" : pauseResetName)
        }
    }
    
    weak var delegate: PauseResetEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        let settingsSize: CGFloat = K.ScreenDimensions.iPhoneWidth
        let settingsScale: CGFloat = GameboardSprite.spriteScale
        let padding: CGFloat = GameboardSprite.padding
        
        // FIXME: - This is atrocious
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: settingsSize, height: settingsSize + ChatEngine.avatarSizeNew + settingsButtonHeight),
                                       cornerRadius: 20)
        backgroundSprite.strokeColor = .white
        backgroundSprite.lineWidth = 0
        backgroundSprite.setScale(0)
        backgroundSprite.zPosition = K.ZPosition.pauseScreen
        
        foregroundSprite = SKShapeNode(rectOf: CGSize(width: settingsSize, height: settingsSize + ChatEngine.avatarSizeNew - settingsButtonHeight))
        foregroundSprite.position = CGPoint(x: 0, y: settingsButtonHeight)
        foregroundSprite.fillColor = .clear
        foregroundSprite.lineWidth = 0
        foregroundSprite.setScale(1)
        
        // FIXME: - Temporary label
        comingSoonLabel = SKLabelNode(text: "      SETTINGS\n(Coming Soon...)")
        comingSoonLabel.numberOfLines = 0
        comingSoonLabel.preferredMaxLayoutWidth = settingsSize * 0.8
        comingSoonLabel.horizontalAlignmentMode = .center
        comingSoonLabel.verticalAlignmentMode = .center
        comingSoonLabel.fontName = UIFont.chatFont
        comingSoonLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        comingSoonLabel.fontColor = .white
        comingSoonLabel.zPosition = 10
        comingSoonLabel.addDropShadow()
        
        countdownLabel = SKLabelNode(text: "3")
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.fontSize = UIFont.gameFontSizeExtraLarge
        countdownLabel.fontName = UIFont.gameFont
        countdownLabel.fontColor = .white
        countdownLabel.zPosition = K.ZPosition.pauseButton
        countdownLabel.name = pauseResetName
        countdownLabel.alpha = 0
        countdownLabel.addDropShadow()
        
        buttonSprite = SKSpriteNode(imageNamed: pauseResetName)
        buttonSprite.scale(to: CGSize(width: buttonSize, height: buttonSize))
        buttonSprite.anchorPoint = .zero
        buttonSprite.name = pauseResetName
        buttonSprite.zPosition = K.ZPosition.pauseButton
        
        let pauseResetScale: CGFloat = 0.95
        let pauseResetButtonSize = CGSize(width: settingsSize / 5 * pauseResetScale, height: 120)
        titleButton = PauseResetButton(text: nameTitle, position: .zero, size: pauseResetButtonSize)
        purchaseButton = PauseResetButton(text: namePurchase, position: .zero, size: pauseResetButtonSize)
        leaderboardButton = PauseResetButton(text: nameLeaderboard, position: .zero, size: pauseResetButtonSize)
        howToPlayButton = PauseResetButton(text: nameHowToPlay, position: .zero, size: pauseResetButtonSize)
        settingsButton = PauseResetButton(text: nameSettings, position: .zero, size: pauseResetButtonSize)
        
        confirmSprite = ConfirmSprite(title: "RETURN TO MAIN MENU?",
                                      message: "Tap Quit to return to the main menu. Your progress will be saved.",
                                      confirm: "Quit",
                                      cancel: "Cancel")

        //Add'l setup/customization
        countdownLabel.position = CGPoint(x: position.x + buttonSize / 2, y: position.y + buttonSize * 1.5)
        buttonSprite.position = position
        backgroundSprite.position = CGPoint(x: settingsScale * (settingsSize + padding) / 2 + GameboardSprite.xPosition + GameboardSprite.padding / 2,
                                            y: position.y + settingsButtonHeight)
        backgroundSprite.fillColor = backgroundColor
//        backgroundSprite.addShadow(rectOf: CGSize(width: settingsSize, height: settingsSize + ChatEngine.avatarSizeNew + settingsButtonHeight),
//                                   cornerRadius: 20,
//                                   shadowColor: backgroundShadowColor)
        backgroundSprite.addDropShadow(rectOf: CGSize(width: settingsSize, height: settingsSize + ChatEngine.avatarSizeNew + settingsButtonHeight),
                                       cornerRadius: 20,
                                       shadowColor: backgroundShadowColor)
        
//        let pauseResetInitialPosition = CGPoint(x: -(settingsSize * settingsScale / 2) + (pauseResetButtonSize.width / 2),
//    y: -settingsSize / 2 - settingsButtonHeight)
        let xPosition = -backgroundSprite.position.x + pauseResetButtonSize.width / pauseResetScale / 2 + abs(titleButton.shadowSize.x) + GameboardSprite.padding / 2
        let yPosition = -settingsSize / 2 - pauseResetButtonSize.height + abs(titleButton.shadowSize.y)
        let pauseResetInitialPosition = CGPoint(x: xPosition, y: yPosition)
        titleButton.position = pauseResetInitialPosition
        purchaseButton.position = titleButton.position + CGPoint(x: pauseResetButtonSize.width / pauseResetScale, y: 0)
        leaderboardButton.position = purchaseButton.position + CGPoint(x: pauseResetButtonSize.width / pauseResetScale, y: 0)
        howToPlayButton.position = leaderboardButton.position + CGPoint(x: pauseResetButtonSize.width / pauseResetScale, y: 0)
        settingsButton.position = howToPlayButton.position + CGPoint(x: pauseResetButtonSize.width / pauseResetScale, y: 0)
        
        titleButton.delegate = self
        purchaseButton.delegate = self
        leaderboardButton.delegate = self
        howToPlayButton.delegate = self
        settingsButton.delegate = self
        confirmSprite.delegate = self
        
        settingsButton.touchDown()

        resetAll()
    }
    
    
    // MARK: - Move Functions
    
    func moveSprites(to superScene: SKScene, level: Int) {
        self.superScene = superScene
        
        superScene.addChild(buttonSprite)
        superScene.addChild(countdownLabel)
        
        currentLevel = level
    }
    
    
    // MARK: - Reset Functions
    
    private func resetAll() {
        resetInitial = Date()
        resetFinal = Date()
    }
    
    
    // MARK: - Touch Functions
    
    /**
     Helper function that checks that superScene has been set up, and that the tap occured within the pauseResetButton node name. Call this, then pass the touch function in the function parameter. Don't use for touchDown due to different parameter list.
     - parameters:
     - location: location of the touch
     - function: the passed in function to be executed once the node has ben found
     */
    func touch(in location: CGPoint?, function: () -> Void) {
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        
        if let location = location {
            for nodeTapped in superScene.nodes(at: location) {
                if nodeTapped.name == pauseResetName {
                    function()
                }
                else if nodeTapped is DecisionButtonSprite {
                    confirmSprite.didTapButton(in: location)
                }
            }
        }
        else {
            function()
        }
    }
    
    /**
     Handles the actual logic for when the user taps the button. Pass this in the touch helper function because it doesn't contain any setup to handle location of the tap.
     */
    func handleControls() {
        guard !isAnimating else { return print("isAnimating is true. Aborting.") }

        if !specialFunctionEnabled {
            openSettingsMenu()
        }
        else {
            callSpecialFunc()
        }
    }
    
    private func openSettingsMenu() {
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard isPressed else { return }
        
        isPaused.toggle()
        
        
        

        // TODO: - Handle actual pause screen here.
        isAnimating = true
        
        if isPaused {
            backgroundSprite.run(SKAction.group([
                SKAction.moveTo(y: GameboardSprite.spriteScale * (K.ScreenDimensions.iPhoneWidth - ChatEngine.avatarSizeNew - settingsButtonHeight + GameboardSprite.padding * 4 + 2) / 2 + GameboardSprite.yPosition, duration: 0.2),
                SKAction.sequence([
                    SKAction.run { [unowned self] in
                        backgroundSprite.fillColor = backgroundColor
                        backgroundSprite.updateShadowColor(backgroundShadowColor)
                    },
                    SKAction.scale(to: GameboardSprite.spriteScale, duration: 0.2)
                ])
            ])) {
                self.isAnimating = false
            }
            
            foregroundSprite.addChild(comingSoonLabel)
            backgroundSprite.addChild(foregroundSprite)
            
            backgroundSprite.addChild(titleButton)
            backgroundSprite.addChild(purchaseButton)
            backgroundSprite.addChild(leaderboardButton)
            backgroundSprite.addChild(howToPlayButton)
            backgroundSprite.addChild(settingsButton)
            
            superScene.addChild(backgroundSprite)
        }
        else {
            backgroundSprite.run(SKAction.group([
                SKAction.moveTo(y: self.position.y, duration: 0.2),
                SKAction.scale(to: 0, duration: 0.2)
            ])) {
                self.isAnimating = false
                
                self.comingSoonLabel.removeFromParent()
                self.foregroundSprite.removeFromParent()

                self.titleButton.removeFromParent()
                self.purchaseButton.removeFromParent()
                self.leaderboardButton.removeFromParent()
                self.howToPlayButton.removeFromParent()
                self.settingsButton.removeFromParent()

                self.backgroundSprite.removeFromParent()
            }
            
        }
        
        
        
        
        K.ButtonTaps.tap1()

        delegate?.didTapPause(isPaused: self.isPaused)
    }
    
    private func callSpecialFunc() {
        delegate?.didTapButtonSpecial()
    }
    
    /**
     Handles when user lifts finger off the button. Pass this in the touch helper function because it doesn't contain any setup to handle location of the tap.
     */
    func touchUp() {
        buttonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))

        if isPressed {
            Haptics.shared.addHapticFeedback(withStyle: .light)
        }
        
        //Prevents touch drag exit keeping it stuck on the refresh button.
        if !specialFunctionEnabled {
            buttonSprite.texture = SKTexture(imageNamed: isPaused ? "\(pauseResetName)2" : "\(pauseResetName)")
        }

        isPressed = false
        resetFinal = Date()
        
        //Reset settings from touchDown animation
        countdownLabel.alpha = 0
        countdownLabel.setScale(1.0)
        countdownLabel.removeAllActions()
        countdownLabel.run(SKAction.rotate(toAngle: 0, duration: 0))

        buttonSprite.removeAction(forKey: resetAnimationKey)
        
        titleButton.touchUp()
        leaderboardButton.touchUp()
        confirmSprite.touchUp()
    }
    
    /**
     Handles when button is tapped down. Call this on it's own; don't use the touch() helper function.
     - parameters:
     - location: location of the tap
     - resetCompletion: if user has button held down for count of the resetThreshold, then the completion gets executed, otherwise it's short circuited in touchUp.
     */
    func touchDown(in location: CGPoint?, resetCompletion: (() -> Void)?) {
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = location else { return print("Location nil. Unable to pauseReset.") }

        guard confirmSprite.parent == nil else {
            confirmSprite.touchDown(in: location)
            return
        }
        
        for nodeTapped in superScene.nodes(at: location) {
            switch nodeTapped.name {
            case pauseResetName:
                handlePauseReset(resetCompletion: resetCompletion)
            case nameTitle:
                guard !titleButton.isPressed else { break }
                
                titleButton.touchDown()
                titleButton.tapButton()
            case namePurchase:
                guard !purchaseButton.isPressed else { break }

                purchaseButton.touchDown()
                purchaseButton.tapButton()

                titleButton.touchUp()
                leaderboardButton.touchUp()
                howToPlayButton.touchUp()
                settingsButton.touchUp()
            case nameLeaderboard:
                guard !leaderboardButton.isPressed else { break }

                leaderboardButton.touchDown()
                leaderboardButton.tapButton()
            case nameHowToPlay:
                guard !howToPlayButton.isPressed else { break }

                howToPlayButton.touchDown()
                howToPlayButton.tapButton()

                titleButton.touchUp()
                purchaseButton.touchUp()
                leaderboardButton.touchUp()
                settingsButton.touchUp()
            case nameSettings:
                guard !settingsButton.isPressed else { break }

                settingsButton.touchDown()
                settingsButton.tapButton()

                titleButton.touchUp()
                purchaseButton.touchUp()
                leaderboardButton.touchUp()
                howToPlayButton.touchUp()
            default:
                break
            }
        } //end for
    } //end func touchDown
    
    
    private func handlePauseReset(resetCompletion: (() -> Void)?) {
        buttonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
        
        isPressed = true
        resetAll()
        Haptics.shared.addHapticFeedback(withStyle: .light)

        guard !specialFunctionEnabled else { return }
        
        //Counts down to see if should reset the level
        let animateCountdown = SKAction.run { [unowned self] in
            resetFinal = Date()
            
            countdownLabel.text = "\(resetThreshold - Int(resetElapsed))"
            countdownLabel.updateShadow()
            
            if resetElapsed >= 0.4 {
                buttonSprite.texture = SKTexture(imageNamed: "\(pauseResetName)4")
                
                countdownLabel.alpha = 1.0
                
                //All this to animate the countdown timer, make it more exciting.
                if floor(resetElapsed) == resetElapsed.truncate(placesAfterDecimal: 1) {
                    countdownLabel.run(SKAction.group([
                        SKAction.sequence([
                            SKAction.scale(to: ceil(resetElapsed) * 0.75, duration: 0.25),
                            SKAction.scale(to: ceil(resetElapsed) * 0.65, duration: 0.25)
                        ]),
                        SKAction.repeatForever(SKAction.sequence([
                            SKAction.rotate(toAngle: .pi / 32 * resetElapsed, duration: 0.1),
                            SKAction.rotate(toAngle: -.pi / 32 * resetElapsed, duration: 0.1)
                        ]))
                    ]))
                }
            }
        } //animateCountdown
        
        let repeatAction = SKAction.repeat(SKAction.sequence([
            animateCountdown,
            SKAction.wait(forDuration: 1.0 / (10 * resetTimerSpeed))
        ]), count: resetThreshold * 10)
        
        let completionAction = SKAction.run {
            if self.isPaused {
                self.handleControls()
            }
            else {
                K.ButtonTaps.tap1()
            }

            self.buttonSprite.texture = SKTexture(imageNamed: "\(self.pauseResetName)")
            self.touchUp()
            
            resetCompletion?()
        }
        
        let sequenceAction = SKAction.sequence([
            repeatAction,
            completionAction
        ])
        
        buttonSprite.run(sequenceAction, withKey: resetAnimationKey)
    }
    
    
}


// MARK: - CustomButtonDelegate

extension PauseResetEngine: PauseResetButtonDelegate {
    func didTapButton(_ node: PauseResetButton) {
        switch node.name {
        case nameTitle:
            guard let superScene = superScene else { return print("superScene not set up. Unable to show title confirm!") }
                        
            confirmSprite.animateShow { }
        
            superScene.addChild(confirmSprite)
        case namePurchase:
            comingSoonLabel.text = "     PURCHASE\n(Coming Soon...)"
            comingSoonLabel.updateShadow()
        case nameLeaderboard:
            GameCenterManager.shared.showLeaderboard(level: currentLevel) {
                self.leaderboardButton.touchUp()
            }
        case nameHowToPlay:
            comingSoonLabel.text = "    HOW TO PLAY\n(Coming Soon...)"
            comingSoonLabel.updateShadow()
        case nameSettings:
            comingSoonLabel.text = "      SETTINGS\n(Coming Soon...)"
            comingSoonLabel.updateShadow()
        default:
            print("Unknown button tapped")
        }
    }
}


// MARK: - ConfirmSpriteDelegate

extension PauseResetEngine: ConfirmSpriteDelegate {
    func didTapConfirm() {
        print("Confirm tapped")

        confirmSprite.animateHide {
            self.confirmSprite.removeFromParent()
            self.delegate?.confirmQuitTapped()
        }
    }
    
    func didTapCancel() {
        print("Cancel tapped")
        
        confirmSprite.animateHide {
            self.confirmSprite.removeFromParent()
        }
    }
}
