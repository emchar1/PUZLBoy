//
//  LaunchScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/22.
//

import SpriteKit

class LaunchScene: SKScene {
    
    // MARK: - Properties
    
    //Shared node names to be used across any object in the LaunchScene folder
    static let nodeName_playerSprite = "playerSprite"
    static let nodeName_playerReflection = "playerReflection"
    static let nodeName_loadingSprite = "loadingSprite"
    static let nodeName_skyNode = "skyNode"
    static let nodeName_skyObjectNode = "skyObjectNode"
    static let nodeName_groundObjectNode = "groundObjectNode"
    
    private var player: Player!
    private var playerReflection: Player!
    private var loadingSprite: LoadingSprite!
    private var skyNode: SKSpriteNode!
    private var moonSprite: MoonSprite!
    private var parallaxManager: ParallaxManager!

    enum AnimationSequence: CaseIterable {
        case jump, fall, running
    }

    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)

        setupSprites()
        animateSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit LaunchScene")
    }
    
    private func setupSprites() {
        let playerPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 3)
        let playerScale: CGFloat = 0.75
        
        player = Player()
        player.sprite.position = playerPosition
        player.sprite.setScale(playerScale)
        player.sprite.color = DayTheme.spriteColor
        player.sprite.colorBlendFactor = DayTheme.spriteShade
        player.sprite.name = LaunchScene.nodeName_playerSprite
        
        playerReflection = Player()
        playerReflection.sprite.position = playerPosition - CGPoint(x: 0, y: Player.size.height / 2 + 50) //why +50???
        playerReflection.sprite.setScale(playerScale)
        playerReflection.sprite.color = DayTheme.spriteColor
        playerReflection.sprite.colorBlendFactor = DayTheme.spriteShade
        playerReflection.sprite.name = LaunchScene.nodeName_playerReflection
        playerReflection.sprite.yScale *= -1
        playerReflection.sprite.alpha = 0.25
        
        loadingSprite = LoadingSprite(position: CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 6))
        loadingSprite.zPosition = K.ZPosition.loadingNode
        loadingSprite.name = LaunchScene.nodeName_loadingSprite
                
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode

        moonSprite = MoonSprite(position: CGPoint(x: K.ScreenDimensions.iPhoneWidth, y: K.ScreenDimensions.height), scale: 0.7 * 3, moonPhase: nil)

        parallaxManager = ParallaxManager(useSet: .grass, xOffsetsArray: nil)//.allCases.randomElement() ?? .grass, xOffsetsArray: nil)
    }
    
    private func animateSprites() {
        var playerSpeed: TimeInterval
        
        switch DayTheme.currentTheme {
        case .dawn: playerSpeed = 0.06
        case .morning: playerSpeed = 0.05
        case .afternoon: playerSpeed = 0.06
        case .night: playerSpeed = 0.06
        }
        
        let playerAnimation = SKAction.animate(
            with: DayTheme.currentTheme == .night || DayTheme.currentTheme == .dawn ? player.textures[Player.Texture.walk.rawValue] : player.textures[Player.Texture.run.rawValue],
            timePerFrame: playerSpeed
        )
        
        player.sprite.run(SKAction.repeatForever(playerAnimation))
        playerReflection.sprite.run(SKAction.repeatForever(playerAnimation))

        loadingSprite.animate()
        parallaxManager.animate()
    }
        
    
    // MARK: - Overriden Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(player.sprite)
        addChild(moonSprite)
        addChild(loadingSprite)
        
        parallaxManager.addSpritesToParent(scene: self)
        
        //Only add a reflection to the marsh background.
        if parallaxManager.set == .marsh {
            addChild(playerReflection.sprite)
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        print("Scene transitioned...")
    }
    
    
    // MARK: - Animation Functions
    
    func animateTransition(animationSequence: AnimationSequence, completion: @escaping ([ParallaxSprite.SpriteXPositions]?) -> Void) {
        switch animationSequence {
        case .running: transitionRunning(completion: completion)
        case .fall: transitionFall(completion: completion)
        case .jump: transitionJump(completion: completion)
        }
    }
    
    ///Boy jumping up and bezier path to center.
    private func transitionJump(completion: @escaping ([ParallaxSprite.SpriteXPositions]?) -> Void) {
        let playerTimePerFrame: TimeInterval = 0.1
        var playerCrouchDuration: TimeInterval { playerTimePerFrame * 5 }
        var moveDuration: TimeInterval { playerCrouchDuration * 2 }
        
        var jumpDuration: TimeInterval { moveDuration }
        var bezierDuration: TimeInterval { moveDuration }
        var maxAnimationDuration: TimeInterval { playerCrouchDuration + jumpDuration + bezierDuration }
        let paddingDuration: TimeInterval = 0.5
        
        for node in children {
            switch node.name {
            case LaunchScene.nodeName_loadingSprite:
                node.run(SKAction.fadeOut(withDuration: 0.5))
            case LaunchScene.nodeName_skyObjectNode:
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: playerCrouchDuration),
                    SKAction.fadeOut(withDuration: moveDuration * maxAnimationDuration - playerCrouchDuration)
                ]))
            case LaunchScene.nodeName_playerSprite, LaunchScene.nodeName_playerReflection:
                guard let node = node as? SKSpriteNode else { return }
                
                node.removeAllActions()
                
                //Player Action properties
                let reflectionMultiplier: CGFloat = node.name == LaunchScene.nodeName_playerReflection ? -4 : 1
                let jumpStartPoint = CGPoint(x: K.ScreenDimensions.iPhoneWidth * 2 / 3, y: K.ScreenDimensions.height / 2 * reflectionMultiplier)
                let jumpEndPoint = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2 * reflectionMultiplier)
                let jumpControlPoint = CGPoint(x: K.ScreenDimensions.iPhoneWidth, y: K.ScreenDimensions.height * reflectionMultiplier)
                
                let jumpBezierPath = UIBezierPath()
                jumpBezierPath.move(to: jumpStartPoint)
                jumpBezierPath.addQuadCurve(to: jumpEndPoint, controlPoint: jumpControlPoint)

                let followBezierAction = SKAction.follow(jumpBezierPath.cgPath, asOffset: false, orientToPath: false, duration: bezierDuration)
                followBezierAction.timingFunction = { time in pow(time, 2) }
                
                let scaleAction = SKAction.scale(to: 2, duration: bezierDuration)
                scaleAction.timingFunction = { time in pow(time, 8) }
                
                //Audio fun
                AudioManager.shared.playSound(for: "boyattack3", delay: moveDuration / 2)
                AudioManager.shared.playSound(for: "boyimpact", delay: moveDuration * maxAnimationDuration)

                //Jump Animation: Total = 2.5
                node.run(SKAction.sequence([
                    //1st Jump = 1.5
                    SKAction.group([
                        SKAction.moveTo(x: K.ScreenDimensions.iPhoneWidth / 4, duration: playerCrouchDuration * parallaxManager.speedFactor),
                        SKAction.animate(with: player.textures[Player.Texture.jump.rawValue], timePerFrame: playerTimePerFrame),
                        SKAction.sequence([
                            SKAction.wait(forDuration: playerCrouchDuration),
                            SKAction.group([
                                SKAction.colorize(withColorBlendFactor: 0, duration: jumpDuration),
                                SKAction.scale(to: 0.1, duration: jumpDuration),
                                SKAction.move(to: jumpStartPoint, duration: jumpDuration)
                            ])
                        ])
                    ]),
                    //2nd Jump = 1
                    SKAction.group([
                        SKAction.setTexture(SKTexture(imageNamed: "Run (5)")),
                        followBezierAction,
                        scaleAction
                    ])
                ]))
            case LaunchScene.nodeName_groundObjectNode:
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: playerCrouchDuration),
                    SKAction.moveBy(x: 0, y: -K.ScreenDimensions.height * 2, duration: moveDuration),
                    SKAction.removeFromParent()
                ]))
            default:
                break
            } //end switch node.name
        } //end for node in children
        
        run(SKAction.wait(forDuration: moveDuration * (maxAnimationDuration + paddingDuration))) {
            completion(nil)
        }
    }
    
    ///Boy continues running. Forever.
    private func transitionRunning(completion: @escaping ([ParallaxSprite.SpriteXPositions]?) -> Void) {
        // TODO: - Needs implementation
        
        let duration: TimeInterval = 1.0
        var xOffsetsArray: [ParallaxSprite.SpriteXPositions] = []
        
        for node in children {
            switch node.name {
            case LaunchScene.nodeName_loadingSprite:
                node.run(SKAction.fadeOut(withDuration: duration))
            case LaunchScene.nodeName_groundObjectNode:
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: duration),
                    SKAction.removeFromParent()
                ]))
            default:
                break
            }
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [unowned self] in
                xOffsetsArray = parallaxManager.pollxOffsetsArray()
            }
        ])) {
            completion(xOffsetsArray)
        }
//        run(SKAction.wait(forDuration: duration), completion: completion)
    }
    
    ///Boy falls like Peter when he bangs his knee
    private func transitionFall(completion: @escaping ([ParallaxSprite.SpriteXPositions]?) -> Void) {
        //needs implementation
        completion(nil)
    }
    
    
}
