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
    
    //Sprite properties
    private var dimOverlaySprite: SKShapeNode!
    private var backgroundSprite: SKShapeNode!
    private var avatarSprite: SKSpriteNode!
    private var fastForwardSprite: SKSpriteNode!
    private var textSprite: SKLabelNode!
    private var superScene: SKScene?
    
    private struct ChatItem {
        let profile: ChatProfile
        let chat: String
        let handler: (() -> Void)?
        
        init(profile: ChatProfile, chat: String, handler: (() -> Void)?) {
            self.profile = profile
            self.chat = chat
            self.handler = handler
        }
        
        init(profile: ChatProfile, chat: String) {
            self.init(profile: profile, chat: chat, handler: nil)
        }
    }
    
    enum ChatProfile {
        case hero, trainer, princess, princess2, villain
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
        backgroundSprite = SKShapeNode()
        backgroundSprite.lineWidth = borderLineWidth
        backgroundSprite.path = UIBezierPath(roundedRect: CGRect(x: origin.x, y: origin.y,
                                                                 width: backgroundSpriteWidth, height: ChatEngine.avatarSizeNew + borderLineWidth),
                                             cornerRadius: 20).cgPath
        backgroundSprite.fillColor = .orange
        backgroundSprite.strokeColor = .white
        backgroundSprite.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        backgroundSprite.setScale(0)
        backgroundSprite.name = "backgroundSprite"
        backgroundSprite.zPosition = K.ZPosition.chatDialogue
        
        dimOverlaySprite = SKShapeNode(rectOf: K.ScreenDimensions.size)
        dimOverlaySprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
        dimOverlaySprite.fillColor = .black
        dimOverlaySprite.lineWidth = 0
        dimOverlaySprite.alpha = 0
        dimOverlaySprite.zPosition = K.ZPosition.chatDimOverlay
        
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
        

        //Add sprites to background
        backgroundSprite.addChild(avatarSprite)
        backgroundSprite.addChild(textSprite)
        backgroundSprite.addChild(fastForwardSprite)
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene
        
        superScene.addChild(dimOverlaySprite)
        superScene.addChild(backgroundSprite)
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
                     startNewChat: currentIndex == 0,
                     endChat: currentIndex == items.count - 1,
                     chat: items[currentIndex].chat) { [unowned self] in
                items[currentIndex].handler?()

                //Recursion!!
                sendChatArray(items: items, currentIndex: currentIndex + 1, completion: completion)
            }
        }
    }
    
    private func sendChat(profile: ChatProfile, startNewChat: Bool, endChat: Bool, chat: String, completion: (() -> ())? = nil) {
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
            backgroundSprite.fillColor = .orange
        case .trainer:
            avatarSprite.texture = SKTexture(imageNamed: "trainer")
            backgroundSprite.fillColor = .blue
        case .princess:
            avatarSprite.texture = SKTexture(imageNamed: "princess")
            backgroundSprite.fillColor = .magenta
        case .princess2:
            avatarSprite.texture = SKTexture(imageNamed: "princess2")
            backgroundSprite.fillColor = .magenta
        case .villain:
            avatarSprite.texture = SKTexture(imageNamed: "villain")
            backgroundSprite.fillColor = .red
        }
        
        textSprite.position.x = origin.x + (profile != .hero ? padding.x : avatarSprite.size.width)
        avatarSprite.position.x = origin.x + (profile == .hero ? padding.x : backgroundSpriteWidth - padding.x)
        backgroundSprite.position.x = profile == .hero ? 0 : K.ScreenDimensions.size.width
        
        avatarSprite.xScale = profile == .hero ? abs(avatarSprite.xScale) : -abs(avatarSprite.xScale)
        backgroundSprite.setScale(0)
        
        //Animates the chat bubble zoom in for startNewChat
        backgroundSprite.run(SKAction.group([
            SKAction.moveTo(x: 0, duration: startNewChat ? 0.4 : 0),
            SKAction.scale(to: 1.0, duration: startNewChat ? 0.4 : 0)
        ])) { [unowned self] in
            if startNewChat {
                AudioManager.shared.playSound(for: "chatopen")
            }
            
            timer = Timer.scheduledTimer(timeInterval: chatSpeed, target: self, selector: #selector(animateText(_:)), userInfo: nil, repeats: true)
        }
        
        //Animates overlaySprite
        if startNewChat {
            dimOverlaySprite.run(SKAction.fadeAlpha(to: 0.8, duration: 1.0))
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
    
    private func closeChat() {
        let duration: TimeInterval = shouldClose ? 0.2 : 0
        
        if shouldClose {
            AudioManager.shared.playSound(for: "chatclose")
        }
        else {
            ButtonTap.shared.tap(type: .buttontap2)
        }
        
        //Animates the chat bubble zoom out for endChat
        backgroundSprite.run(SKAction.group([
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
        dialoguePlayed[Level.partyLevel] = false
        dialoguePlayed[1] = false
        dialoguePlayed[8] = false
        dialoguePlayed[19] = false
        dialoguePlayed[34] = false
        dialoguePlayed[51] = false
        dialoguePlayed[76] = false
        dialoguePlayed[PauseResetEngine.resetButtonUnlock] = false
        dialoguePlayed[112] = false
        dialoguePlayed[131] = false
        dialoguePlayed[PauseResetEngine.hintButtonUnlock] = false

        //Villain capture levels - hand selected. Preferred spawn points are in the comments below.
        dialoguePlayed[132] = false //(3, 1)
        dialoguePlayed[154] = false //(0, 3) // TODO: - WHAT'S SUPPOSED TO HAPPEN HERE??
        dialoguePlayed[187] = false //(2, 1) // TODO: - WHAT'S SUPPOSED TO HAPPEN HERE??
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
        case Level.partyLevel:
            sendChatArray(items: [
                ChatItem(profile: .hero, chat: "Yo, I feel funny. I'm seeing colorful flashing lights and the music is bumpin'. I can't stop moving.. and I like it!"),
                ChatItem(profile: .trainer, chat: "Welcome to the DARK REALM! Looks like you ate one of those rainbow colored jelly beans, I see."),
                ChatItem(profile: .hero, chat: "Jelly beans, right..."),
                ChatItem(profile: .trainer, chat: "Don't worry, the feeling lasts only a short amount of time, but while you're under its effects you can move to your heart's content."),
                ChatItem(profile: .trainer, chat: "Run around collecting all the gems and bonuses that pop up in the level. But you gotta be quick before time runs out."),
                ChatItem(profile: .trainer, chat: "Oh, and the one thing you want to look out for are rainbow bombs."),
                ChatItem(profile: .trainer, chat: "Like, I know it's all pretty and fun looking, but avoid them at all costs, or it's the end of the bonus round."),
                ChatItem(profile: .trainer, chat: "Why is it always the pretty things in life that are the most deadly..."),
                ChatItem(profile: .hero, chat: "Don't step on the bombs. Yeah got it."),
                ChatItem(profile: .trainer, chat: "OK. Now if the flashing lights become too much, you can tap the disco ball below to turn them off. 🪩 READY. SET. GO!")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 1:
            sendChatArray(items: [
                ChatItem(profile: .hero, chat: "PUZL BOY: ...then the dragon swooped down and carried her away! So... what's our game plan? Also I didn't catch your name."),
                ChatItem(profile: .trainer, chat: "MARLIN: I am Marlin. I suspect she is being held captive in the dragon's lair. We must move quickly. I'm going to guide you there, so pay attention."),
                ChatItem(profile: .hero, chat: "Marlin, like the fish??? I hate fish by the way. The smell, the texture... So how do you know that's where they've taken her?"),
                ChatItem(profile: .trainer, chat: "Marlin like the magician. Don't worry about it... OK. The lair is buried miles beneath the Earth's surface, and the only way to reach it is to solve logic puzzles."),
                ChatItem(profile: .hero, chat: "A marlin is a fish... You're thinking of Merlin the Magician. OH! Is that your name? Merlin?"),
                ChatItem(profile: .trainer, chat: "I think I know my own name. Listen!! There are 500 levels in total you will have to solve, each with increasing difficulty."),
                ChatItem(profile: .hero, chat: "500 levels?!! What do I get if I win?"),
                ChatItem(profile: .trainer, chat: "You save the world!!! Geez! Now where was I... Oh yeah, the goal for each level is to get to the gate in under a certain number of moves.", handler: { [unowned self] in
                    delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.illuminatePanel(at: (1, 0), useOverlay: false)
                    delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.illuminatePanel(at: (2, 1), useOverlay: false)
                }),
                ChatItem(profile: .trainer, chat: "You can move to any available panel on your left, right, above, and below. Simply tap the panel to move there. Diagonal moves are not allowed.", handler: { [unowned self] in
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 0), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (2, 1), useOverlay: false)
                    delegate?.illuminateDisplayNode(for: .moves)
                }),
                ChatItem(profile: .trainer, chat: "If your move count hits 0, it's game over, buddy! Your move count can be found in the upper left corner next to the boot. 👢", handler: { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .moves)
                    delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
                    delegate?.illuminatePanel(at: (2, 2), useOverlay: false)
                }),
                ChatItem(profile: .trainer, chat: "See the gate? It's closed. To open it, collect all the gems in the level. Simple, right?"),
                ChatItem(profile: .hero, chat: "Right. Let's go save the princess!")
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                delegate?.deilluminatePanel(at: (2, 2), useOverlay: false)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 8:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Pretty easy, right?! Levels get progressively harder with various obstacles blocking your path.", handler: { [unowned self] in
                    delegate?.illuminateDisplayNode(for: .hammers)
                }),
                ChatItem(profile: .trainer, chat: "You need a hammer to break through those boulders. Your inventory count can be found in the upper right. 🔨"),
                ChatItem(profile: .hero, chat: "Hammers break boulders. Got it.", handler: { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .hammers)
                }),
                ChatItem(profile: .trainer, chat: "Since there are no hammers in this level, you'll just have to go around them."),
                ChatItem(profile: .hero, chat: "Ah well, gotta get my steps in."),
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
                ChatItem(profile: .hero, chat: "Man... and I just got these new kicks!")
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
                ChatItem(profile: .hero, chat: "Is it safe?"),
                ChatItem(profile: .trainer, chat: "I haven't tested it. Theoretically—"),
                ChatItem(profile: .hero, chat: "MARLIN!!! Is it going to rip me apart or what?"),
                ChatItem(profile: .trainer, chat: "I'm sure you'll be fine. Just don't stare at it too long or I'll have you barking like a chicken at the snap of my fingers. ✨SNAP✨ 🫰🏼"),
                ChatItem(profile: .hero, chat: "Chickens don't bark, you nutty profess— 😵‍💫 Woof woof.")
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 51:
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, chat: "THAT'S HIM!!! That's the dragon that abducted the princess! 😡"),
                ChatItem(profile: .trainer, chat: "Relax... That's one of many dragons you'll encounter on your journey. But don't get too close or it'll cost ya 1 health point."),
                ChatItem(profile: .hero, chat: "He looks kinda small and underwhelming to me..."),
                ChatItem(profile: .trainer, chat: "Hey, this is a solo project with $0 budget, whaddya want from me?! As I was saying...", handler: { [unowned self] in
                    delegate?.illuminateDisplayNode(for: .health)
                }),
                ChatItem(profile: .trainer, chat: "Once your health drops to 0, it's lights out, baby. Your health can be found in the upper left next to the heart. 💖", handler: { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .health)
                    delegate?.illuminateDisplayNode(for: .swords)
                }),
                ChatItem(profile: .trainer, chat: "Don't believe me? Go ahead. Try and pet him, I dare you! But you won't be able to defeat him without a sword. 🗡"),
                ChatItem(profile: .hero, chat: "Yeah, ok old man. Lemme guess, I can only use the sword once before it breaks?", handler: { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .swords)
                }),
                ChatItem(profile: .trainer, chat: "You got it. Atta boy! 🫰🏼"),
                ChatItem(profile: .hero, chat: "😵‍💫 Woof woof— Stop that!")
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
                ChatItem(profile: .hero, chat: "Ok. I think I got it, old man.", handler: { [unowned self] in
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.deilluminatePanel(at: (0, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                }),
                ChatItem(profile: .trainer, chat: "Well, I'll leave you alone for now. I'll chime in every now and then if I think you need it.")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case PauseResetEngine.resetButtonUnlock:
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Congrats! You made it to level \(PauseResetEngine.resetButtonUnlock). There's a bonus at the end of every 50 levels. Beat this and you're one step closer to indescribable fun!!! 💃🏾🪩🕺🏻"),
                ChatItem(profile: .hero, chat: "I can hardly contain my excitement.", handler: { [unowned self] in
                    delegate?.illuminateMinorButton(for: .reset)
                }),
                ChatItem(profile: .trainer, chat: "That's the spirit! Now if you ever get stuck, you can tap the Reset button to restart the level."),
                ChatItem(profile: .trainer, chat: "Be warned though, restarting a level will cost you one of your precious lives...", handler: { [unowned self] in
                    delegate?.deilluminateMinorButton(for: .reset)
                }),
                ChatItem(profile: .hero, chat: "It's all good. My mom can buy me more lives if I need it. 😃")
            ]) { [unowned self] in
                GameCenterManager.shared.updateProgress(achievement: .avidReader, shouldReportImmediately: true)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 112:
            sendChatArray(items: [
                ChatItem(profile: .hero, chat: "What's so special about this little girl anyway?"),
                ChatItem(profile: .trainer, chat: "She's no ordinary little girl. She is the princess of Vaeloria, a mystical realm known for its immense magic."),
                ChatItem(profile: .trainer, chat: "Dragons are ancient and powerful creatures that inhabit the land of Vaeloria and are deeply connected to its magic."),
                ChatItem(profile: .trainer, chat: "The sudden emergence of dragons in your world suggests something bigger is at play, and this little girl... Princess Olivia... is at the center of it all."),
                ChatItem(profile: .hero, chat: "What do they want with her anyway?"),
                ChatItem(profile: .trainer, chat: "That has yet to be determined, though I suspect something very dark is at play... Come along. Let's not waste anymore time.")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        // FIXME: - This dialogue sucks..
        case 131:
            sendChatArray(items: [
                ChatItem(profile: .hero, chat: "You good, old man?? You've been awfully quiet. You're usually going on and on about useless info right about now."),
                ChatItem(profile: .trainer, chat: "Don't make me snap."),
                ChatItem(profile: .hero, chat: "Don't snap!!!"),
                ChatItem(profile: .hero, chat: "Look, if it's the old man comments, everybody gets old. It's just an inevitability of life. I'm 16 so everyone looks old to me. And you're..."),
                ChatItem(profile: .trainer, chat: "900."),
                ChatItem(profile: .hero, chat: "NINE HUNDRED??!! What are you, like a wizard or something? \"Marlin the Fish Wizard...\""),
                ChatItem(profile: .hero, chat: "Wait... ARE YOU REALLY A WIZARD?!?! Because I'm not surprised by anything anymore at this point..."),
                ChatItem(profile: .trainer, chat: "There's a lot you must learn to prepare for the upcoming battle to save your world and the worlds beyond your world."),
                ChatItem(profile: .hero, chat: "I mean you don't look a day over 800 to be honest..."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, I need you to be serious! What lies ahead will test your patience. It will make you want to throw your phone out the window. You need to be prepared!"),
                ChatItem(profile: .hero, chat: "Ok ok. I'll be ready. I already know how to use hammers and swords. Nothing can stop me!"),
                ChatItem(profile: .trainer, chat: "You reached out to me for my help. I need you to trust me now."),
                ChatItem(profile: .hero, chat: "Well yeah, after I saw a freakin' dragon swoop down from the sky and snatch a 7 year old girl ...then you appeared almost out of nowhere!"),
                ChatItem(profile: .trainer, chat: "Good. Then we're in agreement. Now no more silly questions. Let's keep pushing forward."),
                ChatItem(profile: .hero, chat: "Wow.. 900 years old. I have soooo many questions...")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 132:
            let spawnPoint: K.GameboardPosition = (3, 1)
            
            delegate?.spawnPrincessCapture(at: spawnPoint) { [unowned self] in
                sendChatArray(items: [
                    ChatItem(profile: .princess, chat: "PRINCESS OLIVIA: Help meeeee PUZL Boy!!! It's dark and scary over here. And this guy's breath is really stinky!"),
                    ChatItem(profile: .villain, chat: "MASKED VILLAIN: If you want to see your precious princess again, you need to go deeper into the dungeon... MUAHAHAHAHAHAHA!!!!"),
                    ChatItem(profile: .princess, chat: "Eww, your breath!"),
                    ChatItem(profile: .hero, chat: "If you touch a hair on her head, it's gonna be the end for you, smelly shadow man!"),
                    ChatItem(profile: .villain, chat: "MUAHAHAHAHAHHAHAHAAGGGGGHH! *cough* *cough* 😮‍💨"),
                    ChatItem(profile: .princess, chat: "Uh gross.. 🤮")
                ]) { [unowned self] in
                    fadeDimOverlay()
                    
                    delegate?.despawnPrincessCapture(at: spawnPoint) { [unowned self] in
                        handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case PauseResetEngine.hintButtonUnlock: // TODO: - Rework
            sendChatArray(items: [
                ChatItem(profile: .hero, chat: "You got something for me?", handler: { [unowned self] in
                    delegate?.illuminateMinorButton(for: .hint)
                }),
                ChatItem(profile: .trainer, chat: "Tap the hint button if you need a hint. Hints work at the start of the level. The number of hints show you how many you have."),
                ChatItem(profile: .trainer, chat: "You can buy more hints in the Shop menu.", handler: { [unowned self] in
                    delegate?.deilluminateMinorButton(for: .hint)
                }),
                ChatItem(profile: .hero, chat: "That is absolutely fantastic!")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        default:
            isChatting = false
            completion?()
        }
    }
}
