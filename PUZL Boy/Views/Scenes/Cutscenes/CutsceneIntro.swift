//
//  CutsceneIntro.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/1/23.
//

import SpriteKit

class CutsceneIntro: SKScene {
    
    // MARK: - Properties
    
    private var player: Player!
    private var skyNode: SKSpriteNode!
    private var parallaxManager: ParallaxManager!
    
    
    // MARK: - Initialization
    
    init(size: CGSize, xOffsetsArray: [ParallaxSprite.SpriteXPositions]) {
        super.init(size: size)
        
        setupScene(xOffsetsArray: xOffsetsArray)
        animateScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CutsceneIntro deinit")
    }
    
    private func setupScene(xOffsetsArray: [ParallaxSprite.SpriteXPositions]) {
        let playerPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 3)
        let playerScale: CGFloat = 0.75

        player = Player()
        player.sprite.position = playerPosition
        player.sprite.setScale(playerScale)
        player.sprite.color = DayTheme.spriteColor
        player.sprite.colorBlendFactor = DayTheme.spriteShade
        player.sprite.name = LaunchScene.nodeName_playerSprite

        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode
        
        parallaxManager = ParallaxManager(useSet: .grass, xOffsetsArray: xOffsetsArray)
    }
    
    private func animateScene() {
        let playerSpeed: TimeInterval = 0.06
        let playerAnimation = SKAction.animate(with: player.textures[Player.Texture.walk.rawValue], timePerFrame: playerSpeed)
        
        player.sprite.run(SKAction.repeatForever(playerAnimation))

        parallaxManager.animate()
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(player.sprite)

        parallaxManager.addSpritesToParent(scene: self)
    }
}
