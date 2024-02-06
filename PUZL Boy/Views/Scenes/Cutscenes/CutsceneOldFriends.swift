//
//  CutsceneOldFriends.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/6/24.
//

import SpriteKit

class CutsceneOldFriends: SKScene {
    
    // MARK: - Properties
    
    private var screenSize: CGSize
    
    private var playerMagmoor: Player!
    private var speechMagmoor: SpeechBubbleSprite!
    private var parallaxManager: ParallaxManager!
    private var skyNode: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        screenSize = size
        
        super.init(size: size)
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        playerMagmoor = Player(type: .villain)
        playerMagmoor.sprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 3)
        
        speechMagmoor = SpeechBubbleSprite(width: 460, position: playerMagmoor.sprite.position + CGPoint(x: 200, y: 400))
        
        parallaxManager = ParallaxManager(useSet: ParallaxObject.SetType.allCases.randomElement() ?? .grass,
                                          xOffsetsArray: nil,
                                          forceSpeed: .walk,
                                          animateForCutscene: false)
        
        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
        skyNode.position = CGPoint(x: 0, y: screenSize.height)
        skyNode.anchorPoint = CGPoint(x: 0, y: 1)
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode

    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        addChild(playerMagmoor.sprite)
        addChild(skyNode)
        
        parallaxManager.addSpritesToParent(scene: self)
    }
    
    
    // MARK: - Animate Functions
    
    func animateScene(completion: (() -> Void)?) {
        let frameRate: TimeInterval = 0.06
        let playerAnimate = SKAction.animate(with: playerMagmoor.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate)

        playerMagmoor.sprite.run(SKAction.repeatForever(playerAnimate))
        
        speechMagmoor.setText(text: "This is a test of the Vaelorian broadcast system (VBS)", superScene: self, parentNode: nil, completion: completion)
    }
}
