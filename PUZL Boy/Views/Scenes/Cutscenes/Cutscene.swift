//
//  Cutscene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/19/24.
//

import SpriteKit

class Cutscene: SKScene {
    
    // MARK: - Properties
    
    //General
    let playerScale: CGFloat = 0.75
    var screenSize: CGSize
    var playerLeftType: Player.PlayerType
    var playerRightType: Player.PlayerType
    var xOffsetsArray: [ParallaxSprite.SpriteXPositions]?
    var disableTaps: Bool = false
    var completion: (() -> Void)?
    
    //Main Nodes
    var parallaxManager: ParallaxManager!
    var skyNode: SKSpriteNode!
    var playerLeft: Player!
    var playerRight: Player!
    var tapPointerEngine: TapPointerEngine!
    
    //Speech Nodes
    var speechPlayerLeft: SpeechBubbleSprite!
    var speechPlayerRight: SpeechBubbleSprite!
    var speechNarrator: SpeechOverlaySprite!
    var skipIntroSprite: SkipIntroSprite!
    
    //Overlay Nodes
    var backgroundNode: SKShapeNode!
    var dimOverlayNode: SKShapeNode!
    var fadeTransitionNode: SKShapeNode!
    var letterbox: LetterboxSprite!
    
    
    // MARK: - Initialization
    
    init(size: CGSize, playerLeftType: Player.PlayerType, playerRightType: Player.PlayerType, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
        self.screenSize = size
        self.playerLeftType = playerLeftType
        self.playerRightType = playerRightType
        self.xOffsetsArray = xOffsetsArray
        
        super.init(size: size)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Cutscene deinit")
    }
    
    func setupScene() {
        playerLeft = Player(type: playerLeftType)
        playerLeft.sprite.position = CGPoint(x: screenSize.width / 4, y: (screenSize.height - playerScale * playerLeft.sprite.size.height) / 2)
        playerLeft.setPlayerScale(playerScale)
        
        playerRight = Player(type: playerRightType)
        playerRight.sprite.position = CGPoint(x: 3 * screenSize.width / 4, y: (screenSize.height - playerScale * playerRight.sprite.size.height) / 2)
        playerRight.setPlayerScale(playerScale)
        
        skipIntroSprite = SkipIntroSprite(text: "SKIP SCENE")
        skipIntroSprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 9)
        skipIntroSprite.zPosition = K.ZPosition.speechBubble
        
        backgroundNode = SKShapeNode(rectOf: screenSize)
        backgroundNode.lineWidth = 0
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(useMorningSky: true)))
        skyNode.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
        skyNode.position = CGPoint(x: 0, y: screenSize.height)
        skyNode.anchorPoint = CGPoint(x: 0, y: 1)
        skyNode.zPosition = K.ZPosition.skyNode
        
        dimOverlayNode = SKShapeNode(rectOf: screenSize)
        dimOverlayNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        dimOverlayNode.fillColor = .black
        dimOverlayNode.lineWidth = 0
        dimOverlayNode.alpha = 0
        dimOverlayNode.zPosition = K.ZPosition.chatDimOverlay
        
        fadeTransitionNode = SKShapeNode(rectOf: screenSize)
        fadeTransitionNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        fadeTransitionNode.fillColor = .black
        fadeTransitionNode.lineWidth = 0
        fadeTransitionNode.alpha = 0
        fadeTransitionNode.zPosition = K.ZPosition.fadeTransitionNode
        
        tapPointerEngine = TapPointerEngine()
        
        letterbox = LetterboxSprite(color: .black, height: screenSize.height / 3)
        parallaxManager = ParallaxManager(useSet: .grass,
                                          xOffsetsArray: xOffsetsArray,
                                          forceSpeed: .walk,
                                          animateForCutscene: true)
        
        speechNarrator = SpeechOverlaySprite()
        speechPlayerLeft = SpeechBubbleSprite(width: 460, position: CGPoint(x: 200, y: 400))
        speechPlayerRight = SpeechBubbleSprite(width: 460, position: CGPoint(x: -200, y: 400), tailOrientation: .bottomRight)
    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        addChild(letterbox)
        addChild(backgroundNode)
        backgroundNode.addChild(skyNode)
        backgroundNode.addChild(dimOverlayNode)
        backgroundNode.addChild(fadeTransitionNode)
        backgroundNode.addChild(playerLeft.sprite)
        backgroundNode.addChild(playerRight.sprite)
        
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disableTaps else { return }
        guard let location = touches.first?.location(in: self) else { return }
        
        skipIntroSprite.touchesBegan(touches, with: event)
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disableTaps else { return }
        
        skipIntroSprite.touchesEnded(touches, with: event)
    }
    
    
    // MARK: - Animation Functions
    
    func animateScene(completion: (() -> Void)?) {
        //Your implementation goes here.
    }
    
    /**
     Helper to SpeechBubbleSprite.setText(). Takes in an array of SpeechBubbleItems and process them recursively, with nesting completion handlers.
     - parameters:
     - items: array of SpeechBubbleItems to process
     - currentIndex: keeps track of the array index, which is handled recursively
     - completion: process any handlers between text animations.
     */
    func setTextArray(items: [SpeechBubbleItem], currentIndex: Int = 0, completion: (() -> Void)?) {
        guard currentIndex < items.count else {
            //Base case
            completion?()
            
            return
        }
        
        items[currentIndex].profile.setText(text: items[currentIndex].chat, speed: items[currentIndex].speed, superScene: self, parentNode: backgroundNode) { [unowned self] in
            items[currentIndex].handler?()
            
            //Recursion!!
            setTextArray(items: items, currentIndex: currentIndex + 1, completion: completion)
        }
    }
    
    
    // MARK: - Skip Intro Helper Function
    
    ///Call this inside the SkipIntroSpriteDelegate didTapButton() function.
    func skipIntroHelper(fadeDuration: TimeInterval) {
        Haptics.shared.stopHapticEngine()
        ButtonTap.shared.tap(type: .buttontap1)
        tapPointerEngine = nil
        disableTaps = true
        
        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.wait(forDuration: 1),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            self.completion?()
        }
    }
    
    
    
}
