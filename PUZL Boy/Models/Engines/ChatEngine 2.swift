//
//  ChatEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit
//import GoogleMobileAds

class ChatEngine {
    
    // MARK: - Properties
    
    //Sprite properties
    private(set) var sprite: SKShapeNode
    private(set) var imageSprite: SKSpriteNode
    private(set) var textSprite: SKLabelNode
    
    //Shared static properties
    private static let spriteSizeNew: CGFloat = 300
    private static let spriteSizeOrig: CGFloat = 512
    private static let margin: CGFloat = 40
    private static let chatBorderWidth: CGFloat = 4
    private static let xOrigin: CGFloat = 30
    private static let yOrigin: CGFloat = K.ScreenDimensions.topOfGameboard - K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale - spriteSizeNew - margin

    //Shared properties
    private var timer: Timer
    private var origScale: CGFloat
    private var chatText: String = ""
    private var chatIndex = 0
    private var allowNewChat = true
    private var shouldClose = true
    private var completion: (() -> ())?
    private var currentProfile: ChatProfile = .hero
    private var dialoguePlayed: [Int: Bool] = [:]           //Only play certain instructions once
    private var chatSpeed: TimeInterval
    private let chatSpeedOrig: TimeInterval = 0.08
            
    enum ChatProfile {
        case hero, trainer, princess, villain
    }
    
    
    // MARK: - Initialization
    
    init() {
        let gradient: UIImage = UIImage.gradientImage(withBounds: CGRect(x: 0, y: 0,
                                                                         width: K.ScreenDimensions.iPhoneWidth,
                                                                         height: K.ScreenDimensions.height),
                                                      startPoint: CGPoint(x: 0.5, y: 1),
                                                      endPoint: CGPoint(x: 0.5, y: 0.5),
                                                      colors: [UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1).cgColor,
                                                               UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor])
        
        timer = Timer()
        
        chatSpeed = chatSpeedOrig
        dialoguePlayed[1] = false
        dialoguePlayed[5] = false
        dialoguePlayed[8] = false
        dialoguePlayed[13] = false
        dialoguePlayed[18] = false
        dialoguePlayed[23] = false
        dialoguePlayed[-1] = false
        
        sprite = SKShapeNode()
        sprite.lineWidth = ChatEngine.chatBorderWidth
        sprite.path = UIBezierPath(roundedRect: CGRect(x: ChatEngine.xOrigin, y: ChatEngine.yOrigin,
                                                       width: K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale,
                                                       height: ChatEngine.spriteSizeNew + ChatEngine.chatBorderWidth),
                                   cornerRadius: 20).cgPath
        sprite.fillColor = .orange
        sprite.strokeColor = .white
        sprite.fillTexture = SKTexture(image: gradient)
        origScale = sprite.xScale
        sprite.setScale(0)

        imageSprite = SKSpriteNode(texture: SKTexture(imageNamed: "puzlboy"))
        imageSprite.position = CGPoint(x: 60, y: ChatEngine.yOrigin + ChatEngine.chatBorderWidth / 2)
        imageSprite.setScale(ChatEngine.spriteSizeNew / ChatEngine.spriteSizeOrig)
        imageSprite.anchorPoint = .zero
        
        textSprite = SKLabelNode(text: "PUZL Boy is the newest puzzle game out there on the App Store. It's so popular, it's going to have over a million downloads, gamers are going to love it - casual gamers, hardcore gamers, and everyone in-between! So download your copy today!!")
        textSprite.position = CGPoint(x: ChatEngine.margin + imageSprite.size.width, y: ChatEngine.yOrigin + ChatEngine.spriteSizeNew - 8)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = K.ScreenDimensions.iPhoneWidth - ChatEngine.spriteSizeNew - 2 * ChatEngine.margin
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSize
        textSprite.fontColor = UIFont.chatFontColor
        
        sprite.addChild(imageSprite)
        sprite.addChild(textSprite)        
    }
    
    
    // MARK: - Functions
    
    func fastForward(in location: CGPoint) {
        guard location.x >= ChatEngine.xOrigin && location.x <= ChatEngine.xOrigin + sprite.frame.size.width && location.y >= ChatEngine.yOrigin && location.y <= ChatEngine.yOrigin + sprite.frame.size.height else { return }
        
        chatSpeed = 0
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
            imageSprite.texture = SKTexture(imageNamed: "puzlboy")
            sprite.fillColor = .orange
        case .trainer:
            imageSprite.texture = SKTexture(imageNamed: "trainer")
            sprite.fillColor = .blue
        case .princess:
            imageSprite.texture = SKTexture(imageNamed: "trainer")
            sprite.fillColor = .magenta
        case .villain:
            imageSprite.texture = SKTexture(imageNamed: "puzlboy")
            sprite.fillColor = .red
        }
        
        imageSprite.position.x = profile == .hero ? 60 : K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale
        imageSprite.xScale = profile == .hero ?  abs(imageSprite.xScale) : -abs(imageSprite.xScale)
        textSprite.position.x = ChatEngine.margin + (profile == .hero ? imageSprite.size.width : 20)

        sprite.setScale(0)
        sprite.position.x = profile != .hero ? K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale : 0
        
        //Animates the chat bubble zoom in for startNewChat
        sprite.run(SKAction.group([
            SKAction.moveTo(x: 0, duration: startNewChat ? 0.4 : 0),
            SKAction.scale(to: origScale, duration: startNewChat ? 0.4 : 0)
        ])) { [unowned self] in
            if startNewChat {
                AudioManager.shared.playSound(for: "chatopen2")
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
        sprite.run(SKAction.group([
            SKAction.moveTo(x: currentProfile != .hero ? K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale : 0, duration: duration),
            SKAction.scale(to: 0, duration: duration)
        ])) { [unowned self] in
            allowNewChat = true
            chatSpeed = chatSpeedOrig
            completion?()
        }
    }
    
    
    // MARK: - Move Functions

    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(sprite)
    }
}


// MARK: - Dialogue Function

extension ChatEngine {
    func shouldPauseGame(level: Int) -> Bool {
        return dialoguePlayed[level] != nil
    }
    
    func dialogue(level: Int, superScene: SKScene? = nil, completion: (() -> Void)?) {
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
                                 chat: "Now in order to open the gate, you'll have to collect all the gems in the level. Give it a go!") { [unowned self] in
                            sendChat(profile: .hero, startNewChat: false, endChat: true,
                                     chat: "PUZL Boy: I got this, yo!") { [unowned self] in
                                dialoguePlayed[level] = true
                                completion?()
                            }
                        }
                    }
                }
            }
        case 5:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Pretty easy, right?! Levels get progressively harder with various obstacles blocking your path.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "You need a hammer to break through those boulders. Your inventory count can be found in the upper right. 🔨") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "Since there are no hammers nearby, you just have to go around, unfortunately. Get those steps in!") { [unowned self] in
                        sendChat(profile: .hero, startNewChat: false, endChat: false,
                                 chat: "So... hammers break boulders. Makes sense.") { [unowned self] in
                            sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                     chat: "Oh, and one more thing... hammers can only be used once before breaking, so plan your moves ahead of time.") { [unowned self] in
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
                     chat: "Watch out for marsh! Stepping on one of these purple colored panels will drag you down, costing ya 2 moves.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "However, sometimes stepping in marsh is unavoidable.") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: true,
                             chat: "Man... and I just got these new kicks!") { [unowned self] in
                        dialoguePlayed[level] = true
                        completion?()
                    }
                }
            }
        case 13:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Whoa, a dragon! Looks like he's sleeping. Don't even try waking him or it'll cost ya 1 health point. 💖") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "Once your health drops to 0, it's lights out, baby. If only you had a sword. 🗡") { [unowned self] in
                    sendChat(profile: .hero, startNewChat: false, endChat: false, chat: "Lemme guess, I can only use the sword once before it breaks?") { [unowned self] in
                        sendChat(profile: .trainer, startNewChat: false, endChat: true,
                                 chat: "B-I-N-G-O!!! Oh sorry, I was playing Bingo with my grandmother. Yes, one sword per dragon.") { [unowned self] in
                            dialoguePlayed[level] = true
                            completion?()
                        }
                    }
                }
            }
        case 18:
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "Those fun looking things are warps. Stepping on one of them will teleport you to the other one. Weeeeeeeee!") { [unowned self] in
                sendChat(profile: .hero, startNewChat: false, endChat: false,
                         chat: "Are those things safe?") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: true,
                             chat: "Probably. Anyhoo, here's a word from our sponsor...") { [unowned self] in
                        dialoguePlayed[level] = true
                        
                        
                        
                        
                        // TODO: Fade out, fade into first interstitial ad
                        if let superScene = superScene {
                            let adSprite = SKSpriteNode(color: .clear,
                                                        size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
                            adSprite.anchorPoint = .zero
                            adSprite.zPosition = K.ZPosition.adScene

                            superScene.addChild(adSprite)
                            
                            let sequence = SKAction.sequence([
                                SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: 1.0),
                                SKAction.wait(forDuration: 2.0), //play ad here
//                                SKAction.colorize(with: .clear, colorBlendFactor: 1.0, duration: 1.0
                            ])

                            adSprite.run(sequence) {
//                                if let mainViewController = K.mainViewController {
//                                    AdMobManager.shared.interstitialAd?.present(fromRootViewController: mainViewController)
//                                }
                                
                                adSprite.run(SKAction.colorize(with: .clear, colorBlendFactor: 1.0, duration: 1.0)) {
                                    completion?()
                                }
                                
//                                completion?()
                            }
                        }
                        else {
                            completion?()
                        }
                        
                        
                        
                        
                    }
                }
            }
//        case 19:
//            if let mainViewController = K.mainViewController {
//                AdMobManager.shared.adBannerView?.delegate = mainViewController.self as? any GADBannerViewDelegate
//                AdMobManager.shared.adBannerView?.rootViewController = mainViewController
////                AdMobManager.shared.interstitialAd?.present(fromRootViewController: mainViewController)
//            }

        case 23:
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
                            
                            GameCenterManager.shared.updateProgress(achievement: .avidReader, shouldReportImmediately: true)
                            
                            completion?()
                        }
                    }
                }
            }
        case -1: //Game Over
            guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck else {
                completion?()
                return
            }
            
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "You win some, you lose some. Next time try to make it to the gate in fewer moves." ) { [unowned self] in
                sendChat(profile: .hero, startNewChat: false, endChat: true,
                         chat: "Man, what a bummer.") { [unowned self] in
                    dialoguePlayed[level] = true
                    completion?()
                }
            }
        default:
            completion?()
        }
    }
}
