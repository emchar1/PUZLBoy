//
//  FinalGameboardScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/8/24.
//

import SpriteKit

class FinalGameboardScene: SKScene {
    
    // MARK: - Properties
    
    private var hero: Player!
    private var villain: Player!
    
    private var gameboardNode: SKShapeNode!
    private var terrainPanels: [SKSpriteNode] = []
    private var overlayPanels: [SKSpriteNode] = []
    
    
    // MARK: - Initialization
        
    override init(size: CGSize) {
        super.init(size: size)
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FinalGameboard deinit")
    }
    
    private func setupNodes() {
        backgroundColor = .black

        let panelLength: CGFloat = 512
        let panelSpacing: CGFloat = 4
        let panelCount: Int = 6
        let catwalkLength: Int = 20
        let panelSize: CGFloat = K.ScreenDimensions.size.width / CGFloat(panelCount)
        var scaleSize: CGSize { CGSize.zero + panelSize - panelSpacing }

        
        //Setup Players
        
        hero = Player(type: .hero)
        hero.sprite.position = CGPoint(x: size.width * 1/4, y: size.height / 2)
        hero.sprite.setScale(Player.getGameboardScale(panelSize: panelSize))
        hero.sprite.zPosition = K.ZPosition.player
        hero.sprite.run(SKAction.repeatForever(SKAction.animate(with: hero.textures[Player.Texture.idle.rawValue], timePerFrame: 0.06)))
        
        villain = Player(type: .villain)
        villain.sprite.position = CGPoint(x: size.width * 3/4, y: size.height / 2)
        villain.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * 1.25)
        villain.sprite.xScale *= -1
        villain.sprite.color = .black
        villain.sprite.colorBlendFactor = 0.0
        villain.sprite.zPosition = K.ZPosition.player
        villain.sprite.run(SKAction.repeatForever(SKAction.animate(with: villain.textures[Player.Texture.idle.rawValue], timePerFrame: 0.08)))


        //Setup Gameboard
        
        gameboardNode = SKShapeNode(rectOf: CGSize(width: CGFloat(catwalkLength + 1) * panelSize + panelSpacing * CGFloat(catwalkLength),
                                                   height: panelSize + 2 * panelSpacing))
        gameboardNode.position = CGPoint(x: 0, y: K.ScreenDimensions.size.height / 2)
        gameboardNode.fillColor = GameboardSprite.gameboardColor
        gameboardNode.lineWidth = 0
                
        for i in 0...catwalkLength {
            let image: String = "partytile"//i == 0 ? "start" : (FireIceTheme.isFire ? "sand" : "snow")
            
            let terrainPanel = SKSpriteNode(imageNamed: image)
            terrainPanel.scale(to: scaleSize)
            terrainPanel.position = CGPoint(x: (terrainPanel.size.width + panelSpacing) * CGFloat(i),
                                            y: -terrainPanel.size.height / 2)
            terrainPanel.anchorPoint = .zero
            terrainPanel.zPosition = K.ZPosition.terrain
            terrainPanel.name = "terrainPanel_\(i)"
            
            terrainPanels.append(terrainPanel)
        }
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(hero.sprite)
        addChild(villain.sprite)
        addChild(gameboardNode)
        
        for terrainPanel in terrainPanels {
            gameboardNode.addChild(terrainPanel)
        }
    }
    
    
}
