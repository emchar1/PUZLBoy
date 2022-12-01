//
//  LaunchScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/22.
//

import SpriteKit

class LaunchScene: SKScene {
    
    // MARK: - Properties
    
    private let treeCount = 6
    private let boulderCount = 8
    private let cloudCount = 3
    
    private var treeSprites: [BackgroundObject] = []
    private var boulderSprites: [BackgroundObject] = []
    private var cloudSprites: [BackgroundObject] = []
    private var mountainSprite: BackgroundObject
    private var moonSprite: BackgroundObject
//    private var grassSprite: BackgroundObject
    
    private var playerTextures: [SKTexture] = []
    private var playerSprite: SKSpriteNode
    private var loadingLabel: SKLabelNode
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        //Setup playerSprite
        let playerAtlas = SKTextureAtlas(named: "player")
        
        for i in 1...15 {
            playerTextures.append(playerAtlas.textureNamed("Run (\(i))"))
        }
        
        playerSprite = SKSpriteNode(texture: playerTextures[0])
        playerSprite.position = CGPoint(x: K.iPhoneWidth / 2 - 50, y: K.height / 2)
        playerSprite.setScale(2)
        playerSprite.zPosition = K.ZPosition.player
        playerSprite.color = .black
        playerSprite.colorBlendFactor = DayTheme.spriteShade
        
        loadingLabel = SKLabelNode(text: "LOADING...")
        loadingLabel.fontName = "AvenirNext-BoldItalic"
        loadingLabel.fontSize = 75
        loadingLabel.fontColor = .white
        loadingLabel.horizontalAlignmentMode = .center
        loadingLabel.alpha = 0.95
        loadingLabel.position = CGPoint(x: K.iPhoneWidth / 2, y: K.height / 6)
        loadingLabel.zPosition = K.ZPosition.display
        
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
        }

        mountainSprite = BackgroundObject(tierLevel: 0, backgroundType: .mountain)
        moonSprite = BackgroundObject(tierLevel: 0, backgroundType: .moon)
//        grassSprite = BackgroundObject(tierLevel: 0, backgroundType: .grass)

        super.init(size: size)
        
        animateSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateSprites() {
        let playerAnimation = SKAction.animate(with: playerTextures, timePerFrame: 0.05)
        playerSprite.run(SKAction.repeatForever(playerAnimation))

        for i in 0..<treeCount {
            treeSprites[i].animateSprite(withDelay: TimeInterval(i))
        }
        
        for i in 0..<boulderCount {
            boulderSprites[i].animateSprite(withDelay: TimeInterval(i))
        }
        
        for i in 0..<cloudCount {
            cloudSprites[i].animateSprite(withDelay: TimeInterval(i))
        }

        mountainSprite.animateSprite(withDelay: nil)
//        grassSprite.animateSprite(withDelay: nil)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        let skyImage: UIImage = UIImage.gradientImage(withBounds: CGRect(x: 0, y: 0, width: K.iPhoneWidth, height: K.height),
                                                      startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 0.5),
                                                      colors: [DayTheme.skyColor.top.cgColor, DayTheme.skyColor.bottom.cgColor])
        let skyNode = SKSpriteNode(texture: SKTexture(image: skyImage))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        
        let grassNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: K.iPhoneWidth, height: K.height / mountainSprite.backgroundBorder))
        grassNode.fillColor = DayTheme.grassColor
        grassNode.strokeColor = DayTheme.grassColor
        grassNode.zPosition = K.ZPosition.gameboard
        
        addChild(skyNode)
        addChild(grassNode)
        addChild(playerSprite)
        
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
//        addChild(grassSprite.sprite)
        
        addChild(loadingLabel)
    }
    
}
