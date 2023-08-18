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
    private var speechHero: SpeechBubbleSprite!
    private var speechPrincess: SpeechBubbleSprite!
    
    
    // MARK: - Initialization
    
    init(size: CGSize, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
        super.init(size: size)
        
        setupScene(xOffsetsArray: xOffsetsArray)
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
        
        speechHero = SpeechBubbleSprite(width: 460, position: heroPosition + CGPoint(x: 200, y: 400))
        speechPrincess = SpeechBubbleSprite(width: 460, position: princessPosition + CGPoint(x: -400, y: 400), shouldFlipTail: true)

    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(hero.sprite)
        addChild(princess.sprite)

        parallaxManager.addSpritesToParent(scene: self)
    }
    
    
    // MARK: - Animation Functions
    
    func animateScene(completion: (() -> Void)?) {
        let frameRate: TimeInterval = 0.06
        let walkCycle: TimeInterval = frameRate * 15 //1 cycle at 0.06s x 15 frames = 0.9s
        let heroWalk = SKAction.animate(with: hero.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        let heroIdle = SKAction.animate(with: hero.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate)
        let princessIdle = SKAction.animate(with: princess.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate * 1.5)
        
        //Hero Sprite
        hero.sprite.run(SKAction.group([
            SKAction.repeat(heroWalk, count: 13),
            SKAction.sequence([
                SKAction.wait(forDuration: 6 * walkCycle),
                SKAction.moveTo(x: 120, duration: 4 * walkCycle),
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
        
        //Speech - Hero Move
        speechHero.run(SKAction.sequence([
            SKAction.wait(forDuration: 4 * walkCycle),
            SKAction.moveTo(x: 120 + speechHero.bubbleDimensions.width / 2, duration: 4 * walkCycle)
        ]))

        //Speech Bubbles
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2 * walkCycle),
            SKAction.run { [unowned self] in
                speechHero.setText(text: "🎵 I'm a Barbie girl,| in the Barbie world.|| Life in plastic,| it's fantastic! You can brush my hair—/Oh.....|| hello.| Didn't see you there... 😬|||| I'm PUZL Boy. 👋🏼", superScene: self) { [unowned self] in
                    
                    closeUpPrincess()
                    
                    speechPrincess.setText(text: "Hi! My name is Princess Olivia and I'm 7 years old.|| I'm late for a V|E|R|Y| important appointment.", superScene: self) { [unowned self] in
                        
                        closeUpHero()
                        
                        speechHero.setText(text: "Wait,| like an actual princess, or...| is that more of a self-proclaimed title?||||||||/Also what kind of important meeting does a 7 year old need to attend?||||||||/And where are your parents?|| Are you here by yourself???", superScene: self) { [unowned self] in
                            
                            closeUpPrincess()
                            
                            speechPrincess.setText(text: "Oh, umm...|| you ask too many questions!||||||||/But if you must know,| the reason why I'm here is because— blah blah blah...||||/Blah blah blah, blah blah blah dragons blah, blah blah, blah blah blah, magic.||||||||/Blah blah, blah. BLAH blah blah blah, blahhhhh blah. Blah. Blah. Blah. Blah blah captured...||||||||/And furthermore— blah blah blah, blah blah blah|| ...last known descendant.", superScene: self) { [unowned self] in
                                
                                wideShot()
                                
                                speechHero.setText(text: "Wow that is some story!|| Well don't worry Princess, I'll get you to where you need to go—", superScene: self) { [unowned self] in
                                    didFinishAnimating(completion: completion)
                                }
                            }
                        }
                    }
                }
            }
        ]))
    }
    
    private func didFinishAnimating(completion: (() -> Void)?) {
        hero.sprite.removeAllActions()
        princess.sprite.removeAllActions()
        parallaxManager.removeAllActions()
        
        hero.sprite.removeFromParent()
        princess.sprite.removeFromParent()
        parallaxManager.removeFromParent()
        
        completion?()
    }
    
    private func closeUpPrincess() {
        princess.sprite.position.x = K.ScreenDimensions.iPhoneWidth / 2
        princess.sprite.setScale(2 * 0.75)
        princess.sprite.xScale = -2 * 0.75
        
        hero.sprite.position.x = -200
        hero.sprite.setScale(playerScale)

        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -K.ScreenDimensions.height / 2 + 400
        parallaxManager.backgroundSprite.position.x = -K.ScreenDimensions.iPhoneWidth / 2
        
        speechPrincess.position = CGPoint(x: K.ScreenDimensions.screenSize.width - 300, y: K.ScreenDimensions.screenSize.height + 400) / 2
    }
    
    private func closeUpHero() {
        princess.sprite.position.x = princessPosition.x
        princess.sprite.setScale(playerScale * 0.75)
        princess.sprite.xScale = -playerScale * 0.75
        
        hero.sprite.position.x = K.ScreenDimensions.iPhoneWidth / 2
        hero.sprite.setScale(2)
        
        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -K.ScreenDimensions.height / 2 + 400
        parallaxManager.backgroundSprite.position.x = K.ScreenDimensions.iPhoneWidth / 2
        
        speechHero.position = CGPoint(x: K.ScreenDimensions.screenSize.width + 300, y: K.ScreenDimensions.screenSize.height + 700) / 2
    }
    
    private func wideShot() {
        princess.sprite.position.x = princessPosition.x - 200
        princess.sprite.setScale(playerScale * 0.75)
        princess.sprite.xScale = -playerScale * 0.75
        
        hero.sprite.position.x = 120
        hero.sprite.setScale(playerScale)

        parallaxManager.backgroundSprite.setScale(1)
        parallaxManager.backgroundSprite.position = .zero
        
        speechPrincess.position = princessPosition + CGPoint(x: -400, y: 400)
        
        speechHero.position = CGPoint(x: 120 + speechHero.bubbleDimensions.width / 2, y: heroPosition.y + 400)
    }
}
