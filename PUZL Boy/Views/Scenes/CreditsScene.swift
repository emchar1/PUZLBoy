//
//  CreditsScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/5/23.
//

import SpriteKit

protocol CreditsSceneDelegate: AnyObject {
    func goBackTapped()
}

class CreditsScene: SKScene {
    
    // MARK: - Properties
    
    private let fadeDuration: TimeInterval = 2
    private let waitDuration: TimeInterval = 3
    private let titleScale: CGFloat = 3
    private let skyColor: (first: UIColor, second: UIColor) = DayTheme.skyColor.bottom.triadic
    private var disableInput = false

    private var fadeOutNode: SKSpriteNode!
    private var skyNode: SKSpriteNode!
    private var moonSprite: MoonSprite!
    private var parallaxManager: ParallaxManager!
    private var player: Player!
    private var playerReflection: Player!
    private var speechBubble: SpeechBubbleSprite!
    
    private var headingLabel: SKLabelNode!
    private var allRightsLabel: SKLabelNode!
    private var subheadingLabels: [SKLabelNode] = []

    weak var creditsSceneDelegate: CreditsSceneDelegate?
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupNodes()
        animateScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CreditsScene deinit")
    }
    
    private func setupNodes() {
        fadeOutNode = SKSpriteNode(color: .black, size: K.ScreenDimensions.size)
        fadeOutNode.anchorPoint = .zero
        fadeOutNode.alpha = 0
        fadeOutNode.zPosition = K.ZPosition.fadeTransitionNode
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.size = CGSize(width: K.ScreenDimensions.size.width, height: K.ScreenDimensions.size.height / 2)
        skyNode.position = CGPoint(x: 0, y: K.ScreenDimensions.size.height)
        skyNode.anchorPoint = CGPoint(x: 0, y: 1)
        skyNode.zPosition = K.ZPosition.skyNode

        moonSprite = MoonSprite(position: CGPoint(x: K.ScreenDimensions.size.width, y: K.ScreenDimensions.size.height), scale: 0.7 * 3)

        parallaxManager = ParallaxManager(useSet: ParallaxObject.SetType.allCases.randomElement() ?? .grass, xOffsetsArray: nil, forceSpeed: .walk)
        parallaxManager.animate()

        let randomPlayer = Player.PlayerType.allCases.randomElement() ?? .hero
        let scaleMultiplier: CGFloat
        
        switch randomPlayer {
        case .princess:     scaleMultiplier = 0.8
        case .villain:      scaleMultiplier = 1.5
        default:            scaleMultiplier = 1
        }
        
        player = Player(type: randomPlayer)
        player.sprite.setScale(0.75 * scaleMultiplier)
        player.sprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 4)
        player.sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        player.sprite.color = DayTheme.spriteColor
        player.sprite.colorBlendFactor = DayTheme.spriteShade
        player.sprite.zPosition = K.ZPosition.player
        
        playerReflection = Player(type: randomPlayer)
        playerReflection.sprite.setScale(0.75 * scaleMultiplier)
        playerReflection.sprite.position = player.sprite.position + CGPoint(x: 0, y: player.sprite.size.height / 4 - 10) //why -10???
        playerReflection.sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        playerReflection.sprite.color = DayTheme.spriteColor
        playerReflection.sprite.colorBlendFactor = DayTheme.spriteShade
        playerReflection.sprite.yScale *= -1
        playerReflection.sprite.alpha = 0.25

        let frameRate: TimeInterval = 0.06
        let playerAnimate = randomPlayer == .villain ? SKAction.animate(with: player.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate) : SKAction.animate(with: player.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)

        player.sprite.run(SKAction.repeatForever(playerAnimate))
        playerReflection.sprite.run(SKAction.repeatForever(playerAnimate))
        
        let speechBubbleWidth: CGFloat = 400
        
        speechBubble = SpeechBubbleSprite(width: speechBubbleWidth, 
                                          position: player.sprite.position + CGPoint(x: speechBubbleWidth / 2, y: Player.size.height),
                                          tailOrientation: .bottomLeft)
        
        headingLabel = SKLabelNode(text: "Heading Label")
        headingLabel.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height * 4 / 5)
        headingLabel.horizontalAlignmentMode = .center
        headingLabel.verticalAlignmentMode = .bottom
        headingLabel.numberOfLines = 0
        headingLabel.fontName = UIFont.chatFont
        headingLabel.fontSize = UIFont.chatFontSizeLarge
        headingLabel.fontColor = UIFont.chatFontColor
        headingLabel.alpha = 0
        headingLabel.zPosition = K.ZPosition.itemsPoints
        headingLabel.addDropShadow()
        
        allRightsLabel = SKLabelNode(text: "©2023 5Play Apps. All rights reserved.")
        allRightsLabel.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height * 1 / 9)
        allRightsLabel.horizontalAlignmentMode = .center
        allRightsLabel.verticalAlignmentMode = .top
        allRightsLabel.fontName = UIFont.chatFont
        allRightsLabel.fontSize = UIFont.chatFontSizeLarge
        allRightsLabel.fontColor = UIFont.chatFontColor
        allRightsLabel.alpha = 0
        allRightsLabel.zPosition = K.ZPosition.itemsPoints
        allRightsLabel.addDropShadow()
    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        addChild(player.sprite)
        addChild(skyNode)
        addChild(moonSprite)
        addChild(headingLabel)
        addChild(allRightsLabel)
        addChild(fadeOutNode)

        parallaxManager.addSpritesToParent(scene: self)

        if parallaxManager.set == .marsh {
            addChild(playerReflection.sprite)
        }
    }
    
    
    // MARK: - Text Functions
    
    private func setSubheadingLabels(texts: [String]) {
        for node in children.filter({ $0.name == "subheadingName" }) {
            node.removeFromParent()
        }
        
        subheadingLabels = []
        
        for (i, text) in texts.enumerated() {
            let labelNode = SKLabelNode(text: text.uppercased())
            labelNode.position = headingLabel.position + CGPoint(x: 0, y: -CGFloat(i) * UIFont.gameFontSizeExtraLarge)
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .top
            labelNode.numberOfLines = 0
            labelNode.fontName = UIFont.gameFont
            labelNode.fontSize = UIFont.gameFontSizeExtraLarge
            labelNode.fontColor = UIFont.gameFontColor
            labelNode.alpha = 0
            labelNode.zPosition = K.ZPosition.itemsPoints
            labelNode.name = "subheadingName"
            
            if text == "PUZL" {
                labelNode.verticalAlignmentMode = .center
                labelNode.addTripleShadow(shadow1Color: skyColor.first, shadow2Color: skyColor.first, shadow3Color: skyColor.first)
                labelNode.showShadow(completion: nil)
            }
            else if text == "Boy" {
                labelNode.position = headingLabel.position + CGPoint(x: UIFont.gameFontSizeExtraLarge,
                                                                     y: -CGFloat(i) * UIFont.gameFontSizeExtraLarge * 2 / 5)
                labelNode.fontColor = skyColor.second
                labelNode.fontSize = UIFont.gameFontSizeExtraLarge * 4 / 5
                labelNode.zPosition += 5
                labelNode.addDropShadow()
                
                labelNode.run(SKAction.rotate(toAngle: .pi / 12, duration: 0))
            }
            else {
                labelNode.addDropShadow()
            }
            
            subheadingLabels.append(labelNode)
            
            addChild(labelNode)
        }
    }
    
    private func setAndAnimateLabels(headingText: String, subheadingTexts: [String], subheadingAction: SKAction, completion: (() -> Void)?) {
        headingLabel.text = headingText
        headingLabel.updateShadow()
        
        headingLabel.run(animateFadeAction()) {
            completion?()
        }
        
        setSubheadingLabels(texts: subheadingTexts)
        
        for subheading in subheadingLabels {
            subheading.run(subheadingAction)
        }
    }
    
    func animateFadeAction() -> SKAction {
        return SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeDuration)
        ])
    }
    
    func animateZoomAction(scale: CGFloat) -> SKAction {
        return SKAction.sequence([
            SKAction.scale(to: 0, duration: 0),
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: waitDuration),
            SKAction.scale(to: scale * 1.1, duration: 0.25),
            SKAction.scale(to: scale * 0.95, duration: 0.2),
            SKAction.scale(to: scale, duration: 0.2),
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeDuration)
        ])
    }
    
    private func animateScene() {
        let speechBubbleYOffset: CGFloat = UIDevice.isiPad ? 100 : 0
        
        //Credits
        setAndAnimateLabels(headingText: "5Play Apps presents", subheadingTexts: [], subheadingAction: animateFadeAction()) { [unowned self] in
            setAndAnimateLabels(headingText: "", subheadingTexts: ["PUZL", "Boy"], subheadingAction: animateZoomAction(scale: titleScale)) { [unowned self] in
                setAndAnimateLabels(headingText: "Art Assets", subheadingTexts: ["Freepik", "Icons8", "Flaticon"], subheadingAction: animateFadeAction()) { [unowned self] in
                    setAndAnimateLabels(headingText: "Created by", subheadingTexts: ["Eddie Char"], subheadingAction: animateFadeAction()) { [unowned self] in
                        
                        speechBubble.run(SKAction.sequence([
                            SKAction.wait(forDuration: waitDuration),
                            SKAction.moveBy(x: 0, y: -speechBubbleYOffset, duration: fadeDuration / 4)
                        ]))
                        
                        setAndAnimateLabels(headingText: "Special Thanks", subheadingTexts: ["Clayton Caldwell", "Michelle Rayfield", "Jackson Rayfield", "Aissa Char", "Michel Char"], subheadingAction: animateFadeAction()) { [unowned self] in
                            
                            speechBubble.run(SKAction.moveBy(x: 0, y: speechBubbleYOffset, duration: fadeDuration / 4))
                            
                            setAndAnimateLabels(headingText: "for", subheadingTexts: ["Olivia", "and Alana"], subheadingAction: animateFadeAction()) { [unowned self] in
                                allRightsLabel.run(SKAction.fadeIn(withDuration: fadeDuration)) { [unowned self] in
                                    disableInput = true
                                    
                                    fadeOutNode.run(SKAction.sequence([
                                        SKAction.wait(forDuration: waitDuration),
                                        SKAction.fadeIn(withDuration: fadeDuration)
                                    ])) { [unowned self] in
                                        creditsSceneDelegate?.goBackTapped()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // TODO: - Speech Bubbles
        speechBubble.setText(text: "I can't wait to play this game, I heard great things!", superScene: self) {
            self.speechBubble.setText(text: "Is it fun? Yes. But is it addictive? Also yes.", superScene: self) {
                self.speechBubble.setText(text: "Of course I finished all my chores! Why do you ask?", superScene: self) {
                    self.speechBubble.setText(text: "I loaded the dishwasher the way to told me to...", superScene: self) {
                        self.speechBubble.setText(text: "No, I don't know how the cutlery ended up on the top shelf.", superScene: self) {
                            self.speechBubble.setText(text: "I didn't because remember you yelled at me about it last time.", superScene: self) {
                                self.speechBubble.setText(text: "I dunno, maybe the neighbor came over and put them there.", superScene: self) {
                                    self.speechBubble.setText(text: "No I'm not calling you a liar. But I told you it wasn't me.", superScene: self) {
                                        self.speechBubble.setText(text: "Oh wait... the phone rang and I got distracted... Yeah, it was me.", superScene: self, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disableInput else { return }
        
        disableInput = true
        ButtonTap.shared.tap(type: .buttontap1)

        fadeOutNode.run(SKAction.fadeIn(withDuration: 1.0)) { [unowned self] in
            disableInput = false
            
            creditsSceneDelegate?.goBackTapped()
        }
    }
}
