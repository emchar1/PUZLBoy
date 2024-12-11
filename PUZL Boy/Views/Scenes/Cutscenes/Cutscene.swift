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
    var xOffsetsArray: [ParallaxSprite.SpriteXPositions]?
    var disableTaps: Bool = false
    var completion: (() -> Void)?
    
    //Main Nodes
    var playerLeft: Player
    var playerRight: Player
    var parallaxManager: ParallaxManager!
    var skyNode: SKSpriteNode!
    var bloodSkyNode: SKSpriteNode!
    var tapPointerEngine: TapPointerEngine!
    let playerLeftNodeName = "PlayerLeftNode"
    let playerRightNodeName = "PlayerRightNode"
    
    //Speech Nodes
    var speechPlayerLeft: SpeechBubbleSprite!
    var speechPlayerRight: SpeechBubbleSprite!
    var speechNarrator: SpeechOverlaySprite!
    var skipSceneSprite: SkipSceneSprite!
    
    //Overlay Nodes
    var backgroundNode: SKShapeNode!
    var dimOverlayNode: SKShapeNode!
    var bloodOverlayNode: SKShapeNode!
    var fadeTransitionNode: SKShapeNode!
    var letterbox: LetterboxSprite!
    
    //Misc Data Structures
    struct NarrationItem {
        let text: String
        let fontColor: UIColor
        let animationSpeed: TimeInterval
        let handler: (() -> Void)?
                
        init(text: String, fontColor: UIColor, animationSpeed: TimeInterval, handler: (() -> Void)?) {
            self.text = text
            self.fontColor = fontColor
            self.animationSpeed = animationSpeed
            self.handler = handler
        }
        
        init(text: String) {
            self.init(text: text, fontColor: SpeechOverlaySprite.fontColorOrig, animationSpeed: SpeechOverlaySprite.animationSpeedOrig, handler: nil)
        }
    }
    
    
    // MARK: - Initialization
    
    init(size: CGSize, playerLeft: Player.PlayerType, playerRight: Player.PlayerType, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
        self.screenSize = size
        self.playerLeft = Player(type: playerLeft)
        self.playerRight = Player(type: playerRight)
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
        playerLeft.sprite.zPosition += 5
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)
        playerLeft.sprite.position = CGPoint(x: screenSize.width * 1 / 4,
                                             y: screenSize.height / 3 + Player.getNormalizedAdjustedHeight(player: playerLeft))
        playerLeft.sprite.name = playerLeftNodeName

        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.position = CGPoint(x: screenSize.width * 3 / 4,
                                              y: screenSize.height / 3 + Player.getNormalizedAdjustedHeight(player: playerRight))
        playerRight.sprite.name = playerRightNodeName

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

        let skyNodeReverse = skyNode.copy() as! SKSpriteNode
        skyNodeReverse.position.y = 0
        skyNodeReverse.anchorPoint.y = -1
        skyNodeReverse.yScale *= -1
        skyNode.addChild(skyNodeReverse)

        dimOverlayNode = SKShapeNode(rectOf: screenSize)
        dimOverlayNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        dimOverlayNode.fillColor = .black
        dimOverlayNode.lineWidth = 0
        dimOverlayNode.alpha = 0
        dimOverlayNode.zPosition = K.ZPosition.chatDimOverlay

        bloodSkyNode = SKSpriteNode(texture: SKTexture(image: UIImage.gradientTextureSkyBlood))
        bloodSkyNode.size = CGSize(width: screenSize.width, height: screenSize.height)
        bloodSkyNode.position = CGPoint(x: 0, y: screenSize.height)
        bloodSkyNode.anchorPoint = CGPoint(x: 0, y: 1)
        bloodSkyNode.zPosition = K.ZPosition.skyNode
        bloodSkyNode.alpha = 0
        
        bloodOverlayNode = SKShapeNode(rectOf: screenSize)
        bloodOverlayNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        bloodOverlayNode.fillColor = .red
        bloodOverlayNode.lineWidth = 0
        bloodOverlayNode.alpha = 0
        bloodOverlayNode.zPosition = K.ZPosition.bloodOverlay
        
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
        backgroundNode.addChild(bloodSkyNode)
        backgroundNode.addChild(bloodOverlayNode)
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
     Removes the previous texture animation and runs a new texture animation on the Player inout argument.
     - parameters:
        - player: the player object to animate.
        - textureType: the type of animation texture to play.
        - timePerFrame: the duration of each frame of the animation. Defaults to nil, which will use the default timePerFrame in Player.animate().
        - timePerFrameMultiplier: adds a multiplier to the timePerFrame, which defaults to 1.
        - repeatCount: number of times to play the animation, or -1 to repeat forever.
     */
    func animatePlayerWithTextures(player: inout Player,
                                   textureType: Player.Texture,
                                   timePerFrame: TimeInterval? = nil,
                                   timePerFrameMultiplier: TimeInterval = 1,
                                   repeatCount: Int = -1) {
        
        let key = "animatePlayerWithTexturesKey"
        let repeatAction = Player.animate(player: player,
                                          type: textureType,
                                          timePerFrame: timePerFrame,
                                          timePerFrameMultiplier: timePerFrameMultiplier,
                                          repeatCount: repeatCount)
        
        player.sprite.removeAction(forKey: key)
        player.sprite.run(repeatAction, withKey: key)
    }
    
    /**
     Simulates the background shaking due to an earthquake or some other life shattering event.
     - parameter duration: the length of time of the shake, which gets multiplied by 4, e.g. duration of 6 -> 6 x 4 =  24 seconds of actual shaking.
     - returns: SKAction of the shake event.
     */
    func shakeBackground(duration: TimeInterval) -> SKAction {
        let nudge: CGFloat = 5
        let nudgeDuration: TimeInterval = 0.04
        
        return SKAction.repeat(SKAction.sequence([
            SKAction.moveBy(x: -nudge, y: nudge, duration: nudgeDuration),
            SKAction.moveBy(x: nudge, y: nudge, duration: nudgeDuration),
            SKAction.moveBy(x: nudge, y: -nudge, duration: nudgeDuration),
            SKAction.moveBy(x: -nudge, y: -nudge, duration: nudgeDuration),
        ]), count: Int(duration / nudgeDuration))
    }
    
    /**
     Dims the sky to a blood-soaked color. To be used when apocalyptic events occur.
     - parameters:
        - fadeDuration: the speed at which the sky darkens
        - delay: add a delay, if desired
     */
    func showBloodSky(fadeDuration: TimeInterval, delay: TimeInterval? = nil) {
        skyNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.fadeOut(withDuration: fadeDuration)
        ]))

        bloodSkyNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.fadeIn(withDuration: fadeDuration)
        ]))
        
        bloodOverlayNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.fadeAlpha(to: 0.35, duration: fadeDuration)
        ]))
    }
    
    /**
     Returns the sky to its original color.
     - parameter fadeDuration: the speed at which the sky returns to normal
     */
    func hideBloodSky(fadeDuration: TimeInterval) {
        skyNode.run(SKAction.fadeIn(withDuration: fadeDuration))
        bloodSkyNode.run(SKAction.fadeOut(withDuration: fadeDuration))
        bloodOverlayNode.run(SKAction.fadeOut(withDuration: fadeDuration))
    }
    
    
    // MARK: - Text Functions
    
    /**
     Helper to SpeechBubbleSprite.setText(). Takes in an array of SpeechBubbleItems and process them recursively, with nesting completion handlers.
     - parameters:
        - items: array of SpeechBubbleItems to process
        - currentIndex: keeps track of the array index, which is handled recursively
        - completion: process any handlers between text animations.
     */
    final func setTextArray(items: [SpeechBubbleItem], currentIndex: Int = 0, completion: (() -> Void)?) {
        guard currentIndex < items.count else {
            //Base case
            completion?()
            
            return
        }
        
        items[currentIndex].profile.setText(text: items[currentIndex].chat, speed: items[currentIndex].speed, superScene: self, parentNode: backgroundNode) { [weak self] in
            items[currentIndex].handler?()
            
            //Recursion!!
            self?.setTextArray(items: items, currentIndex: currentIndex + 1, completion: completion)
        }
    }
    
    /**
     Adds an array of narration text, similar to the ChatArray() function in ChatEngine.
     - parameters:
        - items: the array of NarrationItems
        - currentIndex: don't set this explicitly! Let the recursive function set it
        - completion: handler to execute at the end of the recursion function
     */
    func narrateArray(items: [NarrationItem], currentIndex: Int = 0, completion: (() -> Void)?) {
        if currentIndex == items.count {
            //Base case
            speechNarrator.resetValues()
            completion?()
        }
        else {
            let item = items[currentIndex]

            speechNarrator.setValues(color: item.fontColor, animationSpeed: item.animationSpeed)
            speechNarrator.setText(text: item.text, superScene: self) { [weak self] in
                item.handler?()
                
                //Recursion!! Also the [weak self] prevents a retain cycle here...
                self?.narrateArray(items: items, currentIndex: currentIndex + 1, completion: completion)
            }
        }
    }
    
    
    // MARK: - Cleanup Scene
    
    /**
     Initiates a button tap and cleans up the scene as it transitions out.
     - parameters:
        - fadeDuration: the duration of the fadeTransitionNode as it fades in.
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
            ])) { [weak self] in
                self?.completion?()
            }
        }
        else {
            completion?()
        }
    }

    
}
