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
    private var puzlTitle: SKLabelNode
    private var puzlTitleShadow: SKLabelNode
    private var puzlTitleShadow2: SKLabelNode
    private var puzlTitleShadow3: SKLabelNode
    private var boyTitle: SKLabelNode
    private var menuStart: MenuItemLabel
    private var menuLevelSelect: MenuItemLabel
    private var menuOptions: MenuItemLabel
    private var menuCredits: MenuItemLabel
    private var menuBackground: SKShapeNode
    private var menuBackgroundColor: SKShapeNode
    
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
        let shadowDepth: CGFloat = 10

        puzlTitle = SKLabelNode(text: "PUZL")
        puzlTitle.position = CGPoint(x: 0, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin)
        puzlTitle.fontName = UIFont.gameFont
        puzlTitle.fontSize = sizeA
        puzlTitle.horizontalAlignmentMode = .left
        puzlTitle.verticalAlignmentMode = .top
        puzlTitle.setScale(2)
        puzlTitle.zPosition = K.ZPosition.puzlTitle
        
        puzlTitleShadow = SKLabelNode(text: "PUZL")
        puzlTitleShadow.position = CGPoint(x: -shadowDepth, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - shadowDepth)
        puzlTitleShadow.fontName = UIFont.gameFont
        puzlTitleShadow.fontSize = sizeA
        puzlTitleShadow.horizontalAlignmentMode = .left
        puzlTitleShadow.verticalAlignmentMode = .top
        puzlTitleShadow.setScale(2)
        puzlTitleShadow.alpha = 0
        puzlTitleShadow.zPosition = K.ZPosition.puzlTitleShadow + 2

        puzlTitleShadow2 = SKLabelNode(text: "PUZL")
        puzlTitleShadow2.position = CGPoint(x: -2 * shadowDepth, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - 2 * shadowDepth)
        puzlTitleShadow2.fontName = UIFont.gameFont
        puzlTitleShadow2.fontSize = sizeA
        puzlTitleShadow2.horizontalAlignmentMode = .left
        puzlTitleShadow2.verticalAlignmentMode = .top
        puzlTitleShadow2.setScale(2)
        puzlTitleShadow2.alpha = 0
        puzlTitleShadow2.zPosition = K.ZPosition.puzlTitleShadow + 1

        puzlTitleShadow3 = SKLabelNode(text: "PUZL")
        puzlTitleShadow3.position = CGPoint(x: -3 * shadowDepth, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - 3 * shadowDepth)
        puzlTitleShadow3.fontName = UIFont.gameFont
        puzlTitleShadow3.fontSize = sizeA
        puzlTitleShadow3.horizontalAlignmentMode = .left
        puzlTitleShadow3.verticalAlignmentMode = .top
        puzlTitleShadow3.setScale(2)
        puzlTitleShadow3.alpha = 0
        puzlTitleShadow3.zPosition = K.ZPosition.puzlTitleShadow

        boyTitle = SKLabelNode(text: "Boy")
        boyTitle.position = CGPoint(x: sizeA, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - sizeB)
        boyTitle.fontName = UIFont.gameFont
        boyTitle.fontSize = sizeB
        boyTitle.horizontalAlignmentMode = .left
        boyTitle.verticalAlignmentMode = .top
        boyTitle.zPosition = K.ZPosition.boyTitle
        boyTitle.setScale(2)
        boyTitle.alpha = 0
        boyTitle.run(SKAction.rotate(toAngle: .pi / 12, duration: 0))
        
        
        //Menu Setup
        let menuSize = CGSize(width: 650, height: K.ScreenDimensions.height / 3)
        let menuGap: CGFloat = 133

        menuBackground = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackground.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.bottomMargin + menuSize.height / 2)
        menuBackground.fillColor = .clear
        menuBackground.strokeColor = .white
        menuBackground.lineWidth = 0
        menuBackground.zPosition = K.ZPosition.menuBackground
        
        menuBackgroundColor = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackgroundColor.position = .zero
        menuBackgroundColor.strokeColor = .white
        menuBackgroundColor.lineWidth = 0
        menuBackgroundColor.alpha = 0.8
                
        menuStart = MenuItemLabel(text: "Start Game", ofType: .menuStart, at: CGPoint(x: 0, y: menuSize.height / 2 - 1 * menuGap))
        menuLevelSelect = MenuItemLabel(text: "Select Level", ofType: .menuLevelSelect, at: CGPoint(x: 0, y: menuSize.height / 2 - 2 * menuGap))
        menuOptions = MenuItemLabel(text: "Options", ofType: .menuOptions, at: CGPoint(x: 0, y: menuSize.height / 2 - 3 * menuGap))
        menuCredits = MenuItemLabel(text: "Credits", ofType: .menuCredits, at: CGPoint(x: 0, y: menuSize.height / 2 - 4 * menuGap))

        
        super.init(size: size)
        
        AudioManager.shared.playSound(for: AudioManager.shared.overworldTitle)
        
        menuLevelSelect.setIsEnabled(false)
        mixColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func mixColors() {
        switch Int.random(in: 0...3) {
        case 0:
            puzlTitleShadow.fontColor = DayTheme.skyColor.top.complementary
            boyTitle.fontColor = DayTheme.skyColor.bottom.complementary
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.complementary
        case 1:
            puzlTitleShadow.fontColor = DayTheme.skyColor.bottom.splitComplementary.first
            boyTitle.fontColor = DayTheme.skyColor.bottom.splitComplementary.second
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.splitComplementary.first
        case 2:
            puzlTitleShadow.fontColor = DayTheme.skyColor.bottom.analogous.first
            boyTitle.fontColor = DayTheme.skyColor.bottom.analogous.second
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.analogous.first
        default:
            puzlTitleShadow.fontColor = DayTheme.skyColor.bottom.triadic.first
            boyTitle.fontColor = DayTheme.skyColor.bottom.triadic.second
            menuBackgroundColor.fillColor = DayTheme.skyColor.top.triadic.first
        }

        puzlTitle.fontColor = .white
        puzlTitleShadow2.fontColor = puzlTitleShadow.fontColor
        puzlTitleShadow3.fontColor = puzlTitleShadow.fontColor
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(player.sprite)
        addChild(puzlTitle)
        addChild(boyTitle)
        addChild(menuBackground)
        addChild(fadeSprite)
        
        addChild(puzlTitleShadow)
        addChild(puzlTitleShadow2)
        addChild(puzlTitleShadow3)

        menuBackground.addChild(menuBackgroundColor)
        menuBackground.addChild(menuStart)
        menuBackground.addChild(menuLevelSelect)
        menuBackground.addChild(menuOptions)
        menuBackground.addChild(menuCredits)
        

        let stampAction = SKAction.group([
            SKAction.sequence([
                SKAction.moveBy(x: 100, y: -100, duration: 0.1),
                SKAction.moveBy(x: -20, y: 20, duration: 0.2)
            ]),
            SKAction.sequence([
                SKAction.scale(to: 0.75, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
        ])
        
        puzlTitle.run(stampAction)
        puzlTitleShadow.run(SKAction.sequence([
            stampAction,
            SKAction.fadeAlpha(to: 0.75, duration: 0.1)
        ]))
        puzlTitleShadow2.run(SKAction.sequence([
            stampAction,
            SKAction.fadeAlpha(to: 0.5, duration: 0.2)
        ]))
        puzlTitleShadow3.run(SKAction.sequence([
            stampAction,
            SKAction.fadeAlpha(to: 0.25, duration: 0.3)
        ]))
        
        boyTitle.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeIn(withDuration: 0),
            stampAction,
        ]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard !preventTouch else { return }
        
        for node in nodes(at: location) {
            guard let node = node as? MenuItemLabel else { continue }
            
            node.tapButton(toColor: boyTitle.fontColor!)
            
            switch node.type {
            case .menuStart:
                let fadeDuration: TimeInterval = 2.0
                
                preventTouch = true
                                                
                AudioManager.shared.stopSound(for: AudioManager.shared.overworldTitle, fadeDuration: fadeDuration)

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
    
    
}
