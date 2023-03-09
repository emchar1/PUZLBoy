//
//  TabBarButton.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/9/23.
//

import SpriteKit

class TabBarButton: SKNode {

    // MARK: - Properties
    
    private(set) var iconNode: SKSpriteNode
    private(set) var textNode: SKLabelNode

    enum TabBarType: String {
        case title = "Title", buy = "Buy", pauseReset = "Reset", leaderboard = "Leaderboard", settings = "Settings"
    }
    
    
    // MARK: - Initialization
    
    init(imageName: String, type: TabBarType, position: CGPoint) {
        iconNode = SKSpriteNode(imageNamed: imageName)
        iconNode.anchorPoint = .zero
        iconNode.position = .zero
        
        textNode = SKLabelNode(text: type.rawValue)
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIFont.chatFontSize
        textNode.fontColor = UIFont.chatFontColor

        super.init()

        name = type.rawValue
        self.position = position
        
        addChild(iconNode)
        addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func tapButton() {
        AudioManager.shared.playSound(for: "buttontap")
        Haptics.shared.addHapticFeedback(withStyle: .soft)
    }
}
