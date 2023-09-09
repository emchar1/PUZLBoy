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
    private let heroPosition = CGPoint(x: K.ScreenDimensions.screenSize.width / 2, y: K.ScreenDimensions.screenSize.height / 3)
    private let princessPosition = CGPoint(x: K.ScreenDimensions.screenSize.width - 120, y: K.ScreenDimensions.screenSize.height / 3 - 40)
    private let playerScale: CGFloat = 0.75
    private let screenSize = K.ScreenDimensions.screenSize
    
    //Main Nodes
    private(set) var parallaxManager: ParallaxManager!
    private var skyNode: SKSpriteNode!
    private var hero: Player!
    private var princess: Player!
    private var dragonSprite: SKSpriteNode!
    private var flyingDragon: FlyingDragon!
    
    //Speech
    private var speechHero: SpeechBubbleSprite!
    private var speechPrincess: SpeechBubbleSprite!
    private var overlaySpeech: SpeechOverlaySprite!
    private var skipIntroSprite: SkipIntroSprite!

    //Overlays
    private var dimOverlayNode: SKShapeNode!
    private var bloodOverlayNode: SKShapeNode!
    private var flashOverlayNode: SKShapeNode!
    private var fadeTransitionNode: SKShapeNode!
    
    private var completion: (() -> Void)?

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
        princess.sprite.position = CGPoint(x: princessPosition.x + 200, y: princessPosition.y)
        princess.sprite.setScale(playerScale * 0.75)
        princess.sprite.xScale = -playerScale * 0.75
        princess.sprite.name = LaunchScene.nodeName_playerSprite
        
        overlaySpeech = SpeechOverlaySprite()
        
        skipIntroSprite = SkipIntroSprite()
        skipIntroSprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 9)
        skipIntroSprite.zPosition = K.ZPosition.speechBubble
        skipIntroSprite.delegate = self

        
        dragonSprite = SKSpriteNode(imageNamed: "enemy")
        dragonSprite.position = CGPoint(x: -dragonSprite.size.width, y: K.ScreenDimensions.height + dragonSprite.size.height)
        dragonSprite.zPosition = K.ZPosition.player + 10
        
        flyingDragon = FlyingDragon()

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
        
        fadeTransitionNode = SKShapeNode(rectOf: screenSize)
        fadeTransitionNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        fadeTransitionNode.fillColor = .black
        fadeTransitionNode.lineWidth = 0
        fadeTransitionNode.alpha = 0
        fadeTransitionNode.zPosition = K.ZPosition.fadeTransitionNode
        
        parallaxManager = ParallaxManager(useSet: .grass, xOffsetsArray: xOffsetsArray, shouldWalk: true)
        
        speechHero = SpeechBubbleSprite(width: 460, position: heroPosition + CGPoint(x: 200, y: 400))
        speechPrincess = SpeechBubbleSprite(width: 460, position: princessPosition + CGPoint(x: -200, y: 400), tailOrientation: .bottomRight)

    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(dimOverlayNode)
        addChild(bloodOverlayNode)
        addChild(flashOverlayNode)
        addChild(fadeTransitionNode)
        addChild(hero.sprite)
        addChild(princess.sprite)
        addChild(dragonSprite)
        
        parallaxManager.addSpritesToParent(scene: self)
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        skipIntroSprite.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        skipIntroSprite.touchesEnded(touches, with: event)
    }
    
    
    // MARK: - Animation Functions
    
    func animateScene(completion: (() -> Void)?) {
        let frameRate: TimeInterval = 0.06
        let walkCycle: TimeInterval = frameRate * 15 //1 cycle at 0.06s x 15 frames = 0.9s
        let heroWalk = SKAction.animate(with: hero.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        let heroIdle = SKAction.animate(with: hero.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate)
        let princessIdle = SKAction.animate(with: princess.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate * 1.5)
        
        self.completion = completion
        
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
                SKAction.moveTo(x: princessPosition.x, duration: 2 * walkCycle),
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
                    SpeechBubbleItem(profile: speechHero, chat: "🎵 I'm a Barbie girl,| in the Barbie world.|| Life in plastic,| it's fantastic! You can brush my hair—/Oh.....|| hello.| Didn't see you there... 😬|||| I'm PUZL Boy.") { [unowned self] in
                        addChild(skipIntroSprite)
                        skipIntroSprite.animateSprite()
                    },
                    SpeechBubbleItem(profile: speechPrincess, chat: "Hi! 👋🏽 I'm Princess Olivia and I'm 7 years old.|| I'm late for a V|E|R|Y| important appointment.") { [unowned self] in
                        closeUpHero()
                    },
                    SpeechBubbleItem(profile: speechHero, chat: "Wait,| like an actual princess, or...| is that more of a self-proclaimed title?||||||||/And what kind of important meeting does a 7 year old need to attend?||||||||/Also, where are your parents? Are you here by yourself???") { [unowned self] in
                        closeUpPrincess()
                        
                        dimOverlayNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 15),
                            SKAction.fadeAlpha(to: 0.8, duration: 1),
                            SKAction.wait(forDuration: 1),
                            SKAction.run { [unowned self] in
                                overlaySpeech.setText(
                                    text: "She went on to explain how dragons had disappeared from the realm of some place called Eldoria, where she claims she's from,|| and that the balance of magic had been disrupted.||||||||/The princess then foretold a prophecy where the sky turns blood red, ushering a new era—||At first, it sounded like make believe...|||| And then the CRAZIEST thing happened!!",
                                    superScene: self, completion: nil)
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPrincess, chat: "Oh, umm...|| you ask too many questions!||||||||/But if you must know,| the reason why I'm here is because— blah blah blah...||||/Blah blah blah, blah blah blah DRAGONS blah, blah blah, blah blah blah, blah.||||||||/ELDORIA blah, blah. BLAH blah blah blah, blahhhhh blah. Blah. Blah. Blah. MAGIC!!||||||||/And furthermore— blah blah blah, blah blah blah. Blah, blah, blah|||| ...A|G|E| O|F| R|U|I|N.||||||||") { [unowned self] in
                        wideShot()
                        
                        dimOverlayNode.run(SKAction.fadeOut(withDuration: 1))
                        
                        flyingDragon.animate(toNode: self,
                                             from: CGPoint(x: screenSize.width, y: screenSize.height * 7 / 8),
                                             to: CGPoint(x: -flyingDragon.sprite.size.width, y: 0),
                                             duration: 10)
                        
                        overlaySpeech.removeFromParent()
                        
                        bloodOverlayNode.run(SKAction.fadeAlpha(to: 0.5, duration: 10)) { [unowned self] in
                            skyNode.texture = SKTexture(image: DayTheme.getBloodSkyImage())
                        }
                    },
                    SpeechBubbleItem(profile: speechHero, chat: "Whew, that is some story!|| Well don't worry Princess, I'll get you to where you need to go—") { [unowned self] in
                        run(SKAction.sequence([
                            SKAction.run { [unowned self] in
                                dragonSprite.run(SKAction.group([
                                    SKAction.scale(to: 5, duration: 0.5),
                                    SKAction.move(to: CGPoint(x: princessPosition.x, y: princessPosition.y + princess.sprite.size.height / 2), duration: 0.5)
                                ]))
                            },
                            SKAction.run { [unowned self] in
                                flashOverlayNode.run(SKAction.sequence([
                                    SKAction.fadeIn(withDuration: 0),
                                    SKAction.fadeOut(withDuration: 0.25)
                                ]))
                                AudioManager.shared.playSound(for: "enemyscratch")
                            },
                            SKAction.wait(forDuration: 0.6),
                            SKAction.run { [unowned self] in
                                dragonSprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + princess.sprite.size.height / 2)
                                dragonSprite.setScale(10)
                                closeUpPrincess()
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPrincess, speed: 0.01, chat: "AAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!") { [unowned self] in
                        wideShot()
                        
                        dragonSprite.position = CGPoint(x: princessPosition.x, y: princessPosition.y + princess.sprite.size.height / 2)
                        dragonSprite.setScale(5)
                        
                        let abductionSpeed: TimeInterval = 1
                        
                        princess.sprite.run(SKAction.sequence([
                            SKAction.group([
                                SKAction.move(to: CGPoint(x: 0, y: screenSize.height + dragonSprite.size.height), duration: abductionSpeed),
                                SKAction.scaleX(to: -playerScale / 8 * 0.75, duration: abductionSpeed),
                                SKAction.scaleY(to: playerScale / 8 * 0.75, duration: abductionSpeed)
                            ]),
                            SKAction.group([
                                SKAction.removeFromParent(),
                                SKAction.run { [unowned self] in
                                    princess.sprite.position = CGPoint(x: 150, y: -130)
                                    princess.sprite.setScale(-playerScale / 4 * 0.75)
                                    princess.sprite.zPosition = 1
                                    
                                    flyingDragon.sprite.addChild(princess.sprite)
                                }
                            ])
                        ]))
                        
                        dragonSprite.run(SKAction.group([
                            SKAction.move(to: CGPoint(x: 0, y: screenSize.height + dragonSprite.size.height), duration: abductionSpeed),
                            SKAction.scale(to: 0.5, duration: abductionSpeed)
                        ]))
                        
                        speechPrincess.run(SKAction.sequence([
                            SKAction.group([
                                SKAction.run { [unowned self] in
                                    speechPrincess.updateTailOrientation(.topLeft)
                                },
                                SKAction.move(to: CGPoint(x: speechPrincess.bubbleDimensions.width / 2, y: screenSize.height * 7 / 8 - speechPrincess.bubbleDimensions.height), duration: abductionSpeed),
                            ]),
                            SKAction.group([
                                SKAction.moveTo(x: screenSize.width - speechPrincess.bubbleDimensions.width / 2, duration: 8),
                                SKAction.sequence([
                                    SKAction.wait(forDuration: 6),
                                    SKAction.run { [unowned self] in
                                        speechPrincess.updateTailOrientation(.topRight)
                                    }
                                ])
                            ])
                        ]))
                        
                        flyingDragon.animate(toNode: self,
                                             from: CGPoint(x: -2 * flyingDragon.sprite.size.width, y: screenSize.height * 7 / 8),
                                             to: CGPoint(x: screenSize.width + flyingDragon.sprite.size.width, y: 0),
                                             duration: 10,
                                             reverseDirection: true)
                    },
                    SpeechBubbleItem(profile: speechPrincess, speed: 0.04, chat: "HELP ME MAR—| I mean,| PUZL BOYYYYYYY!!!!!!!||||||||/The fate of Eldoria rests in your hands!") { [unowned self] in
                        let frameRate: TimeInterval = 0.02
                        let runCycle: TimeInterval = frameRate * 15 //1 cycle at 0.02s x 15 frames = 0.3s
                        let heroRun = SKAction.animate(with: hero.textures[Player.Texture.run.rawValue], timePerFrame: frameRate)
                        
                        hero.sprite.run(SKAction.group([
                            SKAction.repeat(heroRun, count: 2),
                            SKAction.sequence([
                                SKAction.moveTo(x: screenSize.width / 2, duration: 2 * runCycle),
                                SKAction.repeatForever(heroIdle)
                            ])
                        ]))
                        
                        speechHero.run(SKAction.moveTo(x: speechHero.position.x + screenSize.width / 2 - hero.sprite.position.x, duration: 2 * runCycle))
                    },
                    SpeechBubbleItem(profile: speechHero, chat: "Hang on princess, I'm coming to get you!!!")
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
        
        items[currentIndex].profile.setText(text: items[currentIndex].chat, speed: items[currentIndex].speed, superScene: self) { [unowned self] in
            items[currentIndex].handler?()
            
            //Recursion!!
            setTextArray(items: items, currentIndex: currentIndex + 1, completion: completion)
        }
    }
    
    private func closeUpPrincess() {
        princess.sprite.position.x = screenSize.width / 2
        princess.sprite.setScale(2 * 0.75)
        princess.sprite.xScale = -2 * 0.75
        
        hero.sprite.position.x = -200
        hero.sprite.setScale(playerScale)

        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 400
        parallaxManager.backgroundSprite.position.x = -screenSize.width / 2
        
        speechPrincess.position = CGPoint(x: screenSize.width - 300, y: screenSize.height + 400) / 2
    }
    
    private func closeUpHero() {
        princess.sprite.position.x = princessPosition.x + 200
        princess.sprite.setScale(playerScale * 0.75)
        princess.sprite.xScale = -playerScale * 0.75
        
        hero.sprite.position.x = screenSize.width / 2
        hero.sprite.setScale(2)
        
        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 400
        parallaxManager.backgroundSprite.position.x = screenSize.width / 2
        
        speechHero.position = CGPoint(x: screenSize.width + 300, y: screenSize.height + 700) / 2
    }
    
    private func wideShot() {
        princess.sprite.position.x = princessPosition.x
        princess.sprite.setScale(playerScale * 0.75)
        princess.sprite.xScale = -playerScale * 0.75
        
        hero.sprite.position.x = 120
        hero.sprite.setScale(playerScale)

        parallaxManager.backgroundSprite.setScale(1)
        parallaxManager.backgroundSprite.position = .zero
        
        speechPrincess.position = princessPosition + CGPoint(x: -200, y: 400)
        
        speechHero.position = CGPoint(x: 120 + speechHero.bubbleDimensions.width / 2, y: heroPosition.y + 400)
    }
}


// MARK: - SkipIntroSpriteDelegate

extension CutsceneIntro: SkipIntroSpriteDelegate {
    func buttonWasTapped() {
        ButtonTap.shared.tap(type: .buttontap1)

        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            self.completion?()
        }
    }
    
}
