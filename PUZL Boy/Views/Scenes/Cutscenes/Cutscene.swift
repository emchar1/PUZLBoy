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
    var screenSize: CGSize
    var playerLeftScale: CGFloat
    var playerRightScale: CGFloat
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
    var skipSceneSprite: SkipSceneSprite!
    
    //Overlay Nodes
    var backgroundNode: SKShapeNode!
    var dimOverlayNode: SKShapeNode!
    var fadeTransitionNode: SKShapeNode!
    var letterbox: LetterboxSprite!
    
    
    // MARK: - Initialization
    
    init(size: CGSize, playerLeftType: Player.PlayerType, playerLeftScale: CGFloat, playerRightType: Player.PlayerType, playerRightScale: CGFloat, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
        self.screenSize = size
        self.playerLeftType = playerLeftType
        self.playerLeftScale = playerLeftScale
        self.playerRightType = playerRightType
        self.playerRightScale = playerRightScale
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
        playerLeft.sprite.position = CGPoint(x: screenSize.width * 1 / 4, y: screenSize.height / 3 + (playerLeftScale - Player.cutsceneScale) / 2)
        playerLeft.sprite.setScale(playerLeftScale)

        playerRight = Player(type: playerRightType)
        playerRight.sprite.position = CGPoint(x: screenSize.width * 3 / 4, y: screenSize.height / 3 + (playerRightScale - Player.cutsceneScale) / 2)
        playerRight.sprite.setScale(playerRightScale)

        skipSceneSprite = SkipSceneSprite(text: "SKIP SCENE")
        skipSceneSprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 9)
        skipSceneSprite.zPosition = K.ZPosition.speechBubble
        
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
        
        skipSceneSprite.touchesBegan(touches, with: event)
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disableTaps else { return }
        
        skipSceneSprite.touchesEnded(touches, with: event)
    }
    
    
    // MARK: - Animation Functions
    
    /**
     Custom animation function that sets the completion handler. Needs implementation in the inheriting child class.
        - parameter completion: completion handler to execute, ideally at the end of all animations (dependent on how the inheriting class implements this function.)
     */
    func animateScene(completion: (() -> Void)?) {
        self.completion = completion
        
        //Add'l implementation goes here.
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
    
    
    // MARK: - Cleanup Scene
    
    /**
     Initiates a button tap and cleans up the scene as it transitions out.
     - parameters:
        - fadeDuration: the duration of thue fadeTransitionNode as it fades in.
        - buttonTap: the type of button tap to play, if non-nil.
     */
    func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        Haptics.shared.stopHapticEngine()
        
        if let buttonTap = buttonTap {
            ButtonTap.shared.tap(type: buttonTap)
        }

        tapPointerEngine = nil
        disableTaps = true
        
        if let fadeDuration = fadeDuration {
            fadeTransitionNode.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: fadeDuration),
                SKAction.wait(forDuration: 1),
                SKAction.removeFromParent()
            ])) { [unowned self] in
                completion?()
            }
        }
        else {
            completion?()
        }
    }

    
}
