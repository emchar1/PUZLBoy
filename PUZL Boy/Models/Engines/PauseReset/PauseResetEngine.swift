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
    func didTapLeaderboards(_ tableView: LeaderboardsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: Bool)
    func didTapAchievements(_ tableView: AchievementsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: Bool)
    func didCompletePurchase(_ currentButton: PurchaseTapButton)
}


class PauseResetEngine {
    
    // MARK: - Properties
    
    //Unlock Minor Buttons
    static let resetButtonUnlock: Int = 100
    static let hintButtonUnlock: Int = 140

    //Size Properties
    private let settingsScale: CGFloat = UIDevice.spriteScale
    private var settingsManagerButtonHeight: CGFloat { 120 / settingsScale }
    private var settingsSize: CGSize {
        let spacing: CGFloat = 60
        
        return CGSize(width: K.ScreenDimensions.size.width,
                      height: ((K.ScreenDimensions.topOfGameboard - pauseButtonPosition.y - pauseButtonSize) / settingsScale) - settingsManagerButtonHeight - spacing)
    }

    //Pause, Reset, Hint Buttons
    private var niteModifier: String { DayTheme.currentTheme == .dawn || DayTheme.currentTheme == .night ? "NITE" : "" }
    private let pauseName = "settingsButton"
    private let resetName = "resetButton"
    private let hintName = "hintButton"
    private let discoName = "discoball"
    private let pauseButtonSize: CGFloat = 180
    private var minorButtonSize: CGFloat { 2 / 3 * pauseButtonSize }
    private var pauseButtonPosition: CGPoint {
        CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.bottomMargin)
    }
    private var minorButtonOffset: CGPoint {
        let spacing: CGFloat = 60 / settingsScale
        
        return CGPoint(x: 0.5 * (pauseButtonSize + minorButtonSize) + spacing, y: 0.5 * (pauseButtonSize - minorButtonSize))
    }
    
    //SKNodes
    private var pauseButtonSprite: SKSpriteNode!
    private var resetButtonSprite: SKSpriteNode!
    private var hintButtonSprite: SKSpriteNode!
    private var hintBadgeSprite: SKShapeNode!
    private var hintCountLabel: SKLabelNode!
    private var backgroundSprite: SKShapeNode!
    private var superScene: SKScene?
    
    //Custom Objects
    private var settingsManager: SettingsManager!
    private var quitConfirmSprite: ConfirmSprite!
    private var leaderboardsPage: LeaderboardsPage!
    private var howToPlayPage: HowToPlayPage!
    private var purchasePage: PurchasePage!
    private var settingsPage: SettingsPage!

    //Misc Properties
    static var backgroundColor: UIColor { DayTheme.skyColor.top.analogous.first.darkenColor(factor: 6) }
    static var backgroundShadowColor: UIColor { DayTheme.skyColor.bottom.analogous.first }
    private var currentLevel: Int = 1
    
    //Boolean properties
    private(set) static var pauseResetEngineIsPaused = false
    private(set) static var currentTab: SettingsButton.SettingsButtonType? = nil
    private var isPressed: Bool = false
    private var isAnimating: Bool = false
    private var isDisabled: Bool = false
    private var isHintButtonDisabled: Bool = !((FIRManager.saveStateModel?.hintAvailable ?? true) && HintEngine.hintCount > 0)
    private var isPaused: Bool = false {
        didSet {
            PauseResetEngine.pauseResetEngineIsPaused = isPaused
        }
    }
    
    enum MinorButton {
        case reset, hint
    }

    weak var delegate: PauseResetEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(level: Int) {
        self.currentLevel = level
        
        setupSprites()
    }
    
    deinit {
        print("PauseResetEngine deinit")
    }
    
    private func setupSprites() {
        let settingsCorner: CGFloat = 20
        
        backgroundSprite = SKShapeNode(rectOf: settingsSize, cornerRadius: settingsCorner)
        backgroundSprite.position = CGPoint(
            x: settingsScale * (settingsSize.width + GameboardSprite.padding) / 2 + GameboardSprite.offsetPosition.x + GameboardSprite.padding / 2,
            y: pauseButtonPosition.y)
        backgroundSprite.strokeColor = .white
        backgroundSprite.lineWidth = 0
        backgroundSprite.setScale(0)
        backgroundSprite.zPosition = K.ZPosition.pauseScreen
        backgroundSprite.addShadow(rectOf: settingsSize, cornerRadius: settingsCorner, shadowOffset: 10, shadowColor: PauseResetEngine.backgroundShadowColor)
        
        //The 3 Buttons
        pauseButtonSprite = SKSpriteNode(imageNamed: pauseName + niteModifier)
        pauseButtonSprite.position = pauseButtonPosition
        pauseButtonSprite.scale(to: CGSize(width: pauseButtonSize, height: pauseButtonSize))
        pauseButtonSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        pauseButtonSprite.name = pauseName
        pauseButtonSprite.zPosition = K.ZPosition.pauseButton
        
        resetButtonSprite = SKSpriteNode(imageNamed: resetName + niteModifier)
        resetButtonSprite.position = pauseButtonPosition + CGPoint(x: -minorButtonOffset.x, y: minorButtonOffset.y)
        resetButtonSprite.scale(to: CGSize(width: minorButtonSize, height: minorButtonSize))
        resetButtonSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        resetButtonSprite.alpha = currentLevel >= PauseResetEngine.resetButtonUnlock ? 1 : 0
        resetButtonSprite.name = resetName
        resetButtonSprite.zPosition = K.ZPosition.pauseButton - 5
        
        hintButtonSprite = SKSpriteNode(imageNamed: getHintButtonImageName())
        hintButtonSprite.position = pauseButtonPosition + CGPoint(x: minorButtonOffset.x, y: minorButtonOffset.y)
        hintButtonSprite.scale(to: CGSize(width: minorButtonSize, height: minorButtonSize))
        hintButtonSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        hintButtonSprite.alpha = currentLevel >= PauseResetEngine.hintButtonUnlock ? 1 : 0
        hintButtonSprite.name = hintName
        hintButtonSprite.zPosition = K.ZPosition.pauseButton - 5
        
        hintBadgeSprite = SKShapeNode() //will get properly set up in updateHintBadgeAndCount()
        
        hintCountLabel = SKLabelNode(text: "\(HintEngine.hintCount)")
        hintCountLabel.fontName = "HelveticaNeue-Bold"
        hintCountLabel.fontColor = UIFont.chatFontColor
        hintCountLabel.fontSize = UIFont.chatFontSizeSmall
        hintCountLabel.horizontalAlignmentMode = .center
        hintCountLabel.verticalAlignmentMode = .center
        hintCountLabel.zPosition = 10
        
        //Settings Manager
        settingsManager = SettingsManager(settingsWidth: settingsSize.width, buttonHeight: settingsManagerButtonHeight)
        settingsManager.setInitialPosition(CGPoint(x: -backgroundSprite.position.x, y: -settingsSize.height / 2))
        settingsManager.delegate = self

        settingsPage = SettingsPage(contentSize: settingsSize)
        settingsPage.zPosition = 10
        
        leaderboardsPage = LeaderboardsPage(contentSize: settingsSize, leaderboardType: .level, currentLevel: currentLevel)
        leaderboardsPage.zPosition = 10
        
        howToPlayPage = HowToPlayPage(contentSize: settingsSize, level: currentLevel)
        howToPlayPage.zPosition = 10
        
        purchasePage = PurchasePage(contentSize: settingsSize, currentLevel: currentLevel)
        purchasePage.zPosition = 10
        purchasePage.delegate = self

        quitConfirmSprite = ConfirmSprite(title: "RETURN HOME?",
                                          message: "Tap Quit Game to return to the main menu. Your progress will be saved.",
                                          confirm: "Quit Game",
                                          cancel: "Cancel")
        quitConfirmSprite.delegate = self
    }
    
    
    // MARK: - Move Functions
    
    func moveSprites(to superScene: SKScene, level: Int) {
        self.superScene = superScene
        
        //Need to remove from parent, otherwise app crashes because it tries to add the node to the parent again.
        settingsManager.removeFromParent()
        
        backgroundSprite.addChild(settingsManager)
        superScene.addChild(backgroundSprite)
        superScene.addChild(pauseButtonSprite)
        superScene.addChild(resetButtonSprite)
        superScene.addChild(hintButtonSprite)
        updateHintBadgeAndCount()
        
        currentLevel = level
        
        if Level.isPartyLevel(currentLevel) {
            pauseButtonSprite.texture = SKTexture(imageNamed: discoName)
            pauseButtonSprite.run(SKAction.colorize(with: .black,
                                                    colorBlendFactor: !UserDefaults.standard.bool(forKey: K.UserDefaults.disableLights) ? 0 : 0.52,
                                                    duration: 0))
            hideMinorButtons()
        }
        else {
            pauseButtonSprite.texture = SKTexture(imageNamed: pauseName + niteModifier)
            pauseButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0, duration: 0))
            resetButtonSprite.texture = SKTexture(imageNamed: resetName + niteModifier)
            showMinorButtons()
        }
    }
    
    
    // MARK: - Helper Functions
    
    func shouldDisable(_ disable: Bool) {
        isDisabled = disable
        
        if disable {
            pauseButtonSprite.texture = SKTexture(imageNamed: Level.isPartyLevel(currentLevel) ? "\(discoName)Disabled" : "\(pauseName)Disabled")
            resetButtonSprite.texture = SKTexture(imageNamed: "\(resetName)Disabled")
            hintButtonSprite.texture = SKTexture(imageNamed: "\(hintName)Disabled")
            
            pauseButtonSprite.alpha = 0.5

            guard !isPaused else { return }
            
            hideMinorButtons()
        }
        else {
            pauseButtonSprite.texture = SKTexture(imageNamed: Level.isPartyLevel(currentLevel) ? discoName : pauseName + niteModifier)
            resetButtonSprite.texture = SKTexture(imageNamed: resetName + niteModifier)
            hintButtonSprite.texture = SKTexture(imageNamed: getHintButtonImageName())
            
            pauseButtonSprite.alpha = 1.0

            guard !isPaused else { return }
            guard !Level.isPartyLevel(currentLevel) else { return }

            showMinorButtons()
        }
    }
    
    func shouldDisableHintButton(_ disable: Bool) {
        isHintButtonDisabled = disable
        
        hintButtonSprite.texture = SKTexture(imageNamed: getHintButtonImageName())
    }
    
    func updateHintBadgeAndCount() {
        hintCountLabel.text = HintEngine.hintCount > 99 ? "99+" : "\(HintEngine.hintCount)"
        
        hintBadgeSprite.removeFromParent()
        hintCountLabel.removeFromParent()
        
        hintBadgeSprite = SKShapeNode(rectOf: CGSize(width: 60 + 20 * (hintCountLabel.text!.count - 1), height: 60), cornerRadius: 30)
        hintBadgeSprite.position = CGPoint(x: hintButtonSprite.frame.width / 2, y: hintButtonSprite.frame.height)
        hintBadgeSprite.fillColor = .red
        hintBadgeSprite.lineWidth = 0
        hintBadgeSprite.zPosition = 10

        hintButtonSprite.addChild(hintBadgeSprite)
        hintBadgeSprite.addChild(hintCountLabel)
    }
    
    func flashMinorButton(for button: MinorButton) {
        let buttonNode: SKSpriteNode
        let offsetMultiplier: CGFloat
        
        switch button {
        case .reset:    
            buttonNode = resetButtonSprite
            buttonNode.texture = SKTexture(imageNamed: resetName + niteModifier)
            offsetMultiplier = -1
        case .hint:
            buttonNode = hintButtonSprite
            buttonNode.texture = SKTexture(imageNamed: hintName + niteModifier)
            offsetMultiplier = 1
        }
        
        buttonNode.run(SKAction.group([
            SKAction.moveTo(x: pauseButtonPosition.x + offsetMultiplier * minorButtonOffset.x, duration: 0),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0),
                SKAction.wait(forDuration: 0.5),
                SKAction.fadeOut(withDuration: 0.5)
            ]))
        ]))
    }
    
    func unflashMinorButton(for button: MinorButton) {
        let buttonNode: SKSpriteNode
        let nodeName: String
        
        switch button {
        case .reset:        
            buttonNode = resetButtonSprite
            nodeName = resetName
        case .hint:
            buttonNode = hintButtonSprite
            nodeName = hintName
        }
        
        buttonNode.removeAllActions()
        
        buttonNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.moveTo(x: pauseButtonPosition.x, duration: 0),
            SKAction.setTexture(SKTexture(imageNamed: nodeName + "Disabled"))
        ]))
    }
    
    func hideDiscoball() {
        pauseButtonSprite.run(SKAction.fadeOut(withDuration: 1))
    }
    
    private func getHintButtonImageName() -> String {
        return hintName + (isHintButtonDisabled ? "Disabled" : niteModifier)
    }
        
    ///Feels like a clunky way of returning the bottom y-value of the settings content page. Needs to be halved depending on where the anchor point is set.
    private func getBottomOfSettings() -> CGFloat {
        return K.ScreenDimensions.topOfGameboard - settingsSize.height / 2 * settingsScale + GameboardSprite.padding
    }
    
    private func showMinorButtons(duration: TimeInterval = 0.25) {
        resetButtonSprite.run(SKAction.group([
            SKAction.moveTo(x: pauseButtonPosition.x - minorButtonOffset.x, duration: duration),
            SKAction.fadeAlpha(to: currentLevel >= PauseResetEngine.resetButtonUnlock ? 1 : 0, duration: duration)
        ]))
        
        hintButtonSprite.run(SKAction.group([
            SKAction.moveTo(x: pauseButtonPosition.x + minorButtonOffset.x, duration: duration),
            SKAction.fadeAlpha(to: currentLevel >= PauseResetEngine.hintButtonUnlock ? 1 : 0, duration: duration)
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
        howToPlayPage.tableView.register(HowToPlayTVCell.self, forCellReuseIdentifier: HowToPlayTVCell.reuseID)
        howToPlayPage.tableView.frame = getTableViewFrame(hasTableViewHeaders: false)
    }
    
    func registerLeaderboardsTableView() {
        leaderboardsPage.leaderboardsTableView.register(LeaderboardsTVCell.self, forCellReuseIdentifier: LeaderboardsTVCell.reuseID)
        leaderboardsPage.leaderboardsTableView.frame = getTableViewFrame(hasTableViewHeaders: true)
    }
    
    func registerAchievementsTableView() {
        leaderboardsPage.achievementsTableView.register(AchievementsTVCell.self, forCellReuseIdentifier: AchievementsTVCell.reuseID)
        leaderboardsPage.achievementsTableView.frame = getTableViewFrame(hasTableViewHeaders: false)
    }
    
    private func getTableViewFrame(hasTableViewHeaders: Bool) -> CGRect {
        let tableViewPadding: CGFloat = UIDevice.isiPad ? 8 : 4
        let topBottomMargin: CGFloat = (leaderboardsPage.titleLabel.frame.height + UIDevice.modelInfo.ratio * ParentPage.padding + (hasTableViewHeaders ? leaderboardsPage.headerBackgroundNode.frame.height : 0)) / K.ScreenDimensions.ratioSKtoUI
                
        let tableViewOrigin = CGPoint(
            x: (backgroundSprite.position.x - settingsScale * settingsSize.width / 2) / K.ScreenDimensions.ratioSKtoUI + tableViewPadding,
            y: (K.ScreenDimensions.size.height - K.ScreenDimensions.topOfGameboard - GameboardSprite.padding) / K.ScreenDimensions.ratioSKtoUI + tableViewPadding + topBottomMargin
        )
        
        let tableViewSize = CGSize(
            width: (settingsScale * settingsSize.width) / K.ScreenDimensions.ratioSKtoUI - 2 * tableViewPadding,
            height: (settingsScale * settingsSize.height) / K.ScreenDimensions.ratioSKtoUI - 2 * tableViewPadding - topBottomMargin
        )
        
        return CGRect(origin: tableViewOrigin, size: tableViewSize)
    }
    
    
    // MARK: - Touch Functions
    
    /**
     Helper function that checks that superScene has been set up, and that the tap occured within the settingsButton node name. Call this, then pass the touch function in the function parameter. Don't use for touchDown due to different parameter list.
     - parameters:
     - location: location of the touch
     - function: the passed in function to be executed once the node has ben found
     */
    func touchHandler(for touches: Set<UITouch>) {
        guard !isDisabled else { return }
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        for nodeTapped in superScene.nodes(at: location) {
            if nodeTapped.name == pauseName
                || nodeTapped.name == resetName
                || nodeTapped.name == hintName
                || nodeTapped is SettingsRadioNode
                || nodeTapped is SettingsTapButton {
                
                handleControls(for: touches)
            }
            else if nodeTapped is DecisionButtonSprite {
                quitConfirmSprite.didTapButton(in: location)
            }
            else if nodeTapped is LeaderboardsPage {
                leaderboardsPage.superScene = superScene
                leaderboardsPage.touchNode(for: touches)
            }
            else if nodeTapped is PurchasePage {
                purchasePage.superScene = superScene
                purchasePage.touchNode(for: touches)
            }
            else if nodeTapped is SettingsPage {
                settingsPage.superScene = superScene
                settingsPage.touchNode(for: touches)
            }
        }
    }
    
    /**
     Handles the actual logic for when the user taps the button, i.e. opens the settings menu.
     */
    private func handleControls(for touches: Set<UITouch>) {
        guard !isDisabled else { return }
        guard !isAnimating else { return }
        guard isPressed else { return }
        
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = touches.first?.location(in: superScene) else { return }

        for nodeTapped in superScene.nodes(at: location) {
            switch nodeTapped.name {
            case pauseName:
                if Level.isPartyLevel(currentLevel) {
                    tapDiscoBall()
                }
                else {
                    openCloseSettings()
                }
            case resetName:
                ButtonTap.shared.tap(type: .buttontap1)
                delegate?.didTapReset()
            case hintName:
                guard !isHintButtonDisabled else { break }
                
                ButtonTap.shared.tap(type: .buttontap1)
                delegate?.didTapHint()
            default:
                break
            }
        }
    }
    
    private func tapDiscoBall() {
        guard isPressed else { return }
        guard !isAnimating else { return }
        
        isPressed = false
        isAnimating = true
        
        let partyLightsOn = !UserDefaults.standard.bool(forKey: K.UserDefaults.disableLights)
        let buttonAnimation: TimeInterval = 0.5
                
        UserDefaults.standard.set(partyLightsOn, forKey: K.UserDefaults.disableLights)

        if partyLightsOn {
            PartyModeSprite.shared.removeLights(duration: buttonAnimation)
            ButtonTap.shared.tap(type: .lightsoff)
            pauseButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.52, duration: buttonAnimation)) { [unowned self] in
                isAnimating = false
            }
        }
        else {
            PartyModeSprite.shared.addLights(duration: buttonAnimation)
            ButtonTap.shared.tap(type: .lightson)
            pauseButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0, duration: buttonAnimation)) { [unowned self] in
                isAnimating = false
            }
        }

        AudioManager.shared.updateVolumes()
    }
    
    private func openCloseSettings() {
        let duration: TimeInterval = 0.25

        isPaused.toggle()
        isAnimating = true
        
        if isPaused {
            hideMinorButtons()
            
            //These need to be here due to time of day feature.
            backgroundSprite.fillColor = PauseResetEngine.backgroundColor
            backgroundSprite.fillTexture = SKTexture(image: DayTheme.getSkyImage())
            
            backgroundSprite.updateShadowColor(PauseResetEngine.backgroundShadowColor)
            backgroundSprite.showShadow(animationDuration: 0.1, delay: duration)

            backgroundSprite.run(SKAction.group([
                SKAction.moveTo(y: getBottomOfSettings(), duration: duration),
                SKAction.scale(to: settingsScale, duration: duration)
            ])) { [unowned self] in
                isAnimating = false
            }
            
            settingsManager.tap(settingsManager.button5, tapQuietly: true, completion: nil)
            settingsManager.updateColors()
            settingsPage.updateRadioNodes()
            settingsPage.updateColors()
            settingsPage.checkReportBugAlreadySubmitted()
            
            ButtonTap.shared.tap(type: .buttontap7)
        }
        else { // PauseResetEngine closed, resuming game...
            howToPlayPage.tableView.removeFromSuperview()
            leaderboardsPage.leaderboardsTableView.removeFromSuperview()
            leaderboardsPage.achievementsTableView.removeFromSuperview()
            leaderboardsPage.removeHeaderBackgroundNode()
            NotificationCenter.default.post(name: .shouldCancelLoadingLeaderboards, object: nil)

            if !Level.isPartyLevel(currentLevel) {
                showMinorButtons()
            }

            backgroundSprite.hideShadow(animationDuration: 0.05)
            
            backgroundSprite.run(SKAction.group([
                SKAction.moveTo(y: pauseButtonPosition.y, duration: duration),
                SKAction.scale(to: 0, duration: duration)
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
        
        pauseButtonSprite.run(SKAction.colorize(withColorBlendFactor: Level.isPartyLevel(currentLevel) ? (!UserDefaults.standard.bool(forKey: K.UserDefaults.disableLights) ? 0 : 0.52) : 0, duration: 0))
        resetButtonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        hintButtonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        
        if isPressed {
            Haptics.shared.addHapticFeedback(withStyle: .soft)
        }
        
        isPressed = false
        
        settingsManager.button1.touchUp(completion: nil) //title
        quitConfirmSprite.touchUp()
        
        leaderboardsPage.touchUp()
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
        guard !isAnimating else { return }
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = touches.first?.location(in: superScene) else { return }
        guard quitConfirmSprite.parent == nil else {
            quitConfirmSprite.touchDown(in: location)
            return
        }
        
        for nodeTapped in superScene.nodes(at: location) {
            switch nodeTapped.name {
            case pauseName:
                isPressed = true

                pauseButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
                Haptics.shared.addHapticFeedback(withStyle: .soft)
            case resetName:
                isPressed = true
                
                resetButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
                Haptics.shared.addHapticFeedback(withStyle: .soft)
            case hintName:
                guard !isHintButtonDisabled else { break }
                
                isPressed = true
                
                hintButtonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
                Haptics.shared.addHapticFeedback(withStyle: .soft)
            case leaderboardsPage.nodeName:
                leaderboardsPage.superScene = superScene
                leaderboardsPage.touchDown(for: touches)
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
                guard let node = nodeTapped as? SettingsButton else { break }
                guard !Level.isPartyLevel(currentLevel) || (node.type != .button1 && node.type != .button2 && node.type != .button3 && node.type != .button4) else {
                    ButtonTap.shared.tap(type: .buttontap6)
                    return
                }
                
                isAnimating = true
                
                settingsManager.tap(node) { [unowned self] in
                    isAnimating = false
                }
                
                PauseResetEngine.currentTab = settingsManager.currentButtonPressed?.type
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
            guard settingsManager.currentButtonPressed?.type != settingsManager.button3.type || !leaderboardsPage.tableViewIsLoading else { 
                isAnimating = false //NEED THIS HERE OR PAUSE SCREEN CAN HANG IF LEADERBOARD IS LOADING AND HOME BUTTON IS PRESSED!
                return
            }
            
            howToPlayPage.tableView.removeFromSuperview()
            leaderboardsPage.leaderboardsTableView.removeFromSuperview()
            leaderboardsPage.achievementsTableView.removeFromSuperview()
            
            //Don't need these because we're just hiding the table views temporarily; may restore if user taps Cancel.
//            leaderboardsPage.removeHeaderBackgroundNode()
//            NotificationCenter.default.post(name: .shouldCancelLoadingLeaderboards, object: nil)

            quitConfirmSprite.animateShow { [unowned self] in
                isAnimating = false
            }
        
            superScene.addChild(quitConfirmSprite)
        case .button2: //purchase
            removePages()
            
            purchasePage.checkWatchAdButtonIsDisabled()
            purchasePage.checkBuyHintsAvailable(level: currentLevel)
            backgroundSprite.addChild(purchasePage)
        case .button3: //leaderboard
            removePages()
            
            //Preserve tableViews so they don't load EVERY time.
            if leaderboardsPage.leaderboardType != .achievements && leaderboardsPage.leaderboardsTableViewHasLoaded && currentLevel == leaderboardsPage.maxLevel {

                leaderboardsPage.addHeaderBackgroundNode()
                delegate?.didTapLeaderboards(leaderboardsPage.leaderboardsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: true)
            }
            else if leaderboardsPage.leaderboardType == .achievements && leaderboardsPage.achievementsTableViewHasLoaded && currentLevel == leaderboardsPage.maxLevel {

                delegate?.didTapAchievements(leaderboardsPage.achievementsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: true)
            }
            else {
                leaderboardsPage.updateValues(type: .level, level: currentLevel)
                leaderboardsPage.prepareTableView()
                
                GameCenterManager.shared.loadScores(leaderboardType: leaderboardsPage.leaderboardType, level: currentLevel) { [weak self] scores in
                    guard let self = self else { return }

                    leaderboardsPage.didLoadTableView(scores: scores)
                    
                    delegate?.didTapLeaderboards(leaderboardsPage.leaderboardsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: false)
                    delegate?.didTapAchievements(leaderboardsPage.achievementsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: false)
                }
            }
            
            backgroundSprite.addChild(leaderboardsPage)
        case .button4: //howToPlay
            removePages()

            backgroundSprite.addChild(howToPlayPage)
            
            howToPlayPage.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            howToPlayPage.tableView.flashScrollIndicators()
            
            delegate?.didTapHowToPlay(howToPlayPage.tableView)
        case .button5: //settings
            removePages()

            backgroundSprite.addChild(settingsPage)
            settingsPage.checkReportBugAlreadySubmitted()
        }
    }
    
    private func removePages() {
        leaderboardsPage.removeFromParent()
        howToPlayPage.removeFromParent()
        purchasePage.removeFromParent()
        settingsPage.removeFromParent()
        howToPlayPage.tableView.removeFromSuperview()
        leaderboardsPage.leaderboardsTableView.removeFromSuperview()
        leaderboardsPage.achievementsTableView.removeFromSuperview()
        leaderboardsPage.removeHeaderBackgroundNode()
        NotificationCenter.default.post(name: .shouldCancelLoadingLeaderboards, object: nil)
    }
}


// MARK: - ConfirmSpriteDelegate

extension PauseResetEngine: ConfirmSpriteDelegate {
    func didTapConfirm(_ confirmSprite: ConfirmSprite) {
        quitConfirmSprite.animateHide { [unowned self] in
            showMinorButtons(duration: 0)
            
            isPaused = false
            isAnimating = false
            
            backgroundSprite.position.y = pauseButtonPosition.y
            backgroundSprite.setScale(0)

            delegate?.confirmQuitTapped()
        }
    }
    
    func didTapCancel(_ confirmSprite: ConfirmSprite) {
        quitConfirmSprite.animateHide { [unowned self] in
            if settingsManager.currentButtonPressed?.type == settingsManager.button4.type {
                delegate?.didTapHowToPlay(howToPlayPage.tableView)
            }
            else if settingsManager.currentButtonPressed?.type == settingsManager.button3.type {
                delegate?.didTapLeaderboards(leaderboardsPage.leaderboardsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: true)
                delegate?.didTapAchievements(leaderboardsPage.achievementsTableView, ignoreShouldCancelLoadingLeaderboardsObserver: true)
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
