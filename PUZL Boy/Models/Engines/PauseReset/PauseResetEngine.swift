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

    //Size Properties
    private let settingsSize = CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth * (UIDevice.isiPad ? 1.2 : 1.25))
    private let settingsScale: CGFloat = GameboardSprite.spriteScale

    //Pause Button
    private let pauseResetName = "pauseresetbutton"
    private let pauseResetButtonSize: CGFloat = 180
    private var pauseResetButtonPosition: CGPoint {
        CGPoint(x: (settingsSize.width - pauseResetButtonSize) / 2, y: K.ScreenDimensions.bottomMargin)
    }
    
    //Reset Countdown
    private let resetAnimationKey = "resetAnimationKey"
    private let resetThreshold: Int = 3
    private let resetTimerSpeed: TimeInterval = 2
    private var resetInitial = Date()
    private var resetFinal = Date()
    private var resetElapsed: TimeInterval {
        TimeInterval(resetFinal.timeIntervalSinceNow - resetInitial.timeIntervalSinceNow) * resetTimerSpeed
    }
    
    //SKNodes
    private var pauseResetButtonSprite: SKSpriteNode
    private var foregroundSprite: SKShapeNode
    private var backgroundSprite: SKShapeNode
    private var comingSoonLabel: SKLabelNode
    private var countdownLabel: SKLabelNode
    private var superScene: SKScene?
    
    //Custom Objects
    private var settingsManager: SettingsManager
    private var quitConfirmSprite: ConfirmSprite
    private var howToPlayPage: HowToPlayPage
    private var settingsPage: SettingsPage

    //Misc Properties
    static var backgroundColor: UIColor { DayTheme.skyColor.top.analogous.first.darkenColor(factor: 6) }
    static var backgroundShadowColor: UIColor { DayTheme.skyColor.bottom.analogous.first }
    private var currentLevelLeaderboard: Int = 1
    private var isPressed: Bool = false
    private var isAnimating: Bool = false

    var specialFunctionEnabled: Bool = false {
        didSet {
            pauseResetButtonSprite.texture = SKTexture(imageNamed: specialFunctionEnabled ? "\(pauseResetName)3" : (isPaused ? "\(pauseResetName)2" : pauseResetName))
        }
    }
    
    var isPaused: Bool = false {
        didSet {
            pauseResetButtonSprite.texture = SKTexture(imageNamed: isPaused ? "\(pauseResetName)2" : pauseResetName)
        }
    }
    
    weak var delegate: PauseResetEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        let settingsCorner: CGFloat = 20
        
        backgroundSprite = SKShapeNode(rectOf: settingsSize, cornerRadius: settingsCorner)
        backgroundSprite.strokeColor = .white
        backgroundSprite.lineWidth = 0
        backgroundSprite.setScale(0)
        backgroundSprite.alpha = 0.9
        backgroundSprite.zPosition = K.ZPosition.pauseScreen
        
        foregroundSprite = SKShapeNode(rectOf: settingsSize, cornerRadius: settingsCorner)
        foregroundSprite.position = CGPoint(x: 0, y: 0)
        foregroundSprite.fillColor = .clear
        foregroundSprite.strokeColor = .white
        foregroundSprite.lineWidth = 0
        foregroundSprite.setScale(1)
        
        // FIXME: - Temporary label
        comingSoonLabel = SKLabelNode(text: "")
        comingSoonLabel.numberOfLines = 0
        comingSoonLabel.preferredMaxLayoutWidth = settingsSize.width * 0.8
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
        
        pauseResetButtonSprite = SKSpriteNode(imageNamed: pauseResetName)
        pauseResetButtonSprite.scale(to: CGSize(width: pauseResetButtonSize, height: pauseResetButtonSize))
        pauseResetButtonSprite.anchorPoint = .zero
        pauseResetButtonSprite.name = pauseResetName
        pauseResetButtonSprite.zPosition = K.ZPosition.pauseButton
        
        settingsManager = SettingsManager(settingsWidth: settingsSize.width, buttonHeight: 120)
        quitConfirmSprite = ConfirmSprite(title: "RETURN TO TITLE SCREEN?",
                                      message: "Tap Quit Game to return to the main menu. Your progress will be saved.",
                                      confirm: "Quit Game",
                                      cancel: "Cancel")
        settingsPage = SettingsPage(contentSize: settingsSize)
        settingsPage.zPosition = 10
        howToPlayPage = HowToPlayPage(maskSize: settingsSize)
        howToPlayPage.zPosition = 10

        //Add'l setup/customization
        countdownLabel.position = CGPoint(x: pauseResetButtonPosition.x + pauseResetButtonSize / 2,
                                          y: pauseResetButtonPosition.y + pauseResetButtonSize * 1.5)
        pauseResetButtonSprite.position = pauseResetButtonPosition
        backgroundSprite.position = CGPoint(
            x: settingsScale * (settingsSize.width + GameboardSprite.padding) / 2 + GameboardSprite.xPosition + GameboardSprite.padding / 2,
            y: pauseResetButtonPosition.y)
        backgroundSprite.addShadow(rectOf: settingsSize, cornerRadius: settingsCorner, shadowOffset: 10, shadowColor: PauseResetEngine.backgroundShadowColor)

        settingsManager.setInitialPosition(CGPoint(x: -backgroundSprite.position.x, y: -settingsSize.height / 2))
        settingsManager.delegate = self
        quitConfirmSprite.delegate = self
                
        resetAll()
    }
    
    deinit {
        print("PauseResetEngine deinit")
    }
    
    
    // MARK: - Move Functions
    
    func moveSprites(to superScene: SKScene, level: Int) {
        self.superScene = superScene
        
        comingSoonLabel.removeFromParent()
        foregroundSprite.removeFromParent()
        settingsManager.removeFromParent()
        
        foregroundSprite.addChild(comingSoonLabel)
        backgroundSprite.addChild(foregroundSprite)
        backgroundSprite.addChild(settingsManager)

        superScene.addChild(backgroundSprite)
        superScene.addChild(pauseResetButtonSprite)
        superScene.addChild(countdownLabel)
        
        currentLevelLeaderboard = level
    }
    
    
    // MARK: - HelperFunctions
    
    private func resetAll() {
        resetInitial = Date()
        resetFinal = Date()
    }
    
    ///Feels like a clunky way of returning the bottom y-value of the settings content page. Needs to be halved depending on where the anchor point is set.
    private func getBottomOfSettings(halved: Bool = true) -> CGFloat {
        let divisor: CGFloat = halved ? 2 : 1
        let value: CGFloat = K.ScreenDimensions.topOfGameboard - settingsSize.height / divisor * settingsScale + GameboardSprite.padding

        return value
    }
    
    
    // MARK: - Touch Functions
    
    /**
     Helper function that checks that superScene has been set up, and that the tap occured within the settingsButton node name. Call this, then pass the touch function in the function parameter. Don't use for touchDown due to different parameter list.
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
                    quitConfirmSprite.didTapButton(in: location)
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
        guard isPressed else { return print("isPressed is false in PauseResetEngine!") }
        
        isPaused.toggle()
        
        
        
        
        
        
        
        
        
        
        
        
        

        // TODO: - Handle actual pause screen here.
        isAnimating = true
        
        if isPaused {
            backgroundSprite.run(SKAction.group([
                SKAction.moveTo(y: getBottomOfSettings(halved: true), duration: 0.2),
                SKAction.sequence([
                    SKAction.run { [unowned self] in
                        //These need to be here due to time of day feature.
                        backgroundSprite.fillColor = PauseResetEngine.backgroundColor
                        backgroundSprite.fillTexture = SKTexture(image: UIImage.skyGradientTexture)
                        backgroundSprite.updateShadowColor(PauseResetEngine.backgroundShadowColor)
                        
                        //Makes it easier if you tap here each time, trust me.
                        settingsManager.tap(settingsManager.button5, tapQuietly: true)
                        settingsManager.updateColors()
                    },
                    SKAction.scale(to: GameboardSprite.spriteScale, duration: 0.2),
                    SKAction.run {
                        self.backgroundSprite.showShadow(animationDuration: 0.1, completion: nil)
                    }
                ])
            ])) {
                self.isAnimating = false
            }
        }
        else {
            backgroundSprite.run(SKAction.group([
                SKAction.run {
                    self.backgroundSprite.hideShadow(animationDuration: 0.05, completion: nil)
                },
                SKAction.moveTo(y: self.pauseResetButtonPosition.y, duration: 0.2),
                SKAction.scale(to: 0, duration: 0.2)
            ])) {
                self.isAnimating = false
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
        pauseResetButtonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))

        if isPressed {
            Haptics.shared.addHapticFeedback(withStyle: .light)
        }
        
        //Prevents touch drag exit keeping it stuck on the refresh button.
        if !specialFunctionEnabled {
            pauseResetButtonSprite.texture = SKTexture(imageNamed: isPaused ? "\(pauseResetName)2" : "\(pauseResetName)")
        }

        isPressed = false
        resetFinal = Date()
        
        //Reset settings from touchDown animation
        countdownLabel.alpha = 0
        countdownLabel.setScale(1.0)
        countdownLabel.removeAllActions()
        countdownLabel.run(SKAction.rotate(toAngle: 0, duration: 0))

        pauseResetButtonSprite.removeAction(forKey: resetAnimationKey)
        
        settingsManager.button1.touchUp() //title
        settingsManager.button3.touchUp() //leaderboard
        quitConfirmSprite.touchUp()
        
        howToPlayPage.touchUp()
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

        guard quitConfirmSprite.parent == nil else {
            quitConfirmSprite.touchDown(in: location)
            return
        }
        
        for nodeTapped in superScene.nodes(at: location) {
            switch nodeTapped.name {
            case pauseResetName:
                handlePauseReset(resetCompletion: resetCompletion)
            case HowToPlayPage.nodeName:
                //limit touch to within the settings page boundary
                guard location.y >= getBottomOfSettings(halved: false) && location.y <= getBottomOfSettings(halved: false) + settingsSize.height * settingsScale else { break }

                howToPlayPage.touchDown(at: location)
            case SettingsPage.nodeName:
                settingsPage.touchDown(at: location)
            default:
                guard !isAnimating else { break }
                guard let node = nodeTapped as? SettingsButton else { break }

                settingsManager.tap(node)
            }
        } //end for
    } //end func touchDown
    
    func touchMove(in location: CGPoint?) {
        guard let superScene = superScene else { return }
        guard let location = location else { return }
        guard let howToPlayNode = superScene.nodes(at: location).filter({ $0.name == HowToPlayPage.nodeName }).first else { return }
        guard let howToPlayPage = howToPlayNode as? HowToPlayPage else { return }
        
        howToPlayPage.scrollNode(to: location)
    }
    
    
    private func handlePauseReset(resetCompletion: (() -> Void)?) {
        pauseResetButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
        
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
                pauseResetButtonSprite.texture = SKTexture(imageNamed: "\(pauseResetName)4")
                
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

            self.pauseResetButtonSprite.texture = SKTexture(imageNamed: "\(self.pauseResetName)")
            self.touchUp()
            
            resetCompletion?()
        }
        
        let sequenceAction = SKAction.sequence([
            repeatAction,
            completionAction
        ])
        
        pauseResetButtonSprite.run(sequenceAction, withKey: resetAnimationKey)
    }
    
    
}


// MARK: - SettingsManagerDelegate

extension PauseResetEngine: SettingsManagerDelegate {
    func didTapButton(_ node: SettingsButton) {
        switch node.type {
        case .button1: //title
            guard let superScene = superScene else { return print("superScene not set up. Unable to show title confirm!") }
                        
            quitConfirmSprite.animateShow { }
        
            superScene.addChild(quitConfirmSprite)
        case .button2: //purchase
            comingSoonLabel.text = "     PURCHASE\n(Coming Soon...)"
            comingSoonLabel.updateShadow()
            
            removePages()
        case .button3: //leaderboard
            guard let superScene = superScene else { return print("superScene not set up. Unable to show leaderboard!") }
            
            let activityIndicator = ActivityIndicatorSprite()
            activityIndicator.move(toParent: superScene)
            
            GameCenterManager.shared.showLeaderboard(level: currentLevelLeaderboard) {
                self.settingsManager.button3.touchUp()
                activityIndicator.removeFromParent()
            }
        case .button4: //howToPlay
            comingSoonLabel.text = ""
            comingSoonLabel.updateShadow()
            
            removePages()

            howToPlayPage.moveContentNode(to: 0, duration: 0)
            backgroundSprite.addChild(howToPlayPage)
        case .button5: //settings
            comingSoonLabel.text = ""
            comingSoonLabel.updateShadow()
            
            removePages()

            backgroundSprite.addChild(settingsPage)
        }
    }
    
    private func removePages() {
        howToPlayPage.removeFromParent()
        settingsPage.removeFromParent()
    }
}


// MARK: - ConfirmSpriteDelegate

extension PauseResetEngine: ConfirmSpriteDelegate {
    func didTapConfirm() {
        print("Confirm tapped")

        quitConfirmSprite.animateHide {
            self.quitConfirmSprite.removeFromParent()
            self.delegate?.confirmQuitTapped()
            
            self.isPaused = false
            self.isAnimating = false
            
            self.backgroundSprite.position.y = self.pauseResetButtonPosition.y
            self.backgroundSprite.setScale(0)
        }
    }
    
    func didTapCancel() {
        print("Cancel tapped")
        
        quitConfirmSprite.animateHide {
            self.quitConfirmSprite.removeFromParent()
        }
    }
}
