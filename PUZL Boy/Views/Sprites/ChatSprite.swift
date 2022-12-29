//
//  ChatSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

class ChatSprite {
    
    // MARK: - Properties
    
    private(set) var sprite: SKShapeNode
    private(set) var imageSprite: SKSpriteNode
    private(set) var textSprite: SKLabelNode
    
    
    // MARK: - Initialization
    
    init(imageName: String, imageLeft: Bool, color: UIColor) {
        let spriteSizeNew: CGFloat = 300
        let spriteSizeOrig: CGFloat = 512
        let margin: CGFloat = 40
        let chatBorderWidth: CGFloat = 4
        let yOrigin = K.ScreenDimensions.topOfGameboard - K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale - spriteSizeNew - margin
        let gradient: UIImage = UIImage.gradientImage(withBounds: CGRect(x: 0, y: 0,
                                                                         width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height),
                                                      startPoint: CGPoint(x: 0.5, y: 1),
                                                      endPoint: CGPoint(x: 0.5, y: 0.5),
                                                      colors: [UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1).cgColor,
                                                               UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor])
        
        sprite = SKShapeNode()
        sprite.lineWidth = chatBorderWidth
        sprite.path = UIBezierPath(roundedRect: CGRect(x: 30, y: yOrigin,
                                                       width: K.ScreenDimensions.iPhoneWidth * 0.94, height: spriteSizeNew + chatBorderWidth),
                                   cornerRadius: 20).cgPath
        sprite.fillColor = color
        sprite.strokeColor = .white
        sprite.fillTexture = SKTexture(image: gradient)
        
        imageSprite = SKSpriteNode(texture: SKTexture(imageNamed: imageName))
        imageSprite.position = CGPoint(x: imageLeft ? 60 : K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale,
                                       y: yOrigin + chatBorderWidth / 2)
        imageSprite.setScale(spriteSizeNew / spriteSizeOrig)
        imageSprite.xScale = (imageLeft ? 1 : -1) * imageSprite.xScale
        imageSprite.anchorPoint = .zero
        
        textSprite = SKLabelNode(text: "PUZL Boy is the newest puzzle game out there on the App Store. It's so popular, it's going to have over a million downloads, gamers are going to love it - casual gamers, hardcore gamers, and everyone in-between! So download your copy today!!")
        textSprite.position = CGPoint(x: 40 + (imageLeft ? imageSprite.size.width : 20), y: yOrigin + spriteSizeNew - 8)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = K.ScreenDimensions.iPhoneWidth - spriteSizeNew - 80
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSize
        textSprite.fontColor = UIFont.chatFontColor
        
        sprite.addChild(imageSprite)
        sprite.addChild(textSprite)
    }
    
    
    // MARK: - Functions
    
    // FIXME: - Need to animate the chat like a typewriter..
    func sendChat(_ chat: String) {
        textSprite.text = ""
        
        for letter in chat {
            self.textSprite.text! += "\(letter)"
        }
    }

    
}
