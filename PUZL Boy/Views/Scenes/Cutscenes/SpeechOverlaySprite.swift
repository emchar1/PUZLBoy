//
//  SpeechOverlaySprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/31/23.
//

import SpriteKit

class SpeechOverlaySprite: SKNode {

    // MARK: - Properties
    
    private let padding: CGFloat = 20
    private let nodeHeight: CGFloat = 200
    private var text: String
    
    private var backgroundNode: SKShapeNode!
    private var speechNode: SKLabelNode!
    
    
    // MARK: - Initialization

    init(text: String) {
        self.text = text
        
        super.init()
        
        self.position = CGPoint(x: padding, y: K.ScreenDimensions.screenSize.height - K.ScreenDimensions.topMargin - padding)
        self.zPosition = K.ZPosition.speechBubble
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        backgroundNode = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth - 2 * padding, height: nodeHeight))
        backgroundNode.fillColor = .clear
        backgroundNode.lineWidth = 0
        
        speechNode = SKLabelNode(text: text)
        speechNode.fontName = UIFont.chatFont
        speechNode.fontSize = UIFont.chatFontSizeLarge
        speechNode.fontColor = .white
        speechNode.position = .zero
        speechNode.numberOfLines = 0
        speechNode.preferredMaxLayoutWidth = backgroundNode.frame.size.width
        speechNode.horizontalAlignmentMode = .left
        speechNode.verticalAlignmentMode = .top
        speechNode.addDropShadow(shadowOffset: CGPoint(x: -6, y: -6))
        speechNode.zPosition = 5
        
        addChild(backgroundNode)
        backgroundNode.addChild(speechNode)
    }
}
