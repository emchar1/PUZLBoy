//
//  LaunchScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/22.
//

import SpriteKit

class LaunchScene: SKScene {
    
    // MARK: - Properties
    
    private let treeCount = 60
    private let boulderCount = 80
    private let cloudCount = 3
    
    private var treeSprites: [BackgroundObject] = []
    private var boulderSprites: [BackgroundObject] = []
    private var cloudSprites: [BackgroundObject] = []
    private var mountainSprite: BackgroundObject
    private var moonSprite: BackgroundObject
    private var player = Player()
    private var loadingSprite: LoadingSprite
    private var skyNode: SKSpriteNode
    private var grassNode: SKSpriteNode

    
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
            treeSprites.append(treeObject)
        }

        for _ in 0..<boulderCount {
            let boulderObject = BackgroundObject(tierLevel: Int.random(in: 0...BackgroundObject.maxTier), backgroundType: .boulder)
            boulderSprites.append(boulderObject)
        }

        for i in 0..<cloudCount {
            let cloudObject = BackgroundObject(tierLevel: i.clamp(min: 0, max: BackgroundObject.maxTier), backgroundType: .cloud)
            cloudSprites.append(cloudObject)
            cloudSprites[i].sprite.name = "skyObjectNode"
        }

        mountainSprite = BackgroundObject(tierLevel: 0, backgroundType: .mountain)
        moonSprite = BackgroundObject(tierLevel: 0, backgroundType: .moon)
        moonSprite.sprite.name = "skyObjectNode"
        
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

        for i in 0..<treeCount {
            treeSprites[i].animateSprite(withDelay: TimeInterval(i))
        }
        
        for i in 0..<boulderCount {
            boulderSprites[i].animateSprite(withDelay: TimeInterval(i))
        }
        
        for i in 0..<cloudCount {
            cloudSprites[i].animateSprite(withDelay: nil)
        }
        
        loadingSprite.animate()
        mountainSprite.animateSprite(withDelay: nil)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(grassNode)
        addChild(player.sprite)
        
        for i in 0..<treeCount {
            addChild(treeSprites[i].sprite)
        }

        for i in 0..<boulderCount {
            addChild(boulderSprites[i].sprite)
        }

        for i in 0..<cloudCount {
            addChild(cloudSprites[i].sprite)
        }

        addChild(mountainSprite.sprite)
        addChild(moonSprite.sprite)
        addChild(loadingSprite)
    }
    
    func animateTransition(completion: @escaping () -> Void) {
        let playerTimePerFrame: TimeInterval = 0.1
        var playerCrouchDuration: TimeInterval { playerTimePerFrame * 5 }
        var moveDuration: TimeInterval { playerCrouchDuration * 2 }

        for node in self.children {
            guard node.name != "skyNode" else { continue }
            
            switch node.name {
            case "loadingSprite":
                node.run(SKAction.fadeOut(withDuration: 0.5))
            case "skyObjectNode":
                node.run(SKAction.fadeOut(withDuration: moveDuration * 5))
            case "playerSprite":
                guard let node = node as? SKSpriteNode else { return }
                
                node.removeAllActions()
                
                let jumpAnimation = SKAction.animate(with: player.textures[Player.Texture.jump.rawValue], timePerFrame: playerTimePerFrame)
                let playerDescendAction = SKAction.moveTo(y: K.ScreenDimensions.height * (2 / 3), duration: moveDuration * 1)
                let playerDescendSlowerAction = SKAction.moveTo(y: K.ScreenDimensions.height / 2, duration: moveDuration * 2)
                let floatDistance: CGFloat = 30
                let floatAction = SKAction.repeat(SKAction.sequence([
                    SKAction.moveBy(x: 0, y: -floatDistance, duration: moveDuration / 4),
                    SKAction.moveBy(x: -floatDistance, y: 0, duration: moveDuration / 4),
                    SKAction.moveBy(x: 0, y: floatDistance, duration: moveDuration / 4),
                    SKAction.moveBy(x: floatDistance, y: 0, duration: moveDuration / 4)
                ]), count: Int(moveDuration) * 3)
                
                playerDescendAction.timingMode = .easeIn
                playerDescendSlowerAction.timingMode = .easeOut

                //Jump animation: duration = 4.5 = 1.5 + 3
                node.run(SKAction.group([
                    SKAction.moveTo(x: K.ScreenDimensions.iPhoneWidth / 4, duration: playerCrouchDuration),
                    SKAction.scale(to: 0.75, duration: playerCrouchDuration),
                    jumpAnimation,
                    SKAction.sequence([
                        SKAction.wait(forDuration: playerCrouchDuration),
                        SKAction.group([
                            SKAction.colorize(withColorBlendFactor: 0.0, duration: moveDuration),
                            SKAction.moveBy(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height, duration: moveDuration)
                        ])
                    ])
                ])) { //Completion:
                    node.texture = SKTexture(imageNamed: "Run (5)")
                    
                    //Descend animation: duration = 3
                    node.run(SKAction.group([
                        SKAction.scale(to: 2, duration: 0),
                        SKAction.moveTo(x: K.ScreenDimensions.iPhoneWidth / 2, duration: 0),
                        floatAction,
                        SKAction.sequence([
                            playerDescendAction,
                            playerDescendSlowerAction
                        ])
                    ]))
                }
            default:
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: playerCrouchDuration),
                    SKAction.moveBy(x: node.speed, y: -K.ScreenDimensions.height, duration: moveDuration / 2)
                ]))
            } //end switch node.name
        } //end for node in self.children
        
        run(SKAction.wait(forDuration: moveDuration * 5), completion: completion)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        print("Scene transitioned...")
    }
}
