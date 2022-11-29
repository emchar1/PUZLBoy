//
//  LaunchScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/22.
//

import SpriteKit

class LaunchScene: SKScene {
    
    // MARK: - Properties
    
    private let treeCount = 5
    private let boulderCount = 7
    private let cloudCount = 2
    
    private var treeSprites: [BackgroundObject] = []
    private var boulderSprites: [BackgroundObject] = []
    private var cloudSprites: [BackgroundObject] = []
    private var mountainSprite: BackgroundObject
    
    private var playerTextures: [SKTexture] = []
    private var playerSprite: SKSpriteNode
    private var loadingLabel: SKLabelNode
    
    enum DayTheme {
        case morning, afternoon, night
    }
    
    
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
        
        // FIXME: - For if I want to shade the sprites for evening daytime
        playerSprite.color = .black
        playerSprite.colorBlendFactor = 0
        
        loadingLabel = SKLabelNode(text: "LOADING...")
        loadingLabel.fontName = "AvenirNext-BoldItalic"
        loadingLabel.fontSize = 75
        loadingLabel.fontColor = .white
        loadingLabel.horizontalAlignmentMode = .center
        loadingLabel.alpha = 0.95
        loadingLabel.position = CGPoint(x: K.iPhoneWidth / 2, y: K.height / 6)
        loadingLabel.zPosition = K.ZPosition.display
        
        
        //Setup background objects
        for _ in 0...treeCount {
            let treeObject = BackgroundObject(tierLevel: Int.random(in: 0...BackgroundObject.maxTier), backgroundType: .tree)
            treeSprites.append(treeObject)
        }

        for _ in 0...boulderCount {
            let boulderObject = BackgroundObject(tierLevel: Int.random(in: 0...BackgroundObject.maxTier), backgroundType: .boulder)
            boulderSprites.append(boulderObject)
        }

        for i in 0...cloudCount {
            let cloudObject = BackgroundObject(tierLevel: i.clamp(min: 0, max: BackgroundObject.maxTier), backgroundType: .cloud)
            cloudSprites.append(cloudObject)
        }

        mountainSprite = BackgroundObject(tierLevel: 0, backgroundType: .mountain)

        super.init(size: size)
        
        animateSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateSprites() {
        let playerAnimation = SKAction.animate(with: playerTextures, timePerFrame: 0.05)
        playerSprite.run(SKAction.repeatForever(playerAnimation))
        
        for i in 0...treeCount {
            let treeAnimation = SKAction.move(to: treeSprites[i].endPosition, duration: treeSprites[i].speed)
            let sequence = SKAction.sequence([SKAction.wait(forDuration: treeSprites[i].delay * 2 * TimeInterval(i)),
                                              SKAction.repeat(treeAnimation, count: 1)])
            treeSprites[i].sprite.run(sequence)
        }
        
        for i in 0...boulderCount {
            let boulderAnimation = SKAction.move(to: boulderSprites[i].endPosition, duration: boulderSprites[i].speed)
            let sequence = SKAction.sequence([SKAction.wait(forDuration: boulderSprites[i].delay * 2 * TimeInterval(i)),
                                              SKAction.repeat(boulderAnimation, count: 1)])
            boulderSprites[i].sprite.run(sequence)
        }
        
        for i in 0...cloudCount {
            let cloudAnimation = SKAction.move(to: cloudSprites[i].endPosition, duration: cloudSprites[i].speed)
            cloudSprites[i].sprite.run(cloudAnimation)
        }

        
        let mountainAnimation = SKAction.move(to: mountainSprite.endPosition, duration: mountainSprite.speed)
        mountainSprite.sprite.run(mountainAnimation)
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        let skyDay = UIColor(red: 162 / 255, green: 229 / 255, blue: 255 / 255, alpha: 1.0)
//        let skySunset = UIColor(red: 205 / 255, green: 174 / 255, blue: 102 / 255, alpha: 1.0)
        let skyColor = skyDay
        let skyNode = SKShapeNode(rect: CGRect(x: 0, y: K.height / mountainSprite.backgroundBorder, width: K.iPhoneWidth, height: K.height))
        skyNode.fillColor = skyColor
        skyNode.strokeColor = skyColor
        skyNode.zPosition = K.ZPosition.gameboard
        
        let grassDay = UIColor(red: 94 / 255, green: 177 / 255, blue: 72 / 255, alpha: 1.0)
//        let grassSunset = UIColor(red: 104 / 255, green: 147 / 255, blue: 42 / 255, alpha: 1.0)
        let grassColor = grassDay
        let grassNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: K.iPhoneWidth, height: K.height / mountainSprite.backgroundBorder))
        grassNode.fillColor = grassColor
        grassNode.strokeColor = grassColor
        grassNode.zPosition = K.ZPosition.gameboard
        
        addChild(skyNode)
        addChild(grassNode)
        addChild(playerSprite)
        
        for i in 0...treeCount {
            addChild(treeSprites[i].sprite)
        }

        for i in 0...boulderCount {
            addChild(boulderSprites[i].sprite)
        }

        for i in 0...cloudCount {
            addChild(cloudSprites[i].sprite)
        }

        addChild(mountainSprite.sprite)
        addChild(loadingLabel)
    }
    
}
