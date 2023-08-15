//
//  CutsceneIntro.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/1/23.
//

import SpriteKit

class CutsceneIntro: SKScene {
    
    // MARK: - Properties
    
    private let heroPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 3)
    private let princessPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth + 80, y: K.ScreenDimensions.height / 3 - 40)
    private let playerScale: CGFloat = 0.75
    
    private var hero: Player!
    private var princess: Player!
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
        hero = Player(type: .hero)
        hero.sprite.position = heroPosition
        hero.sprite.setScale(playerScale)
        hero.sprite.name = LaunchScene.nodeName_playerSprite
        
        princess = Player(type: .princess)
        princess.sprite.position = princessPosition
        princess.sprite.setScale(playerScale * 0.75)
        princess.sprite.xScale = -playerScale * 0.75
        princess.sprite.name = LaunchScene.nodeName_playerSprite

        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(useMorningSky: true)))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode
        
        parallaxManager = ParallaxManager(useSet: .grass, xOffsetsArray: xOffsetsArray, shouldWalk: true)
    }
    
    private func animateScene() {
        let frameRate: TimeInterval = 0.06
        let walkCycle: TimeInterval = frameRate * 15 //1 cycle at 0.06s x 15 frames = 0.9s
        let heroWalk = SKAction.animate(with: hero.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        let heroIdle = SKAction.animate(with: hero.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate)
        let princessIdle = SKAction.animate(with: princess.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate * 1.5)
        
        let speechHero = SpeechBubbleSprite(text: "🎵I'm a Barbie girl,| in the Barbie world.|| Life in plastic,| it's fantastic. You can brush my—/Oh.. hello!",
                                            width: 460,
                                            position: CGPoint(x: heroPosition.x + 200, y: heroPosition.y + 400))

        //Hero Sprite
        hero.sprite.run(SKAction.group([
            SKAction.repeat(heroWalk, count: 13),
            SKAction.sequence([
                SKAction.wait(forDuration: 6 * walkCycle),
                SKAction.group([
                    SKAction.moveTo(x: 120, duration: 4 * walkCycle),
//                    SKAction.moveTo(y: playerPosition.y - 60, duration: 4 * walkCycle),
//                    SKAction.scale(to: playerScale * 0.75, duration: 4 * walkCycle)
                ]),
                SKAction.wait(forDuration: 3 * walkCycle),
                SKAction.repeatForever(heroIdle)
            ])
        ]))
        
        //Princess Sprite
        princess.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 11 * walkCycle),
            SKAction.group([
                SKAction.moveTo(x: princessPosition.x - 200, duration: 2 * walkCycle),
                SKAction.repeatForever(princessIdle)
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
                speechHero.beginAnimation(superScene: self) {
                    print("Certida")
                    
                }
            }
        ]))
        
        speechHero.run(SKAction.sequence([
            SKAction.wait(forDuration: 6 * walkCycle),
            SKAction.moveTo(x: 120 + speechHero.bubbleDimensions.width / 2, duration: 4 * walkCycle)
        ]))
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(hero.sprite)
        addChild(princess.sprite)

        parallaxManager.addSpritesToParent(scene: self)
    }
    
    func finishAnimating(completion: @escaping () -> Void) {
        hero.sprite.removeAllActions()
        princess.sprite.removeAllActions()
        parallaxManager.removeAllActions()
        
        hero.sprite.removeFromParent()
        princess.sprite.removeFromParent()
        parallaxManager.removeFromParent()
        
        completion()
    }
}
