//
//  ChatEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

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
    private static let yOrigin: CGFloat = K.ScreenDimensions.topOfGameboard - K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale - spriteSizeNew - margin

    //Shared properties. These seem weird..
    private var timer: Timer
    private var origScale: CGFloat
    private var chatText: String = ""
    private var chatIndex = 0
    private var allowNewChat = true
    private var shouldClose = true
    private var completion: (() -> ())?
    private var currentProfile: ChatProfile = .hero
        
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
        
        sprite = SKShapeNode()
        sprite.lineWidth = ChatEngine.chatBorderWidth
        sprite.path = UIBezierPath(roundedRect: CGRect(x: 30, y: ChatEngine.yOrigin,
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
    
    func dialogue(level: Int, completion: (() -> Void)?) {
        switch level {
        case 1:
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "TRAINER: Welcome, PUZL Boy! Boy, you look puzzled. Don't worry, it's just a puzzle.") { [unowned self] in
                sendChat(profile: .trainer, startNewChat: false, endChat: false,
                         chat: "Also.... don't forget to use your potions. It's the only thing you've got!") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "You may run into a dragon. that's ok. Just walk around him. Or her? They/them?") { [unowned self] in
                        sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                 chat: "Oh, and one more thing.... I forgot.") { [unowned self] in
                            sendChat(profile: .hero, startNewChat: false, endChat: true,
                                     chat: "PUZL BOY: Yup, I got it. (Sheesh, does this guy ever stop talking???") {
                                completion?()
                            }
                        }
                    }
                }
            }
        case 10:
            sendChat(profile: .trainer, startNewChat: true, endChat: false,
                     chat: "You've made it this far! Give your self a pat on the back 🤚🏼") { [unowned self] in
                sendChat(profile: .hero, startNewChat: false, endChat: false,
                         chat: "(Just go away already...)") { [unowned self] in
                    sendChat(profile: .trainer, startNewChat: false, endChat: false,
                             chat: "What?! I heard that!") { [unowned self] in
                        sendChat(profile: .hero, startNewChat: false, endChat: false,
                                 chat: "You weren't supposed to see that! That's my inner monologue vaginas.") { [unowned self] in
                            sendChat(profile: .trainer, startNewChat: false, endChat: false,
                                     chat: "I can see it on the screen, PUZ! And don't get on me about 4th wallin' it. I'm psychopathic!") { [unowned self] in
                                sendChat(profile: .hero, startNewChat: false, endChat: true, chat: "(Ugh, whatever.)") {
                                    completion?()
                                }
                            }
                        }
                    }
                }
            }
        default:
            completion?()
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
            imageSprite.texture = SKTexture(imageNamed: "puzlboy")
            sprite.fillColor = .orange
        case .trainer:
            imageSprite.texture = SKTexture(imageNamed: "trainer")
            sprite.fillColor = .gray
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
        sprite.run(SKAction.group([
            SKAction.moveTo(x: 0, duration: startNewChat ? 0.4 : 0),
            SKAction.scale(to: origScale, duration: startNewChat ? 0.4 : 0)
        ])) { [unowned self] in
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(animateText(_:)), userInfo: nil, repeats: true)
        }
    }

    ///This contains the magic of animating the characters of the string like a typewriter, until it gets to the end of the chat.
    @objc private func animateText(_ sender: Timer) {
        let chatChar = chatText[chatText.index(chatText.startIndex, offsetBy: chatIndex)]

        textSprite.text! += "\(chatChar)"
                
        chatIndex += 1

        if chatIndex >= chatText.count {
            timer.invalidate() //MUST be here, else crash!

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.closeChat()
            }
        }
    }
    
    private func closeChat() {
        let duration: TimeInterval = shouldClose ? 0.2 : 0
        
        sprite.run(SKAction.group([
            SKAction.moveTo(x: currentProfile != .hero ? K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale : 0, duration: duration),
            SKAction.scale(to: 0, duration: duration)
        ])) { [unowned self] in
            allowNewChat = true
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
