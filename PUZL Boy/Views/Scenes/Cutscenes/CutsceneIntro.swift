//
//  CutsceneIntro.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/1/23.
//

import SpriteKit

class CutsceneIntro: SKScene {
    
    // MARK: - Properties

    //Positions, Scales
    private let heroPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 3)
    private let princessPosition = CGPoint(x: K.ScreenDimensions.iPhoneWidth + 80, y: K.ScreenDimensions.height / 3 - 40)
    private let playerScale: CGFloat = 0.75
    
    //Main Nodes
    private(set) var parallaxManager: ParallaxManager!
    private var skyNode: SKSpriteNode!
    private var hero: Player!
    private var princess: Player!
    private var dragonSprite: SKSpriteNode!
    
    //Speech
    private var speechHero: SpeechBubbleSprite!
    private var speechPrincess: SpeechBubbleSprite!
    private var overlaySpeech: SpeechOverlaySprite!
    
    //Overlays
    private var dimOverlayNode: SKShapeNode!
    private var bloodOverlayNode: SKShapeNode!
    private var flashOverlayNode: SKShapeNode!

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
        let screenSize: CGSize = K.ScreenDimensions.screenSize
        
        hero = Player(type: .hero)
        hero.sprite.position = heroPosition
        hero.sprite.setScale(playerScale)
        hero.sprite.name = LaunchScene.nodeName_playerSprite
        
        princess = Player(type: .princess)
        princess.sprite.position = princessPosition
        princess.sprite.setScale(playerScale * 0.75)
        princess.sprite.xScale = -playerScale * 0.75
        princess.sprite.name = LaunchScene.nodeName_playerSprite
        
        overlaySpeech = SpeechOverlaySprite(text: "She just kept rambling and rambling and rambling... I had no idea what she was talking about but she mentioned something about Dragons appearing out of nowhere and the capture of the king. It was surreal...")
        
        dragonSprite = SKSpriteNode(imageNamed: "enemy")
        dragonSprite.position = CGPoint(x: -dragonSprite.size.width, y: K.ScreenDimensions.height + dragonSprite.size.height)
        dragonSprite.zPosition = K.ZPosition.player + 10

        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(useMorningSky: true)))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode
        
        dimOverlayNode = SKShapeNode(rectOf: screenSize)
        dimOverlayNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        dimOverlayNode.fillColor = .black
        dimOverlayNode.lineWidth = 0
        dimOverlayNode.alpha = 0
        dimOverlayNode.zPosition = K.ZPosition.chatDimOverlay
        
        bloodOverlayNode = SKShapeNode(rectOf: screenSize)
        bloodOverlayNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        bloodOverlayNode.fillColor = .red
        bloodOverlayNode.lineWidth = 0
        bloodOverlayNode.alpha = 0
        bloodOverlayNode.zPosition = K.ZPosition.bloodOverlay
        
        flashOverlayNode = SKShapeNode(rectOf: screenSize)
        flashOverlayNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        flashOverlayNode.fillColor = .yellow
        flashOverlayNode.lineWidth = 0
        flashOverlayNode.alpha = 0
        flashOverlayNode.zPosition = K.ZPosition.bloodOverlay + 10
        
        parallaxManager = ParallaxManager(useSet: .grass, xOffsetsArray: xOffsetsArray, shouldWalk: true)
        
        speechHero = SpeechBubbleSprite(width: 460, position: heroPosition + CGPoint(x: 200, y: 400))
        speechPrincess = SpeechBubbleSprite(width: 460, position: princessPosition + CGPoint(x: -400, y: 400), shouldFlipTail: true)

    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(dimOverlayNode)
        addChild(bloodOverlayNode)
        addChild(flashOverlayNode)
        addChild(hero.sprite)
        addChild(princess.sprite)
        addChild(dragonSprite)
        
        addChild(overlaySpeech)

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
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechHero, chat: "🎵 I'm a Barbie girl,| in the Barbie world.|| Life in plastic,| it's fantastic! You can brush my hair—/Oh.....|| hello.| Didn't see you there... 😬|||| I'm PUZL Boy. 👋🏼", handler: closeUpPrincess),
                    SpeechBubbleItem(profile: speechPrincess, chat: "Hi! My name is Princess Olivia and I'm 9 years old.|| I'm late for a V|E|R|Y| important appointment.", handler: closeUpHero),
                    SpeechBubbleItem(profile: speechHero, chat: "Wait,| like an actual princess, or...| is that more of a self-proclaimed title?||||||||/Also what kind of important meeting does a 9 year old need to attend?||||||||/And where are your parents?|| Are you here by yourself???") { [unowned self] in
                        closeUpPrincess()
                        
                        dimOverlayNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 12),
                            SKAction.fadeAlpha(to: 0.8, duration: 1)
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPrincess, chat: "Oh, umm...|| you ask too many questions!||||||||/But if you must know,| the reason why I'm here is because— blah blah blah...||||/Blah blah blah, blah blah blah dragons blah, blah blah, blah blah blah, magic.||||||||/Blah blah, blah. BLAH blah blah blah, blahhhhh blah. Blah. Blah. Blah. Blah blah captured...||||||||/And furthermore— blah blah blah, blah blah blah|| ...last known descendant.") { [unowned self] in
                        wideShot()
                        
                        dimOverlayNode.run(SKAction.fadeOut(withDuration: 1))
                    },
                    SpeechBubbleItem(profile: speechHero, chat: "Wow that is some story!|| Well don't worry Princess, I'll get you to where you need to go—") { [unowned self] in
                        
                        // TODO: - All the dragon action here...
                        run(SKAction.sequence([
                            SKAction.run { [unowned self] in
                                skyNode.texture = SKTexture(image: DayTheme.getBloodSkyImage())
                                bloodOverlayNode.run(SKAction.fadeAlpha(to: 0.5, duration: 1))
                            },
                            SKAction.wait(forDuration: 2),
                            SKAction.run { [unowned self] in
                                dragonSprite.run(SKAction.group([
                                    SKAction.scale(to: 5, duration: 0.5),
                                    SKAction.move(to: CGPoint(x: K.ScreenDimensions.screenSize.width / 2, y: K.ScreenDimensions.screenSize.height / 2), duration: 0.5)
                                ]))
                            },
                            SKAction.wait(forDuration: 2),
                            SKAction.run { [unowned self] in
                                flashOverlayNode.run(SKAction.sequence([
                                    SKAction.fadeIn(withDuration: 0),
                                    SKAction.fadeOut(withDuration: 0.25)
                                ]))
                                AudioManager.shared.playSound(for: "enemyscratch")
                            }
                        ]))
                        
                        
                    },
                    SpeechBubbleItem(profile: speechPrincess, chat: "Great, now I'm being captured. Could this day get any worse?!?!") { [unowned self] in
                        didFinishAnimating()
                    }
                ], completion: completion)
            }
        ])) //end Speech Bubbles animation
        
        
    }

    /**
     Helper to SpeechBubbleSprite.setText(). Takes in an array of SpeechBubbleItems and process them recursively, with nesting completion handlers.
     - parameters:
        - items: array of SpeechBubbleItems to process
        - currentIndex: keeps track of the array index, which is handled recursively
        - completion: process any handlers between text animations.
     */
    private func setTextArray(items: [SpeechBubbleItem], currentIndex: Int = 0, completion: (() -> Void)?) {
        guard currentIndex < items.count else {
            //Base case
            completion?()

            return
        }
        
        items[currentIndex].profile.setText(text: items[currentIndex].chat, superScene: self) { [unowned self] in
            items[currentIndex].handler?()
            
            //Recursion!!
            setTextArray(items: items, currentIndex: currentIndex + 1, completion: completion)
        }
    }
    
    private func didFinishAnimating() {
        hero.sprite.removeAllActions()
        princess.sprite.removeAllActions()
        parallaxManager.removeAllActions()
        
        hero.sprite.removeFromParent()
        princess.sprite.removeFromParent()
        parallaxManager.removeFromParent()
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
