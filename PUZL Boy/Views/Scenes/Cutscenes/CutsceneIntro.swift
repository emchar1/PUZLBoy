//
//  CutsceneIntro.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/1/23.
//

import SpriteKit

class CutsceneIntro: Cutscene {
    
    // MARK: - Properties
    
    //General
    private let grasslandOverworld = "overworldgrassland"
    private var heroPositionInitial: CGPoint { CGPoint(x: screenSize.width / 2, y: screenSize.height / 3) }
    private var heroPositionFinal: CGPoint { CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 3) }
    private var princessPositionInitial: CGPoint { CGPoint(x: screenSize.width + 100,
                                                           y: screenSize.height / 3 + Player.getNormalizedAdjustedHeight(player: playerRight)) }
    private var princessPositionFinal: CGPoint { CGPoint(x: screenSize.width * 4 / 5,
                                                         y: screenSize.height / 3 + Player.getNormalizedAdjustedHeight(player: playerRight)) }
    
    //Main Nodes
    private var dragonSprite: SKSpriteNode!
    
    //Overlay Nodes
    private var flashOverlayNode: SKShapeNode!
    
    //Funny Quotes
    static var funnyQuotes: [String] = [
        "I'm a Barbie girl,| in a Barbie world.|| Life in plastic,| it's fantastic! You can brush my hair",
    ]
    
    
    // MARK: - Initialization
    
    init() {
        super.init(size: K.ScreenDimensions.size, playerLeft: .hero, playerRight: .princess, xOffsetsArray: nil)
        
        //Custom implementation here, if needed.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupScene() {
        super.setupScene()
        
        playerLeft.sprite.position = heroPositionInitial
        
        playerRight.sprite.position = princessPositionInitial
        playerRight.sprite.xScale *= -1
        
        skipSceneSprite.setText(text: "SKIP INTRO")
        skipSceneSprite.delegate = self
        
        dragonSprite = SKSpriteNode(imageNamed: "enemyLarge")
        dragonSprite.position = CGPoint(x: -dragonSprite.size.width, y: screenSize.height + dragonSprite.size.height)
        dragonSprite.zPosition = K.ZPosition.player - 10
        
        flashOverlayNode = SKShapeNode(rectOf: screenSize)
        flashOverlayNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        flashOverlayNode.fillColor = .yellow
        flashOverlayNode.lineWidth = 0
        flashOverlayNode.alpha = 0
        flashOverlayNode.zPosition = K.ZPosition.bloodOverlay + 10
        
        speechPlayerLeft.position += heroPositionInitial
        speechPlayerRight.position += princessPositionFinal
        
        AudioManager.shared.playSound(for: "birdsambience", fadeIn: 5)
        AudioManager.shared.playSound(for: grasslandOverworld, fadeIn: 5)
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)
        
        //Custom implementation here, if needed.
    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundNode.addChild(flashOverlayNode)
        backgroundNode.addChild(dragonSprite)
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //Custom implementation here, if needed.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        //Custom implementation here, if needed.
    }
    
    
    // MARK: - Animation Functions
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)
        
        let frameRate: TimeInterval = 0.06
        let walkCycle: TimeInterval = frameRate * 15 //1 cycle at 0.06s x 15 frames = 0.9s
        
        //Letterbox
        letterbox.show()
        
        //Hero Sprite
        playerLeft.sprite.run(SKAction.group([
            Player.animate(player: playerLeft, type: .walk, timePerFrame: frameRate, repeatCount: 13),
            SKAction.sequence([
                SKAction.wait(forDuration: 6 * walkCycle),
                SKAction.moveTo(x: heroPositionFinal.x, duration: 4 * walkCycle),
                SKAction.wait(forDuration: 3 * walkCycle),
                Player.animate(player: playerLeft, type: .idle, timePerFrame: frameRate)
            ])
        ]))
        
        //Princess Sprite
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 11 * walkCycle),
            SKAction.group([
                SKAction.moveTo(x: princessPositionFinal.x, duration: 2 * walkCycle),
                Player.animate(player: playerRight, type: .idle, timePerFrame: frameRate * 1.5)
            ])
        ]))
        
        //Parallax Manager
        parallaxManager.animate()
        run(SKAction.sequence([
            SKAction.wait(forDuration: 13 * walkCycle),
            SKAction.run { [weak self] in
                self?.parallaxManager.stopAnimation()
                Haptics.shared.addHapticFeedback(withStyle: .heavy)
            }
        ]))
        
        //Speech - Hero Move
        speechPlayerLeft.run(SKAction.sequence([
            SKAction.wait(forDuration: 4 * walkCycle),
            SKAction.moveTo(x: heroPositionFinal.x + speechPlayerLeft.bubbleDimensions.width / 2, duration: 4 * walkCycle)
        ]))
        
        //Speech Bubbles
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2 * walkCycle),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                //Properties for dragon spawn sequence, below. The hard coded values seem a bit random, but they are indeed all intentional and thus should not be changed under any circumstances! (Unless they change in their physical assets...)
                let parallaxLayer = parallaxManager.getSpriteFor(set: ParallaxObject.SetType.grass.rawValue, layer: 1) ?? SKNode()
                let parallaxLayerZPosition = K.ZPosition.parallaxLayer0 - 5 * CGFloat(1) + 3 + 1
                let particleHalfHeight: CGFloat = CGFloat(877) / 2
                let particleStart: CGPoint = CGPoint(x: 580, y: 300)
                let particleScale: CGFloat = CGFloat(2048) / CGFloat(1550)
                
                
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "🎵 \(CutsceneIntro.funnyQuotes.randomElement() ?? "Error0")—/Oh.....|| hello.| Didn't see you there... 😬|||| I'm PUZL Boy.") {
                        self.addChild(self.skipSceneSprite)
                        self.skipSceneSprite.animateSprite()
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "Hi! 👋🏽| I'm Princess Olivia and I'm 7 years old.|| I'm late for a V|E|R|Y| important appointment.") {
                        self.closeUpHero()
                    },
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "Awww...|| wait, like an actual princess, or is that what mommy and daddy call you?||||||||/And what kind of important meeting does a 7 year old need to attend?||||||||/Speaking of which, where are your parents?| Are you here by yourself???") {
                        self.closeUpPrincess()
                        
                        self.dimOverlayNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 28),
                            SKAction.fadeAlpha(to: 0.8, duration: 1),
                            SKAction.wait(forDuration: 2),
                            SKAction.group([
                                SKAction.fadeIn(withDuration: 23), //34 total seconds, to coincide with closeUpPrincess() animation sequence
                                SKAction.run {
                                    self.narrateArray(items: [
                                        NarrationItem(text: "PUZL Boy: The princess went on to explain how dragons had disappeared from the realm of some place called Vaeloria, where she claims she's from,|| and that the balance of magic had been disrupted threatening our very existence.||||||||/She spoke about a prophecy where the Earth splits open and the sky turns to ash, signaling the Age of Ruin, and that she was the only one who could stop it—||At first, I thought this little girl just had an overactive imagination...||||||/..........Then the CRAZIEST thing happened!!")
                                    ], completion: nil)
                                    
                                    AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: 5)
                                    AudioManager.shared.stopSound(for: self.grasslandOverworld, fadeDuration: 8)
                                    AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 8)
                                }
                            ])
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "Wow.|| You sure ask a lot of questions!||||||||/But if you must know, the reason I'm here is because, well.. first of all, Oh—I'm a princess!||/And, but I'm not a princess here though I'm a princess in a very very far away place.|/You see, I'm not from this place but I am from, umm, wait... Let me start over.| Okay so.....|/Blah blah blah, blah blah blah DRAGONS blah, blah blah, blah blah blah, blah.||||||||/VAELORIA blah, blah.| Blah, blah blah blah, blah blah. Blah. Blah. Blah.| M|A|G|I|C!!||||||||/Blah blah, blah blah!|| blah blah blah,| blah blah blah.| Blah, blah, blah|| .|.|.|A|G|E| O|F| R|U|I|N|.||||||||||||") {
                        
                        self.wideShot(shouldResetForeground: true)
                        self.dimOverlayNode.run(SKAction.fadeOut(withDuration: 1))
                        self.speechNarrator.removeFromParent()
                        self.showBloodSky(fadeDuration: 6, delay: 4)
                        
                        self.backgroundNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 4),
                            self.shakeBackground(duration: 6)
                        ]))
                        
                        self.run(SKAction.sequence([
                            SKAction.run {
                                AudioManager.shared.playSound(for: "birdsambience", fadeIn: 2)
                                AudioManager.shared.playSound(for: self.grasslandOverworld, fadeIn: 2)
                                AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 3)
                            },
                            SKAction.wait(forDuration: 2),
                            SKAction.run {
                                AudioManager.shared.playSound(for: "thunderrumble")
                                AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: 6)
                                AudioManager.shared.stopSound(for: self.grasslandOverworld, fadeDuration: 6)
                            },
                            SKAction.wait(forDuration: 2),
                            SKAction.run {
                                Haptics.shared.executeCustomPattern(pattern: .thunder)
                                
                                ParticleEngine.shared.animateParticles(
                                    type: .groundSplit,
                                    toNode: parallaxLayer,
                                    position: CGPoint(x: particleStart.x * particleScale, y: particleHalfHeight + particleStart.y * particleScale),
                                    scale: UIDevice.modelInfo.ratio / 2,
                                    zPosition: parallaxLayerZPosition,
                                    duration: 0)
                            },
                            SKAction.wait(forDuration: 4),
                            SKAction.run {
                                AudioManager.shared.playSoundThenStop(for: "lavaappear2", playForDuration: 2, fadeOut: 2)
                                AudioManager.shared.playSound(for: "ageofruin")
                                
                                self.parallaxManager.addSplitGroundSprite(animationDuration: 0.1) {
                                    let parallaxSplitLayer = self.parallaxManager.getSpriteFor(set: ParallaxObject.SetType.grass.rawValue, layer: 13) ?? SKNode()
                                    
                                    for i in 0..<65 {
                                        let dragonSpawn = FlyingDragon(scale: CGFloat.random(in: 0.35...0.5))
                                        let spawnRange = CGFloat.random(in: -250...250)
                                        let posStart = CGPoint(x: particleStart.x + FlyingDragon.size.width / 2,
                                                               y: particleStart.y + FlyingDragon.size.height / 2)
                                        
                                        dragonSpawn.sprite.zRotation = .pi / 2
                                        dragonSpawn.sprite.yScale *= spawnRange < 0 ? -1 : 1
                                        dragonSpawn.sprite.zPosition = parallaxLayerZPosition
                                        
                                        self.run(SKAction.sequence([
                                            SKAction.wait(forDuration: TimeInterval(i) * 0.2),
                                            SKAction.run {
                                                dragonSpawn.animate(toNode: parallaxSplitLayer,
                                                                    from: posStart,
                                                                    to: CGPoint(x: posStart.x + spawnRange, y: K.ScreenDimensions.size.height),
                                                                    duration: TimeInterval.random(in: 1...2))
                                            }
                                        ]))
                                    }
                                    
                                    ParticleEngine.shared.animateParticles(
                                        type: .groundExplode,
                                        toNode: parallaxSplitLayer,
                                        position: CGPoint(x: particleStart.x * particleScale,
                                                          y: particleHalfHeight + particleStart.y * particleScale),
                                        scale: UIDevice.modelInfo.ratio / 2,
                                        zPosition: parallaxLayerZPosition,
                                        duration: 0)
                                    
                                    ParticleEngine.shared.animateParticles(
                                        type: .groundWarp,
                                        toNode: parallaxSplitLayer,
                                        position: CGPoint(x: particleStart.x * particleScale,
                                                          y: particleHalfHeight + particleStart.y * particleScale),
                                        scale: UIDevice.modelInfo.ratio / 2,
                                        zPosition: parallaxLayerZPosition - 1,
                                        duration: 0)
                                    
                                    ParticleEngine.shared.removeParticles(fromNode: parallaxLayer)
                                }
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "What a cute story!|| Well don't worry, I'll get you to where you need to...|| WHAT THE—") {
                        self.run(SKAction.sequence([
                            SKAction.run {
                                self.dragonSprite.run(SKAction.group([
                                    SKAction.scale(to: 2, duration: 0.5),
                                    SKAction.move(to: CGPoint(x: self.princessPositionFinal.x,
                                                              y: self.princessPositionFinal.y + self.playerRight.sprite.size.height / 2), duration: 0.5)
                                ]))
                            },
                            SKAction.wait(forDuration: 0.6),
                            SKAction.run {
                                
                                //Fly, my dragons!
                                for i in 0..<60 {
                                    let randomY = CGFloat.random(in: 5.5...7)
                                    let randomScale: CGFloat = (0.8 * randomY - 4.1) / 3 //y = mx + b for points (5.5, 0.1) and (7, 0.5)
                                    
                                    let flyingDragons = FlyingDragon(scale: randomScale)
                                    flyingDragons.sprite.zPosition = parallaxLayerZPosition - 2
                                    
                                    self.run(SKAction.sequence([
                                        SKAction.wait(forDuration: TimeInterval(i) * TimeInterval.random(in: 0.5...2)),
                                        SKAction.run {
                                            flyingDragons.animate(toNode: self,
                                                                  from: CGPoint(x: -FlyingDragon.size.width,
                                                                                y: self.screenSize.height * randomY / 8),
                                                                  to: CGPoint(x: self.screenSize.width + FlyingDragon.size.width, y: 0),
                                                                  duration: TimeInterval.random(in: 8...10))
                                        }
                                    ]))
                                }
                                
                                self.flashOverlayNode.run(SKAction.sequence([
                                    SKAction.fadeIn(withDuration: 0),
                                    SKAction.fadeOut(withDuration: 0.25)
                                ]))
                                
                                self.midShotPrincessDragon()
                                
                                AudioManager.shared.playSound(for: "enemyroar")
                                Haptics.shared.executeCustomPattern(pattern: .enemy)
                                ParticleEngine.shared.animateParticles(type: .dragonFire,
                                                                       toNode: self.dragonSprite,
                                                                       position: CGPoint(x: 10, y: 80),
                                                                       duration: 5)
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, speed: 0.01, chat: "AAAAAAAHHHHH! IT'S HAPPENING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!") {
                        let flyingDragon = FlyingDragon()
                        
                        self.wideShot()
                        
                        self.dragonSprite.position = CGPoint(x: self.princessPositionFinal.x,
                                                             y: self.princessPositionFinal.y + self.playerRight.sprite.size.height / 2)
                        self.dragonSprite.setScale(2)
                        
                        ParticleEngine.shared.removeParticles(fromNode: self.dragonSprite)
                        
                        let abductionSpeed: TimeInterval = 1
                        
                        self.playerRight.sprite.run(SKAction.sequence([
                            SKAction.group([
                                SKAction.move(to: CGPoint(x: -self.dragonSprite.size.width * 0.25,
                                                          y: self.screenSize.height - self.letterbox.height / 2 + self.dragonSprite.size.height * 0.25),
                                              duration: abductionSpeed),
                                SKAction.scaleX(to: -self.playerRight.scaleMultiplier * Player.cutsceneScale / 8, duration: abductionSpeed),
                                SKAction.scaleY(to: self.playerRight.scaleMultiplier * Player.cutsceneScale / 8, duration: abductionSpeed)
                            ]),
                            SKAction.removeFromParent()
                        ])) {
                            self.playerRight.sprite.position = CGPoint(x: 180, y: -140) //specific position so princess is in dragon's clutches
                            self.playerRight.sprite.setScale(self.playerRight.scaleMultiplier * Player.cutsceneScale / 4)
                            self.playerRight.sprite.yScale *= -1
                            self.playerRight.sprite.zPosition = -1
                            
                            //Just in case sprite's removeFromParent() went out of sync and still has a parent...
                            self.playerRight.sprite.removeFromParent()
                            flyingDragon.sprite.addChild(self.playerRight.sprite)
                        }
                        
                        self.dragonSprite.run(SKAction.group([
                            SKAction.move(to: CGPoint(x: -self.dragonSprite.size.width * 0.25,
                                                      y: self.screenSize.height - self.letterbox.height / 2 + self.dragonSprite.size.height * 0.25),
                                          duration: abductionSpeed),
                            SKAction.scale(to: 0.25, duration: abductionSpeed)
                        ]))
                        
                        self.speechPlayerRight.updateTailOrientation(.topLeft)
                        self.speechPlayerRight.run(SKAction.sequence([
                            SKAction.move(to: CGPoint(x: self.speechPlayerRight.bubbleDimensions.width / 2,
                                                      y: self.screenSize.height * 6 / 8 - self.speechPlayerRight.bubbleDimensions.height),
                                          duration: abductionSpeed),
                            SKAction.wait(forDuration: 2),
                            SKAction.group([
                                SKAction.moveTo(x: self.screenSize.width - self.speechPlayerRight.bubbleDimensions.width / 2, duration: 6),
                                SKAction.sequence([
                                    SKAction.wait(forDuration: 3),
                                    SKAction.run {
                                        self.speechPlayerRight.updateTailOrientation(.topRight)
                                    }
                                ])
                            ])
                        ]))
                        
                        flyingDragon.animate(toNode: self,
                                             from: CGPoint(x: -FlyingDragon.size.width, y: self.screenSize.height * 6 / 8),
                                             to: CGPoint(x: self.screenSize.width + FlyingDragon.size.width, y: 0),
                                             duration: 10)
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, speed: 0.04, chat: "SAVE ME MAR—|I mean,| PUZL BOYYY!!!!||||/The fate of the world rests in your hands!!") {
                        let frameRateFast: TimeInterval = 0.02
                        let runCycle: TimeInterval = frameRateFast * 15 //1 cycle at 0.02s x 15 frames = 0.3s
                        
                        self.playerLeft.sprite.run(SKAction.group([
                            Player.animate(player: self.playerLeft, type: .run, timePerFrame: frameRateFast, repeatCount: 2),
                            SKAction.sequence([
                                SKAction.moveTo(x: self.screenSize.width / 2, duration: 1.5 * runCycle),
                                Player.animate(player: self.playerLeft, type: .idle, timePerFrame: frameRate)
                            ])
                        ]))
                        
                        self.speechPlayerLeft.run(SKAction.moveTo(x: self.speechPlayerLeft.position.x + self.screenSize.width / 2 - self.playerLeft.sprite.position.x, duration: 1.5 * runCycle))
                        
                        self.skipSceneSprite.removeAllActions()
                        self.skipSceneSprite.removeFromParent()
                        
                        self.hideBloodSky(fadeDuration: 5)
                        self.letterbox.hide(delay: 2)
                        
                        AudioManager.shared.stopSound(for: "thunderrumble", fadeDuration: 5)
                    },
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "Hang on princess! I'm coming to rescue you!!!")
                ]) {
                    AudioManager.shared.stopSound(for: "ageofruin", fadeDuration: 4)
                    UserDefaults.standard.set(true, forKey: K.UserDefaults.shouldSkipIntro)
                    self.cleanupScene(buttonTap: nil, fadeDuration: 2)
                } //end setTextArray()
            } //end SKAction.run { [weak self]...
        ])) //end run(SKAction.sequence[(...
    } //end animateScene()
    
    
    // MARK: - Camera Shots
    
    private func closeUpHero() {
        playerRight.sprite.position = princessPositionInitial
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1
        
        playerLeft.sprite.position.x = screenSize.width / 2
        playerLeft.sprite.setScale(2)
        
        skyNode.setScale(1)

        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 400
        parallaxManager.backgroundSprite.position.x = screenSize.width / 2
        
        speechPlayerLeft.position = CGPoint(x: screenSize.width + 300, y: screenSize.height + 700) / 2
    }
    
    private func closeUpPrincess() {
        playerRight.sprite.position.x = screenSize.width / 2
        playerRight.sprite.position.y = princessPositionInitial.y
        playerRight.sprite.setScale(2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier)
        playerRight.sprite.xScale *= -1
        
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 34),
            SKAction.group([
                SKAction.scaleX(to: -4 * 0.75, y: 4 * 0.75, duration: 20),
                SKAction.moveBy(x: 0, y: 2 * 4 * 0.75 * 20, duration: 20)
            ])
        ]), withKey: "princessCloseUpAction")
        
        playerLeft.sprite.position.x = -200
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)
        
        skyNode.setScale(1)

        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 400
        parallaxManager.backgroundSprite.position.x = -screenSize.width / 2
        
        speechPlayerRight.position = CGPoint(x: screenSize.width - 300, y: screenSize.height + 400) / 2
    }
    
    private func closeUpSplitGround(particleStart: CGPoint) {
        playerRight.sprite.position.y = -screenSize.height
        playerLeft.sprite.position.y = -screenSize.height
        
        skyNode.setScale(2)

        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -screenSize.height * 2 / 3
        parallaxManager.backgroundSprite.position.x = -2 * particleStart.x + screenSize.width / 2
        
        speechPlayerRight.position = CGPoint(x: -speechPlayerRight.bubbleDimensions.width / 2, y: princessPositionFinal.y)
        speechPlayerLeft.position = CGPoint(x: speechPlayerLeft.bubbleDimensions.width / 2, y: heroPositionFinal.y)
    }
    
    private func midShotPrincessDragon() {
        playerRight.sprite.position.x = screenSize.width / 2
        playerRight.sprite.position.y = princessPositionFinal.y
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1
        
        playerRight.sprite.run(Player.animate(player: playerRight, type: .jump, timePerFrame: 0.02), withKey: "writhe")
        
        playerLeft.sprite.position.x = -200
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)
        
        dragonSprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        dragonSprite.setScale(4)
        
        skyNode.setScale(1)
        
        parallaxManager.backgroundSprite.setScale(1 / 0.75)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 750
        parallaxManager.backgroundSprite.position.x = -screenSize.width / 2
        
        speechPlayerRight.position = CGPoint(x: screenSize.width - 300, y: screenSize.height) / 2
    }
    
    private func wideShot(shouldResetForeground: Bool = false) {
        playerRight.sprite.removeAction(forKey: "princessCloseUpAction")
        playerRight.sprite.position = princessPositionFinal
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1
        
        playerLeft.sprite.position = heroPositionFinal
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)
        
        skyNode.setScale(1)

        parallaxManager.backgroundSprite.setScale(1)
        parallaxManager.backgroundSprite.position = .zero
        
        if shouldResetForeground {
            parallaxManager.resetxPositions(index: 0)
            parallaxManager.resetxPositions(index: 1)
        }
        
        speechPlayerRight.position = princessPositionFinal + CGPoint(x: -200, y: 400)
        speechPlayerLeft.position = CGPoint(x: heroPositionFinal.x + speechPlayerLeft.bubbleDimensions.width / 2, y: heroPositionInitial.y + 400)
    }
    
}


// MARK: - SkipSceneSpriteDelegate

extension CutsceneIntro: SkipSceneSpriteDelegate {
    func buttonWasTapped() {
        let fadeDuration: TimeInterval = 1
        
        stopAllMusic(fadeDuration: fadeDuration)
        UserDefaults.standard.set(true, forKey: K.UserDefaults.shouldSkipIntro)
        cleanupScene(buttonTap: .buttontap1, fadeDuration: fadeDuration)
    }
    
    ///Helper function that stops all music, preventing bug# 240616E01
    func stopAllMusic(fadeDuration: TimeInterval) {
        AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: grasslandOverworld, fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "ageofruin", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "thunderrumble", fadeDuration: fadeDuration)
    }
}
