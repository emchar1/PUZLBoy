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
    
    init(size: CGSize, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
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
    
    private func setupScene(xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
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
        
        let speechSmallThings = SpeechBubbleSprite(text: "All the| small things.| True care| truth brings.| I'll take| one lift—/Oh.. hello!",
                                                   width: 460,
                                                   position: CGPoint(x: playerPosition.x, y: playerPosition.y + 200))

        //Player Sprite
        player.sprite.run(SKAction.group([
            SKAction.repeat(playerWalk, count: 13),
            SKAction.sequence([
                SKAction.wait(forDuration: 6 * walkCycle),
                SKAction.group([
                    SKAction.moveTo(x: 120, duration: 4 * walkCycle),
//                    SKAction.moveTo(y: playerPosition.y - 60, duration: 4 * walkCycle),
//                    SKAction.scale(to: playerScale * 0.75, duration: 4 * walkCycle)
                ]),
                SKAction.wait(forDuration: 3 * walkCycle),
                SKAction.repeatForever(playerIdle)
            ])
        ]))
                        
        //Parallax Manager
        run(SKAction.sequence([
            SKAction.run { [unowned self] in
                parallaxManager.animate()
            },
            SKAction.wait(forDuration: 13 * walkCycle),
            SKAction.run { [unowned self] in
                parallaxManager.stopAnimation()
            }
        ]))

        //Speech Bubbles
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2 * walkCycle),
            SKAction.run {
                speechSmallThings.beginAnimation(superScene: self) { [unowned self] in
                    print("Certida")
                    speechSmallThings.setText(text: "Oh, and I also don't like the fact that you're this rich spoiled girl who just nags and nags and nags and nags...", superScene: self) { [unowned self] in
                        speechSmallThings.setText(text: "But I guess that's all I have to say on that...", superScene: self) {
                            print("Now... done.")
                        }
                        print("Even more.")
                    }
                }
            }
        ]))
        
        speechSmallThings.run(SKAction.sequence([
            SKAction.wait(forDuration: 6 * walkCycle),
            SKAction.moveTo(x: 120 + speechSmallThings.bubbleDimensions.width / 2, duration: 4 * walkCycle)
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
