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
    private var heroPositionInitial: CGPoint { CGPoint(x: screenSize.width / 2, y: screenSize.height / 3) }
    private var heroPositionFinal: CGPoint { CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 3) }
    private var princessPositionInitial: CGPoint { CGPoint(x: screenSize.width + 100,
                                                           y: screenSize.height / 3 + Player.getNormalizedAdjustedHeight(player: playerRight)) }
    private var princessPositionFinal: CGPoint { CGPoint(x: screenSize.width * 4 / 5, 
                                                         y: screenSize.height / 3 + Player.getNormalizedAdjustedHeight(player: playerRight)) }
    
    //Main Nodes
    private var bloodSkyNode: SKSpriteNode!
    private var dragonSprite: SKSpriteNode!
    private var flyingDragon: FlyingDragon!

    //Overlay Nodes
    private var bloodOverlayNode: SKShapeNode!
    private var flashOverlayNode: SKShapeNode!
    
    //Funny Quotes
    static var funnyQuotes: [String] = [
        "I'm a Barbie girl,| in a Barbie world.|| Life in plastic,| it's fantastic! You can brush my hair",
    ]


    // MARK: - Initialization
    
    override init(size: CGSize, playerLeft: Player.PlayerType, playerRight: Player.PlayerType, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
        super.init(size: size, playerLeft: playerLeft, playerRight: playerRight, xOffsetsArray: xOffsetsArray)
        
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
        
        flyingDragon = FlyingDragon()
                
        bloodSkyNode = SKSpriteNode(texture: SKTexture(image: UIImage.gradientSkyBlood))
        bloodSkyNode.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
        bloodSkyNode.position = CGPoint(x: 0, y: screenSize.height)
        bloodSkyNode.anchorPoint = CGPoint(x: 0, y: 1)
        bloodSkyNode.zPosition = K.ZPosition.skyNode
        bloodSkyNode.alpha = 0
        
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
        
        speechPlayerLeft.position += heroPositionInitial
        speechPlayerRight.position += princessPositionFinal
        
        AudioManager.shared.playSound(for: "birdsambience", fadeIn: 5)
        AudioManager.shared.playSound(for: AudioManager.shared.grasslandTheme, fadeIn: 5)
    }
    
    
    // MARK: - Move Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundNode.addChild(bloodSkyNode)
        backgroundNode.addChild(bloodOverlayNode)
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
        let heroWalk = SKAction.animate(with: playerLeft.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
        let heroIdle = SKAction.animate(with: playerLeft.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate)
        let princessIdle = SKAction.animate(with: playerRight.textures[Player.Texture.idle.rawValue], timePerFrame: frameRate * 1.5)
        
        //Letterbox
        letterbox.show()
        
        //Hero Sprite
        playerLeft.sprite.run(SKAction.group([
            SKAction.repeat(heroWalk, count: 13),
            SKAction.sequence([
                SKAction.wait(forDuration: 6 * walkCycle),
                SKAction.moveTo(x: heroPositionFinal.x, duration: 4 * walkCycle),
                SKAction.wait(forDuration: 3 * walkCycle),
                SKAction.repeatForever(heroIdle)
            ])
        ]))
        
        //Princess Sprite
        playerRight.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 11 * walkCycle),
            SKAction.group([
                SKAction.moveTo(x: princessPositionFinal.x, duration: 2 * walkCycle),
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
        speechPlayerLeft.run(SKAction.sequence([
            SKAction.wait(forDuration: 4 * walkCycle),
            SKAction.moveTo(x: heroPositionFinal.x + speechPlayerLeft.bubbleDimensions.width / 2, duration: 4 * walkCycle)
        ]))

        //Speech Bubbles
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2 * walkCycle),
            SKAction.run { [unowned self] in
                setTextArray(items: [
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "🎵 \(CutsceneIntro.funnyQuotes.randomElement() ?? "Error0")—/Oh.....|| hello.| Didn't see you there... 😬|||| I'm PUZL Boy.") { [unowned self] in
                        addChild(skipSceneSprite)
                        skipSceneSprite.animateSprite()
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "Hi! 👋🏽| I'm Princess Olivia and I'm 7 years old.|| I'm late for a V|E|R|Y| important appointment.") { [unowned self] in
                        closeUpHero()
                    },
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "Awww...|| wait, like an actual princess, or is that what mommy and daddy call you?||||||||/And what kind of important meeting does a 7 year old need to attend?||||||||/Speaking of which, where are your parents?| Are you here by yourself???") { [unowned self] in
                        closeUpPrincess()
                        
                        dimOverlayNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 28),
                            SKAction.fadeAlpha(to: 0.8, duration: 1),
                            SKAction.wait(forDuration: 2),
                            SKAction.group([
                                SKAction.fadeIn(withDuration: 23), //34 total seconds, to coincide with closeUpPrincess() animation sequence
                                SKAction.run { [unowned self] in
                                    speechNarrator.setText(
                                        text: "PUZL Boy: The princess went on to explain how dragons had disappeared from the realm of some place called Vaeloria, where she claims she's from,|| and that the balance of magic had been disrupted threatening our very existence.||||||||/She spoke about a prophecy where the Earth splits open and the sky darkens, signaling the Age of Ruin, and that she was the only one who could stop it—||At first, I thought this little girl just had an overactive imagination...||||||/  ..........Then the CRAZIEST thing happened!!",
                                        superScene: self, completion: nil)
                                    
                                    AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: 5)
                                    AudioManager.shared.stopSound(for: AudioManager.shared.grasslandTheme, fadeDuration: 8)
                                    AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 5, delay: 3)
                                }
                            ])
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, chat: "Wow.|| You sure ask a lot of questions!||||||||/But if you must know,| the reason I'm here is because, well.. first of all, Oh—I'm a princess!|||/And, but... oh! Not here though. I'm a princess in a very very far away place.|||/You see, I'm not from this place. But I am from, well—blah blah blah...||||/Blah blah blah, blah blah blah DRAGONS blah, blah blah, blah blah blah, blah.||||||||/VAELORIA blah, blah.| BLAH blah blah blah, blahhhhh blah.| Blah. Blah. Blah. M|A|G|I|C!!||||||||/And then. And THEN!|| blah blah blah,| blah blah blah.| Blah, blah, blah|| .|.|.|A|G|E| O|F| R|U|I|N|.||||||||||||") { [unowned self] in
                        wideShot(shouldResetForeground: true)
                        
                        dimOverlayNode.run(SKAction.fadeOut(withDuration: 1))
                                                
                        flyingDragon.animate(toNode: self,
                                             from: CGPoint(x: screenSize.width, y: screenSize.height * 6 / 8),
                                             to: CGPoint(x: -flyingDragon.sprite.size.width, y: 0),
                                             duration: 10)
                        
                        speechNarrator.removeFromParent()
                        
                        skyNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 4),
                            SKAction.fadeOut(withDuration: 6)
                        ]))

                        bloodSkyNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 4),
                            SKAction.fadeIn(withDuration: 6)
                        ]))
                        
                        bloodOverlayNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 4),
                            SKAction.fadeAlpha(to: 0.25, duration: 6)
                        ]))

                        
                        let nudge: CGFloat = 5
                        let nudgeDuration: TimeInterval = 0.04
                        
                        backgroundNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 4),
                            SKAction.repeat(SKAction.sequence([
                                SKAction.moveBy(x: -nudge, y: nudge, duration: nudgeDuration),
                                SKAction.moveBy(x: nudge, y: nudge, duration: nudgeDuration),
                                SKAction.moveBy(x: nudge, y: -nudge, duration: nudgeDuration),
                                SKAction.moveBy(x: -nudge, y: -nudge, duration: nudgeDuration),
                            ]), count: Int(6.0 / nudgeDuration))
                        ]))
                        
                        run(SKAction.sequence([
                            SKAction.run {
                                AudioManager.shared.playSound(for: "birdsambience", fadeIn: 2)
                                AudioManager.shared.playSound(for: AudioManager.shared.grasslandTheme, fadeIn: 2)
                                AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 3)
                            },
                            SKAction.wait(forDuration: 2),
                            SKAction.run {
                                AudioManager.shared.playSound(for: "thunderrumble")
                                AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: 6)
                                AudioManager.shared.stopSound(for: AudioManager.shared.grasslandTheme, fadeDuration: 6)
                            },
                            SKAction.wait(forDuration: 2),
                            SKAction.run {
                                Haptics.shared.executeCustomPattern(pattern: .thunder)
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "What a cute story!|| Well don't worry, I'll get you to where you need to...|| WHAT THE—") { [unowned self] in
                        run(SKAction.sequence([
                            SKAction.run { [unowned self] in
                                dragonSprite.run(SKAction.group([
                                    SKAction.scale(to: 2, duration: 0.5),
                                    SKAction.move(to: CGPoint(x: princessPositionFinal.x,
                                                              y: princessPositionFinal.y + playerRight.sprite.size.height / 2), duration: 0.5)
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
                                
                                AudioManager.shared.playSound(for: "enemyroar")
                                AudioManager.shared.playSound(for: "enemyscratch")
                                Haptics.shared.executeCustomPattern(pattern: .enemy)
                                ParticleEngine.shared.animateParticles(type: .dragonFire,
                                                                       toNode: dragonSprite,
                                                                       position: CGPoint(x: 10, y: 80),
                                                                       duration: 5)
                            }
                        ]))
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, speed: 0.01, chat: "AAAAAAAHHHHH! IT'S HAPPENING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!") { [unowned self] in
                        wideShot()
                        
                        dragonSprite.position = CGPoint(x: princessPositionFinal.x, y: princessPositionFinal.y + playerRight.sprite.size.height / 2)
                        dragonSprite.setScale(2)
                        
                        ParticleEngine.shared.removeParticles(fromNode: dragonSprite)
                        
                        let abductionSpeed: TimeInterval = 1
                        
                        playerRight.sprite.run(SKAction.sequence([
                            SKAction.group([
                                SKAction.move(to: CGPoint(x: -dragonSprite.size.width * 0.25, 
                                                          y: screenSize.height - letterbox.height / 2 + dragonSprite.size.height * 0.25),
                                              duration: abductionSpeed),
                                SKAction.scaleX(to: -playerRight.scaleMultiplier * Player.cutsceneScale / 8, duration: abductionSpeed),
                                SKAction.scaleY(to: playerRight.scaleMultiplier * Player.cutsceneScale / 8, duration: abductionSpeed)
                            ]),
                            SKAction.group([
                                SKAction.removeFromParent(),
                                SKAction.run { [unowned self] in
                                    playerRight.sprite.position = CGPoint(x: 180, y: -140) //specific position so princess is in dragon's clutches
                                    playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale / 4)
                                    playerRight.sprite.yScale *= -1
                                    playerRight.sprite.zPosition = -1
                                    flyingDragon.sprite.addChild(playerRight.sprite)
                                }
                            ])
                        ]))
                        
                        dragonSprite.run(SKAction.group([
                            SKAction.move(to: CGPoint(x: -dragonSprite.size.width * 0.25,
                                                      y: screenSize.height - letterbox.height / 2 + dragonSprite.size.height * 0.25),
                                          duration: abductionSpeed),
                            SKAction.scale(to: 0.25, duration: abductionSpeed)
                        ]))
                        
                        speechPlayerRight.run(SKAction.sequence([
                            SKAction.group([
                                SKAction.run { [unowned self] in
                                    speechPlayerRight.updateTailOrientation(.topLeft)
                                },
                                SKAction.move(to: CGPoint(x: speechPlayerRight.bubbleDimensions.width / 2, y: screenSize.height * 6 / 8 - speechPlayerRight.bubbleDimensions.height), duration: abductionSpeed),
                            ]),
                            SKAction.wait(forDuration: 2),
                            SKAction.group([
                                SKAction.moveTo(x: screenSize.width - speechPlayerRight.bubbleDimensions.width / 2, duration: 6),
                                SKAction.sequence([
                                    SKAction.wait(forDuration: 3),
                                    SKAction.run { [unowned self] in
                                        speechPlayerRight.updateTailOrientation(.topRight)
                                    }
                                ])
                            ])
                        ]))
                        
                        flyingDragon.animate(toNode: self,
                                             from: CGPoint(x: -2 * flyingDragon.sprite.size.width, y: screenSize.height * 6 / 8),
                                             to: CGPoint(x: screenSize.width + flyingDragon.sprite.size.width, y: 0),
                                             duration: 10,
                                             reverseDirection: true)
                    },
                    SpeechBubbleItem(profile: speechPlayerRight, speed: 0.04, chat: "SAVE ME MARIO—|I mean,| PUZL BOYYYYYYY!!!!!!!|||||||/The fate of the world rests in your haaaaands!") { [unowned self] in
                        let frameRate: TimeInterval = 0.02
                        let runCycle: TimeInterval = frameRate * 15 //1 cycle at 0.02s x 15 frames = 0.3s
                        let heroRun = SKAction.animate(with: playerLeft.textures[Player.Texture.run.rawValue], timePerFrame: frameRate)
                        
                        playerLeft.sprite.run(SKAction.group([
                            SKAction.repeat(heroRun, count: 2),
                            SKAction.sequence([
                                SKAction.moveTo(x: screenSize.width / 2, duration: 1.5 * runCycle),
                                SKAction.repeatForever(heroIdle)
                            ])
                        ]))
                        
                        speechPlayerLeft.run(SKAction.moveTo(x: speechPlayerLeft.position.x + screenSize.width / 2 - playerLeft.sprite.position.x,
                                                             duration: 1.5 * runCycle))
                        
                        skipSceneSprite.removeAllActions()
                        skipSceneSprite.removeFromParent()

                        skyNode.run(SKAction.fadeIn(withDuration: 5))
                        bloodSkyNode.run(SKAction.fadeOut(withDuration: 5))
                        bloodOverlayNode.run(SKAction.fadeOut(withDuration: 5))
                        letterbox.hide(delay: 2)

                        AudioManager.shared.stopSound(for: "thunderrumble", fadeDuration: 5)
                    },
                    SpeechBubbleItem(profile: speechPlayerLeft, chat: "Hang on princess! I'm coming to rescue you!!!|||")
                ]) { [unowned self] in
                    AudioManager.shared.stopSound(for: "ageofruin", fadeDuration: 4)
                    UserDefaults.standard.set(true, forKey: K.UserDefaults.shouldSkipIntro)
                    cleanupScene(buttonTap: nil, fadeDuration: 2)
                }
            }
        ])) //end Speech Bubbles animation
    }
    
    
    // MARK: - Animation Helper Functions
    
    private func closeUpHero() {
        playerRight.sprite.position = princessPositionInitial
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1
        
        playerLeft.sprite.position.x = screenSize.width / 2
        playerLeft.sprite.setScale(2)
        
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
        ]))
        
        playerLeft.sprite.position.x = -200
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)

        parallaxManager.backgroundSprite.setScale(2)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 400
        parallaxManager.backgroundSprite.position.x = -screenSize.width / 2
        
        speechPlayerRight.position = CGPoint(x: screenSize.width - 300, y: screenSize.height + 400) / 2
    }
    
    private func midShotPrincessDragon() {
        playerRight.sprite.position.x = screenSize.width / 2
        playerRight.sprite.position.y = princessPositionFinal.y
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1
        
        playerRight.sprite.run(SKAction.repeatForever(SKAction.animate(with: playerRight.textures[Player.Texture.jump.rawValue],
                                                                       timePerFrame: 0.02)), withKey: "writhe")
        
        playerLeft.sprite.position.x = -200
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)
        
        dragonSprite.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        dragonSprite.setScale(4)

        parallaxManager.backgroundSprite.setScale(1 / 0.75)
        parallaxManager.backgroundSprite.position.y = -screenSize.height / 2 + 750
        parallaxManager.backgroundSprite.position.x = -screenSize.width / 2
        
        speechPlayerRight.position = CGPoint(x: screenSize.width - 300, y: screenSize.height) / 2
    }
    
    private func wideShot(shouldResetForeground: Bool = false) {
        playerRight.sprite.position = princessPositionFinal
        playerRight.sprite.setScale(playerRight.scaleMultiplier * Player.cutsceneScale)
        playerRight.sprite.xScale *= -1
        
        playerLeft.sprite.position.x = heroPositionFinal.x
        playerLeft.sprite.setScale(playerLeft.scaleMultiplier * Player.cutsceneScale)

        parallaxManager.backgroundSprite.setScale(1)
        parallaxManager.backgroundSprite.position = .zero
        
        if shouldResetForeground {
            parallaxManager.resetxPositions(index: 0)
        }
            
        speechPlayerRight.position = princessPositionFinal + CGPoint(x: -200, y: 400)
        speechPlayerLeft.position = CGPoint(x: heroPositionFinal.x + speechPlayerLeft.bubbleDimensions.width / 2, y: heroPositionInitial.y + 400)
    }
    
}


// MARK: - SkipSceneSpriteDelegate

extension CutsceneIntro: SkipSceneSpriteDelegate {
    func buttonWasTapped() {
        let fadeDuration: TimeInterval = 1
        
        //MUST stop all sounds if rage quitting early!
        AudioManager.shared.stopSound(for: "birdsambience", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: AudioManager.shared.grasslandTheme, fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "ageofruin", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "thunderrumble", fadeDuration: fadeDuration)
        
        UserDefaults.standard.set(true, forKey: K.UserDefaults.shouldSkipIntro)
        cleanupScene(buttonTap: .buttontap1, fadeDuration: fadeDuration)
    }
    
}
