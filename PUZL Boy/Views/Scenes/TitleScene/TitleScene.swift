//
//  TitleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/31/23.
//

import SpriteKit
import FirebaseAuth

protocol TitleSceneDelegate: AnyObject {
    func didTapStart()
    func didTapCredits()
}

class TitleScene: SKScene {
    
    // MARK: - Properties

    //Sprites
    private var player = Player()
    private var skyNode: SKSpriteNode
    private var fadeSprite: SKSpriteNode
    private var fadeOutSprite: SKSpriteNode

    //Title Properties
    private var puzlTitle: SKLabelNode
    private var boyTitle: SKLabelNode
    
    //Menu Properties
    private var menuStart: MenuItemLabel
    private var menuLevelSelect: MenuItemLabel
    private var menuOptions: MenuItemLabel
    private var menuCredits: MenuItemLabel
    private var menuBackground: SKShapeNode
    private var menuBackgroundText: SKShapeNode
    private var settingsBackground: SKShapeNode
    private var settingsClose: SKSpriteNode
    private var settingsPage: SettingsPage

    //Misc.
    private var user: User?
    private var myColors: (title: UIColor, background: UIColor, shadow: UIColor) = (.black, .black, .black)
    private let shadowDepth: CGFloat = 10
    private var disableInput: Bool = false
    private let menuSize = CGSize(width: 650, height: K.ScreenDimensions.height / 3)
    private let settingsSize = CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth * 5 / 4)

    weak var titleSceneDelegate: TitleSceneDelegate?
    
    
    // MARK: - Initializtion
    
    init(size: CGSize, user: User?) {
        self.user = user
        
        //Sprites Setup
        player.sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        player.sprite.setScale(2)
        player.sprite.texture = SKTexture(imageNamed: "Run (5)")
        player.sprite.name = "playerSprite"
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = "skyNode"
        
        fadeSprite = SKSpriteNode(color: .white, size: K.ScreenDimensions.screenSize)
        fadeSprite.anchorPoint = .zero
        fadeSprite.alpha = 0
        fadeSprite.zPosition = K.ZPosition.fadeTransitionNode
        
        // TODO: - CreditsScene
        fadeOutSprite = SKSpriteNode(color: .black, size: K.ScreenDimensions.screenSize)
        fadeOutSprite.anchorPoint = .zero
        fadeOutSprite.alpha = 0
        fadeOutSprite.zPosition = K.ZPosition.fadeTransitionNode
        
        
        //Title Setup
        let sizeA: CGFloat = K.ScreenDimensions.iPhoneWidth / 4
        let sizeB: CGFloat = sizeA * (4 / 5)
        let zPositionOffset: CGFloat = 5

        puzlTitle = SKLabelNode(text: "PUZL")
        puzlTitle.position = CGPoint(x: 0, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin)
        puzlTitle.fontName = UIFont.gameFont
        puzlTitle.fontSize = sizeA
        puzlTitle.horizontalAlignmentMode = .left
        puzlTitle.verticalAlignmentMode = .top
        puzlTitle.setScale(4)
        puzlTitle.alpha = 1
        puzlTitle.zPosition = K.ZPosition.puzlTitle
        puzlTitle.addTripleShadow(shadowOffset: -shadowDepth)

        boyTitle = SKLabelNode(text: "Boy")
        boyTitle.position = CGPoint(x: sizeA, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - sizeB)
        boyTitle.fontName = UIFont.gameFont
        boyTitle.fontSize = sizeB
        boyTitle.horizontalAlignmentMode = .left
        boyTitle.verticalAlignmentMode = .top
        boyTitle.zPosition = K.ZPosition.boyTitle
        boyTitle.setScale(4)
        boyTitle.alpha = 0
        boyTitle.run(SKAction.rotate(toAngle: .pi / 12, duration: 0))
        boyTitle.addHeavyDropShadow(alpha: 0.1)
        
        
        //Menu Setup
        let menuPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: menuSize.height / 2 + K.ScreenDimensions.bottomMargin)
        let menuGap: CGFloat = 133
        let menuCornerRadius: CGFloat = 20

        menuBackground = SKShapeNode(rectOf: menuSize, cornerRadius: menuCornerRadius)
        menuBackground.position = menuPosition + CGPoint(x: -3 * shadowDepth, y: -3 * shadowDepth)
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

        menuStart = MenuItemLabel(text: "Start Game", ofType: .menuStart, at: CGPoint(x: 0, y: menuSize.height / 2 - 1 * menuGap))
        menuLevelSelect = MenuItemLabel(text: "Select Level", ofType: .menuLevelSelect, at: CGPoint(x: 0, y: menuSize.height / 2 - 2 * menuGap))
        menuOptions = MenuItemLabel(text: "Settings", ofType: .menuOptions, at: CGPoint(x: 0, y: menuSize.height / 2 - 3 * menuGap))
        menuCredits = MenuItemLabel(text: "Credits", ofType: .menuCredits, at: CGPoint(x: 0, y: menuSize.height / 2 - 4 * menuGap))
        
        
        //Settings Setup
        let closeSize: CGFloat = 80
        let closeInset: CGFloat = 20
        
        settingsClose = SKSpriteNode(imageNamed: "closeButton")
        settingsClose.scale(to: CGSize(width: closeSize, height: closeSize))
        settingsClose.position = CGPoint(x: (settingsSize.width - closeSize) / 2 - closeInset, y: (settingsSize.height - closeSize) / 2 - closeInset)
        settingsClose.zPosition = 10
        settingsClose.name = "closeSettings"
        
        settingsBackground = SKShapeNode(rectOf: settingsSize, cornerRadius: menuCornerRadius)
        settingsBackground.lineWidth = 0
        settingsBackground.position = CGPoint(x: K.ScreenDimensions.screenSize.width / 2, y: menuSize.height / 2 + K.ScreenDimensions.bottomMargin)
        settingsBackground.xScale = menuSize.width / settingsSize.width
        settingsBackground.yScale = menuSize.height / settingsSize.height
        settingsBackground.alpha = 0
        settingsBackground.zPosition = K.ZPosition.pauseScreen
        settingsBackground.addShadow(rectOf: settingsSize, cornerRadius: menuCornerRadius)

        settingsPage = SettingsPage(user: user, contentSize: settingsSize)
        settingsPage.zPosition = 10

        settingsBackground.addChild(settingsPage)
        settingsBackground.addChild(settingsClose)

        
        super.init(size: size)
        
        menuStart.delegate = self
        menuLevelSelect.delegate = self
        menuOptions.delegate = self
        menuCredits.delegate = self
                
        menuLevelSelect.setIsEnabled(false)

        mixColors()
        animateSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func mixColors() {
        switch Int.random(in: 0...3) {
        case 0:
            myColors.title = DayTheme.skyColor.bottom.complementary
            myColors.background = DayTheme.skyColor.top.complementary.complementary.darkenColor(factor: 6)
            myColors.shadow = DayTheme.skyColor.top.complementary
        case 1:
            myColors.title = DayTheme.skyColor.bottom.splitComplementary.second
            myColors.background = DayTheme.skyColor.top.splitComplementary.first.darkenColor(factor: 6)
            myColors.shadow = DayTheme.skyColor.bottom.splitComplementary.first
        case 2:
            myColors.title = DayTheme.skyColor.bottom.analogous.second
            myColors.background = DayTheme.skyColor.top.analogous.first.darkenColor(factor: 6)
            myColors.shadow = DayTheme.skyColor.bottom.analogous.first
        default:
            myColors.title = DayTheme.skyColor.bottom.triadic.second
            myColors.background = DayTheme.skyColor.top.triadic.first.darkenColor(factor: 6)
            myColors.shadow = DayTheme.skyColor.bottom.triadic.first
        }
        
        puzlTitle.fontColor = .white
        puzlTitle.updateShadowColor(myColors.shadow)
        
        boyTitle.fontColor = myColors.title
        
        menuBackground.fillColor = myColors.background
        menuBackground.fillTexture = SKTexture(image: UIImage.menuGradientTexture)
        menuBackground.updateShadowColor(myColors.shadow)
        
        settingsBackground.fillColor = myColors.background
        settingsBackground.fillTexture = SKTexture(image: UIImage.menuGradientTexture)
        settingsBackground.updateShadowColor(myColors.shadow)
        
        settingsClose.color = .black
        settingsClose.colorBlendFactor = 0
    }
    
    private func animateSprites() {
        
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
        puzlTitle.showShadow(shadowOffset: -shadowDepth, animationDuration: animationDuration, completion: nil)
        
        boyTitle.run(SKAction.sequence([
            SKAction.wait(forDuration: animationDuration),
            SKAction.fadeIn(withDuration: 0),
            stampAction,
        ]))
        
        
        //Menu Animation
        let delayMenu: TimeInterval = 3 * animationDuration
        
        menuBackground.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.9, duration: 3 * animationDuration),
                SKAction.repeat(SKAction.moveBy(x: shadowDepth, y: shadowDepth, duration: animationDuration), count: 3),
                SKAction.run { [unowned self] in
                    menuBackground.showShadow(shadowOffset: -shadowDepth, animationDuration: animationDuration, completion: nil)
                }
            ])
        ]))

        menuBackgroundText.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu + 3 * animationDuration),
            SKAction.fadeAlpha(to: 1.0, duration: 2 * 3 * animationDuration)
        ]))

        
        //Audio
        AudioManager.shared.playSound(for: "punchwhack1")
        AudioManager.shared.playSound(for: "punchwhack2", delay: animationDuration)
        AudioManager.shared.playSound(for: AudioManager.shared.titleLogo, delay: delayMenu)
    }
    
    deinit {
        print("deinit TitleScene")
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(player.sprite)
        addChild(puzlTitle)
        addChild(boyTitle)
        addChild(menuBackground)
        addChild(settingsBackground)
        addChild(fadeSprite)
        addChild(fadeOutSprite)

        menuBackground.addChild(menuBackgroundText)
        menuBackgroundText.addChild(menuStart)
        menuBackgroundText.addChild(menuLevelSelect)
        menuBackgroundText.addChild(menuOptions)
        menuBackgroundText.addChild(menuCredits)
    }
    
    
    // MARK: - Helper Functions
    
    private func showSettings(shouldHide: Bool) {
        let animationDuration: TimeInterval = 0.25
        
        disableInput = true
        
        if shouldHide {
            settingsBackground.hideShadow(completion: nil)

            settingsBackground.run(SKAction.group([
                SKAction.scaleX(to: menuSize.width / settingsSize.width, duration: animationDuration),
                SKAction.scaleY(to: menuSize.height / settingsSize.height, duration: animationDuration),
                SKAction.moveTo(y: menuSize.height / 2 + K.ScreenDimensions.bottomMargin, duration: animationDuration),
                SKAction.fadeOut(withDuration: animationDuration)
            ])) { [unowned self] in
                menuBackground.showShadow(completion: nil)
                
                disableInput = false
            }
            
            menuBackground.run(SKAction.group([
                SKAction.scaleX(to: 1, duration: animationDuration),
                SKAction.scaleY(to: 1, duration: animationDuration),
                SKAction.moveTo(y: menuSize.height / 2 + K.ScreenDimensions.bottomMargin, duration: animationDuration),
                SKAction.fadeAlpha(to: 0.9, duration: animationDuration)
            ]))
        }
        else {
            menuBackground.hideShadow(completion: nil)

            menuBackground.run(SKAction.group([
                SKAction.scaleX(to: settingsSize.width / menuSize.width * GameboardSprite.spriteScale, duration: animationDuration),
                SKAction.scaleY(to: settingsSize.height / menuSize.height * GameboardSprite.spriteScale, duration: animationDuration),
                SKAction.moveTo(y: settingsSize.height / 2 * GameboardSprite.spriteScale + K.ScreenDimensions.bottomMargin, duration: animationDuration),
                SKAction.fadeOut(withDuration: animationDuration)
            ])) { [unowned self] in
                settingsBackground.showShadow(completion: nil)
                
                disableInput = false
            }
            
            settingsBackground.run(SKAction.group([
                SKAction.scaleX(to: GameboardSprite.spriteScale, duration: animationDuration),
                SKAction.scaleY(to: GameboardSprite.spriteScale, duration: animationDuration),
                SKAction.moveTo(y: settingsSize.height / 2 * GameboardSprite.spriteScale + K.ScreenDimensions.bottomMargin, duration: animationDuration),
                SKAction.fadeAlpha(to: 0.9, duration: animationDuration)
            ]))
        }
    }
    
    
    // MARK: - UI Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !disableInput else { return }
        
        for node in nodes(at: location) {
            if node.name == "closeSettings", let settingsClose = node as? SKSpriteNode {
                settingsClose.colorBlendFactor = 0.25
            }
            else if let node = node as? MenuItemLabel {
                node.touchDown()
            }
            else if let node = node as? SettingsPage {
                node.superScene = self
                node.touchDown(for: touches)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !disableInput else { return }
        
        for node in nodes(at: location) {
            if node.name == "closeSettings", let settingsClose = node as? SKSpriteNode, settingsClose.colorBlendFactor == 0.25 {
                showSettings(shouldHide: true)

                ButtonTap.shared.tap(type: .buttontap6)
                
                touchUpButtons()
            }
            else if let node = node as? MenuItemLabel {
                node.tapButton(toColor: myColors.shadow)
                
                touchUpButtons()
            }
            else if let node = node as? SettingsPage {
                node.touchNode(for: touches)
                
                touchUpButtons()
            }
        }
    }
    
    private func touchUpButtons() {
        menuStart.touchUp()
        menuLevelSelect.touchUp()
        menuOptions.touchUp()
        menuCredits.touchUp()
        
        settingsPage.touchUp()
        settingsClose.colorBlendFactor = 0
    }
}


// MARK: - MenuItemLabelDelegate

extension TitleScene: MenuItemLabelDelegate {
    func buttonWasTapped(_ node: MenuItemLabel) {
        switch node.type {
        case .menuStart:
            let fadeDuration: TimeInterval = 2.0
            
            disableInput = true
            AudioManager.shared.stopSound(for: AudioManager.shared.titleLogo, fadeDuration: fadeDuration)

            fadeSprite.run(SKAction.fadeIn(withDuration: fadeDuration)) { [unowned self] in
                disableInput = false
                titleSceneDelegate?.didTapStart()
            }
        case .menuLevelSelect:
            print("Level Select not implemented.")
        case .menuOptions:
            showSettings(shouldHide: false)
        case .menuCredits:
            let fadeDuration: TimeInterval = 1.0
            
            disableInput = true
            AudioManager.shared.stopSound(for: AudioManager.shared.titleLogo, fadeDuration: fadeDuration)

            // TODO: - Credits Scene
            fadeOutSprite.run(SKAction.fadeIn(withDuration: fadeDuration)) { [unowned self] in
                disableInput = false
                titleSceneDelegate?.didTapCredits()
            }
            
            
            print("Credits Tapped")
            
            
            // TODO: - Cirle Animation Transition
            //Attempt 1
//            let fullScreen = SKSpriteNode(color: .black, size: K.ScreenDimensions.screenSize)
//            let mask = SKSpriteNode(color: .black, size: K.ScreenDimensions.screenSize)
//            let circle = SKShapeNode(circleOfRadius: K.ScreenDimensions.height / 2)
//            circle.fillColor = .white
//            circle.blendMode = .subtract
//            circle.setScale(0)
//            circle.isHidden = true
//            circle.name = "circleShape"
//            mask.addChild(circle)
//
//            let crop = SKCropNode()
//            crop.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
//            crop.maskNode = mask
//            crop.name = "cropNode"
//            crop.addChild(fullScreen)
//            crop.zPosition = 9999
//
//            addChild(crop)
//
//            let waitAction = SKAction.wait(forDuration: 2.0)
//            let callAction = SKAction.run { [unowned self] in
//                let cropNode = childNode(withName: "cropNode") as! SKCropNode
//                let maskNode = cropNode.maskNode as! SKSpriteNode
//                let circleNode = maskNode.childNode(withName: "circleShape") as! SKShapeNode
//                circleNode.isHidden = false
//                let scaleAction = SKAction.scale(to: 2, duration: 1)
//                circleNode.run(scaleAction) {
//                    cropNode.removeFromParent()
//                }
//            }
//
//            let seqAction = SKAction.sequence([waitAction, callAction])
//            run(seqAction) {
//                self.disableInput = false
////                self.titleSceneDelegate?.didTapCredits()
//            }
            
            //Attempt 2
//            circleTransition()
            
            //Attempt 3
//            let spriteSize = vector_float2(Float(K.ScreenDimensions.iPhoneWidth / 40), Float(K.ScreenDimensions.height / 40))
//
//            let shader = SKShader(fileNamed: "transitionShader.fsh")
//            shader.attributes = [SKAttribute(name: "a_sprite_size", type: .vectorFloat2), SKAttribute(name:"a_duration", type: .float)]
//
//            let fullScreen = SKSpriteNode(color: .red, size: K.ScreenDimensions.screenSize)
//            fullScreen.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
//            fullScreen.zPosition = 9999
//            fullScreen.shader = shader
//            fullScreen.setValue(SKAttributeValue(vectorFloat2: spriteSize), forAttribute: "a_sprite_size")
//            fullScreen.setValue(SKAttributeValue(float: Float(fadeDuration)), forAttribute: "a_duration")
//
//            addChild(fullScreen)
//
//            run(SKAction.wait(forDuration: fadeDuration)) { [unowned self] in
//                disableInput = false
//                fullScreen.removeFromParent()
//            }
            

            //Attempt 4
//            let effect = SKEffectNode()
//            effect.zPosition = 9999
//            addChild(effect)
//
//            let rect = SKShapeNode(rect: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
//            rect.fillColor = .black
//            effect.addChild(rect)
//
//            let mask = SKShapeNode(circleOfRadius: 100)
//            mask.position = CGPoint(x: 200, y: 300)
//            mask.fillColor = .white
//            mask.blendMode = .subtract
//            rect.addChild(mask)
                                                                                                                                                                                                                   
        }
    }
    
    
    // TODO: - Circle Animation Transition
    func circleTransition() {
        let bgMask = SKSpriteNode(color: .black, size: K.ScreenDimensions.screenSize)
        bgMask.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        bgMask.zPosition = 5000
        addChild(bgMask)

        let transitionCircle = SKSpriteNode(texture: SKTexture(imageNamed: "transition_circle"), color: .clear, size: CGSize(width: 13, height: 13))
        transitionCircle.position = CGPoint.zero
        transitionCircle.zPosition = 1
        transitionCircle.blendMode = .subtract
        bgMask.addChild(transitionCircle)

//        let bgOverlay = SKSpriteNode(texture: SKTexture(imageNamed: "bg_overlay"), color: .clear, size: CGSize(width: self.size.width, height: self.size.height))
//        let bgOverlay = SKSpriteNode(color: .black, size: K.ScreenDimensions.screenSize)
//        bgOverlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//        bgOverlay.zPosition = 5001
//        addChild(bgOverlay)

        bgMask.run(SKAction.sequence([SKAction.scale(to: 100.0, duration: 2.0), SKAction.removeFromParent()])) { [weak self] in
            self?.disableInput = false
        }
        
//        bgOverlay.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.removeFromParent()]))
    }
    
    
    
}
