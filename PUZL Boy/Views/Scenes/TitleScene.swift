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
    
    private static let rangeSize: CGFloat = 50
    private static let range0: ClosedRange<CGFloat> = (255 - rangeSize) / 255...1
    private static let range1: ClosedRange<CGFloat> = (165 - rangeSize) / 255...165 / 255
    private static let range2: ClosedRange<CGFloat> = 0...rangeSize / 255
    private static let boyColors: [UIColor] = [
        //Reds
        UIColor(red: CGFloat.random(in: range0), green: CGFloat.random(in: range2), blue: CGFloat.random(in: range2), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range0), green: CGFloat.random(in: range1), blue: CGFloat.random(in: range2), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range0), green: CGFloat.random(in: range0), blue: CGFloat.random(in: range2), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range0), green: CGFloat.random(in: range2), blue: CGFloat.random(in: range1), alpha: 1.0),

        //Greens
        UIColor(red: CGFloat.random(in: range2), green: CGFloat.random(in: range0), blue: CGFloat.random(in: range2), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range2), green: CGFloat.random(in: range0), blue: CGFloat.random(in: range1), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range2), green: CGFloat.random(in: range0), blue: CGFloat.random(in: range0), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range1), green: CGFloat.random(in: range0), blue: CGFloat.random(in: range2), alpha: 1.0),

        //Blues
        UIColor(red: CGFloat.random(in: range2), green: CGFloat.random(in: range2), blue: CGFloat.random(in: range0), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range1), green: CGFloat.random(in: range2), blue: CGFloat.random(in: range0), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range0), green: CGFloat.random(in: range2), blue: CGFloat.random(in: range0), alpha: 1.0),
        UIColor(red: CGFloat.random(in: range2), green: CGFloat.random(in: range1), blue: CGFloat.random(in: range0), alpha: 1.0),
    ]
    private static let selectedColor = Int.random(in: 0..<boyColors.count)
    
    private let menuSize = CGSize(width: 650, height: K.ScreenDimensions.height / 3)
    private let menuGap: CGFloat = 133
    private var player = Player()
    private var skyNode: SKSpriteNode
    private var puzlTitle: SKLabelNode
    private var puzlTitleShadow: SKLabelNode
    private var boyTitle: SKLabelNode
    private var menuStart: SKLabelNode
    private var menuLevelSelect: SKLabelNode
    private var menuOptions: SKLabelNode
    private var menuCredits: SKLabelNode
    private var menuBackground: SKShapeNode
    private var fadeSprite: SKSpriteNode
    
    weak var titleSceneDelegate: TitleSceneDelegate?
    
    
    // MARK: - Initializtion
    
    override init(size: CGSize) {
        let sizeA: CGFloat = K.ScreenDimensions.iPhoneWidth / 4
        let sizeB: CGFloat = sizeA * (4 / 5)

        player.sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        player.sprite.setScale(2)
        player.sprite.texture = SKTexture(imageNamed: "Run (5)")
        player.sprite.name = "playerSprite"
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = "skyNode"
        
        puzlTitle = SKLabelNode(text: "PUZL")
        puzlTitle.position = CGPoint(x: 0, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin)
        puzlTitle.fontName = UIFont.gameFont
        puzlTitle.fontSize = sizeA
        puzlTitle.fontColor = .white
        puzlTitle.horizontalAlignmentMode = .left
        puzlTitle.verticalAlignmentMode = .top
        puzlTitle.setScale(2)
        puzlTitle.zPosition = K.ZPosition.puzlTitle
        
        puzlTitleShadow = SKLabelNode(text: "PUZL")
        puzlTitleShadow.position = CGPoint(x: 20, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - 20)
        puzlTitleShadow.fontName = UIFont.gameFont
        puzlTitleShadow.fontSize = sizeA
        puzlTitleShadow.fontColor = .black
        puzlTitleShadow.horizontalAlignmentMode = .left
        puzlTitleShadow.verticalAlignmentMode = .top
        puzlTitleShadow.setScale(2)
        puzlTitleShadow.zPosition = K.ZPosition.puzlTitleShadow

        boyTitle = SKLabelNode(text: "Boy")
        boyTitle.position = CGPoint(x: sizeA, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - sizeB)
        boyTitle.fontName = UIFont.gameFont
        boyTitle.fontSize = sizeB
        boyTitle.fontColor = .white//TitleScene.boyColors[TitleScene.selectedColor]
        boyTitle.horizontalAlignmentMode = .left
        boyTitle.verticalAlignmentMode = .top
        boyTitle.zPosition = K.ZPosition.boyTitle
        boyTitle.setScale(2)
        boyTitle.alpha = 0
        boyTitle.run(SKAction.rotate(toAngle: .pi / 12, duration: 0))
        
        menuStart = SKLabelNode(text: "Start Game")
        menuStart.position = CGPoint(x: 0, y: menuSize.height / 2 - menuGap)
        menuStart.fontName = UIFont.chatFont
        menuStart.fontSize = 75
        menuStart.fontColor = .white
        menuStart.horizontalAlignmentMode = .center
        menuStart.verticalAlignmentMode = .center
        menuStart.zPosition = K.ZPosition.menuItem
        menuStart.name = "menuStart"

        menuLevelSelect = SKLabelNode(text: "Level Select")
        menuLevelSelect.position = CGPoint(x: 0, y: menuSize.height / 2 - 2 * menuGap)
        menuLevelSelect.fontName = UIFont.chatFont
        menuLevelSelect.fontSize = 75
        menuLevelSelect.fontColor =  .white
        menuLevelSelect.horizontalAlignmentMode = .center
        menuLevelSelect.verticalAlignmentMode = .center
        menuLevelSelect.alpha = 0.25
        menuLevelSelect.zPosition = K.ZPosition.menuItem

        menuOptions = SKLabelNode(text: "Options")
        menuOptions.position = CGPoint(x: 0, y: menuSize.height / 2 - 3 * menuGap)
        menuOptions.fontName = UIFont.chatFont
        menuOptions.fontSize = 75
        menuOptions.fontColor = .white
        menuOptions.horizontalAlignmentMode = .center
        menuOptions.verticalAlignmentMode = .center
        menuOptions.alpha = 0.25
        menuOptions.zPosition = K.ZPosition.menuItem

        menuCredits = SKLabelNode(text: "Credits")
        menuCredits.position = CGPoint(x: 0, y: menuSize.height / 2 - 4 * menuGap)
        menuCredits.fontName = UIFont.chatFont
        menuCredits.fontSize = 75
        menuCredits.fontColor = .white
        menuCredits.horizontalAlignmentMode = .center
        menuCredits.verticalAlignmentMode = .center
        menuCredits.alpha = 0.25
        menuCredits.zPosition = K.ZPosition.menuItem
        
        menuBackground = SKShapeNode(rectOf: CGSize(width: menuSize.width, height: menuSize.height), cornerRadius: 20)
        menuBackground.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.bottomMargin + menuSize.height / 2)
        menuBackground.fillColor = DayTheme.skyColor.top
        menuBackground.strokeColor = .white
        menuBackground.lineWidth = 0
        menuBackground.alpha = 0.9
        menuBackground.zPosition = K.ZPosition.menuBackground

        fadeSprite = SKSpriteNode(color: .white, size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        fadeSprite.anchorPoint = .zero
        fadeSprite.alpha = 0
        fadeSprite.zPosition = K.ZPosition.fadeTransitionNode
        fadeSprite.name = "fadeSprite"

        super.init(size: size)
        
        AudioManager.shared.playSound(for: AudioManager.shared.overworldTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(player.sprite)
        addChild(puzlTitleShadow)
        addChild(puzlTitle)
        addChild(boyTitle)
        addChild(menuBackground)
        addChild(fadeSprite)
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
        
        let seizureDuration: TimeInterval = 0.1
        let seizureAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.colorize(with: TitleScene.boyColors[0], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[1], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[2], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[3], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[4], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[5], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[6], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[7], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[8], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[9], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[10], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: TitleScene.boyColors[11], colorBlendFactor: 1, duration: seizureDuration),
            SKAction.colorize(with: .white, colorBlendFactor: 1, duration: seizureDuration)
        ]))
        
        puzlTitleShadow.run(stampAction)
        puzlTitle.run(stampAction)
        
        boyTitle.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeIn(withDuration: 0),
            stampAction,
            seizureAction
        ]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        for node in nodes(at: location) {
            switch node.name {
            case "menuStart":
                let fadeDuration: TimeInterval = 2.0
                                
                AudioManager.shared.stopSound(for: AudioManager.shared.overworldTitle, fadeDuration: fadeDuration) {
                    self.titleSceneDelegate?.didTapStart()
                    self.boyTitle.removeAllActions()
                }

                fadeSprite.run(SKAction.fadeIn(withDuration: fadeDuration))
                buttonTap(button: menuStart)
            default:
                Haptics.shared.addHapticFeedback(withStyle: .rigid)
            }
        }
    }
    
    private func buttonTap(button: SKLabelNode) {
        button.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1, duration: 0.2)
        ]))
        
        K.ButtonTaps.tap1()
    }
    
    
}
