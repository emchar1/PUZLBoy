//
//  TitleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/31/23.
//

import SpriteKit

protocol TitleSceneDelegate: AnyObject {
    func didTapStart()
}

class TitleScene: SKScene {
    
    // MARK: - Properties
    
    private var preventTouch: Bool = false

    private var player = Player()
    private var skyNode: SKSpriteNode
    private var fadeSprite: SKSpriteNode

    //Title Properties
    private var puzlTitle: SKLabelNode
    private var puzlTitleShadow1: SKLabelNode
    private var puzlTitleShadow2: SKLabelNode
    private var puzlTitleShadow3: SKLabelNode
    private var boyTitle: SKLabelNode
    private let shadowDepth: CGFloat = 10
    
    //Menu Properties
    private var menuStart: MenuItemLabel
    private var menuLevelSelect: MenuItemLabel
    private var menuOptions: MenuItemLabel
    private var menuCredits: MenuItemLabel
    private var menuBackground: SKShapeNode
    private var menuBackgroundText: SKShapeNode
    private var menuBackgroundColor: SKShapeNode
    private var menuBackgroundShadow1: SKShapeNode
    private var menuBackgroundShadow2: SKShapeNode
    private var menuBackgroundShadow3: SKShapeNode

    weak var titleSceneDelegate: TitleSceneDelegate?
    
    
    // MARK: - Initializtion
    
    override init(size: CGSize) {
        player.sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        player.sprite.setScale(2)
        player.sprite.texture = SKTexture(imageNamed: "Run (5)")
        player.sprite.name = "playerSprite"
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = "skyNode"
        
        fadeSprite = SKSpriteNode(color: .white, size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        fadeSprite.anchorPoint = .zero
        fadeSprite.alpha = 0
        fadeSprite.zPosition = K.ZPosition.fadeTransitionNode
        
        
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
        puzlTitle.alpha = 1.0
        puzlTitle.zPosition = K.ZPosition.puzlTitle
        
        puzlTitleShadow1 = SKLabelNode(text: "PUZL")
        puzlTitleShadow1.position = CGPoint(x: -shadowDepth, y: -shadowDepth)
        puzlTitleShadow1.fontName = UIFont.gameFont
        puzlTitleShadow1.fontSize = sizeA
        puzlTitleShadow1.horizontalAlignmentMode = .left
        puzlTitleShadow1.verticalAlignmentMode = .top
        puzlTitleShadow1.alpha = 0
        puzlTitleShadow1.zPosition = -zPositionOffset

        puzlTitleShadow2 = SKLabelNode(text: "PUZL")
        puzlTitleShadow2.position = CGPoint(x: -2 * shadowDepth, y: -2 * shadowDepth)
        puzlTitleShadow2.fontName = UIFont.gameFont
        puzlTitleShadow2.fontSize = sizeA
        puzlTitleShadow2.horizontalAlignmentMode = .left
        puzlTitleShadow2.verticalAlignmentMode = .top
        puzlTitleShadow2.alpha = 0
        puzlTitleShadow2.zPosition = -2 * zPositionOffset

        puzlTitleShadow3 = SKLabelNode(text: "PUZL")
        puzlTitleShadow3.position = CGPoint(x: -3 * shadowDepth, y: -3 * shadowDepth)
        puzlTitleShadow3.fontName = UIFont.gameFont
        puzlTitleShadow3.fontSize = sizeA
        puzlTitleShadow3.horizontalAlignmentMode = .left
        puzlTitleShadow3.verticalAlignmentMode = .top
        puzlTitleShadow3.alpha = 0
        puzlTitleShadow3.zPosition = -3 * zPositionOffset

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
        let menuSize = CGSize(width: 650, height: K.ScreenDimensions.height / 3)
        let menuGap: CGFloat = 133

        menuBackground = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackground.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.bottomMargin + menuSize.height / 2)
        menuBackground.fillColor = .clear
        menuBackground.strokeColor = .white
        menuBackground.lineWidth = 0
        menuBackground.zPosition = K.ZPosition.menuBackground
        
        menuBackgroundText = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackgroundText.position = .zero
        menuBackgroundText.strokeColor = .white
        menuBackgroundText.lineWidth = 0
        menuBackgroundText.alpha = 0
        menuBackgroundText.zPosition = zPositionOffset

        menuBackgroundColor = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackgroundColor.position = CGPoint(x: -3 * shadowDepth, y: -3 * shadowDepth)
        menuBackgroundColor.strokeColor = .white
        menuBackgroundColor.lineWidth = 0
        menuBackgroundColor.alpha = 0
        menuBackgroundColor.zPosition = -zPositionOffset

        menuBackgroundShadow1 = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackgroundShadow1.position = CGPoint(x: -3 * shadowDepth, y: -3 * shadowDepth)
        menuBackgroundShadow1.strokeColor = .white
        menuBackgroundShadow1.lineWidth = 0
        menuBackgroundShadow1.alpha = 0
        menuBackgroundShadow1.zPosition = -2 * zPositionOffset

        menuBackgroundShadow2 = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackgroundShadow2.position = CGPoint(x: -3 * shadowDepth, y: -3 * shadowDepth)
        menuBackgroundShadow2.strokeColor = .white
        menuBackgroundShadow2.lineWidth = 0
        menuBackgroundShadow2.alpha = 0
        menuBackgroundShadow2.zPosition = -3 * zPositionOffset

        menuBackgroundShadow3 = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackgroundShadow3.position = CGPoint(x: -3 * shadowDepth, y: -3 * shadowDepth)
        menuBackgroundShadow3.strokeColor = .white
        menuBackgroundShadow3.lineWidth = 0
        menuBackgroundShadow3.alpha = 0
        menuBackgroundShadow3.zPosition = -4 * zPositionOffset

        menuStart = MenuItemLabel(text: "Start Game", ofType: .menuStart, at: CGPoint(x: 0, y: menuSize.height / 2 - 1 * menuGap))
        menuLevelSelect = MenuItemLabel(text: "Select Level", ofType: .menuLevelSelect, at: CGPoint(x: 0, y: menuSize.height / 2 - 2 * menuGap))
        menuOptions = MenuItemLabel(text: "Options", ofType: .menuOptions, at: CGPoint(x: 0, y: menuSize.height / 2 - 3 * menuGap))
        menuCredits = MenuItemLabel(text: "Credits", ofType: .menuCredits, at: CGPoint(x: 0, y: menuSize.height / 2 - 4 * menuGap))

        
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
            puzlTitleShadow1.fontColor = DayTheme.skyColor.top.complementary
            boyTitle.fontColor = DayTheme.skyColor.bottom.complementary
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.complementary.complementary.darkenColor(factor: 6)
        case 1:
            puzlTitleShadow1.fontColor = DayTheme.skyColor.bottom.splitComplementary.first
            boyTitle.fontColor = DayTheme.skyColor.bottom.splitComplementary.second
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.splitComplementary.first.darkenColor(factor: 6)
        case 2:
            puzlTitleShadow1.fontColor = DayTheme.skyColor.bottom.analogous.first
            boyTitle.fontColor = DayTheme.skyColor.bottom.analogous.second
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.analogous.first.darkenColor(factor: 6)
        default:
            puzlTitleShadow1.fontColor = DayTheme.skyColor.bottom.triadic.first
            boyTitle.fontColor = DayTheme.skyColor.bottom.triadic.second
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.triadic.first.darkenColor(factor: 6)
        }

        puzlTitle.fontColor = .white
                
        puzlTitleShadow2.fontColor = puzlTitleShadow1.fontColor
        puzlTitleShadow3.fontColor = puzlTitleShadow1.fontColor

        menuBackgroundShadow1.fillColor = puzlTitleShadow1.fontColor ?? .black
        menuBackgroundShadow2.fillColor = menuBackgroundShadow1.fillColor
        menuBackgroundShadow3.fillColor = menuBackgroundShadow1.fillColor
        
        menuBackgroundColor.fillTexture = SKTexture(image: UIImage.menuGradientTexture)
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
        
        puzlTitleShadow1.run(SKAction.sequence([
            SKAction.wait(forDuration: 3 * animationDuration),
            SKAction.fadeAlpha(to: 0.75, duration: animationDuration)
        ]))
        
        puzlTitleShadow2.run(SKAction.sequence([
            SKAction.wait(forDuration: 3 * animationDuration),
            SKAction.fadeAlpha(to: 0.5, duration: 2 * animationDuration)
        ]))
        
        puzlTitleShadow3.run(SKAction.sequence([
            SKAction.wait(forDuration: 3 * animationDuration),
            SKAction.fadeAlpha(to: 0.25, duration: 3 * animationDuration)
        ]))
        
        boyTitle.run(SKAction.sequence([
            SKAction.wait(forDuration: animationDuration),
            SKAction.fadeIn(withDuration: 0),
            stampAction,
        ]))
        
        
        //Menu Animation
        let delayMenu: TimeInterval = 3 * animationDuration
        
        menuBackgroundText.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu + 3 * animationDuration),
            SKAction.fadeAlpha(to: 1.0, duration: 2 * 3 * animationDuration)
        ]))
        
        menuBackgroundColor.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.9, duration: 3 * animationDuration),
                SKAction.sequence([
                    SKAction.move(to: CGPoint(x: -2 * shadowDepth, y: -2 * shadowDepth), duration: animationDuration),
                    SKAction.move(to: CGPoint(x: -1 * shadowDepth, y: -1 * shadowDepth), duration: animationDuration),
                    SKAction.move(to: CGPoint(x: -0 * shadowDepth, y: -0 * shadowDepth), duration: animationDuration)
                ])
            ])
        ]))
        
        menuBackgroundShadow1.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu + animationDuration),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.75, duration: 3 * animationDuration),
                SKAction.sequence([
                    SKAction.move(to: CGPoint(x: -2 * shadowDepth, y: -2 * shadowDepth), duration: animationDuration),
                    SKAction.move(to: CGPoint(x: -1 * shadowDepth, y: -1 * shadowDepth), duration: animationDuration),
                ])
            ])
        ]))

        menuBackgroundShadow2.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu + 2 * animationDuration),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.5, duration: 3 * animationDuration),
                SKAction.move(to: CGPoint(x: -2 * shadowDepth, y: -2 * shadowDepth), duration: animationDuration),
            ])
        ]))
        
        menuBackgroundShadow3.run(SKAction.sequence([
            SKAction.wait(forDuration: delayMenu + 3 * animationDuration),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.25, duration: 3 * animationDuration),
            ])
        ]))

        
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
        addChild(fadeSprite)
        
        puzlTitle.addChild(puzlTitleShadow1)
        puzlTitle.addChild(puzlTitleShadow2)
        puzlTitle.addChild(puzlTitleShadow3)

        menuBackground.addChild(menuBackgroundText)
        menuBackground.addChild(menuBackgroundColor)
        menuBackground.addChild(menuBackgroundShadow1)
        menuBackground.addChild(menuBackgroundShadow2)
        menuBackground.addChild(menuBackgroundShadow3)
        
        menuBackgroundText.addChild(menuStart)
        menuBackgroundText.addChild(menuLevelSelect)
        menuBackgroundText.addChild(menuOptions)
        menuBackgroundText.addChild(menuCredits)
    }
    
    
    // MARK: - UI Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !preventTouch else { return }
        
        for node in nodes(at: location) {
            guard let node = node as? MenuItemLabel else { return }

            node.touchDown()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !preventTouch else { return }
        
        for node in nodes(at: location) {
            guard let node = node as? MenuItemLabel else {
                touchUpButtons()
                continue
            }
            
            node.tapButton(toColor: menuBackgroundShadow1.fillColor)
            touchUpButtons()
        }
    }
    
    private func touchUpButtons() {
        menuStart.touchUp()
        menuLevelSelect.touchUp()
        menuOptions.touchUp()
        menuCredits.touchUp()
    }
}


// MARK: - MenuItemLabelDelegate

extension TitleScene: MenuItemLabelDelegate {
    func buttonWasTapped(_ node: MenuItemLabel) {
        switch node.type {
        case .menuStart:
            let fadeDuration: TimeInterval = 2.0
            
            preventTouch = true
                                            
            AudioManager.shared.stopSound(for: AudioManager.shared.titleLogo, fadeDuration: fadeDuration)

            fadeSprite.run(SKAction.fadeIn(withDuration: fadeDuration)) {
                self.titleSceneDelegate?.didTapStart()
                self.boyTitle.removeAllActions()
                self.preventTouch = false
            }
        case .menuLevelSelect:
            print("Level Select not implemented.")
        case .menuOptions:
            print("Options not implemented.")
        case .menuCredits:
            print("Credits not implemented.")
        }
    }
}
