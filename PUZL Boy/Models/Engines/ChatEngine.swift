//
//  ChatEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

class ChatEngine {
    
    // MARK: - Properties
    
    //avatarSizeNew and Orig should be static so other classes can access w/o creating an instance
    static let avatarSizeNew: CGFloat = 300
    static let avatarSizeOrig: CGFloat = 512
    
    //Size and position properties
    private let padding: CGPoint = CGPoint(x: 20, y: 8)
    private var origin: CGPoint {
        CGPoint(x: GameboardSprite.xPosition, y: K.ScreenDimensions.topOfGameboard - backgroundSpriteWidth - ChatEngine.avatarSizeNew - 40)
    }
    private var backgroundSpriteWidth: CGFloat {
        K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale
    }

    //Other properties
    private var timer: Timer
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
    private var backgroundSprite: SKShapeNode
    private var avatarSprite: SKSpriteNode
    private var textSprite: SKLabelNode
    private var superScene: SKScene?
    
    enum ChatProfile {
        case hero, trainer, princess, villain
    }
    
    
    // MARK: - Initialization
    
    init() {
        timer = Timer()
        
        chatSpeed = chatSpeedOrig
        
        // MARK: - Include key dialogue here
        dialoguePlayed[1] = false
        dialoguePlayed[8] = false
        dialoguePlayed[19] = false
        dialoguePlayed[34] = false
        dialoguePlayed[51] = false
        dialoguePlayed[76] = false

        //Property initialization
        backgroundSprite = SKShapeNode()
        avatarSprite = SKSpriteNode(texture: SKTexture(imageNamed: "puzlboy"))
        textSprite = SKLabelNode(text: "PUZL Boy is the newest puzzle game out there on the App Store. It's so popular, it's going to have over a million downloads, gamers are going to love it - casual gamers, hardcore gamers, and everyone in-between! So download your copy today!!")

        //Setup
        let borderLineWidth: CGFloat = 4
        
        backgroundSprite.lineWidth = borderLineWidth
        backgroundSprite.path = UIBezierPath(roundedRect: CGRect(x: origin.x, y: origin.y,
                                                                 width: backgroundSpriteWidth, height: ChatEngine.avatarSizeNew + borderLineWidth),
                                             cornerRadius: 20).cgPath
        backgroundSprite.fillColor = .orange
        backgroundSprite.strokeColor = .white
        backgroundSprite.fillTexture = SKTexture(image: UIImage.chatGradientTexture)
        backgroundSprite.setScale(0)
        backgroundSprite.name = "backgroundSprite"
        backgroundSprite.zPosition = K.ZPosition.gameboard

        avatarSprite.position = CGPoint(x: origin.x, y: origin.y + borderLineWidth / 2)
        avatarSprite.setScale(ChatEngine.avatarSizeNew / ChatEngine.avatarSizeOrig)
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
        
        //Add sprites to background
        backgroundSprite.addChild(avatarSprite)
        backgroundSprite.addChild(textSprite)        
    }
    
    
    // MARK: - Functions
    
    func fastForward(in location: CGPoint) {
        guard let superScene = superScene else { return print("superScene not set in ChatEngine! Can't fast forward.") }
        
        for node in superScene.nodes(at: location) {
            if node.name == "backgroundSprite" {
                chatSpeed = 0
                
                return
            }
        }
    }
    
    func sendChat(profile: ChatProfile, startNewChat: Bool, endChat: Bool, chat: String, completion: (() -> ())? = nil) {
        //Only allow a new chat if current chat isn't happening
        guard allowNewChat else { return }
        
        textSprite.text = ""
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
        backgroundSprite.position.x = profile == .hero ? 0 : K.ScreenDimensions.width

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
    }

    ///This contains the magic of animating the characters of the string like a typewriter, until it gets to the end of the chat.
    @objc private func animateText(_ sender: Timer) {
        guard chatSpeed > 0 && chatIndex < chatText.count else {
            timer.invalidate()
            textSprite.text = chatText
            
            //If you fast forward, add >= 2 more seconds delay
            DispatchQueue.main.asyncAfter(deadline: .now() + (chatSpeed > 0 ? 2.0 : max(2.0, Double(chatText.count) / 30))) {
                self.closeChat()
            }
            
            return
        }


        let chatChar = chatText[chatText.index(chatText.startIndex, offsetBy: chatIndex)]

        textSprite.text! += "\(chatChar)"
                
        chatIndex += 1
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
    
    
    // MARK: - Move Functions

    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene
        
        superScene.addChild(backgroundSprite)
    }
}


// MARK: - Dialogue Function

extension ChatEngine {
    func shouldPauseGame(level: Int) -> Bool {
        return dialoguePlayed[level] != nil
    }
    
    func dialogue(level: Int, completion: (() -> Void)?) {
        switch level {
        case 1:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "TRAINER: Welcome, PUZL Boy! The goal of the game is to get to the gate in under a certain number of moves.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "You can move to any available panel on your left, right, above and below. Simply tap the panel to move there. Diagonal moves are NOT allowed.") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "If your move count hits 0, it's game over, buddy! Your move count can be found in the upper left corner next to the boot. 👢") { [unowned self] in
                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                 chat: "See the gate? It's closed. To open it, collect all the gems in the level. Give it a go!") { [unowned self] in
                            sendChat(profile: .hero, startNewChat: false, endChat: true,
                                     chat: "PUZL Boy: I got this, yo!") { [unowned self] in
                                dialoguePlayed[level] = true
                                completion?()
                            }
                        }
                    }
                }
            }
        case 8:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Pretty easy, right?! Levels get progressively harder with various obstacles blocking your path.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "You need a hammer to break through those boulders. Your inventory count can be found in the upper right. 🔨") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: false,
                             chat: "Hammers break boulders. Got it.") { [unowned self] in
                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                 chat: "Since there are no hammers in this level, you'll just have to go around them.") { [unowned self] in
                            sendChat(profile: .hero, startNewChat: false, endChat: false,
                                     chat: "Well then, that was pointless.") { [unowned self] in
                                sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                         chat: "Oh, and one more thing... hammers can only be used once before breaking, so plan your moves ahead of time.") { [unowned self] in
                                    dialoguePlayed[level] = true
                                    completion?()
                                }
                            }
                        }
                    }
                }
            }
        case 19:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Watch out for marsh! Stepping on one of the crimson colored panels will drag you down, costing ya 2 moves.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "However, sometimes stepping in marsh is unavoidable.") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: true,
                             chat: "Man... and I just got these new kicks!") { [unowned self] in
                        dialoguePlayed[level] = true
                        completion?()
                    }
                }
            }
        case 34:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Those fun looking things are warps. Stepping on one of them will teleport you to the other one. Weeeeeeeee!") { [unowned self] in
                sendChat(profile: .hero, startNewChat: false, endChat: false,
                         chat: "Are those things safe?") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "About to find out. Good luck!") { [unowned self] in
                        sendChat(profile: .hero, startNewChat: false, endChat: true,
                                 chat: "Here goes nothing...") { [unowned self] in
                            dialoguePlayed[level] = true
                            completion?()
                        }
                    }
                }
            }
        case 51:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Whoa, a dragon! Looks like he's sleeping. Don't even try waking him or it'll cost ya 1 health point. 💖") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "Don't believe me??? Go ahead. Try and pet him, I DARE YOU!") { [unowned self] in // Let player touch dragon before continuing...
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "Once your health drops to 0, it's lights out, baby. If only you had a sword. 🗡") { [unowned self] in
                        sendChat(profile: .hero, startNewChat: false, endChat: false, chat: "Lemme guess, I can only use the sword once before it breaks?") { [unowned self] in
                            sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                     chat: "B-I-N-G-O!!! Oh sorry, I was playing Bingo with my grandmother. Yep, one sword per dragon.") { [unowned self] in
                                dialoguePlayed[level] = true
                                completion?()
                            }
                        }
                    }
                }
            }
        
        case 76:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Ice, ice, baby! Step on this and you'll slide until you hit either an obstacle, another terrain panel, or the edge of the level.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "The nice thing though is that it'll only cost you 1 move as long as you're sliding continuously.") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: false,
                             chat: "Ok. I think I got it, old man.") { [unowned self] in
                        sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                 chat: "Well, I'll leave you alone for now. I'll chime in every now and then if I think you need it.") { [unowned self] in
                            dialoguePlayed[level] = true
                                                        
                            completion?()
                        }
                    }
                }
            }
        default:
            completion?()
        }
    }
}
