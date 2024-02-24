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
    private var screenSize: CGSize

    private var fadeOutNode: SKSpriteNode!
    private var skyNode: SKSpriteNode!
    private var moonSprite: MoonSprite!
    private var parallaxManager: ParallaxManager!
    private var player: Player!
    private var playerReflection: Player!
    private var speechBubble: SpeechBubbleSprite!
    private var tapPointerEngine: TapPointerEngine!
    
    private var headingLabel: SKLabelNode!
    private var allRightsLabel: SKLabelNode!
    private var subheadingLabels: [SKLabelNode] = []
    
    private struct LabelEntity {
        let headingText: String
        let subheadingTexts: [String]
        let subheadingAction: SKAction
        let handler: (() -> Void)?
        
        init(headingText: String, subheadingTexts: [String], subheadingAction: SKAction, handler: (() -> Void)? = nil) {
            self.headingText = headingText
            self.subheadingTexts = subheadingTexts
            self.subheadingAction = subheadingAction
            self.handler = handler
        }
    }
    
    weak var creditsSceneDelegate: CreditsSceneDelegate?
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        self.screenSize = size
        
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
        fadeOutNode = SKSpriteNode(color: .black, size: screenSize)
        fadeOutNode.anchorPoint = .zero
        fadeOutNode.alpha = 0
        fadeOutNode.zPosition = K.ZPosition.fadeTransitionNode
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
        skyNode.position = CGPoint(x: 0, y: screenSize.height)
        skyNode.anchorPoint = CGPoint(x: 0, y: 1)
        skyNode.zPosition = K.ZPosition.skyNode

        moonSprite = MoonSprite(position: CGPoint(x: screenSize.width, y: screenSize.height), scale: 0.7 * 3)
        
        parallaxManager = ParallaxManager(useSet: ParallaxObject.SetType.allCases.randomElement() ?? .grass,
                                          xOffsetsArray: nil,
                                          forceSpeed: .walk,
                                          animateForCutscene: false)
        parallaxManager.animate()
        
        tapPointerEngine = TapPointerEngine()



        var randomPlayer: Player.PlayerType

        // FIXME: - princess2 walk textures don't exist off the top of my head. Need to write this special case, which is obviously buggy!
        repeat {
            randomPlayer = Player.PlayerType.allCases.randomElement() ?? .hero
        } while randomPlayer == .princess2
        
        player = Player(type: randomPlayer)
        player.sprite.setScale(Player.cutsceneScale * player.scaleMultiplier)
        player.sprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 4)
        player.sprite.color = DayTheme.spriteColor
        player.sprite.colorBlendFactor = DayTheme.spriteShade
        player.sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        player.sprite.zPosition = K.ZPosition.player
        
        playerReflection = Player(type: randomPlayer)
        playerReflection.sprite.setScale(Player.cutsceneScale * playerReflection.scaleMultiplier)
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
        headingLabel.position = CGPoint(x: screenSize.width / 2, y: screenSize.height * 4 / 5)
        headingLabel.horizontalAlignmentMode = .center
        headingLabel.verticalAlignmentMode = .bottom
        headingLabel.numberOfLines = 0
        headingLabel.fontName = UIFont.chatFont
        headingLabel.fontSize = UIFont.chatFontSizeLarge
        headingLabel.fontColor = UIFont.chatFontColor
        headingLabel.alpha = 0
        headingLabel.zPosition = K.ZPosition.itemsPoints
        headingLabel.addDropShadow()
        
        allRightsLabel = SKLabelNode(text: "©2024 5Play Apps. All rights reserved.")
        allRightsLabel.position = CGPoint(x: screenSize.width / 2, y: screenSize.height * 1 / 9)
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
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disableInput else { return }
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disableInput else { return }
        
        disableInput = true
        ButtonTap.shared.tap(type: .buttontap1)

        fadeOutNode.run(SKAction.fadeIn(withDuration: 1.0)) { [unowned self] in
            disableInput = false
            
            cleanupAndGoBack()
        }
    }
    
    private func cleanupAndGoBack() {
        //BUGFIX# 231222E01 MUST call this here!!! Prevents memory leak when rage quitting early.
        speechBubble.cleanupManually()
        speechBubble = nil
        tapPointerEngine = nil
        
        creditsSceneDelegate?.goBackTapped()
    }
    
    
    // MARK: - Label/Bubble Speech Functions
    
    private func setSpeechBubblesArray(texts: [String], currentIndex: Int = 0, completion: (() -> Void)?) {
        if currentIndex == texts.count {
            //Base case
            completion?()
        }
        else {
            speechBubble.setText(text: texts[currentIndex], superScene: self) { [unowned self] in
                //Recursion!!
                setSpeechBubblesArray(texts: texts, currentIndex: currentIndex + 1, completion: completion)
            }
        }
    }
    
    private func setLabelsArray(entities: [LabelEntity], currentIndex: Int = 0, completion: (() -> Void)?) {
        if currentIndex == entities.count {
            //Base case
            completion?()
        }
        else {
            setLabels(headingText: entities[currentIndex].headingText,
                                subheadingTexts: entities[currentIndex].subheadingTexts,
                                subheadingAction: entities[currentIndex].subheadingAction) { [unowned self] in
                entities[currentIndex].handler?()

                //Recursion!!
                setLabelsArray(entities: entities, currentIndex: currentIndex + 1, completion: completion)
            }
        }
    }
    
    private func setLabels(headingText: String, subheadingTexts: [String], subheadingAction: SKAction, completion: (() -> Void)?) {
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
                labelNode.zRotation = .pi / 12
                labelNode.zPosition += 5
                labelNode.addDropShadow()
            }
            else {
                labelNode.addDropShadow()
            }
            
            subheadingLabels.append(labelNode)
            
            addChild(labelNode)
        }
    }
    
    
    // MARK: - Animation Functions
    
    private func animateScene() {
        let speechBubbleYOffset: CGFloat = UIDevice.isiPad ? 100 : 0
        
        //Credits
        setLabelsArray(entities: [
            LabelEntity(headingText: "5Play Apps presents",
                        subheadingTexts: [],
                        subheadingAction: animateFadeAction()),
            LabelEntity(headingText: "",
                        subheadingTexts: ["PUZL", "Boy"],
                        subheadingAction: animateZoomAction(scale: titleScale)),
            LabelEntity(headingText: "Art Assets",
                        subheadingTexts: ["Deviant Art", "Flaticon", "Freepik", "Game Art 2D"],
                        subheadingAction: animateFadeAction()),
            LabelEntity(headingText: "Created by",
                        subheadingTexts: ["Eddie Char"],
                        subheadingAction: animateFadeAction()) { [unowned self] in
                            speechBubble.run(SKAction.sequence([
                                SKAction.wait(forDuration: waitDuration),
                                SKAction.moveBy(x: 0, y: -speechBubbleYOffset, duration: fadeDuration / 4)
                            ]))
                        },
            LabelEntity(headingText: "Special Thanks",
                        subheadingTexts: ["Clayton Caldwell", "Michelle Rayfield", "Jackson Rayfield", "Aissa Char", "Michel Char"],
                        subheadingAction: animateFadeAction()) { [unowned self] in
                            speechBubble.run(SKAction.moveBy(x: 0, y: speechBubbleYOffset, duration: fadeDuration / 4))
                        },
            LabelEntity(headingText: "for",
                        subheadingTexts: ["Olivia🦄", "and Alana"],
                        subheadingAction: animateFadeAction()),
        ]) { [unowned self] in
            allRightsLabel.run(SKAction.fadeIn(withDuration: fadeDuration)) { [unowned self] in
                disableInput = true
                
                fadeOutNode.run(SKAction.sequence([
                    SKAction.wait(forDuration: waitDuration),
                    SKAction.fadeIn(withDuration: fadeDuration)
                ])) { [unowned self] in
                    cleanupAndGoBack()
                }
            }
        }
        
        
        // TODO: - Speech Bubbles for each Player
        setSpeechBubblesArray(texts: [
            "I can't wait to play this game, I heard great things!",
            "Is it fun? Yes. But is it addictive? Also yes.",
            "Of course I finished all my chores. Why do you ask?",
            "I loaded the dishwasher the way to told me to.",
            "I don't know how the forks ended up on the top shelf.",
            "No because you yelled at me about it last time.",
            "Maybe Gina came over and put them there.",
            "There's the phone, you can give her a call yourself.",
            "I'm not giving you attitude.",
            "Well, I'm not calling you a liar but you's a big fat liar!"
        ], completion: nil)
    }
    
    private func animateFadeAction() -> SKAction {
        return SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeDuration)
        ])
    }
    
    private func animateZoomAction(scale: CGFloat) -> SKAction {
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
    
    
}
