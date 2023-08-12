//
//  CutsceneIntro.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/1/23.
//

import SpriteKit

class CutsceneIntro: SKScene {
    
    // MARK: - Properties
    
    private let playerPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 3)
    private let playerScale: CGFloat = 0.75
    
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
        player = Player()
        player.sprite.position = playerPosition
        player.sprite.setScale(playerScale)
        player.sprite.name = LaunchScene.nodeName_playerSprite

        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(useMorningSky: true)))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode
        
        parallaxManager = ParallaxManager(useSet: .grass, xOffsetsArray: xOffsetsArray, shouldWalk: true)
    }
    
    private func animateScene() {
        let frameRate: TimeInterval = 0.06
        let walkCycle: TimeInterval = frameRate * 15 //1 cycle at 0.06s x 15 frames = 0.9s
        let playerWalk = SKAction.animate(with: player.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        let playerIdle = SKAction.animate(with: player.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate)
        
//        player.sprite.run(SKAction.repeatForever(playerAnimation))

        player.sprite.run(SKAction.group([
            SKAction.repeat(playerWalk, count: 8),
            SKAction.sequence([
                SKAction.wait(forDuration: 2 * walkCycle),
                SKAction.group([
                    SKAction.moveTo(x: 120, duration: 4 * walkCycle),
                    SKAction.moveTo(y: playerPosition.y - 60, duration: 4 * walkCycle),
                    SKAction.scale(to: playerScale * 0.75, duration: 4 * walkCycle)
                ]),
                SKAction.wait(forDuration: 2 * walkCycle),
                SKAction.repeatForever(playerIdle)
            ])
        ]))
                
        parallaxManager.animate()
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 8 * walkCycle),
            SKAction.run { [unowned self] in
                parallaxManager.stopAnimation()
            }
        ]))
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(player.sprite)

        parallaxManager.addSpritesToParent(scene: self)
    }
    
    func finishAnimating(completion: @escaping () -> Void) {
        player.sprite.removeAllActions()
        parallaxManager.removeAllActions()
        parallaxManager.removeFromParent()
        player.sprite.removeFromParent()

        completion()
    }
}
