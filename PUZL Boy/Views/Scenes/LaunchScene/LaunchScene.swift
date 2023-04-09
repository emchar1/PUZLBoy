//
//  LaunchScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/22.
//

import SpriteKit

class LaunchScene: SKScene {
    
    // MARK: - Properties
    
    private let treeCount = 3
    private let boulderCount = 4
    private let cloudCount = 3
    
    private var treeSprites: [BackgroundObject] = []
    private var boulderSprites: [BackgroundObject] = []
    private var cloudSprites: [BackgroundObject] = []
    private var mountainSprite: BackgroundObject
    private var moonSprite: BackgroundObject
    private var player = Player()
    private var loadingSprite: LoadingSprite
    private var isTransitioning: Bool = false
    private var skyNode: SKSpriteNode
    private var grassNode: SKSpriteNode
    
    enum AnimationSequence: CaseIterable {
        case jump, fall, running
    }

    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        player.sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        player.sprite.setScale(2)
        player.sprite.color = DayTheme.spriteColor
        player.sprite.colorBlendFactor = DayTheme.spriteShade
        player.sprite.name = "playerSprite"
        
        loadingSprite = LoadingSprite(position: CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 6))
        loadingSprite.zPosition = K.ZPosition.loadingNode
        loadingSprite.name = "loadingSprite"
        
        //Setup BackgroundObjects
        for _ in 0..<treeCount {
            let treeObject = BackgroundObject(tierLevel: Int.random(in: 0...BackgroundObject.maxTier), backgroundType: .tree)
            treeObject.name = "groundObjectNode"
            treeSprites.append(treeObject)
        }

        for _ in 0..<boulderCount {
            let boulderObject = BackgroundObject(tierLevel: Int.random(in: 0...BackgroundObject.maxTier), backgroundType: .boulder)
            boulderObject.name = "groundObjectNode"
            boulderSprites.append(boulderObject)
        }

        for i in 0..<cloudCount {
            let cloudObject = BackgroundObject(tierLevel: i.clamp(min: 0, max: BackgroundObject.maxTier), backgroundType: .cloud)
            cloudObject.name = "skyObjectNode"
            cloudSprites.append(cloudObject)
        }

        mountainSprite = BackgroundObject(tierLevel: 0, backgroundType: .mountain)
        mountainSprite.name = "groundObjectNode"
        
        moonSprite = BackgroundObject(tierLevel: 0, backgroundType: .moon)
        moonSprite.name = "skyObjectNode"
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = "skyNode"
        
        let grassImage: UIImage = UIImage.createGradientImage(withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height / mountainSprite.backgroundBorder), startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1), colors: [DayTheme.grassColor.top.cgColor, DayTheme.grassColor.bottom.cgColor])
        grassNode = SKSpriteNode(texture: SKTexture(image: grassImage))
        grassNode.color = DayTheme.spriteColor
        grassNode.colorBlendFactor = DayTheme.spriteShade
        grassNode.anchorPoint = .zero
        grassNode.zPosition = K.ZPosition.grassNode
        grassNode.name = "grassNode"

        super.init(size: size)
        
        animateSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateSprites() {
        var playerSpeed: TimeInterval
        switch DayTheme.currentTheme {
        case .dawn: playerSpeed = 0.06
        case .morning: playerSpeed = 0.05
        case .afternoon: playerSpeed = 0.06
        case .night: playerSpeed = 0.06
        }
        
        let playerAnimation = SKAction.animate(with: DayTheme.currentTheme == .night || DayTheme.currentTheme == .dawn ? player.textures[Player.Texture.walk.rawValue] : player.textures[Player.Texture.run.rawValue], timePerFrame: playerSpeed)
        player.sprite.run(SKAction.repeatForever(playerAnimation))

        loadingSprite.animate()
        
        for i in 0..<treeCount {
            animateBackgroundObject(treeSprites[i], shouldStartAtEdge: false)
        }
        
        for i in 0..<boulderCount {
            animateBackgroundObject(boulderSprites[i], shouldStartAtEdge: false)
        }
        
        for i in 0..<cloudCount {
            animateBackgroundObject(cloudSprites[i], shouldStartAtEdge: false)
        }
        
        animateBackgroundObject(mountainSprite, shouldStartAtEdge: false)
    }
    
    private func animateBackgroundObject(_ object: BackgroundObject, shouldStartAtEdge: Bool, shouldReverse: Bool = false, withDelay: TimeInterval? = nil) {
        object.resetSprite(shouldStartAtEdge: shouldStartAtEdge, shouldReverse: shouldReverse)
        object.animateSprite(withDelay: withDelay, shouldReverse: shouldReverse)
    }
    
    
    // MARK: - Overriden Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(grassNode)
        addChild(player.sprite)
        
        for i in 0..<treeCount {
            addChild(treeSprites[i])
        }

        for i in 0..<boulderCount {
            addChild(boulderSprites[i])
        }

        for i in 0..<cloudCount {
            addChild(cloudSprites[i])
        }

        addChild(mountainSprite)
        addChild(moonSprite)
        addChild(loadingSprite)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        print("Scene transitioned...")
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        guard !isTransitioning else { return }
        
        
        for i in 0..<treeCount {
            if treeSprites[i].didFinishAnimating {
                animateBackgroundObject(treeSprites[i], shouldStartAtEdge: true, withDelay: TimeInterval(i))
            }
        }

        for i in 0..<boulderCount {
            if boulderSprites[i].didFinishAnimating {
                animateBackgroundObject(boulderSprites[i], shouldStartAtEdge: true, withDelay: TimeInterval(i))
            }
        }
        
        for i in 0..<cloudCount {
            if cloudSprites[i].didFinishAnimating {
                animateBackgroundObject(cloudSprites[i], shouldStartAtEdge: true, withDelay: TimeInterval(i))
            }
        }
        
        if mountainSprite.didFinishAnimating {
            animateBackgroundObject(mountainSprite, shouldStartAtEdge: true)
        }
    }
    
    
    // MARK: - Animation Functions
    
    func animateTransition(animationSequence: AnimationSequence, completion: @escaping () -> Void) {
        isTransitioning = true
        
        switch animationSequence {
        case .running: transitionRunning(completion: completion)
        case .fall: transitionFall(completion: completion)
        case .jump: transitionJump(completion: completion)
        }
    }
    
    ///Boy jumping up and bezier path to center.
    private func transitionJump(completion: @escaping () -> Void) {
        let playerTimePerFrame: TimeInterval = 0.1
        var playerCrouchDuration: TimeInterval { playerTimePerFrame * 5 }
        var moveDuration: TimeInterval { playerCrouchDuration * 2 }
        
        let maxAnimationDuration: TimeInterval = 2.5
        let paddingDuration: TimeInterval = 0.25
        
        for node in self.children {
            guard node.name != "skyNode" else { continue }
            
            switch node.name {
            case "loadingSprite":
                node.run(SKAction.fadeOut(withDuration: 0.5))
            case "skyObjectNode":
                node.run(SKAction.fadeOut(withDuration: moveDuration * maxAnimationDuration))
            case "playerSprite":
                guard let node = node as? SKSpriteNode else { return }
                
                node.removeAllActions()
                
                //Player Action properties
                let jumpStartPoint = CGPoint(x: K.ScreenDimensions.iPhoneWidth * 2 / 3, y: K.ScreenDimensions.height / 2)
                let jumpEndPoint = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
                let jumpControlPoint = CGPoint(x: K.ScreenDimensions.iPhoneWidth, y: K.ScreenDimensions.height)
                
                let jumpBezierPath = UIBezierPath()
                jumpBezierPath.move(to: jumpStartPoint)
                jumpBezierPath.addQuadCurve(to: jumpEndPoint, controlPoint: jumpControlPoint)

                let followBezierAction = SKAction.follow(jumpBezierPath.cgPath, asOffset: false, orientToPath: false, duration: moveDuration)
                followBezierAction.timingFunction = { time in pow(time, 2) }
                
                let scaleAction = SKAction.scale(to: 2, duration: moveDuration)
                scaleAction.timingFunction = { time in pow(time, 8) }
                
                //Audio fun
                AudioManager.shared.playSound(for: "boyattack3", delay: moveDuration / 2)
                AudioManager.shared.playSound(for: "boyimpact", delay: moveDuration * maxAnimationDuration)

                //Jump Animation: Total = 2.5
                node.run(SKAction.sequence([
                    //1st Jump = 1.5
                    SKAction.group([
                        SKAction.moveTo(x: K.ScreenDimensions.iPhoneWidth / 4, duration: playerCrouchDuration),
                        SKAction.scale(to: 0.75, duration: playerCrouchDuration),
                        SKAction.animate(with: player.textures[Player.Texture.jump.rawValue], timePerFrame: playerTimePerFrame),
                        SKAction.sequence([
                            SKAction.wait(forDuration: playerCrouchDuration),
                            SKAction.group([
                                SKAction.colorize(withColorBlendFactor: 0, duration: moveDuration),
                                SKAction.scale(to: 0.1, duration: moveDuration),
                                SKAction.move(to: jumpStartPoint, duration: moveDuration)
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
            case "groundObjectNode", "grassNode":
                let objectNode = node as? BackgroundObject
                let xSpeed: CGFloat = objectNode?.objectSpeed ?? 0
                
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: playerCrouchDuration),
                    SKAction.moveBy(x: xSpeed, y: -K.ScreenDimensions.height, duration: moveDuration / 5)
                ]))
            default:
                break
            } //end switch node.name
        } //end for node in self.children
        
        run(SKAction.wait(forDuration: moveDuration * (maxAnimationDuration + paddingDuration)), completion: completion)
    }
    
    ///Boy continues running. Forever.
    private func transitionRunning(completion: @escaping () -> Void) {
        //needs implementation
    }
    
    ///Boy falls like Peter when he bangs his knee
    private func transitionFall(completion: @escaping () -> Void) {
        let playerTimePerFrame: TimeInterval = 0.04
        
        for node in self.children {
            guard node.name != "skyNode" else { continue }
            
            switch node.name {
            case "loadingSprite":
                node.run(SKAction.fadeOut(withDuration: 0.5))
            case "playerSprite":
                guard let node = node as? SKSpriteNode else { return }
                
                node.removeAllActions()
                
                node.run(SKAction.group([
                    SKAction.animate(with: player.textures[Player.Texture.dead.rawValue], timePerFrame: playerTimePerFrame),
                    SKAction.moveTo(x: -K.ScreenDimensions.iPhoneWidth * 2, duration: 1)
                ]))
            case "grassNode":
                break
            case "groundObjectNode", "skyObjectNode":
                guard let node = node as? BackgroundObject else { return }

                //Original
//                node.run(SKAction.wait(forDuration: 2.0)) {
//                    node.removeAllActions()
//
//                    node.run(SKAction.sequence([
//                        SKAction.wait(forDuration: 2.0),
//                        SKAction.moveBy(x: K.ScreenDimensions.iPhoneWidth * 2, y: 0, duration: 0.5)
//                    ]))
//                }
                
                
                
                
                
                let sequence = SKAction.sequence([
                    SKAction.wait(forDuration: 2.0),
                    
                    SKAction.run {
                        node.stopSprite()
                    },

                    SKAction.wait(forDuration: 1.0),

                    // FIXME: - Reverse for a time, then stop.
                    SKAction.run {
//                        node.resetSprite(shouldStartAtEdge: true, shouldReverse: true)
                        node.animateSprite(withDelay: 0, shouldReverse: true)
                    }
                    
//                    SKAction.repeatForever(SKAction.run {
//                        if node.didFinishAnimating {
//                            self.animateBackgroundObject(node, shouldStartAtEdge: true, shouldReverse: true, withDelay: 0)
//                        }
//                    })
                    

                ])
                
                node.run(sequence)
                
                
                
                
            default:
                break
            } //end switch
        } //end for node
    } //end transitionFall()
    
    
}
