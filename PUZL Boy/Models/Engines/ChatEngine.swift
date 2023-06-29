//
//  ChatEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

protocol ChatEngineDelegate: AnyObject {
    func illuminatePanel(at panelName: (row: Int, col: Int), useOverlay: Bool)
    func deIlluminatePanel(at panelName: (row: Int, col: Int), useOverlay: Bool)
    func illuminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
    func deIlluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
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
        CGPoint(x: GameboardSprite.xPosition + borderLineWidth / 2,
                y: K.ScreenDimensions.topOfGameboard - backgroundSpriteWidth - ChatEngine.avatarSizeNew - 40)
    }
    private var backgroundSpriteWidth: CGFloat {
        K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale
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
    private var dimOverlaySprite: SKShapeNode
    private var backgroundSprite: SKShapeNode
    private var avatarSprite: SKSpriteNode
    private var fastForwardSprite: SKSpriteNode
    private var textSprite: SKLabelNode
    private var superScene: SKScene?
    
    enum ChatProfile {
        case hero, trainer, princess, villain
    }
    
    weak var delegate: ChatEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        timer = Timer()
        dispatchWorkItem = DispatchWorkItem(block: { })
        
        chatSpeed = chatSpeedOrig
        
        // MARK: - Include key dialogue here
        dialoguePlayed[Level.partyLevel] = false
        dialoguePlayed[1] = false
        dialoguePlayed[8] = false
        dialoguePlayed[19] = false
        dialoguePlayed[34] = false
        dialoguePlayed[51] = false
        dialoguePlayed[76] = false
        dialoguePlayed[100] = false
        
        //Property initialization
        backgroundSprite = SKShapeNode()
        dimOverlaySprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        avatarSprite = SKSpriteNode(texture: SKTexture(imageNamed: "puzlboy"))
        fastForwardSprite = SKSpriteNode(imageNamed: "forwardButton")
        textSprite = SKLabelNode(text: "PUZL Boy is the newest puzzle game out there on the App Store. It's so popular, it's going to have over a million downloads, gamers are going to love it - casual gamers, hardcore gamers, and everyone in-between! So download your copy today!!")
        
        //Setup
        backgroundSprite.lineWidth = borderLineWidth
        backgroundSprite.path = UIBezierPath(roundedRect: CGRect(x: origin.x, y: origin.y,
                                                                 width: backgroundSpriteWidth, height: ChatEngine.avatarSizeNew + borderLineWidth),
                                             cornerRadius: 20).cgPath
        backgroundSprite.fillColor = .orange
        backgroundSprite.strokeColor = .white
        backgroundSprite.fillTexture = SKTexture(image: UIImage.chatGradientTexture)
        backgroundSprite.setScale(0)
        backgroundSprite.name = "backgroundSprite"
        backgroundSprite.zPosition = K.ZPosition.chatDialogue
        
        dimOverlaySprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        dimOverlaySprite.fillColor = .black
        dimOverlaySprite.lineWidth = 0
        dimOverlaySprite.alpha = 0
        dimOverlaySprite.zPosition = K.ZPosition.chatDimOverlay
        
        avatarSprite.position = CGPoint(x: origin.x, y: origin.y + borderLineWidth / 2)
        avatarSprite.setScale(ChatEngine.avatarSizeNew / ChatEngine.avatarSizeOrig * 3)
        avatarSprite.anchorPoint = .zero
        avatarSprite.color = .magenta
        
        textSprite.position = CGPoint(x: origin.x, y: origin.y + ChatEngine.avatarSizeNew - padding.y)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = backgroundSpriteWidth - ChatEngine.avatarSizeNew
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSize
        textSprite.fontColor = UIFont.chatFontColor
        textSprite.zPosition = 10
        textSprite.addDropShadow()
        
        fastForwardSprite.setScale(0.35 * 3)
        fastForwardSprite.anchorPoint = CGPoint(x: 1, y: 0)
        fastForwardSprite.position = CGPoint(x: origin.x + backgroundSpriteWidth - padding.x, y: origin.y + padding.x)
        fastForwardSprite.alpha = 1
        fastForwardSprite.zPosition = 15
        
        animateFFButton()
        
        //Add sprites to background
        backgroundSprite.addChild(avatarSprite)
        backgroundSprite.addChild(textSprite)
        backgroundSprite.addChild(fastForwardSprite)
    }
    
    deinit {
        print("ChatEngine deinit")
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
        guard !isAnimating else { return print("No spamming tapping the chat allowed!") }
        
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
            
            ButtonTap.shared.tap(type: .buttontap2)
        }
        else {
            dispatchWorkItem.cancel()
            closeChat()
            
            ButtonTap.shared.tap(type: shouldClose ? .noSound : .buttontap2)
        }
        
        //Prevents spamming of the chat fast forward tapping. Adds a 0.25 second delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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
            avatarSprite.texture = SKTexture(imageNamed: "trainer")
            backgroundSprite.fillColor = .magenta
        case .villain:
            avatarSprite.texture = SKTexture(imageNamed: "puzlboy")
            backgroundSprite.fillColor = .red
        }
        
        textSprite.position.x = origin.x + (profile != .hero ? padding.x : avatarSprite.size.width)
        avatarSprite.position.x = origin.x + (profile == .hero ? padding.x : backgroundSpriteWidth - padding.x)
        backgroundSprite.position.x = profile == .hero ? 0 : K.ScreenDimensions.iPhoneWidth
        
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
            dispatchWorkItem = DispatchWorkItem(block: {
                self.closeChat()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chatSpeed > 0 ? 5.0 : max(5.0, Double(chatText.count) / 10)), execute: dispatchWorkItem)
        }
    }
    
    private func closeChat() {
        let duration: TimeInterval = shouldClose ? 0.2 : 0
        
        if shouldClose {
            AudioManager.shared.playSound(for: "chatclose")
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
}


// MARK: - Dialogue Function

extension ChatEngine {
    func dialogue(level: Int, completion: (() -> Void)?) {
        isChatting = true
        
        switch level {
        case Level.partyLevel:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            sendChat(profile: .hero, startNewChat: true, endChat: false,
                     chat: "Yo, I feel funny. I'm seeing colorful flashing lights and the music is bumpin'. I can't stop moving.. and I like it!") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "Welcome to the PARTY ZONE! Looks like you ate one of those rainbow colored jelly beans, I see.") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: false,
                             chat: "Jelly beans, right...") { [unowned self] in
                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                 chat: "Don't worry, the feeling lasts only a short amount of time, but while you're under its effects you can move as much as your heart desires.") { [unowned self] in
                            sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                     chat: "Run around collecting all the gems and bonuses that pop up in the level. But you gotta be quick before the time runs out.") { [unowned self] in
                                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                         chat: "Oh, and the one thing you want to look out for are rainbow bombs.") { [unowned self] in
                                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                             chat: "Like, I know it's all pretty and fun looking, but avoid them at all costs, or it's the end of the bonus round.") { [unowned self] in
                                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                                 chat: "Why is it always the pretty things in life that are the most deadly...") { [unowned self] in
                                            sendChat(profile: .hero, startNewChat: false, endChat: false,
                                                     chat: "Don't step on the bombs. Yeah got it.") { [unowned self] in
                                                sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                                         chat: "OK. Now if the flashing lights become too much, you can tap the disco ball below to turn them off. 🪩 GET READY!!!") { [unowned self] in
                                                    dialoguePlayed[level] = true
                                                    fadeDimOverlay()
                                                    isChatting = false
                                                    completion?()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case 1:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "TRAINER: Welcome, PUZL Boy! The goal of the game is to get to the gate in under a certain number of moves.") { [unowned self] in
                
                delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
                delegate?.illuminatePanel(at: (1, 0), useOverlay: false)
                delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
                delegate?.illuminatePanel(at: (2, 1), useOverlay: false)

                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "You can move to any available panel on your left, right, above and below. Simply tap the panel to move there. Diagonal moves are not allowed.") { [unowned self] in

                    delegate?.deIlluminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.deIlluminatePanel(at: (1, 0), useOverlay: false)
                    delegate?.deIlluminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.deIlluminatePanel(at: (2, 1), useOverlay: false)
                    delegate?.illuminateDisplayNode(for: .moves)
                    
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "If your move count hits 0, it's game over, buddy! Your move count can be found in the upper left corner next to the boot. 👢") { [unowned self] in
                        
                        delegate?.deIlluminateDisplayNode(for: .moves)
                        delegate?.illuminatePanel(at: (0, 2), useOverlay: true)
                        delegate?.illuminatePanel(at: (2, 2), useOverlay: false)
                        
                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                 chat: "See the gate? It's closed. To open it, collect all the gems in the level. Give it a go!") { [unowned self] in
                            sendChat(profile: .hero, startNewChat: false, endChat: true,
                                     chat: "PUZL Boy: I got this, yo!") { [unowned self] in
                                dialoguePlayed[level] = true
                                delegate?.deIlluminatePanel(at: (0, 2), useOverlay: true)
                                delegate?.deIlluminatePanel(at: (2, 2), useOverlay: false)
                                fadeDimOverlay()
                                isChatting = false
                                completion?()
                            }
                        }
                    }
                }
            }
        case 8:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)

            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Pretty easy, right?! Levels get progressively harder with various obstacles blocking your path.") { [unowned self] in
                
                delegate?.illuminateDisplayNode(for: .hammers)
                
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "You need a hammer to break through those boulders. Your inventory count can be found in the upper right. 🔨") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: false,
                             chat: "Hammers break boulders. Got it.") { [unowned self] in
                        
                        delegate?.deIlluminateDisplayNode(for: .hammers)
                        
                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                 chat: "Since there are no hammers in this level, you'll just have to go around them.") { [unowned self] in
                            sendChat(profile: .hero, startNewChat: false, endChat: false,
                                     chat: "Well then, that was pointless.") { [unowned self] in
                                sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                         chat: "Oh, and one more thing... hammers can only be used once before breaking, so plan your moves ahead of time.") { [unowned self] in
                                    dialoguePlayed[level] = true
                                    fadeDimOverlay()
                                    isChatting = false
                                    completion?()
                                }
                            }
                        }
                    }
                }
            }
        case 19:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (2, 1), useOverlay: false)

            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Watch out for marsh! Stepping on one of the crimson colored panels will drag you down, costing ya 2 moves.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "However, sometimes stepping in marsh is unavoidable.") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: true,
                             chat: "Man... and I just got these new kicks!") { [unowned self] in
                        dialoguePlayed[level] = true
                        delegate?.deIlluminatePanel(at: (0, 1), useOverlay: false)
                        delegate?.deIlluminatePanel(at: (2, 1), useOverlay: false)
                        fadeDimOverlay()
                        isChatting = false
                        completion?()
                    }
                }
            }
        case 34:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)

            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Those fun looking things are warps. Stepping on one of them will teleport you to the other one. Weeeeeeeee!") { [unowned self] in
                sendChat(profile: .hero, startNewChat: false, endChat: false,
                         chat: "Are those things safe?") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "About to find out. Good luck!") { [unowned self] in
                        sendChat(profile: .hero, startNewChat: false, endChat: true,
                                 chat: "Here goes nothing...") { [unowned self] in
                            dialoguePlayed[level] = true
                            delegate?.deIlluminatePanel(at: (0, 1), useOverlay: true)
                            delegate?.deIlluminatePanel(at: (1, 2), useOverlay: true)
                            fadeDimOverlay()
                            isChatting = false
                            completion?()
                        }
                    }
                }
            }
        case 51:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Look, a terrifyingly majestic dragon! Wonder in awe in his magnificence! But don't get too close or it'll cost ya 1 health point.") { [unowned self] in
                sendChat(profile: .hero, startNewChat: false, endChat: false,
                         chat: "He looks kinda small and underwhelming to me...") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false, chat: "Hey, this is a solo project with 0 budget, whaddya want from me?!\n\nAnyway...") { [unowned self] in
                        
                        delegate?.illuminateDisplayNode(for: .health)

                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                 chat: "Once your health drops to 0, it's lights out, baby. Your health can be found in the upper left next to the heart. 💖") { [unowned self] in
                            
                            delegate?.deIlluminateDisplayNode(for: .health)
                            delegate?.illuminateDisplayNode(for: .swords)
                            
                            sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                     chat: "Don't believe me? Go ahead. Try and pet him, I dare you! But you won't be able to defeat him without a sword. 🗡") { [unowned self] in
                                sendChat(profile: .hero, startNewChat: false, endChat: false, chat: "Lemme guess, I can only use the sword once before it breaks?") { [unowned self] in
                                    
                                    delegate?.deIlluminateDisplayNode(for: .swords)
                                    
                                    sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                             chat: "B-I-N-G-O!!! Oh whoops, I was playing Bingo with my grams. Yep, one sword per dragon.") { [unowned self] in
                                        dialoguePlayed[level] = true
                                        fadeDimOverlay()
                                        isChatting = false
                                        completion?()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        case 76:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)

            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Ice, ice, baby! Step on this and you'll slide until you hit either an obstacle or the edge of the level.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "The nice thing though is that it'll only cost you 1 move as long as you're sliding continuously.") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: false,
                             chat: "Ok. I think I got it, old man.") { [unowned self] in
                        
                        delegate?.deIlluminatePanel(at: (0, 1), useOverlay: false)
                        delegate?.deIlluminatePanel(at: (0, 2), useOverlay: false)
                        delegate?.deIlluminatePanel(at: (1, 2), useOverlay: false)
                        delegate?.deIlluminatePanel(at: (0, 1), useOverlay: true)
                        delegate?.deIlluminatePanel(at: (1, 2), useOverlay: true)
                        fadeDimOverlay()
                        
                        sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                 chat: "Well, I'll leave you alone for now. I'll chime in every now and then if I think you need it.") { [unowned self] in
                            dialoguePlayed[level] = true
                            isChatting = false
                            completion?()
                        }
                    }
                }
            }
        case 100:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                isChatting = false
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Congrats! You made it to level 100. There's a bonus at the end of every 50 levels. Beat this and you're one step closer to indescribable fun!!! 💃🏾🪩🕺🏻") { [unowned self] in
                sendChat(profile: .hero, startNewChat: false, endChat: false, chat: "I can hardly contain my excitement. 😒") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false, chat: "That's the spirit! Now if you ever get stuck, you can tap the red Reset button to restart the level.") { [unowned self] in
                        sendChat(profile: .trainer, startNewChat: false, endChat: false, chat: "Be warned though, restarting a level will cost you one of your precious lives...") { [unowned self] in
                            sendChat(profile: .hero, startNewChat: false, endChat: true, chat: "It's all good. My mom can buy me more lives if I need it. 😃") { [unowned self] in
                                dialoguePlayed[level] = true
                                fadeDimOverlay()
                                isChatting = false
                                completion?()
                            }
                        }
                    }
                }
            }
        default:
            isChatting = false
            completion?()
        }
    }
}
