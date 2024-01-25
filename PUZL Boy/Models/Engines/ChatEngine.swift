//
//  ChatEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

protocol ChatEngineDelegate: AnyObject {
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool)
    func deilluminatePanel(at position: K.GameboardPosition, useOverlay: Bool)
    func illuminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
    func deilluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
    func illuminateMinorButton(for button: PauseResetEngine.MinorButton)
    func deilluminateMinorButton(for button: PauseResetEngine.MinorButton)
    func spawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void)
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void)
}

class ChatEngine {
    
    // MARK: - Properties
    
    //avatarSizeNew and Orig should be static so other classes can access w/o creating an instance
    static let avatarSizeNew: CGFloat = 300
    static let avatarSizeOrig: CGFloat = 512
    
    //Size and position properties
    private let padding: CGPoint = CGPoint(x: 20, y: 8)
    private let borderLineWidth: CGFloat = 6
    private var origin: CGPoint {
        CGPoint(x: GameboardSprite.offsetPosition.x + borderLineWidth / 2,
                y: K.ScreenDimensions.topOfGameboard - backgroundSpriteWidth - ChatEngine.avatarSizeNew - 40)
    }
    private var backgroundSpriteWidth: CGFloat {
        K.ScreenDimensions.size.width * UIDevice.spriteScale
    }
    
    //Other properties
    private(set) var isChatting: Bool = false
    private var isAnimating: Bool = false
    private var timer: Timer
    private var dispatchWorkItem: DispatchWorkItem //Used to closeChat() and cancel any scheduled closeChat() calls. It works!!!
    private var chatText: String = ""
    private var chatIndex = 0
    private var allowNewChat = true
    private var shouldClose = true
    private var completion: (() -> ())?
    private var currentProfile: ChatProfile = .hero
    private var dialoguePlayed: [Int: Bool] = [:]           //Only play certain instructions once
    private var chatSpeed: TimeInterval
    private let chatSpeedOrig: TimeInterval = 0.08
    
    //Chat Sprites
    private var chatBackgroundSprite: SKShapeNode!
    private var avatarSprite: SKSpriteNode!
    private var textSprite: SKLabelNode!
    private var fastForwardSprite: SKSpriteNode!

    //Overlay Sprites
    private var superScene: SKScene?
    private var dimOverlaySprite: SKShapeNode!
    private var marlinBlast: MarlinBlastSprite!
    private var magmoorScary: MagmoorScarySprite!
    
    
    private struct ChatItem {
        let profile: ChatProfile
        let imgPos: ImagePosition
        let pause: TimeInterval?
        let startNewChat: Bool
        let endChat: Bool
        let chat: String
        let handler: (() -> Void)?
        
        enum ImagePosition {
            case left, right
        }
        
        init(profile: ChatProfile, imgPos: ImagePosition = .right, pause: TimeInterval? = nil, startNewChat: Bool = false, endChat: Bool = false, chat: String, handler: (() -> Void)?) {
            self.profile = profile
            self.imgPos = imgPos
            self.pause = pause
            self.startNewChat = startNewChat
            self.endChat = endChat
            self.chat = chat
            self.handler = handler
        }
        
        init(profile: ChatProfile, imgPos: ImagePosition = .right, chat: String) {
            self.init(profile: profile, imgPos: imgPos, pause: nil, startNewChat: false, endChat: false, chat: chat, handler: nil)
        }
    }
    
    enum ChatProfile {
        case hero, trainer, princess, princess2, villain, blankvillain, blankprincess
    }
    
    weak var delegate: ChatEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        timer = Timer()
        dispatchWorkItem = DispatchWorkItem(block: {})
        
        chatSpeed = chatSpeedOrig

        populateKeyDialogue()
        setupSprites()
        animateFFButton()
    }
    
    deinit {
        print("ChatEngine deinit")
    }
    
    private func setupSprites() {
        //Chat Sprites setup
        chatBackgroundSprite = SKShapeNode()
        chatBackgroundSprite.lineWidth = borderLineWidth
        chatBackgroundSprite.path = UIBezierPath(roundedRect: CGRect(x: origin.x, y: origin.y,
                                                                     width: backgroundSpriteWidth,
                                                                     height: ChatEngine.avatarSizeNew + borderLineWidth),
                                                 cornerRadius: 20).cgPath
        chatBackgroundSprite.fillColor = .orange
        chatBackgroundSprite.strokeColor = .white
        chatBackgroundSprite.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        chatBackgroundSprite.setScale(0)
        chatBackgroundSprite.name = "backgroundSprite"
        chatBackgroundSprite.zPosition = K.ZPosition.chatDialogue
                
        avatarSprite = SKSpriteNode(texture: SKTexture(imageNamed: "puzlboy"))
        avatarSprite.position = CGPoint(x: origin.x, y: origin.y + borderLineWidth / 2)
        avatarSprite.setScale(ChatEngine.avatarSizeNew / ChatEngine.avatarSizeOrig * 3)
        avatarSprite.anchorPoint = .zero
        avatarSprite.color = .magenta
        
        textSprite = SKLabelNode(text: "PUZL Boy is the newest puzzle game out there on the App Store. It's so popular, it's going to have over a million downloads, gamers are going to love it - casual gamers, hardcore gamers, and everyone in-between! So download your copy today!!")
        textSprite.position = CGPoint(x: origin.x, y: origin.y + ChatEngine.avatarSizeNew - padding.y)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = backgroundSpriteWidth - ChatEngine.avatarSizeNew
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSizeMedium
        textSprite.fontColor = UIFont.chatFontColor
        textSprite.zPosition = 10
        textSprite.addDropShadow()
        
        fastForwardSprite = SKSpriteNode(imageNamed: "forwardButton")
        fastForwardSprite.setScale(0.35 * 3)
        fastForwardSprite.anchorPoint = CGPoint(x: 1, y: 0)
        fastForwardSprite.position = CGPoint(x: origin.x + backgroundSpriteWidth - padding.x, y: origin.y + padding.x)
        fastForwardSprite.alpha = 1
        fastForwardSprite.zPosition = 15

        
        //Overlay Sprites setup
        dimOverlaySprite = SKShapeNode(rectOf: K.ScreenDimensions.size)
        dimOverlaySprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
        dimOverlaySprite.fillColor = .black
        dimOverlaySprite.lineWidth = 0
        dimOverlaySprite.alpha = 0
        dimOverlaySprite.zPosition = K.ZPosition.chatDimOverlay

        marlinBlast = MarlinBlastSprite()
        marlinBlast.zPosition = K.ZPosition.chatDialogue - 1
        
        magmoorScary = MagmoorScarySprite(boundingBox: chatBackgroundSprite.path?.boundingBox)
        magmoorScary.zPosition = K.ZPosition.chatDialogue + 5
        

        //Add sprites to background
        chatBackgroundSprite.addChild(avatarSprite)
        chatBackgroundSprite.addChild(textSprite)
        chatBackgroundSprite.addChild(fastForwardSprite)
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene
        
        superScene.addChild(chatBackgroundSprite)
        superScene.addChild(dimOverlaySprite)
    }
    
    
    // MARK: - Touch Functions
    
    func touchDown(in location: CGPoint) {
        guard let superScene = superScene else { return }
        guard superScene.nodes(at: location).filter({ $0.name == "backgroundSprite" }).first != nil else { return }
        guard !isAnimating else { return }
        
        isAnimating = true
        
        fastForwardSprite.removeAllActions()
        fastForwardSprite.alpha = 1
        
        fastForward()
    }
    
    func touchUp() {
        animateFFButton()
    }
    
    
    // MARK: - Misc Functions

    func shouldPauseGame(level: Int) -> Bool {
        return dialoguePlayed[level] != nil
    }

    func fastForward() {
        guard isAnimating else { return }
        
        if chatSpeed > 0 && chatIndex < chatText.count {
            chatSpeed = 0
        }
        else {
            dispatchWorkItem.cancel()
            closeChat()
        }
        
        //Prevents spamming of the chat while FF tapping. Adds a 0.5s delay; MUST be 0.5s and no shorter to prevent crashing. BUGFIX# 230921E01
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    private func animateFFButton() {
        fastForwardSprite.removeAllActions()
        
        fastForwardSprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeAlpha(to: 0, duration: 0.75),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeAlpha(to: 1, duration: 0.75)
        ])))
    }
    
    
    // MARK: - Chat Functions
    
    ///Helper function that handles the nesting of chats via recursion
    private func sendChatArray(items: [ChatItem], currentIndex: Int = 0, completion: (() -> Void)?) {
        if currentIndex == items.count {
            //Base case
            completion?()
        }
        else {
            sendChat(profile: items[currentIndex].profile,
                     imgPos: items[currentIndex].imgPos,
                     pause: items[currentIndex].pause,
                     startNewChat: items[currentIndex].startNewChat || currentIndex == 0,
                     endChat: items[currentIndex].endChat || currentIndex == items.count - 1,
                     chat: items[currentIndex].chat) { [unowned self] in
                items[currentIndex].handler?()

                //Recursion!!
                sendChatArray(items: items, currentIndex: currentIndex + 1, completion: completion)
            }
        }
    }
    
    private func sendChat(profile: ChatProfile, imgPos: ChatItem.ImagePosition, pause: TimeInterval?, startNewChat: Bool, endChat: Bool, chat: String, completion: (() -> ())? = nil) {
        //Only allow a new chat if current chat isn't happening
        guard allowNewChat else { return }
        
        textSprite.text = ""
        textSprite.updateShadow()
        timer.invalidate()
        chatText = chat
        chatIndex = 0
        allowNewChat = false //prevents interruption of current chat, which could lead to crashing due to index out of bounds
        shouldClose = endChat
        currentProfile = profile
        self.completion = completion
        
        switch profile {
        case .hero:
            avatarSprite.texture = SKTexture(imageNamed: "puzlboy")
            chatBackgroundSprite.fillColor = .orange
        case .trainer:
            avatarSprite.texture = SKTexture(imageNamed: "trainer")
            chatBackgroundSprite.fillColor = .blue
        case .princess:
            avatarSprite.texture = SKTexture(imageNamed: "princess")
            chatBackgroundSprite.fillColor = .magenta
        case .princess2:
            avatarSprite.texture = SKTexture(imageNamed: "princess2")
            chatBackgroundSprite.fillColor = .magenta
        case .villain:
            avatarSprite.texture = SKTexture(imageNamed: "villain")
            chatBackgroundSprite.fillColor = .red
        case .blankvillain:
            avatarSprite.texture = nil
            chatBackgroundSprite.fillColor = .red
        case .blankprincess:
            avatarSprite.texture = nil
            chatBackgroundSprite.fillColor = .magenta
        }
        
        if profile == .blankvillain || profile == .blankprincess {
            avatarSprite.isHidden = true
            
            textSprite.position.x = K.ScreenDimensions.size.width / 2
            textSprite.preferredMaxLayoutWidth = backgroundSpriteWidth
            textSprite.horizontalAlignmentMode = .center
        }
        else {
            avatarSprite.position.x = origin.x + (imgPos == .left ? padding.x : backgroundSpriteWidth - padding.x)
            avatarSprite.xScale = imgPos == .left ? abs(avatarSprite.xScale) : -abs(avatarSprite.xScale)
            avatarSprite.isHidden = false
            
            textSprite.position.x = origin.x + (imgPos == .right ? padding.x : avatarSprite.size.width)
            textSprite.preferredMaxLayoutWidth = backgroundSpriteWidth - ChatEngine.avatarSizeNew
            textSprite.horizontalAlignmentMode = .left
        }
        
        chatBackgroundSprite.position.x = imgPos == .left ? 0 : K.ScreenDimensions.size.width
        chatBackgroundSprite.setScale(0)
        

        //Animates the chat bubble zoom in for startNewChat. Need to do 2 cases because even with a wait of 0 seconds, it adds a flicker that could be distracting.
        let animateBackgroundSprite = SKAction.group([
            SKAction.moveTo(x: 0, duration: startNewChat ? 0.4 : 0),
            SKAction.scale(to: 1.0, duration: startNewChat ? 0.4 : 0)
        ])
        
        if let pause = pause {
            chatBackgroundSprite.run(SKAction.sequence([
                SKAction.wait(forDuration: pause),
                animateBackgroundSprite
            ])) { [unowned self] in
                if startNewChat {
                    playChatOpenNotification()
                }
                
                timer = Timer.scheduledTimer(timeInterval: chatSpeed, target: self, selector: #selector(animateText(_:)), userInfo: nil, repeats: true)
            }
        }
        else {
            //Leave out the wait
            chatBackgroundSprite.run(animateBackgroundSprite) { [unowned self] in
                if startNewChat {
                    playChatOpenNotification()
                }
                
                timer = Timer.scheduledTimer(timeInterval: chatSpeed, target: self, selector: #selector(animateText(_:)), userInfo: nil, repeats: true)
            }
        }
        
        //Animates dimOverlaySprite to darken the background.
        if startNewChat {
            dimOverlaySprite.run(SKAction.sequence([
                SKAction.wait(forDuration: pause ?? 0),
                SKAction.fadeAlpha(to: 0.8, duration: 1.0)
            ]))
        }
    }
    
    ///This contains the magic of animating the characters of the string like a typewriter, until it gets to the end of the chat.
    @objc private func animateText(_ sender: Timer) {
        if chatSpeed > 0 && chatIndex < chatText.count {
            let chatChar = chatText[chatText.index(chatText.startIndex, offsetBy: chatIndex)]
            
            textSprite.text! += "\(chatChar)"
            textSprite.updateShadow()
            
            chatIndex += 1
        }
        else if chatSpeed <= 0 && chatIndex < chatText.count {
            textSprite.text = chatText
            textSprite.updateShadow()
            
            chatIndex = chatText.count
        }
        else if chatIndex >= chatText.count {
            timer.invalidate()
            
            //Set it here so you can cancel it if needed.
            dispatchWorkItem = DispatchWorkItem(block: { [unowned self] in
                closeChat()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chatSpeed > 0 ? 5.0 : max(5.0, Double(chatText.count) / 10)), execute: dispatchWorkItem)
        }
    }
    
    private func playChatOpenNotification() {
        switch currentProfile {
        case .hero:                                 AudioManager.shared.playSound(for: "chatopen")
        case .trainer:                              AudioManager.shared.playSound(for: "chatopentrainer")
        case .princess, .princess2, .blankprincess: AudioManager.shared.playSound(for: "chatopenprincess")
        case .villain, .blankvillain:               AudioManager.shared.playSound(for: "chatopenvillain")
        }
    }
    
    private func closeChat() {
        let duration: TimeInterval = shouldClose ? 0.2 : 0
        
        if shouldClose {
            AudioManager.shared.playSound(for: "chatclose")
        }
        else {
            ButtonTap.shared.tap(type: .buttontap2)
        }
        
        //Animates the chat bubble zoom out for endChat
        chatBackgroundSprite.run(SKAction.group([
            SKAction.moveTo(x: currentProfile != .hero ? backgroundSpriteWidth : 0, duration: duration),
            SKAction.scale(to: 0, duration: duration)
        ])) { [unowned self] in
            allowNewChat = true
            chatSpeed = chatSpeedOrig
            self.completion?()
        }
    }
    
    private func fadeDimOverlay() {
        dimOverlaySprite.run(SKAction.fadeAlpha(to: 0.0, duration: 1.0))
    }
    
    ///Helper function to wrap up a chat dialogue and call the completion handler.
    private func handleDialogueCompletion(level: Int, completion: (() -> Void)?) {
        dialoguePlayed[level] = true
        isChatting = false
        fadeDimOverlay()
        completion?()
    }
}


// MARK: - Dialogue Function

extension ChatEngine {
    ///Populates the dialoguePlayed array. Need to include all levels where dialogue is to occur, and also add the level case in the playDialogue() function.
    private func populateKeyDialogue() {
        //Villain Party Dialogue
        dialoguePlayed[-200] = false
        dialoguePlayed[-150] = false
        dialoguePlayed[-100] = false
        
        //Main Dialogue
        dialoguePlayed[Level.partyLevel] = false //Level: -1
        dialoguePlayed[1] = false
        dialoguePlayed[8] = false
        dialoguePlayed[19] = false
        dialoguePlayed[34] = false
        dialoguePlayed[51] = false
        dialoguePlayed[76] = false
        dialoguePlayed[PauseResetEngine.resetButtonUnlock] = false //Level: 100
        dialoguePlayed[112] = false
        dialoguePlayed[PauseResetEngine.hintButtonUnlock] = false //Level: 140

        //Princess Capture Dialogue
        dialoguePlayed[157] = false //(3, 2)
    }
    
    /**
     Main function to play chat dialogue for a given level.
     - parameters:
        - level: the level # for the chat dialogue to play
        - completion: completion handler to execute at the end of the dialogue
     */
    func playDialogue(level: Int, completion: (() -> Void)?) {
        guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
            isChatting = false
            completion?()
            return
        }

        isChatting = true

        switch level {
        case -100:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)

            sendChatArray(items: [
                ChatItem(profile: .blankvillain, chat: "\n\n...turn back now, before it's too late..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Who are you!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...the question is, where are we?..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "We are in the Dark Realm where evil cannot reach. What business do you have here?!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...all will be revealed soon...") { [unowned self] in
                    superScene?.addChild(marlinBlast)
                    marlinBlast.animateBlast(playSound: true)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "⚡️REVEAL YOURSELF!!!⚡️") {
                    AudioManager.shared.playSound(for: "littlegirllaugh")
                    AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 2)
                },
                ChatItem(profile: .blankvillain, chat: "\n\n...heh heh heh heh...")
            ]) { [unowned self] in
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 3)
                
                chatBackgroundSprite.run(SKAction.wait(forDuration: 1)) { [unowned self] in
                    marlinBlast.removeFromParent()
                    
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -150:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            
            sendChatArray(items: [
                ChatItem(profile: .blankvillain, chat: "\n\n...marlin..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Gah, would you stop doing that!! It's freaky!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...do not follow. do not proceed..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Do not pass go, do not collect... blah, blah, blah. Where is the princess!!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...she is here now..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Where is she?!! Is she unharmed??"),
                ChatItem(profile: .blankvillain, chat: "\n\n...see for yourself...") {
                    AudioManager.shared.playSound(for: "littlegirllaugh")
                    AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 2)
                },
                ChatItem(profile: .blankprincess, chat: "\n\nHELP MEEE! IT'S SO DARK OVER HERE!!!"),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Stop with the games! Now tell me exactly who you are—") { [unowned self] in
                    superScene?.addChild(marlinBlast)
                    superScene?.addChild(magmoorScary)

                    marlinBlast.animateBlast(playSound: false)
                    magmoorScary.flashImage(delay: 0.25)

                    AudioManager.shared.stopSound(for: "magicheartbeatloop1")
                    AudioManager.shared.playSound(for: "magicheartbeatloop2")
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "⚡️MAGIC!!!⚡️"),
                ChatItem(profile: .villain, chat: "be seeing ya soon."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "............no. It can't be.")
            ]) { [unowned self] in
                AudioManager.shared.stopSound(for: "magicheartbeatloop2", fadeDuration: 3)
                
                chatBackgroundSprite.run(SKAction.wait(forDuration: 1)) { [unowned self] in
                    marlinBlast.removeFromParent()
                    magmoorScary.removeFromParent()
                    
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -200:
            AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 3)
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            
            superScene?.addChild(magmoorScary)

            sendChatArray(items: [
                ChatItem(profile: .villain, chat: "MYSTERIOUS FIGURE: you'll never find her. you can keep trying, but it will all be in vain. give up now...") { [unowned self] in
                    magmoorScary.slowReveal(alpha: 0.1)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "YOU!!! I should have known! The whole time I'm thinking, \"No way he came crawling back into my life.\" And here you are...") { [unowned self] in
                    magmoorScary.slowReveal(alpha: 0.2)
                },
                ChatItem(profile: .villain, chat: "surprised much? you need me. you're the yin to my yang. we're bounded by fate, as the priestess machinegunkelly revealed during the trial of mages.") { [unowned self] in
                    magmoorScary.slowReveal(alpha: 0.3)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "That was over 500 years ago. Give up the child and leave this world!!") { [unowned self] in
                    magmoorScary.slowReveal(alpha: 0.4)
                },
                ChatItem(profile: .villain, chat: "we would have made a great duo: the strongest mystics in all the realms. but you chose a different path ..............why did you leave me?") { [unowned self] in
                    magmoorScary.slowReveal(alpha: 0.5)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "..............I did what I had to."),
                ChatItem(profile: .villain, chat: "your loss.. such a shame.. you'll soon regret it.....")
            ]) { [unowned self] in
                AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 5)
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 5)
                
                chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) { [unowned self] in
                    handleDialogueCompletion(level: level) { [unowned self] in
                        magmoorScary.resetAlpha()
                        magmoorScary.removeFromParent()
                        
                        completion?()
                    }
                }
            }
        case Level.partyLevel: //Level: -1
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "Yo, I feel funny. I'm seeing colorful flashing lights and the music is bumpin'. I can't stop moving.. and I like it!"),
                ChatItem(profile: .trainer, chat: "Welcome to the DARK REALM, the hidden realm that exists between PUZZLE REALMS. You ate one of those rainbow colored jelly beans, I see."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Jelly beans, right..."),
                ChatItem(profile: .trainer, chat: "Don't worry, the feeling lasts only a short amount of time, but while you're under its effects you can move to your heart's content."),
                ChatItem(profile: .trainer, chat: "Run around collecting all the gems and bonuses that pop up in the level. But you gotta be quick before time runs out."),
                ChatItem(profile: .trainer, chat: "Oh, and the one thing you want to look out for are rainbow bombs."),
                ChatItem(profile: .trainer, chat: "Like, I know it's all pretty and fun looking, but avoid them at all costs, or it's the end of the bonus round."),
                ChatItem(profile: .trainer, chat: "Why is it always the pretty things in life that are the most deadly..."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Don't step on the bombs. Yeah got it."),
                ChatItem(profile: .trainer, chat: "OK. Now if the flashing lights become too much, you can tap the disco ball below to turn them off. 🪩 READY. SET. GO!")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 1:
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "PUZL BOY: ...then the dragon swooped down and carried her away! It. Was. Harrowing. So... where are we? And who are you again??") { [unowned self] in

                    
                    
                    
                    // FIXME: - Testing out Magic Swirl
                    if let superScene = superScene {
                        ParticleEngine.shared.animateParticles(
                            type: .magicLight,
                            toNode: superScene,
                            position: CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2),
                            duration: 10)
                    }
                    
                    
                    
                    
                },
                ChatItem(profile: .trainer, chat: "MARLIN: I am Marlin. I suspect she is being taken to the dragon's lair. I have transported you to the PUZZLE REALM, which is our gateway to the lair."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Marlin, like the fish??? I hate fish by the way. The smell, the texture... So how do you know that's where they're taking her?"),
                ChatItem(profile: .trainer, chat: "Don't worry about it... And no, not like the fish. Marlin like the Magician."),
                ChatItem(profile: .trainer, chat: "As a matter of fact, I come from a long line of legendary and powerful Mystics, each with our own unique powers and abilities..."),
                ChatItem(profile: .trainer, chat: "Some Mystics control the elements: fire-water, earth-air, some are all-knowing, while others govern the arts and science. I happen to be a water mage, myself."),
                ChatItem(profile: .hero, imgPos: .left, chat: "🍿"),
                ChatItem(profile: .trainer, chat: "Let's see, there's Maxel, Mywren, and Malana, our Mystics in training who I am personally mentoring..."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Mmmkay. Got it 🥱"),
                ChatItem(profile: .trainer, chat: ".......moving on. The lair is buried deep inside Earth's core, and the only way to reach it is to solve logic puzzles—"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Water mage... like a fish? A marlin is a fish. You're thinking of Merlin the Magician. OH! Is that your name? Merlin ...the Magician?"),
                ChatItem(profile: .trainer, chat: "Enough with the fish already! Listen!! There are 500 levels in total you will have to solve, each with increasing difficulty."),
                ChatItem(profile: .hero, imgPos: .left, chat: "500 levels?!! How long is that gonna take? I gotta be home by 7. What do I get if I win?"),
                ChatItem(profile: .trainer, chat: "YOU SAVE THE WORLD!!! OMG! Now where was I... Oh yeah, the goal for each level is to get to the gate in under a certain number of moves.") { [unowned self] in
                    delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.illuminatePanel(at: (1, 0), useOverlay: false)
                    delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.illuminatePanel(at: (2, 1), useOverlay: false)
                },
                ChatItem(profile: .trainer, chat: "You can move to any available panel on your left, right, above, and below. Simply tap the panel to move there. Diagonal moves are not allowed.") { [unowned self] in
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 0), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (2, 1), useOverlay: false)
                    delegate?.illuminateDisplayNode(for: .moves)
                },
                ChatItem(profile: .trainer, chat: "If your move count hits 0, it's game over, buddy! Your move count can be found in the upper left corner next to the boot. 👢") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .moves)
                    delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
                    delegate?.illuminatePanel(at: (2, 2), useOverlay: false)
                },
                ChatItem(profile: .trainer, chat: "See the gate? It's closed. To open it, collect all the gems in the level. Simple, right?"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Right. Let's go save the princess!")
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                delegate?.deilluminatePanel(at: (2, 2), useOverlay: false)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 8:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Pretty easy, right? Levels get progressively harder with various obstacles blocking your path.") { [unowned self] in
                    delegate?.illuminateDisplayNode(for: .hammers)
                },
                ChatItem(profile: .trainer, chat: "You need a hammer to break through those boulders. Your inventory count can be found in the upper right. 🔨"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Hammers break boulders. Got it.") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .hammers)
                },
                ChatItem(profile: .trainer, chat: "Since there are no hammers in this level, you'll just have to go around them."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ah well, gotta get my steps in."),
                ChatItem(profile: .trainer, chat: "Oh, and one more thing... hammers can only be used once before breaking, so plan your moves ahead of time.")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 19:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (2, 1), useOverlay: false)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Watch out for poison marsh! Stepping on one of the crimson colored panels will drag you down, costing you 2 moves."),
                ChatItem(profile: .trainer, chat: "However, sometimes stepping in poison marsh is unavoidable."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Man... and I just got these new kicks!")
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                delegate?.deilluminatePanel(at: (2, 1), useOverlay: false)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 34:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Those fun looking things are warps. Stepping on one of them will teleport you to the other one. Weeeeeeeee!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Is it safe?"),
                ChatItem(profile: .trainer, chat: "I haven't tested it. Theoretically—"),
                ChatItem(profile: .hero, imgPos: .left, chat: "MARLIN!!! Is it going to rip me apart or what?"),
                ChatItem(profile: .trainer, chat: "I'm sure you'll be fine. Just don't stare at it too long or I'll have you barking like a chicken at the snap of my fingers. ✨SNAP✨ 🫰🏼"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Chickens don't bark, you nutty profess— 😵‍💫 Woof woof.")
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
        
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 51:
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "Yo! That's the dragon that took the princess! 😡"),
                ChatItem(profile: .trainer, chat: "Relax... That's one of many dragons you'll encounter on your journey. But don't get too close or it'll cost ya 1 health point."),
                ChatItem(profile: .hero, imgPos: .left, chat: "He looks kinda small and underwhelming to me..."),
                ChatItem(profile: .trainer, chat: "Hey, this is a solo project with zero budget, whaddya want from me?! As I was saying...") { [unowned self] in
                    delegate?.illuminateDisplayNode(for: .health)
                },
                ChatItem(profile: .trainer, chat: "Once your health drops to 0, it's lights out! Your health can be found in the upper left next to the heart. 💖") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .health)
                    delegate?.illuminateDisplayNode(for: .swords)
                },
                ChatItem(profile: .trainer, chat: "Don't believe me? Go ahead. Try and pet him, I dare you! But you won't be able to defeat him without a sword. 🗡"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yeah, ok old man. Lemme guess, I can only use the sword once before it breaks?") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .swords)
                },
                ChatItem(profile: .trainer, chat: "You got it. Atta boy! 🫰🏼"),
                ChatItem(profile: .hero, imgPos: .left, chat: "😵‍💫 Woof woof— Stop that!")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 76:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Ice, ice, baby! Step on this and you'll slide until you hit either an obstacle or the edge of the level."),
                ChatItem(profile: .trainer, chat: "The nice thing though is that it'll only cost you 1 move as long as you're sliding continuously."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok. I think I got it, old man.") { [unowned self] in
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.deilluminatePanel(at: (0, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                },
                ChatItem(profile: .trainer, chat: "Well, I'll leave you alone for now. I'll chime in every now and then if I think you need it.")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case PauseResetEngine.resetButtonUnlock: //Level: 100
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Congrats! You made it to level \(PauseResetEngine.resetButtonUnlock). There's a bonus at the end of every 50 levels. Beat this and you're one step closer to indescribable fun!!! 💃🏾🪩🕺🏻"),
                ChatItem(profile: .hero, imgPos: .left, chat: "I can hardly contain my excitement.") { [unowned self] in
                    delegate?.illuminateMinorButton(for: .reset)
                },
                ChatItem(profile: .trainer, chat: "That's the spirit! Now if you ever get stuck, you can tap the Reset button to restart the level."),
                ChatItem(profile: .trainer, chat: "Be warned though, restarting a level will cost you one of your precious lives...") { [unowned self] in
                    delegate?.deilluminateMinorButton(for: .reset)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "It's all good. My mom can buy me more lives if I need it. 😃")
            ]) { [unowned self] in
                GameCenterManager.shared.updateProgress(achievement: .avidReader, shouldReportImmediately: true)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 112:
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "What's so special about this little girl anyway?"),
                ChatItem(profile: .trainer, chat: "She's no ordinary little girl. She is the princess of Vaeloria, a mystical realm known for its immense magic."),
                ChatItem(profile: .trainer, chat: "Dragons are ancient and powerful creatures that inhabit the land of Vaeloria and are deeply connected to its magic."),
                ChatItem(profile: .trainer, chat: "The sudden emergence of dragons in your world suggests something bigger is at play, and this little girl... Princess Olivia... is at the center of it all."),
                ChatItem(profile: .hero, imgPos: .left, chat: "What do they want with her anyway?"),
                ChatItem(profile: .trainer, chat: "That has yet to be determined, though I suspect something very dark is behind all this... Come. Let's not waste anymore time.")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case PauseResetEngine.hintButtonUnlock: //Level: 140
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "You good, old man?? You've been awfully quiet. You're usually going on and on and on about useless info right about now."),
                ChatItem(profile: .trainer, chat: "Don't make me snap."),
                ChatItem(profile: .hero, imgPos: .left, chat: "No don't! Look, if it's the old man comments, everybody gets old. It's just an inevitability of life. I'm 16 so everyone looks old to me. You're like what... 50?"),
                ChatItem(profile: .trainer, chat: "902."),
                ChatItem(profile: .hero, imgPos: .left, chat: "NINE HUNDRED??!! What are you, like a wizard or something? \"Marlin the Fish Wizard...\""),
                ChatItem(profile: .hero, imgPos: .left, chat: "Wait... So you really ARE a wizard!! Because I'm not surprised by anything anymore at this point..."),
                ChatItem(profile: .trainer, chat: "MYSTIC!!! I told you I'm a Mystic! M.Y.S.T.I.C. Yeesh, my blood pressure..."),
                ChatItem(profile: .trainer, chat: "Once we've located the princess, I need to cast the gateway spell to open the portal so she can return to her home in Vaeloria."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yeah... mystic. Which is basically a wizard. Or magician. Well you don't look a day over 800 to be honest..."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, I need you to be serious! What lies ahead will test your patience. It will make you want to throw your phone out the window. You need to be prepared!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok ok. I'll be ready. I already know how to use hammers and swords. Nothing can stop me!") { [unowned self] in
                    delegate?.illuminateMinorButton(for: .hint)
                },
                ChatItem(profile: .trainer, chat: "Hilarious. I'm adding another tool to your arsenal. Tap the Hints button at the start of a level to illuminate your next move. Tap again to get the next hint."),
                ChatItem(profile: .trainer, chat: "Keep tapping for as many hints you need. Hints become disabled once you move past your last hint. The number in red is your available hints."),
                ChatItem(profile: .trainer, chat: "If you run out of hints, you can buy more in the Shop tab of the Settings menu. Any questions?") { [unowned self] in
                    delegate?.deilluminateMinorButton(for: .hint)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "Wow.. you're 900 years old. I have soooo many questions...")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 157:
            let spawnPoint: K.GameboardPosition = (0, 2)
            
            delegate?.spawnPrincessCapture(at: spawnPoint) { [unowned self] in
                sendChatArray(items: [
                    ChatItem(profile: .princess, chat: "PRINCESS OLIVIA: Help meeeee PUZL Boy!!! It's dark and scary over here. And this guy's breath is really stinky!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Gandhi on a gondola! Who the #&*@! are are you?!!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Magmoor, stop this at once! It's not too late."),
                    ChatItem(profile: .villain, chat: "MAGMOOR: if you want to see your precious princess again, then let us merge powers."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "No!!! You want absolute power. All Mystics share power evenly; it keeps the realms in balance. You seek to plunge the realms into total darkness."),
                    ChatItem(profile: .villain, chat: "the world is broken and the realms are already headed towards eternal darkness. it requires cleansing."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "You've completely lost it. LET THE PRINCESS GO AND THINGS WON'T GET UGLY!!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Yeah, if you touch a hair on her head, it's gonna be the end for you, Mantamar!"),
                    ChatItem(profile: .villain, chat: "embrace the light and you shall see! MUAHAHAHAHAAGGGHHHH! *cough* *cough* *HACK* 😮‍💨 ...ugh that one's black."),
                    ChatItem(profile: .princess, endChat: true, chat: "Ew gross!! 🤮") { [unowned self] in
                        fadeDimOverlay()
                        delegate?.despawnPrincessCapture(at: spawnPoint, completion: { })
                    },
                    ChatItem(profile: .hero, imgPos: .left, pause: 8, startNewChat: true, chat: "That was creepy. What does Marzipan want with the princess? He's not gonna sacrifice her is he?! 😱 I've seen too many movies...") {
                        //Sheep walking across the level randomly
                    },
                    ChatItem(profile: .trainer, chat: "Magmoor—one of the most powerful Mystics from my realm. He wasn't always like this. We were once good friends. Then he went all Mabritney on everyone."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "You guys have Britney in your world?"),
                    ChatItem(profile: .trainer, chat: "No—MAbritney. She's an elemental mage who wields forbidden dark magic. She does a Dance of Knives that summons Chaos."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Well he sounds toxic ...so what's our next move:\nPURSUE HIM | PREPARE FIRST"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "We should prepare first..."),
                    ChatItem(profile: .trainer, chat: "A wise decision. Let's keep moving."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "BRING ME MAGMOOR!"),
                    ChatItem(profile: .trainer, chat: "Okay but let's be careful.")
                ]) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        default:
            isChatting = false
            completion?()
        }
    }
}
