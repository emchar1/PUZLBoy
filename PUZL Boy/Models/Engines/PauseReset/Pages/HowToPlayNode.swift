//
//  HowToPlayNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/15/23.
//

import SpriteKit

class HowToPlayNode: SKNode {
    
    // MARK: - Properties
    
    static let iconSize: CGFloat = UIDevice.isiPad ? 350 : 250
    
    private var currentLevel: Int
    private var requiredLevel: Int
    private var canShow: Bool { currentLevel >= requiredLevel }

    private var iconNode: SKSpriteNode!
    private var titleNode: SKLabelNode!
    private var descriptionNode: SKLabelNode!
    
    
    // MARK: - Initialization
    
    init(imageName: String, currentLevel: Int, requiredLevel: Int, nodeWidth: CGFloat, descriptionText: String) {
        self.currentLevel = currentLevel
        self.requiredLevel = requiredLevel
                
        super.init()
        
        let padding: CGFloat = 20
        
        let borderNode = SKShapeNode(rectOf: CGSize(width: HowToPlayNode.iconSize, height: HowToPlayNode.iconSize), cornerRadius: 20)
        borderNode.position = CGPoint(x: HowToPlayNode.iconSize / 2, y: -HowToPlayNode.iconSize / 2)
        borderNode.fillColor = .clear
        borderNode.strokeColor = .white
        borderNode.lineWidth = 8
        borderNode.zPosition = 5

        iconNode = canShow ? SKSpriteNode(imageNamed: imageName) : SKSpriteNode(color: .black, size: CGSize(width: HowToPlayNode.iconSize, height: HowToPlayNode.iconSize))
        iconNode.position = CGPoint(x: 0, y: 0)
        iconNode.anchorPoint = CGPoint(x: 0, y: 1)
        iconNode.size = CGSize(width: HowToPlayNode.iconSize, height: HowToPlayNode.iconSize)
        iconNode.name = "iconNode"
        iconNode.zPosition = 10
        
        titleNode = SKLabelNode(text: canShow ? imageName.uppercased() : "???")
        titleNode.position = CGPoint(x: HowToPlayNode.iconSize + padding, y: 0)
        titleNode.horizontalAlignmentMode = .left
        titleNode.verticalAlignmentMode = .top
        titleNode.fontName = UIFont.gameFont
        titleNode.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        titleNode.fontColor = UIFont.gameFontColor
        titleNode.name = "titleNode"
        titleNode.zPosition = 10
        titleNode.addDropShadow()
        
        descriptionNode = SKLabelNode(text: canShow ? descriptionText : "\nReach level \(requiredLevel) to unlock this hint.")
        descriptionNode.position = CGPoint(x: HowToPlayNode.iconSize + padding, y: UIDevice.isiPad ? -80 : -60)
        descriptionNode.horizontalAlignmentMode = .left
        descriptionNode.verticalAlignmentMode = .top
        descriptionNode.preferredMaxLayoutWidth = nodeWidth - (HowToPlayNode.iconSize + padding)
        descriptionNode.numberOfLines = 0
        descriptionNode.fontName = UIFont.chatFont
        descriptionNode.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.chatFontSize
        descriptionNode.fontColor = UIFont.chatFontColor
        descriptionNode.name = "descriptionNode"
        descriptionNode.zPosition = 10
        descriptionNode.addDropShadow()
        
        
        iconNode.addChild(borderNode)
        addChild(iconNode)
        addChild(titleNode)
        addChild(descriptionNode)

//        //FIXME: - Debug only
//        let backgroundColor = SKSpriteNode(color: .magenta, size: CGSize(width: nodeWidth, height: iconSize))
//        backgroundColor.anchorPoint = CGPoint(x: 0, y: 1)
//        addChild(backgroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    
}
