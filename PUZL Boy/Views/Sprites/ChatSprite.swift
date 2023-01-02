//
//  ChatSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

class ChatSprite {
    
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
        sprite.lineWidth = ChatSprite.chatBorderWidth
        sprite.path = UIBezierPath(roundedRect: CGRect(x: 30, y: ChatSprite.yOrigin,
                                                       width: K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale,
                                                       height: ChatSprite.spriteSizeNew + ChatSprite.chatBorderWidth),
                                   cornerRadius: 20).cgPath
        sprite.fillColor = .orange
        sprite.strokeColor = .white
        sprite.fillTexture = SKTexture(image: gradient)
        origScale = sprite.xScale
        sprite.setScale(0)

        imageSprite = SKSpriteNode(texture: SKTexture(imageNamed: "puzlboy"))
        imageSprite.position = CGPoint(x: 60, y: ChatSprite.yOrigin + ChatSprite.chatBorderWidth / 2)
        imageSprite.setScale(ChatSprite.spriteSizeNew / ChatSprite.spriteSizeOrig)
        imageSprite.anchorPoint = .zero
        
        textSprite = SKLabelNode(text: "PUZL Boy is the newest puzzle game out there on the App Store. It's so popular, it's going to have over a million downloads, gamers are going to love it - casual gamers, hardcore gamers, and everyone in-between! So download your copy today!!")
        textSprite.position = CGPoint(x: ChatSprite.margin + imageSprite.size.width, y: ChatSprite.yOrigin + ChatSprite.spriteSizeNew - 8)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = K.ScreenDimensions.iPhoneWidth - ChatSprite.spriteSizeNew - 2 * ChatSprite.margin
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSize
        textSprite.fontColor = UIFont.chatFontColor
        
        sprite.addChild(imageSprite)
        sprite.addChild(textSprite)        
    }
    
    
    // MARK: - Functions
    
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
        textSprite.position.x = ChatSprite.margin + (profile == .hero ? imageSprite.size.width : 20)

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
}
