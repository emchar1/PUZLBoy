//
//  TitleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/31/23.
//

import SpriteKit
import FirebaseAuth

protocol TitleSceneDelegate: AnyObject {
    func didTapStart(levelSelectNewLevel: Int?)
    func didTapLevelSelect()
    func didTapCredits()
}

class TitleScene: SKScene {
    
    // MARK: - Properties

    //Sprites
    private var player: Player!
    private var playerPossibleRuin: Player!
    private var skyNode: SKSpriteNode!
    private var fadeSprite: SKSpriteNode!
    private var fadeOutSprite: SKSpriteNode!
    private var tapPointerEngine: TapPointerEngine!

    //Title Properties
    private var puzlTitle: SKLabelNode!
    private var boyTitle: SKLabelNode!
    
    //Menu Properties
    private var menuStart: MenuItemLabel!
    private var menuLevelSelect: MenuItemLabel!
    private var menuSettings: MenuItemLabel!
    private var menuCredits: MenuItemLabel!
    private var menuBackground: SKShapeNode!
    private var menuBackgroundText: SKShapeNode!
    private var levelSelectBackground: SKShapeNode!
    private var levelSelectPage: LevelSelectPage!
    private var levelSelectPicker: LevelSelectPicker!
    private var settingsBackground: SKShapeNode!
    private var settingsPage: SettingsPage!
    private var closeButton: CloseButtonSprite!

    //Misc.
    private var myColors: (title: UIColor, background: UIColor, shadow: UIColor) = (.black, .black, .black)
    private let shadowDepth: CGFloat = 10
    private var screenSize: CGSize
    private var shouldInitializeAsHero: Bool
    private var disableInput: Bool = false
    private var menuSizeShort: CGSize { CGSize(width: 650, height: 540) }
    private var menuSizeTall: CGSize { CGSize(width: 650, height: 680) }
    private var menuSizeStartOnly: CGSize { CGSize(width: 650, height: 275) }
    private var menuSize: CGSize {
        let saveStateModelNewLevel = FIRManager.saveStateModel?.newLevel ?? 0
        
        if UserDefaults.standard.bool(forKey: K.UserDefaults.hasPlayedBefore) || saveStateModelNewLevel > 0 {
            return isGameCompleted ? menuSizeTall : menuSizeShort
        }
        else {
            return menuSizeStartOnly
        }
    }
    private var levelSelectSize: CGSize { CGSize(width: 650, height: screenSize.height / 4) / UIDevice.spriteScale }
    private var settingsSize: CGSize { CGSize(width: screenSize.width, height: screenSize.width * 5 / 4) }
    private var currentMenuSelected: MenuPage = .main
    private var isGameCompleted: Bool { FIRManager.saveStateModel?.gameCompleted ?? false }
    
    weak var titleSceneDelegate: TitleSceneDelegate?
    
    enum MenuPage {
        case main, levelSelect, settings
    }
    
    
    // MARK: - Initializtion
    
    init(size: CGSize, shouldInitializeAsHero: Bool) {
        self.screenSize = size
        self.shouldInitializeAsHero = shouldInitializeAsHero
        
        super.init(size: size)
        
        setupSprites()
        mixColors()
        animateSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("TitleScene deinit")
    }

    private func setupSprites() {
        //Sprites Setup
        if shouldInitializeAsHero {
            player = Player(type: .hero)
        }
        else {
            player = Player(type: AgeOfRuin.isActive ? .youngTrainer : .hero)
        }
        
        player.sprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        player.sprite.setScale(2)
        player.sprite.texture = player.textures[Player.Texture.run.rawValue][4]
        player.sprite.name = "playerSprite"

        playerPossibleRuin = Player(type: AgeOfRuin.isActive ? .youngTrainer : .hero)
        playerPossibleRuin.sprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        playerPossibleRuin.sprite.setScale(2)
        playerPossibleRuin.sprite.texture = playerPossibleRuin.textures[Player.Texture.run.rawValue][4]
        playerPossibleRuin.sprite.zPosition -= 1
        playerPossibleRuin.sprite.name = "playerSpritePossibleRuin"

        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.size = screenSize
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = "skyNode"
        
        fadeSprite = SKSpriteNode(color: .white, size: screenSize)
        fadeSprite.anchorPoint = .zero
        fadeSprite.alpha = 0
        fadeSprite.zPosition = K.ZPosition.fadeTransitionNode
        
        fadeOutSprite = SKSpriteNode(color: .black, size: screenSize)
        fadeOutSprite.anchorPoint = .zero
        fadeOutSprite.alpha = 0
        fadeOutSprite.zPosition = K.ZPosition.fadeTransitionNode
        
        tapPointerEngine = TapPointerEngine()
        
        
        //Title Setup
        let sizeA: CGFloat = screenSize.width / 4
        let sizeB: CGFloat = sizeA * (4 / 5)

        puzlTitle = SKLabelNode(text: "PUZL")
        puzlTitle.position = CGPoint(x: 0, y: screenSize.height - K.ScreenDimensions.topMargin)
        puzlTitle.fontName = UIFont.gameFont
        puzlTitle.fontSize = sizeA
        puzlTitle.horizontalAlignmentMode = .left
        puzlTitle.verticalAlignmentMode = .top
        puzlTitle.setScale(4)
        puzlTitle.alpha = 1
        puzlTitle.zPosition = K.ZPosition.puzlTitle
        puzlTitle.addTripleShadow(shadowOffset: -shadowDepth)

        boyTitle = SKLabelNode(text: "Boy")
        boyTitle.position = CGPoint(x: sizeA, y: screenSize.height - K.ScreenDimensions.topMargin - sizeB)
        boyTitle.fontName = UIFont.gameFont
        boyTitle.fontSize = sizeB
        boyTitle.horizontalAlignmentMode = .left
        boyTitle.verticalAlignmentMode = .top
        boyTitle.zRotation = .pi / 12
        boyTitle.zPosition = K.ZPosition.boyTitle
        boyTitle.setScale(4)
        boyTitle.alpha = 0
        boyTitle.addHeavyDropShadow(alpha: 0.1)
        
        
        //Menu Setup
        let menuPosition = CGPoint(x: screenSize.width / 2, y: menuSizeTall.height / 2 + K.ScreenDimensions.bottomMargin)
        let menuSpacing: CGFloat = 133
        let menuCornerRadius: CGFloat = 20

        menuBackground = SKShapeNode(rectOf: menuSize, cornerRadius: menuCornerRadius)
        menuBackground.position = menuPosition - 3 * shadowDepth
        menuBackground.strokeColor = .white
        menuBackground.lineWidth = 0
        menuBackground.alpha = 0
        menuBackground.zPosition = K.ZPosition.menuBackground
        menuBackground.addShadow(rectOf: menuSize, cornerRadius: menuCornerRadius)
        
        menuBackgroundText = SKShapeNode(rectOf: menuSize, cornerRadius: menuCornerRadius)
        menuBackgroundText.position = .zero
        menuBackgroundText.strokeColor = .white
        menuBackgroundText.lineWidth = 0
        menuBackgroundText.alpha = 0
        menuBackgroundText.zPosition = zPositionOffset

        menuStart = MenuItemLabel(text: "Start Game", ofType: .menuStart, at: CGPoint(x: 0, y: menuSize.height / 2 - 1 * menuSpacing))
        menuLevelSelect = MenuItemLabel(text: "Level Select", ofType: .menuLevelSelect, at: CGPoint(x: 0, y: menuSize.height / 2 - 2 * menuSpacing))
        menuSettings = MenuItemLabel(text: "Settings", ofType: .menuSettings, at: CGPoint(x: 0, y: menuSize.height / 2 - (isGameCompleted ? 3 : 2) * menuSpacing))
        menuCredits = MenuItemLabel(text: "Credits", ofType: .menuCredits, at: CGPoint(x: 0, y: menuSize.height / 2 - (isGameCompleted ? 4 : 3) * menuSpacing))
        
        menuStart.delegate = self
        menuLevelSelect.delegate = self
        menuSettings.delegate = self
        menuCredits.delegate = self
        
        menuLevelSelect.setIsEnabled(isGameCompleted)
        
        
        //Level Select Setup
        let sizeUI = K.ScreenDimensions.sizeUI
        let ratioSKtoUI = K.ScreenDimensions.ratioSKtoUI
        let levelSelectPickerSize = CGSize(width: 160, height: 92) / UIDevice.spriteScale
        let levelSelectPickerOffset: CGFloat = 42 * UIDevice.spriteScale

        levelSelectBackground = SKShapeNode(rectOf: levelSelectSize, cornerRadius: menuCornerRadius)
        levelSelectBackground.position = menuPosition
        levelSelectBackground.xScale = menuSize.width / levelSelectSize.width
        levelSelectBackground.yScale = menuSize.height / levelSelectSize.height
        levelSelectBackground.strokeColor = .white
        levelSelectBackground.lineWidth = 0
        levelSelectBackground.alpha = 0
        levelSelectBackground.zPosition = K.ZPosition.menuBackground
        levelSelectBackground.addShadow(rectOf: levelSelectSize, cornerRadius: menuCornerRadius)
        
        levelSelectPage = LevelSelectPage(contentSize: levelSelectSize)
        levelSelectPage.zPosition = zPositionOffset
        levelSelectPage.delegate = self
                
        levelSelectPicker = LevelSelectPicker(frame: CGRect(
            x: (sizeUI.width - levelSelectPickerSize.width) / 2,
            y: sizeUI.height - levelSelectBackground.position.y / ratioSKtoUI - levelSelectPickerSize.height + levelSelectPickerOffset,
            width: levelSelectPickerSize.width, height: levelSelectPickerSize.height), level: FIRManager.saveStateModel?.newLevel)

        
        //Settings Setup
        settingsBackground = SKShapeNode(rectOf: settingsSize, cornerRadius: menuCornerRadius)
        settingsBackground.position = menuPosition
        settingsBackground.xScale = menuSize.width / settingsSize.width
        settingsBackground.yScale = menuSize.height / settingsSize.height
        settingsBackground.strokeColor = .white
        settingsBackground.lineWidth = 0
        settingsBackground.alpha = 0
        settingsBackground.zPosition = K.ZPosition.pauseScreen
        settingsBackground.addShadow(rectOf: settingsSize, cornerRadius: menuCornerRadius)

        settingsPage = SettingsPage(contentSize: settingsSize)
        settingsPage.zPosition = zPositionOffset
        
        closeButton = CloseButtonSprite()
        closeButton.delegate = self
    }
    
    private func mixColors() {
        let skyColor: DayTheme.SkyColors = DayTheme.skyColor
        
        switch Int.random(in: 0...3) {
        case 0:
            myColors.title = skyColor.bottom.complementary
            myColors.background = skyColor.top.complementary.complementary.darkenColor(factor: 6)
            myColors.shadow = skyColor.top.complementary
        case 1:
            myColors.title = skyColor.bottom.splitComplementary.second
            myColors.background = skyColor.top.splitComplementary.first.darkenColor(factor: 6)
            myColors.shadow = skyColor.bottom.splitComplementary.first
        case 2:
            myColors.title = skyColor.bottom.analogous.second
            myColors.background = skyColor.top.analogous.first.darkenColor(factor: 6)
            myColors.shadow = skyColor.bottom.analogous.first
        default:
            myColors.title = skyColor.bottom.triadic.second
            myColors.background = skyColor.top.triadic.first.darkenColor(factor: 6)
            myColors.shadow = skyColor.bottom.triadic.first
        }
        
        puzlTitle.fontColor = .white
        puzlTitle.updateShadowColor(myColors.shadow)
        
        boyTitle.fontColor = myColors.title
        
        menuBackground.fillColor = myColors.background
        menuBackground.fillTexture = SKTexture(image: UIImage.gradientTextureMenu)
        menuBackground.updateShadowColor(myColors.shadow)
        
        levelSelectBackground.fillColor = myColors.background
        levelSelectBackground.fillTexture = SKTexture(image: UIImage.gradientTextureMenu)
        levelSelectBackground.updateShadowColor(myColors.shadow)
        
        settingsBackground.fillColor = myColors.background
        settingsBackground.fillTexture = SKTexture(image: UIImage.gradientTextureMenu)
        settingsBackground.updateShadowColor(myColors.shadow)
    }
    
    private func animateSprites() {

        //Player Animation
        player.sprite.run(SKAction.fadeOut(withDuration: 2.5))
        
        
        //Title Animation
        let animationDuration: TimeInterval = 0.15

        let stampAction = SKAction.group([
            SKAction.sequence([
                SKAction.moveBy(x: 100, y: -100, duration: 1 * animationDuration),
                SKAction.moveBy(x: -20, y: 20, duration: 2 * animationDuration)
            ]),
            SKAction.sequence([
                SKAction.scale(to: 0.75, duration: 1 * animationDuration),
                SKAction.scale(to: 1.0, duration: 2 * animationDuration)
            ])
        ])
        
        puzlTitle.run(stampAction)
        puzlTitle.showShadow(shadowOffset: -shadowDepth, animationDuration: animationDuration)
        
        boyTitle.run(SKAction.sequence([
            SKAction.wait(forDuration: animationDuration),
            SKAction.fadeIn(withDuration: 0),
            stampAction,
        ]))
        
        
        //Menu Animation
        let delayMenu: TimeInterval = 3 * animationDuration
        
        menuBackground.showShadow(shadowOffset: -shadowDepth, animationDuration: animationDuration, delay: delayMenu)
        menuBackground.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.9, duration: 3 * animationDuration),
                SKAction.repeat(SKAction.moveBy(x: shadowDepth, y: shadowDepth, duration: animationDuration), count: 3)
            ])
        ]))

        menuBackgroundText.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu + 3 * animationDuration),
            SKAction.fadeAlpha(to: 1.0, duration: 2 * 3 * animationDuration)
        ]))

        
        //Audio
        AudioManager.shared.playSound(for: "punchwhack1")
        AudioManager.shared.playSound(for: "punchwhack2", delay: animationDuration)
        AudioManager.shared.playSound(for: AudioManager.titleLogo, delay: delayMenu)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(player.sprite)
        addChild(playerPossibleRuin.sprite)
        addChild(puzlTitle)
        addChild(boyTitle)
        addChild(menuBackground)
        addChild(levelSelectBackground)
        addChild(settingsBackground)
        addChild(fadeSprite)
        addChild(fadeOutSprite)

        menuBackground.addChild(menuBackgroundText)
        menuBackgroundText.addChild(menuStart)

        let saveStateModelNewLevel = FIRManager.saveStateModel?.newLevel ?? 0

        if UserDefaults.standard.bool(forKey: K.UserDefaults.hasPlayedBefore) || saveStateModelNewLevel > 0 {
            if isGameCompleted {
                menuBackgroundText.addChild(menuLevelSelect)
            }
            
            menuBackgroundText.addChild(menuSettings)
            menuBackgroundText.addChild(menuCredits)
        }
        
        levelSelectBackground.addChild(levelSelectPage)
        settingsBackground.addChild(settingsPage)
    }
    
    
    // MARK: - Helper Functions
    
    private func showLevelSelect(shouldHide: Bool) {
        showSecondMenu(secondNode: levelSelectBackground,
                       secondNodeSize: levelSelectSize,
                       scale: UIDevice.spriteScale,
                       shouldAnchorBottom: false,
                       shouldHide: shouldHide,
                       completion: nil)
        
        currentMenuSelected = shouldHide ? .main : .levelSelect
    }
    
    private func showSettings(shouldHide: Bool) {
        showSecondMenu(secondNode: settingsBackground,
                       secondNodeSize: settingsSize,
                       scale: UIDevice.spriteScale,
                       shouldAnchorBottom: true,
                       shouldHide: shouldHide,
                       completion: settingsPage.checkReportBugAlreadySubmitted)

        currentMenuSelected = shouldHide ? .main : .settings
    }
    
    private func showSecondMenu(secondNode: SKShapeNode,
                                secondNodeSize: CGSize,
                                scale: CGFloat = 1,
                                shouldAnchorBottom: Bool,
                                shouldHide: Bool,
                                completion: (() -> Void)?) {
        
        let animationDuration: TimeInterval = 0.25
        let bottomMargin: CGFloat = K.ScreenDimensions.bottomMargin

        disableInput = true
        
        if shouldHide {
            secondNode.hideShadow()
            
            secondNode.run(SKAction.group([
                SKAction.scaleX(to: menuSize.width / secondNodeSize.width, duration: animationDuration),
                SKAction.scaleY(to: menuSize.height / secondNodeSize.height, duration: animationDuration),
                SKAction.fadeOut(withDuration: 0)
            ])) { [weak self] in
                self?.menuBackground.showShadow()
                self?.closeButton.removeFromParent()
                
                self?.disableInput = false
            }

            menuBackground.run(SKAction.group([
                SKAction.scaleX(to: 1, duration: animationDuration),
                SKAction.scaleY(to: 1, duration: animationDuration),
                SKAction.fadeAlpha(to: 0.9, duration: 0)
            ]))
            
            if shouldAnchorBottom {
                secondNode.run(SKAction.moveTo(y: menuSizeTall.height / 2 + bottomMargin, duration: animationDuration))
                menuBackground.run( SKAction.moveTo(y: menuSizeTall.height / 2 + bottomMargin, duration: animationDuration))
            }
        }
        else {
            menuBackground.hideShadow()

            menuBackground.run(SKAction.group([
                SKAction.scaleX(to: secondNodeSize.width / menuSize.width * scale, duration: animationDuration),
                SKAction.scaleY(to: secondNodeSize.height / menuSize.height * scale, duration: animationDuration),
                SKAction.fadeOut(withDuration: 0)
            ])) { [weak self] in
                secondNode.showShadow()
                
                self?.disableInput = false
            }
            
            secondNode.run(SKAction.group([
                SKAction.scaleX(to: scale, duration: animationDuration),
                SKAction.scaleY(to: scale, duration: animationDuration),
                SKAction.fadeAlpha(to: 0.9, duration: 0)
            ]))
            
            secondNode.addChild(closeButton)
            closeButton.setPosition(to: CGPoint(x: secondNodeSize.width / 2, y: secondNodeSize.height / 2))

            if shouldAnchorBottom {
                menuBackground.run(SKAction.moveTo(y: secondNodeSize.height / 2 * scale + bottomMargin, duration: animationDuration))
                secondNode.run(SKAction.moveTo(y: secondNodeSize.height / 2 * scale + bottomMargin, duration: animationDuration))
            }

            completion?()
        }
    }
    
    
    // MARK: - UI Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !disableInput else { return }

        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
        
        for node in nodes(at: location) {
            if let node = node as? MenuItemLabel {
                node.touchDown()
            }
            else if let node = node as? SettingsPage {
                node.superScene = self
                node.touchDown(for: touches)
            }
            else if let node = node as? LevelSelectPage {
                node.superScene = self
                node.touchDown(for: touches)
            }
            else if let node = node as? CloseButtonSprite {
                node.touchDown()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !disableInput else { return }
        
        for node in nodes(at: location) {
            if let node = node as? MenuItemLabel {
                node.tapButton(toColor: myColors.shadow)

                touchUpButtons()
            }
            else if let node = node as? SettingsPage {
                node.touchNode(for: touches)

                touchUpButtons()
            }
            else if let node = node as? LevelSelectPage {
                node.touchNode(for: touches)
                
                touchUpButtons()
            }
            else if let node = node as? CloseButtonSprite {
                node.buttonTapped()
                
                touchUpButtons()
            }
            else if node.name != TapPointerEngine.nodeName {
                touchUpMenuItems()
            }
        }
    }
    
    private func touchUpMenuItems() {
        menuStart.touchUp()
        menuLevelSelect.touchUp()
        menuSettings.touchUp()
        menuCredits.touchUp()
    }
    
    private func touchUpButtons() {
        touchUpMenuItems()
        
        settingsPage.touchUp()
        levelSelectPage.touchUp()
        closeButton.touchUp()
    }
}


// MARK: - LevelSelectPageDelegate

extension TitleScene: LevelSelectPageDelegate {
    func didTapLevelSelect() {
        let newLevel = levelSelectPicker.selectedLevel
        
        FIRManager.updateFirestoreRecordNewLevel(newLevel: newLevel)
        startGame(levelSelectNewLevel: newLevel)
    }
}


// MARK: - CloseButtonSpriteDelegate

extension TitleScene: CloseButtonSpriteDelegate {
    func didTapButton() {
        if currentMenuSelected == .settings {
            showSettings(shouldHide: true)
        }
        else if currentMenuSelected == .levelSelect {
            showLevelSelect(shouldHide: true)

            levelSelectPicker.updatePicker(level: FIRManager.saveStateModel?.newLevel, shouldAnimate: false)
            levelSelectPicker.removeFromSuperview()
        }
    }
}



// MARK: - MenuItemLabelDelegate

extension TitleScene: MenuItemLabelDelegate {
    private func startGame(levelSelectNewLevel: Int?) {
        let fadeDuration: TimeInterval = 2.0
        
        disableInput = true
        AudioManager.shared.stopSound(for: AudioManager.titleLogo, fadeDuration: fadeDuration)

        UIView.animate(withDuration: fadeDuration) { [weak self] in
            self?.levelSelectPicker.alpha = 0
        }

        //IMPORTANT TO MAKE THESE NIL!! Otherwise you get retain cycle!!!
        levelSelectPage.superScene = nil
        settingsPage.superScene = nil
        tapPointerEngine = nil

        fadeSprite.run(SKAction.fadeIn(withDuration: fadeDuration)) { [weak self] in
            self?.disableInput = false
            self?.levelSelectPicker.removeFromSuperview()
            self?.titleSceneDelegate?.didTapStart(levelSelectNewLevel: levelSelectNewLevel)
        }
    }
    
    func buttonWasTapped(_ node: MenuItemLabel) {
        switch node.type {
        case .menuStart:
            startGame(levelSelectNewLevel: nil)
        case .menuLevelSelect:
            showLevelSelect(shouldHide: false)
            
            scene?.view?.addSubview(levelSelectPicker)
            
            titleSceneDelegate?.didTapLevelSelect()
        case .menuSettings:
            showSettings(shouldHide: false)
        case .menuCredits:
            let fadeDuration: TimeInterval = 1.0
            
            disableInput = true
            AudioManager.shared.stopSound(for: AudioManager.titleLogo, fadeDuration: fadeDuration)
            
            //IMPORTANT TO MAKE THESE NIL!! Otherwise you get retain cycle!!!
            levelSelectPage.superScene = nil
            settingsPage.superScene = nil
            tapPointerEngine = nil

            fadeOutSprite.run(SKAction.fadeIn(withDuration: fadeDuration)) { [weak self] in
                self?.disableInput = false
                self?.levelSelectPicker.removeFromSuperview()
                self?.titleSceneDelegate?.didTapCredits()
            }
        }
    }

    
}
