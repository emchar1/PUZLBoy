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
        sprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth / 5, height: K.ScreenDimensions.iPhoneWidth / 5))
        sprite.fillColor = .red
        sprite.lineWidth = 2
        
        iconNode = SKSpriteNode(imageNamed: imageName)
        iconNode.scale(to: CGSize(width: 50, height: 50))
        iconNode.anchorPoint = .zero
        iconNode.position = .zero
        
        textNode = SKLabelNode(text: type.rawValue)
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIFont.chatFontSize
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
        AudioManager.shared.playSound(for: "buttontap")
        Haptics.shared.addHapticFeedback(withStyle: .soft)
    }
}
