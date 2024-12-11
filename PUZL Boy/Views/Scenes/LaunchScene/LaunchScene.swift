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
    static let nodeName_skyNodePossibleBlood = "skyNodePossibleBlood"
    static let nodeName_skyObjectNode = "skyObjectNode"
    static let nodeName_groundObjectNode = "groundObjectNode"
    static let nodeName_backgroundNode = "backgroundNode"
    
    private var screenSize: CGSize
    private var player: Player!
    private var playerReflection: Player!
    private var loadingSprite: LoadingSprite!
    private var skyNode: SKSpriteNode!
    private var skyNodePossibleBlood: SKSpriteNode!
    private var moonSprite: MoonSprite!
    private var parallaxManager: ParallaxManager!

    enum AnimationSequence: CaseIterable {
        case jump, fall, running
    }

    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        self.screenSize = size
        
        super.init(size: size)

        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("LaunchScene deinit")
    }
    
    private func setupSprites() {
        let playerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 3)
        
        player = Player(type: .hero)
        player.sprite.position = playerPosition
        player.sprite.setScale(Player.cutsceneScale * player.scaleMultiplier)
        player.sprite.name = LaunchScene.nodeName_playerSprite

        if UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) {
            player.sprite.color = DayTheme.spriteColor
            player.sprite.colorBlendFactor = DayTheme.spriteShade
        }
        
        playerReflection = Player(type: .hero)
        playerReflection.sprite.position = playerPosition - CGPoint(x: 0, y: Player.size.height / 2 + 50) //why +50???
        playerReflection.sprite.setScale(Player.cutsceneScale * playerReflection.scaleMultiplier)
        playerReflection.sprite.color = DayTheme.spriteColor
        playerReflection.sprite.colorBlendFactor = DayTheme.spriteShade
        playerReflection.sprite.name = LaunchScene.nodeName_playerReflection
        playerReflection.sprite.yScale *= -1
        playerReflection.sprite.alpha = 0.25
        
        loadingSprite = LoadingSprite(position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 6))
        loadingSprite.zPosition = K.ZPosition.loadingNode
        loadingSprite.name = LaunchScene.nodeName_loadingSprite
                
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(useMorningSky: !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro))))
        skyNode.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
        skyNode.position = CGPoint(x: 0, y: screenSize.height)
        skyNode.anchorPoint = CGPoint(x: 0, y: 1)
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode
        
        skyNodePossibleBlood = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(useMorningSky: !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro))))
        skyNodePossibleBlood.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
        skyNodePossibleBlood.position = CGPoint(x: 0, y: screenSize.height)
        skyNodePossibleBlood.anchorPoint = CGPoint(x: 0, y: 1)
        skyNodePossibleBlood.zPosition = K.ZPosition.skyNode - 1
        skyNodePossibleBlood.name = LaunchScene.nodeName_skyNodePossibleBlood
        
        let skyNodeReverse = skyNode.copy() as! SKSpriteNode
        skyNodeReverse.position.y = 0
        skyNodeReverse.anchorPoint.y = -1
        skyNodeReverse.yScale *= -1
        skyNode.addChild(skyNodeReverse)
        
        let parallaxSet: ParallaxObject.SetType = (ParallaxObject.SetType.allCases.filter { $0 != .planet }).randomElement() ?? .grass

        moonSprite = MoonSprite(position: CGPoint(x: screenSize.width, y: screenSize.height), 
                                scale: 0.7 * 3,
                                moonPhase: nil,
                                alwaysHideMoon: !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro))

        parallaxManager = ParallaxManager(useSet: parallaxSet,
                                          xOffsetsArray: nil,
                                          forceSpeed: UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) ? nil : .run,
                                          animateForCutscene: !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro))
    }
        
    
    // MARK: - Overriden Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(skyNodePossibleBlood)
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
    
    func animateSprites() {
        //playerSpeed must not come from the default values for hero and needs to be explicitly set here.
        var playerSpeed: TimeInterval
        
        switch DayTheme.currentTheme {
        case .dawn: playerSpeed = 0.06
        case .morning: playerSpeed = 0.05
        case .afternoon: playerSpeed = 0.06
        case .night: playerSpeed = 0.06
        case .blood: playerSpeed = 0.06
        }
        
        if !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) {
            playerSpeed = 0.05
        }
        
        let shouldWalk: Bool = (DayTheme.currentTheme == .night || DayTheme.currentTheme == .dawn) && UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro)
        let playerAnimation = Player.animate(player: player, type: shouldWalk ? .walk : .run, timePerFrame: playerSpeed)
        
        player.sprite.run(playerAnimation)
        playerReflection.sprite.run(playerAnimation)

        loadingSprite.animate()
        parallaxManager.animate()
    }
    
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
        let impactShakeDuration: TimeInterval = 0.1
        
        func fadeSkyObjectNode(_ node: SKNode) {
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: playerCrouchDuration),
                SKAction.fadeOut(withDuration: moveDuration * maxAnimationDuration - playerCrouchDuration)
            ]))
        }
        
        for node in children {
            switch node.name {
            case LaunchScene.nodeName_loadingSprite:
                node.run(SKAction.fadeOut(withDuration: 0.5))
            case LaunchScene.nodeName_skyObjectNode:
                fadeSkyObjectNode(node)
            case LaunchScene.nodeName_skyNode:
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: playerCrouchDuration),
                    SKAction.scaleY(to: 2, duration: moveDuration / 4),
                    SKAction.fadeOut(withDuration: moveDuration * 2)
                ]))
            case LaunchScene.nodeName_skyNodePossibleBlood:
                guard let bloodNode = node as? SKSpriteNode else { break }
                
                //Need to re-establish for if/when FIRManager gets initialized
                bloodNode.texture = SKTexture(image: DayTheme.getSkyImage(useMorningSky: !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro)))
                
                bloodNode.run(SKAction.sequence([
                    SKAction.wait(forDuration: playerCrouchDuration),
                    SKAction.scaleY(to: 2, duration: moveDuration / 4)
                ]))
            case LaunchScene.nodeName_backgroundNode:
                for backgroundNode in node.children {
                    switch backgroundNode.name {
                    case let nodeName where nodeName?.contains(LaunchScene.nodeName_groundObjectNode) ?? false:
                        backgroundNode.run(SKAction.sequence([
                            SKAction.group([
                                SKAction.scale(to: 2, duration: playerTimePerFrame),
                                SKAction.moveTo(y: -screenSize.height / 2, duration: playerTimePerFrame)
                            ]),
                            SKAction.wait(forDuration: playerCrouchDuration - 2 * playerTimePerFrame),
                            SKAction.group([
                                SKAction.scale(to: 1, duration: playerTimePerFrame),
                                SKAction.moveTo(y: 0, duration: playerTimePerFrame)
                            ]),
                            SKAction.moveBy(x: -screenSize.width, y: -screenSize.height * 2, duration: moveDuration),
                            SKAction.removeFromParent()
                        ]))
                    case LaunchScene.nodeName_skyObjectNode:
                        fadeSkyObjectNode(backgroundNode)
                    default:
                        break
                    }
                }
            case LaunchScene.nodeName_playerSprite, LaunchScene.nodeName_playerReflection:
                guard let node = node as? SKSpriteNode else { return }
                
                node.removeAllActions()
                
                //Player Action properties
                let reflectionScaleY: CGFloat = node.name == LaunchScene.nodeName_playerReflection ? -1 : 1
                let reflectionMoveY: CGFloat = node.name == LaunchScene.nodeName_playerReflection ? -Player.size.height : 0
                
                let reflectionMultiplier: CGFloat = node.name == LaunchScene.nodeName_playerReflection ? -4 : 1
                let jumpStartPoint = CGPoint(x: screenSize.width / 3, y: screenSize.height / 3 * reflectionMultiplier)
                let jumpEndPoint = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 * reflectionMultiplier)
                let jumpControlPoint = CGPoint(x: screenSize.width * 2 / 3, y: screenSize.height * 2 / 3 * reflectionMultiplier)
                
                let jumpBezierPath = UIBezierPath()
                jumpBezierPath.move(to: jumpStartPoint)
                jumpBezierPath.addQuadCurve(to: jumpEndPoint, controlPoint: jumpControlPoint)

                let followBezierAction = SKAction.follow(jumpBezierPath.cgPath, asOffset: false, orientToPath: false, duration: bezierDuration)
                followBezierAction.timingFunction = { time in pow(time, 2) }
                
                let scaleAction = SKAction.scale(to: 2, duration: bezierDuration)
                scaleAction.timingFunction = { time in pow(time, 16) }
                
                let impactShakeAction = SKAction.sequence([
                    SKAction.wait(forDuration: bezierDuration),
                    SKAction.scale(to: 3, duration: impactShakeDuration),
                    SKAction.scale(to: 2, duration: impactShakeDuration)
                ])
                
                //Audio fun
                AudioManager.shared.playSound(for: "boyattack3", delay: moveDuration / 2)
                AudioManager.shared.playSound(for: "boyimpact", delay: moveDuration * maxAnimationDuration)

                //Jump Animation: Total = 2.5
                node.run(SKAction.sequence([
                    //1st Jump = 1.5
                    SKAction.group([
                        SKAction.moveTo(x: screenSize.width / 4, duration: playerCrouchDuration * parallaxManager.speedFactor),
                        SKAction.animate(with: player.textures[Player.Texture.jump.rawValue], timePerFrame: playerTimePerFrame),
                        SKAction.sequence([
                            SKAction.group([
                                SKAction.scaleX(to: 2, y: 2 * reflectionScaleY, duration: playerTimePerFrame),
                                SKAction.moveBy(x: 0, y: reflectionMoveY, duration: playerTimePerFrame)
                            ]),
                            SKAction.wait(forDuration: playerCrouchDuration - 2 * playerTimePerFrame),
                            SKAction.group([
                                SKAction.scaleX(to: Player.cutsceneScale, y: Player.cutsceneScale * reflectionScaleY, duration: playerTimePerFrame),
                                SKAction.moveBy(x: 0, y: -reflectionMoveY, duration: playerTimePerFrame)
                            ]),
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
                        scaleAction,
                        impactShakeAction
                    ])
                ]))
            default:
                //ignore skyNode
                break
            } //end switch node.name
        } //end for node in children
        
        //Total = 1 * (2.5 + 0.5) + 0.1 * 2 = 3.2
        run(SKAction.wait(forDuration: moveDuration * (maxAnimationDuration + paddingDuration) + impactShakeDuration * 2)) {
            completion(nil)
        }
    }
    
    ///Boy continues running. Forever.
    private func transitionRunning(completion: @escaping ([ParallaxSprite.SpriteXPositions]?) -> Void) {
        let duration: TimeInterval = 1.0
        var xOffsetsArray: [ParallaxSprite.SpriteXPositions] = []
        
        for node in children {
            switch node.name {
            case LaunchScene.nodeName_loadingSprite:
                node.run(SKAction.fadeOut(withDuration: duration))
            case LaunchScene.nodeName_backgroundNode:
                for backgroundNode in node.children {
                    if backgroundNode.name?.contains(LaunchScene.nodeName_groundObjectNode) ?? false {
                        backgroundNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: duration),
                            SKAction.removeFromParent()
                        ]))
                    }
                }
            default:
                break
            }
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                xOffsetsArray = parallaxManager.pollxOffsetsArray()
            }
        ])) {
            completion(xOffsetsArray)
        }
    }
    
    ///Boy falls like Peter when he bangs his knee
    private func transitionFall(completion: @escaping ([ParallaxSprite.SpriteXPositions]?) -> Void) {
        // TODO: - Needs implementation
        
        completion(nil)
    }
    
    
}
