//
//  TabBarButton.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/9/23.
//

import SpriteKit

class TabBarButton: SKNode {

    // MARK: - Properties
    
    private(set) var sprite: SKShapeNode
    private(set) var iconNode: SKSpriteNode
    private(set) var textNode: SKLabelNode
    private(set) var type: TabBarType

    enum TabBarType: String {
        case title = "Title", buy = "Buy", pauseReset = "Reset", leaderboard = "Leaderboard", settings = "Settings"
    }
    
    
    // MARK: - Initialization
    
    init(imageName: String, type: TabBarType, position: CGPoint) {
        let buttonSize: CGFloat = K.ScreenDimensions.iPhoneWidth / 5
        
        sprite = SKShapeNode(rectOf: CGSize(width: buttonSize, height: buttonSize))
//        sprite.fillColor = .red
        sprite.lineWidth = 0
        
        iconNode = SKSpriteNode(imageNamed: imageName)
        iconNode.scale(to: CGSize(width: 100, height: 100))
        iconNode.position = .zero
        
        textNode = SKLabelNode(text: type.rawValue)
        textNode.position = CGPoint(x: 0, y: -buttonSize / 2)
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIFont.gameFontSizeSmall
        textNode.fontColor = UIFont.chatFontColor
        
        self.type = type

        super.init()

        name = type.rawValue
        self.position = position
        
        addChild(sprite)
        sprite.addChild(iconNode)
        sprite.addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func tapButton() {
        print("Tapped button for \(type.rawValue).")
        K.ButtonTaps.tap1()
    }
}
