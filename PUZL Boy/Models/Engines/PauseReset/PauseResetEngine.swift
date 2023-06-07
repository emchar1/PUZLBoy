//
//  PauseResetEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/12/23.
//

import SpriteKit
import FirebaseAuth

protocol PauseResetEngineDelegate: AnyObject {
    func didTapPause(isPaused: Bool)
    func didTapReset()
    func didTapHint()
    
    func confirmQuitTapped()
    func didTapHowToPlay(_ tableView: HowToPlayTableView)
    func didCompletePurchase(_ currentButton: PurchaseTapButton)
}


class PauseResetEngine {
    
    // MARK: - Properties

    //Size Properties
    private let settingsSize = CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth * (UIDevice.isiPad ? 1.2 : 1.25))
    private let settingsScale: CGFloat = GameboardSprite.spriteScale

    //Pause, Reset, Hint Buttons
    private let pauseName = "settingsButton"
    private let resetName = "resetButton"
    private let hintName = "hintButton"
    private let pauseButtonSize: CGFloat = 180
    private var minorButtonSize: CGFloat { 2 / 3 * pauseButtonSize }
    private var pauseButtonPosition: CGPoint {
        CGPoint(x: settingsSize.width / 2, y: K.ScreenDimensions.bottomMargin)
    }
    private var minorButtonOffset: CGPoint {
        let spacing: CGFloat = UIDevice.isiPad ? 80 : 60
        
        return CGPoint(x: 0.5 * (pauseButtonSize + minorButtonSize) + spacing, y: 0.5 * (pauseButtonSize - minorButtonSize))
    }
    
    //SKNodes
    private var pauseButtonSprite: SKSpriteNode
    private var resetButtonSprite: SKSpriteNode
    private var hintButtonSprite: SKSpriteNode
    private var backgroundSprite: SKShapeNode
    private var superScene: SKScene?
    
    //Custom Objects
    private var settingsManager: SettingsManager
    private var quitConfirmSprite: ConfirmSprite
    private var howToPlayPage: HowToPlayPage
    private var purchasePage: PurchasePage
    private var settingsPage: SettingsPage

    //Misc Properties
    static var backgroundColor: UIColor { DayTheme.skyColor.top.analogous.first.darkenColor(factor: 6) }
    static var backgroundShadowColor: UIColor { DayTheme.skyColor.bottom.analogous.first }
    private var user: User?
    private var currentLevel: Int = 1
    
    //Boolean properties
    private var isPressed: Bool = false
    private var isAnimating: Bool = false
    private var isDisabled: Bool = false
    private(set) var isPaused: Bool = false

    weak var delegate: PauseResetEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(user: User?, level: Int) {
        let settingsCorner: CGFloat = 20
        
        self.user = user
        self.currentLevel = level
        
        backgroundSprite = SKShapeNode(rectOf: settingsSize, cornerRadius: settingsCorner)
        backgroundSprite.strokeColor = .white
        backgroundSprite.lineWidth = 0
        backgroundSprite.setScale(0)
        backgroundSprite.zPosition = K.ZPosition.pauseScreen
        
        pauseButtonSprite = SKSpriteNode(imageNamed: pauseName)
        pauseButtonSprite.scale(to: CGSize(width: pauseButtonSize, height: pauseButtonSize))
        pauseButtonSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        pauseButtonSprite.name = pauseName
        pauseButtonSprite.zPosition = K.ZPosition.pauseButton
        
        resetButtonSprite = SKSpriteNode(imageNamed: resetName)
        resetButtonSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        resetButtonSprite.name = resetName
        resetButtonSprite.zPosition = K.ZPosition.pauseButton - 5
        
        hintButtonSprite = SKSpriteNode(imageNamed: hintName)
        hintButtonSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        hintButtonSprite.name = hintName
        hintButtonSprite.zPosition = K.ZPosition.pauseButton - 5
        
        settingsManager = SettingsManager(settingsWidth: settingsSize.width, buttonHeight: 120)
        
        settingsPage = SettingsPage(user: user, contentSize: settingsSize)
        settingsPage.zPosition = 10
        
        howToPlayPage = HowToPlayPage(contentSize: settingsSize, level: currentLevel)
        howToPlayPage.zPosition = 10
        
        purchasePage = PurchasePage(contentSize: settingsSize)
        purchasePage.zPosition = 10
        
        quitConfirmSprite = ConfirmSprite(title: "RETURN HOME?",
                                          message: "Tap Quit Game to return to the main menu. Your progress will be saved.",
                                          confirm: "Quit Game",
                                          cancel: "Cancel")

        
        //Add'l setup/customization
        pauseButtonSprite.position = pauseButtonPosition
        resetButtonSprite.scale(to: CGSize(width: minorButtonSize, height: minorButtonSize))
        resetButtonSprite.position = pauseButtonPosition + CGPoint(x: -minorButtonOffset.x, y: minorButtonOffset.y)
        hintButtonSprite.scale(to: CGSize(width: minorButtonSize, height: minorButtonSize))
        hintButtonSprite.position = pauseButtonPosition + CGPoint(x: minorButtonOffset.x, y: minorButtonOffset.y)
        
        backgroundSprite.position = CGPoint(
            x: settingsScale * (settingsSize.width + GameboardSprite.padding) / 2 + GameboardSprite.xPosition + GameboardSprite.padding / 2,
            y: pauseButtonPosition.y)
        backgroundSprite.addShadow(rectOf: settingsSize, cornerRadius: settingsCorner, shadowOffset: 10, shadowColor: PauseResetEngine.backgroundShadowColor)

        settingsManager.setInitialPosition(CGPoint(x: -backgroundSprite.position.x, y: -settingsSize.height / 2))
        settingsManager.delegate = self
        quitConfirmSprite.delegate = self
        purchasePage.delegate = self
    }
    
    deinit {
        print("PauseResetEngine deinit")
    }
    
    
    // MARK: - Move Functions
    
    func moveSprites(to superScene: SKScene, level: Int) {
        self.superScene = superScene
        
        settingsManager.removeFromParent()
        
        backgroundSprite.addChild(settingsManager)
        superScene.addChild(backgroundSprite)
        superScene.addChild(pauseButtonSprite)
        superScene.addChild(resetButtonSprite)
        superScene.addChild(hintButtonSprite)
        
        currentLevel = level
    }
    
    
    // MARK: - Helper Functions
    
    func shouldDisable(_ disable: Bool) {
        isDisabled = disable
        
        if disable {
            pauseButtonSprite.texture = SKTexture(imageNamed: "\(pauseName)Disabled")
            resetButtonSprite.texture = SKTexture(imageNamed: "\(resetName)Disabled")
            hintButtonSprite.texture = SKTexture(imageNamed: "\(hintName)Disabled")
            
            guard !isPaused else { return }
            
            hideMinorButtons()
        }
        else {
            pauseButtonSprite.texture = SKTexture(imageNamed: pauseName)
            resetButtonSprite.texture = SKTexture(imageNamed: resetName)
            hintButtonSprite.texture = SKTexture(imageNamed: hintName)
            
            guard !isPaused else { return }

            showMinorButtons()
        }
    }
    
    ///Feels like a clunky way of returning the bottom y-value of the settings content page. Needs to be halved depending on where the anchor point is set.
    private func getBottomOfSettings() -> CGFloat {
        return K.ScreenDimensions.topOfGameboard - settingsSize.height / 2 * settingsScale + GameboardSprite.padding
    }
    
    private func showMinorButtons(duration: TimeInterval = 0.25) {
        resetButtonSprite.run(SKAction.group([
            SKAction.moveTo(x: pauseButtonPosition.x - minorButtonOffset.x, duration: duration),
            SKAction.fadeAlpha(to: 1, duration: duration)
        ]))
        
        hintButtonSprite.run(SKAction.group([
            SKAction.moveTo(x: pauseButtonPosition.x + minorButtonOffset.x, duration: duration),
            SKAction.fadeAlpha(to: 1, duration: duration)
        ]))
    }
    
    private func hideMinorButtons(duration: TimeInterval = 0.25) {
        resetButtonSprite.run(SKAction.group([
            SKAction.moveTo(x: pauseButtonPosition.x, duration: duration),
            SKAction.fadeAlpha(to: 0, duration: duration)
        ]))
        
        hintButtonSprite.run(SKAction.group([
            SKAction.moveTo(x: pauseButtonPosition.x, duration: duration),
            SKAction.fadeAlpha(to: 0, duration: duration)
        ]))
    }
    
    
    // MARK: - Table View Functions
    
    func registerHowToPlayTableView() {
        let topMargin: CGFloat = UIDevice.isiPad ? 80 : 40
        let bottomMargin: CGFloat = UIDevice.isiPad ? 30 : 50
        let rightMargin: CGFloat = UIDevice.isiPad ? -8 : 8
        
        howToPlayPage.tableView.register(HowToPlayTVCell.self, forCellReuseIdentifier: HowToPlayTVCell.reuseID)
        
        howToPlayPage.tableView.frame = CGRect(
            origin: CGPoint(x: HowToPlayPage.padding / K.ScreenDimensions.ratioSKtoUI + K.ScreenDimensions.lrMargin,
                            y: (K.ScreenDimensions.height - K.ScreenDimensions.topOfGameboard) / K.ScreenDimensions.ratioSKtoUI + topMargin),
            size: CGSize(width: settingsSize.width / K.ScreenDimensions.ratioSKtoUI * GameboardSprite.spriteScale - rightMargin,
                         height: settingsSize.height / K.ScreenDimensions.ratioSKtoUI * GameboardSprite.spriteScale - bottomMargin))
    }
        
    
    // MARK: - Touch Functions
    
    /**
     Helper function that checks that superScene has been set up, and that the tap occured within the settingsButton node name. Call this, then pass the touch function in the function parameter. Don't use for touchDown due to different parameter list.
     - parameters:
     - location: location of the touch
     - function: the passed in function to be executed once the node has ben found
     */
    func touch(for touches: Set<UITouch>, function: (Set<UITouch>) -> Void) {
        guard !isDisabled else { return }
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        for nodeTapped in superScene.nodes(at: location) {
            if nodeTapped.name == pauseName {
                function(touches)
            }
            else if nodeTapped is DecisionButtonSprite {
                quitConfirmSprite.didTapButton(in: location)
            }
            else if nodeTapped is PurchasePage {
                purchasePage.superScene = superScene
                purchasePage.touchNode(for: touches)
            }
            else if nodeTapped is SettingsPage {
                settingsPage.superScene = superScene
                settingsPage.touchNode(for: touches)
            }
            else {
                function(touches)
            }
        }
    }
    
    /**
     Handles the actual logic for when the user taps the button, i.e. opens the settings menu.
     */
    func handleControls(for touches: Set<UITouch>) {
        guard !isDisabled else { return }
        guard !isAnimating else { return }
        guard isPressed else { return }
        
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = touches.first?.location(in: superScene) else { return }

        for nodeTapped in superScene.nodes(at: location) {
            switch nodeTapped.name {
            case pauseName:
                openCloseSettings()
            case resetName:
                ButtonTap.shared.tap(type: .buttontap1)
                delegate?.didTapReset()
            case hintName:
                ButtonTap.shared.tap(type: .buttontap1)
                delegate?.didTapHint()
            default:
                break
            }
        }
    }
    
    private func openCloseSettings() {
        isPaused.toggle()
        
        isAnimating = true
        
        if isPaused {
            hideMinorButtons()
            
            backgroundSprite.run(SKAction.group([
                SKAction.moveTo(y: getBottomOfSettings(), duration: 0.25),
                SKAction.sequence([
                    SKAction.run { [unowned self] in
                        //These need to be here due to time of day feature.
                        backgroundSprite.fillColor = PauseResetEngine.backgroundColor
                        backgroundSprite.fillTexture = SKTexture(image: UIImage.skyGradientTexture)
                        backgroundSprite.updateShadowColor(PauseResetEngine.backgroundShadowColor)
                        
                        //Makes it easier if you tap here each time, trust me.
                        settingsManager.tap(settingsManager.button5, tapQuietly: true)
                        settingsManager.updateColors()
                        
                        settingsPage.updateColors()
                    },
                    SKAction.scale(to: GameboardSprite.spriteScale, duration: 0.25),
                    SKAction.run { [unowned self] in
                        backgroundSprite.showShadow(animationDuration: 0.1, completion: nil)
                    }
                ])
            ])) { [unowned self] in
                isAnimating = false
            }
            
            ButtonTap.shared.tap(type: .buttontap7)
        }
        else {
            howToPlayPage.tableView.removeFromSuperview()

            showMinorButtons()

            backgroundSprite.run(SKAction.group([
                SKAction.run { [unowned self] in
                    backgroundSprite.hideShadow(animationDuration: 0.05, completion: nil)
                },
                SKAction.moveTo(y: pauseButtonPosition.y, duration: 0.25),
                SKAction.scale(to: 0, duration: 0.25)
            ])) { [unowned self] in
                isAnimating = false
            }
            
            AudioManager.shared.playSound(for: "chatclose")
        }
        
        delegate?.didTapPause(isPaused: isPaused)
    }
    
    /**
     Handles when user lifts finger off the button. Pass this in the touch helper function because it doesn't contain any setup to handle location of the tap.
     */
    func touchUp() {
        guard !isDisabled else { return }
        
        pauseButtonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        resetButtonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        hintButtonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        
        if isPressed {
            Haptics.shared.addHapticFeedback(withStyle: .light)
        }
        
        isPressed = false
        
        settingsManager.button1.touchUp() //title
        settingsManager.button3.touchUp() //leaderboard
        quitConfirmSprite.touchUp()
        
        howToPlayPage.touchUp()
        settingsPage.touchUp()
        purchasePage.touchUp()
    }
    
    /**
     Handles when button is tapped down. Call this on it's own; don't use the touch() helper function.
     - parameters:
     - location: location of the tap
     - resetCompletion: if user has button held down for count of the resetThreshold, then the completion gets executed, otherwise it's short circuited in touchUp.
     */
    func touchDown(for touches: Set<UITouch>) {
        guard !isDisabled else { return }
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = touches.first?.location(in: superScene) else { return }
        guard quitConfirmSprite.parent == nil else {
            quitConfirmSprite.touchDown(in: location)
            return
        }
        
        for nodeTapped in superScene.nodes(at: location) {
            switch nodeTapped.name {
            case pauseName:
                guard !isAnimating else { break }
                
                isPressed = true

                pauseButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
                Haptics.shared.addHapticFeedback(withStyle: .light)
            case resetName:
                guard !isAnimating else { break }
                
                isPressed = true
                
                resetButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
                Haptics.shared.addHapticFeedback(withStyle: .light)
            case hintName:
                guard !isAnimating else { break }
                
                isPressed = true
                
                hintButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
                Haptics.shared.addHapticFeedback(withStyle: .light)
            case howToPlayPage.nodeName:
                howToPlayPage.superScene = superScene
                howToPlayPage.touchDown(for: touches)
            case purchasePage.nodeName:
                purchasePage.superScene = superScene
                purchasePage.touchDown(for: touches)
            case settingsPage.nodeName:
                settingsPage.superScene = superScene
                settingsPage.touchDown(for: touches)
            default:
                guard !isAnimating else { break }
                guard let node = nodeTapped as? SettingsButton else { break }

                settingsManager.tap(node)
            }
        } //end for
    } //end func touchDown
    
}


// MARK: - SettingsManagerDelegate

extension PauseResetEngine: SettingsManagerDelegate {
    func didTapButton(_ node: SettingsButton) {
        switch node.type {
        case .button1: //title
            guard let superScene = superScene else { return print("superScene not set up. Unable to show title confirm!") }
            
            howToPlayPage.tableView.removeFromSuperview()
                        
            quitConfirmSprite.animateShow { }
        
            superScene.addChild(quitConfirmSprite)
        case .button2: //purchase
            removePages()
            
            backgroundSprite.addChild(purchasePage)
        case .button3: //leaderboard
            guard let superScene = superScene else { return print("superScene not set up. Unable to show leaderboard!") }
            
            let activityIndicator = ActivityIndicatorSprite()
            activityIndicator.move(toParent: superScene)
            
            howToPlayPage.tableView.removeFromSuperview()
            
            GameCenterManager.shared.showLeaderboard(level: currentLevel) { [unowned self] in
                settingsManager.button3.touchUp()
                activityIndicator.removeFromParent()
                
                if settingsManager.currentButtonPressed?.type == settingsManager.button4.type {
                    delegate?.didTapHowToPlay(howToPlayPage.tableView)
                }
            }
        case .button4: //howToPlay
            removePages()

            backgroundSprite.addChild(howToPlayPage)
            
            howToPlayPage.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            howToPlayPage.tableView.flashScrollIndicators()
            
            delegate?.didTapHowToPlay(howToPlayPage.tableView)
        case .button5: //settings
            removePages()

            backgroundSprite.addChild(settingsPage)
        }
    }
    
    private func removePages() {
        howToPlayPage.removeFromParent()
        purchasePage.removeFromParent()
        settingsPage.removeFromParent()
        howToPlayPage.tableView.removeFromSuperview()
    }
}


// MARK: - ConfirmSpriteDelegate

extension PauseResetEngine: ConfirmSpriteDelegate {
    func didTapConfirm(_ confirmSprite: ConfirmSprite) {
        quitConfirmSprite.animateHide { [unowned self] in
            showMinorButtons(duration: 0)

            quitConfirmSprite.removeFromParent()
            delegate?.confirmQuitTapped()
            
            isPaused = false
            isAnimating = false
            
            backgroundSprite.position.y = pauseButtonPosition.y
            backgroundSprite.setScale(0)
        }
    }
    
    func didTapCancel(_ confirmSprite: ConfirmSprite) {
        quitConfirmSprite.animateHide { [unowned self] in
            quitConfirmSprite.removeFromParent()

            if settingsManager.currentButtonPressed?.type == settingsManager.button4.type {
                delegate?.didTapHowToPlay(howToPlayPage.tableView)
            }
        }
    }
}


// MARK: - PurchasePageDelegate

extension PauseResetEngine: PurchasePageDelegate {
    func purchaseCompleted(_ currentButton: PurchaseTapButton) {
        //This seems hokey, but it works...
        isAnimating = false
        isPressed = true

        shouldDisable(false)
        openCloseSettings()

        isPressed = false
        
        delegate?.didCompletePurchase(currentButton)
    }
    
    func purchaseFailed() {
        shouldDisable(false)
    }
    
    func purchaseDidTap() {
        shouldDisable(true)
    }
}
