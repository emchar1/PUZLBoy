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
    
    private var imageName: String
    private var titleText: String
    private var descriptionText: String
    private var currentLevel: Int
    private var requiredLevel: Int
    private var hintType: HintType
    private var nodeWidth: CGFloat
    private var canShow: Bool { currentLevel >= requiredLevel }

    private var iconNode: SKSpriteNode!
    private var titleNode: SKLabelNode!
    private var descriptionNode: SKLabelNode!
    
    enum HintType {
        case terrain, overlay
    }
    
    
    // MARK: - Initialization
    
    init(imageName: String, titleText: String, hintType: HintType, currentLevel: Int, requiredLevel: Int, nodeWidth: CGFloat, descriptionText: String) {
        self.imageName = imageName
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.currentLevel = currentLevel
        self.requiredLevel = requiredLevel
        self.hintType = hintType
        self.nodeWidth = nodeWidth
                
        super.init()
        
        setupSprites()
        updateLabels(level: currentLevel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        let padding: CGFloat = 20
        let lineWidth: CGFloat = 8
        
        let borderNode = SKShapeNode(rectOf: CGSize(width: HowToPlayNode.iconSize + lineWidth, height: HowToPlayNode.iconSize + lineWidth), cornerRadius: 20)
        borderNode.position = CGPoint(x: HowToPlayNode.iconSize / 2, y: -HowToPlayNode.iconSize / 2)
        borderNode.fillColor = .clear
        borderNode.strokeColor = .white
        borderNode.lineWidth = lineWidth
        borderNode.zPosition = 5

        iconNode = SKSpriteNode(color: .black, size: CGSize(width: HowToPlayNode.iconSize, height: HowToPlayNode.iconSize))
        iconNode.position = CGPoint(x: 0, y: 0)
        iconNode.anchorPoint = CGPoint(x: 0, y: 1)
        iconNode.size = CGSize(width: HowToPlayNode.iconSize, height: HowToPlayNode.iconSize)
        iconNode.name = "iconNode"
        iconNode.zPosition = 10
        
        titleNode = SKLabelNode()
        titleNode.position = CGPoint(x: HowToPlayNode.iconSize + padding, y: 0)
        titleNode.horizontalAlignmentMode = .left
        titleNode.verticalAlignmentMode = .top
        titleNode.fontName = UIFont.gameFont
        titleNode.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        titleNode.fontColor = UIFont.gameFontColor
        titleNode.name = "titleNode"
        titleNode.zPosition = 10
        titleNode.addDropShadow()
        
        descriptionNode = SKLabelNode()
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
        
        if hintType == .overlay {
            // FIXME: - When does this get called???
            let terrainBackground = SKSpriteNode(imageNamed: imageName == "partyGem" ? "partytile" : "grass")
            terrainBackground.position = CGPoint(x: 0, y: -HowToPlayNode.iconSize)
            terrainBackground.anchorPoint = .zero
            terrainBackground.size = CGSize(width: HowToPlayNode.iconSize, height: HowToPlayNode.iconSize)
            terrainBackground.zPosition = -5

            iconNode.addChild(terrainBackground)
        }
    }
    
    
    // MARK: - Functions
    
    func updateLabels(level: Int) {
        currentLevel = level
        
        iconNode.texture = canShow ? SKTexture(imageNamed: imageName) : nil
        titleNode.text = canShow ? titleText.uppercased() : "???"
        descriptionNode.text = canShow ? descriptionText : "\nReach level \(requiredLevel) to unlock this hint."
    }
}
