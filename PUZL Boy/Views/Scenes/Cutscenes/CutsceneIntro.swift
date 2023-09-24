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
    private var bloodSkyNode: SKSpriteNode!
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
    
    //Misc.
    private var completion: (() -> Void)?

    //Funny Quotes
    static var funnyQuotes: [String] = [
        "I'm a Barbie girl,| in a Barbie world.|| Life in plastic,| it's fantastic! You can brush my hair",
    ]


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

        
        dragonSprite = SKSpriteNode(imageNamed: "enemyLarge")
        dragonSprite.position = CGPoint(x: -dragonSprite.size.width, y: K.ScreenDimensions.height + dragonSprite.size.height)
        dragonSprite.zPosition = K.ZPosition.player + 10
        
        flyingDragon = FlyingDragon()

        skyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage(useMorningSky: true)))
        skyNode.anchorPoint = .zero
        skyNode.zPosition = K.ZPosition.skyNode
        skyNode.name = LaunchScene.nodeName_skyNode
        
        bloodSkyNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getBloodSkyImage()))
        bloodSkyNode.anchorPoint = .zero
        bloodSkyNode.zPosition = K.ZPosition.skyNode
        bloodSkyNode.name = LaunchScene.nodeName_skyNode
        bloodSkyNode.alpha = 0
        
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

        AudioManager.shared.playSound(for: "birdsambience", fadeIn: 5)
    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        addChild(skyNode)
        addChild(bloodSkyNode)
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
                Haptics.shared.addHapticFeedback(withStyle: .heavy)
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
                    SpeechBubbleItem(profile: speechHero, chat: "🎵 \(CutsceneIntro.funnyQuotes.randomElement() ?? "Error0")—/Oh.....|| hello.| Didn't see you there... 😬|||| I'm PUZL Boy.") { [unowned self] in
                        addChild(skipIntroSprite)
                        skipIntroSprite.animateSprite()
                    },
                    SpeechBubbleItem(profile: speechPrincess, chat: "Hi! 👋🏽| I'm Princess Olivia and I'm 7 years old.|| I'm late for a V|E|R|Y| important appointment.") { [unowned self] in
                        closeUpHero()
                    },
                    SpeechBubbleItem(profile: speechHero, chat: "Awww...|| wait, like an actual princess, or is that what mommy and daddy call you?||||||||/And what kind of important meeting does a 7 year old need to attend?||||||||/Speaking of which, where are your parents?| Are you here by yourself???") { [unowned self] in
                        closeUpPrincess()
                        
                        dimOverlayNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 14),
                            SKAction.fadeAlpha(to: 0.8, duration: 1),
                            SKAction.wait(forDuration: 2),
                            SKAction.run { [unowned self] in
                                overlaySpeech.setText(
                                    text: "The princess went on to explain how dragons had disappeared from the realm of some place called Vaeloria, where she claims she's from,|| and that the balance of magic had been disrupted threatening our very existence.||||||||/She foretold of a prophecy where the sky turns blood red, and that she was the only one who could stop it—||At first, I thought this little girl just had an overactive imagination...|| then the CRAZIEST thing happened!!",
                                    superScene: self, completion: nil)
                                
                                AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: 5)
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPrincess, chat: "Oh, umm...|| you sure ask a lot of questions!||||||||/But if you must know,| the reason why I'm here is because—blah blah blah...||||/Blah blah blah, blah blah blah DRAGONS blah, blah blah, blah blah blah, blah.||||||||/VAELORIA blah, blah.| BLAH blah blah blah, blahhhhh blah.| Blah. Blah. Blah. M|A|G|I|C!!||||||||/And furthermore—||blah blah blah,| blah blah blah.| Blah, blah, blah|| .|.|.|A|G|E| O|F| R|U|I|N|.||||||||") { [unowned self] in
                        wideShot()
                        
                        dimOverlayNode.run(SKAction.fadeOut(withDuration: 1))
                                                
                        flyingDragon.animate(toNode: self,
                                             from: CGPoint(x: screenSize.width, y: screenSize.height * 7 / 8),
                                             to: CGPoint(x: -flyingDragon.sprite.size.width, y: 0),
                                             duration: 10)
                        
                        overlaySpeech.removeFromParent()
                        
                        skyNode.run(SKAction.fadeOut(withDuration: 10))
                        bloodSkyNode.run(SKAction.fadeIn(withDuration: 10))
                        bloodOverlayNode.run(SKAction.fadeAlpha(to: 0.25, duration: 10))

                        run(SKAction.sequence([
                            SKAction.run {
                                AudioManager.shared.playSound(for: "birdsambience", fadeIn: 2)
                            },
                            SKAction.wait(forDuration: 2),
                            SKAction.run {
                                AudioManager.shared.playSound(for: "thunderrumble")
                                AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: 3)
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechHero, chat: "Whew, that is some story!|| Well don't worry, I'll get you to where you need to...|| WHAT THE—") { [unowned self] in
                        run(SKAction.sequence([
                            SKAction.run { [unowned self] in
                                dragonSprite.run(SKAction.group([
                                    SKAction.scale(to: 2, duration: 0.5),
                                    SKAction.move(to: CGPoint(x: princessPosition.x, y: princessPosition.y + princess.sprite.size.height / 2), duration: 0.5)
                                ]))
                                
                                AudioManager.shared.playSound(for: "ageofruin")
                            },
                            SKAction.wait(forDuration: 0.6),
                            SKAction.run { [unowned self] in
                                flashOverlayNode.run(SKAction.sequence([
                                    SKAction.fadeIn(withDuration: 0),
                                    SKAction.fadeOut(withDuration: 0.25)
                                ]))
                                
                                midShotPrincessDragon()
                                
                                AudioManager.shared.playSound(for: "enemyscratch")
                                Haptics.shared.executeCustomPattern(pattern: .enemy)
                                ParticleEngine.shared.animateParticles(type: .dragonFire,
                                                                       toNode: dragonSprite,
                                                                       position: CGPoint(x: 10, y: 80),
                                                                       duration: 5)
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPrincess, speed: 0.01, chat: "AAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!") { [unowned self] in
                        wideShot()
                        
                        dragonSprite.position = CGPoint(x: princessPosition.x, y: princessPosition.y + princess.sprite.size.height / 2)
                        dragonSprite.setScale(2)
                        
                        ParticleEngine.shared.removeParticles(fromNode: dragonSprite)
                        
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
                                    princess.sprite.position = CGPoint(x: 180, y: -140)
                                    princess.sprite.xScale = playerScale / 4 * 0.75
                                    princess.sprite.yScale = -playerScale / 4 * 0.75
                                    princess.sprite.zPosition = 1
                                    
                                    flyingDragon.sprite.addChild(princess.sprite)
                                }
                            ])
                        ]))
                        
                        dragonSprite.run(SKAction.group([
                            SKAction.move(to: CGPoint(x: 0, y: screenSize.height + dragonSprite.size.height), duration: abductionSpeed),
                            SKAction.scale(to: 0.25, duration: abductionSpeed)
                        ]))
                        
                        speechPrincess.run(SKAction.sequence([
                            SKAction.group([
                                SKAction.run { [unowned self] in
                                    speechPrincess.updateTailOrientation(.topLeft)
                                },
                                SKAction.move(to: CGPoint(x: speechPrincess.bubbleDimensions.width / 2, y: screenSize.height * 7 / 8 - speechPrincess.bubbleDimensions.height), duration: abductionSpeed),
                            ]),
                            SKAction.wait(forDuration: 2),
                            SKAction.group([
                                SKAction.moveTo(x: screenSize.width - speechPrincess.bubbleDimensions.width / 2, duration: 6),
                                SKAction.sequence([
                                    SKAction.wait(forDuration: 3),
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
                    SpeechBubbleItem(profile: speechPrincess, speed: 0.04, chat: "SAVE ME MAR—|I mean,| PUZL BOYYYYYYY!!!!!!!||||||||/The fate of the world rests in your haaaaands!") { [unowned self] in
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

                        skyNode.run(SKAction.fadeIn(withDuration: 5))
                        bloodSkyNode.run(SKAction.fadeOut(withDuration: 5))
                        bloodOverlayNode.run(SKAction.fadeOut(withDuration: 5))
                    },
                    SpeechBubbleItem(profile: speechHero, chat: "Hang on princess...| I'm coming to rescue you!!!||||")
                ]) {
                    UserDefaults.standard.set(true, forKey: K.UserDefaults.shouldSkipIntro)

                    completion?()
                }
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
    
    private func midShotPrincessDragon() {
        princess.sprite.position.x = screenSize.width / 2
        princess.sprite.setScale(0.75)
        princess.sprite.xScale = -0.75
        
        hero.sprite.position.x = -200
        hero.sprite.setScale(playerScale)
        
        dragonSprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        dragonSprite.setScale(4)

        parallaxManager.backgroundSprite.setScale(1 / 0.75)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 750
        parallaxManager.backgroundSprite.position.x = -screenSize.width / 2
        
        speechPrincess.position = CGPoint(x: screenSize.width - 300, y: screenSize.height) / 2
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
        AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: 1)
        AudioManager.shared.stopSound(for: "ageofruin", fadeDuration: 1)
        UserDefaults.standard.set(true, forKey: K.UserDefaults.shouldSkipIntro)

        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            self.completion?()
        }
    }
    
}
