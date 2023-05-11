//
//  ParentPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/11/23.
//

import SpriteKit

class ParentPage: SKNode {
    
    // MARK: - Properties
    
    let padding: CGFloat = 40
    var nodeName = "parentPage"
    var contentSize: CGSize
    var contentNode: SKSpriteNode
    var titleLabel: SKLabelNode

    
    // MARK: - Initialization
    
    init(contentSize: CGSize, titleText: String) {
        self.contentSize = contentSize

        contentNode = SKSpriteNode(color: .clear, size: contentSize)
        contentNode.anchorPoint = CGPoint(x: 0, y: 1)
        contentNode.position = CGPoint(x: -contentSize.width / 2, y: contentSize.height / 2)
        
        titleLabel = SKLabelNode(text: titleText.uppercased())
        titleLabel.position = CGPoint(x: contentSize.width / 2, y: -padding)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .top
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeMedium
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.addHeavyDropShadow()
        titleLabel.zPosition = 10
        
        super.init()
        
        name = nodeName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Touch Functions
    
    func touchDown(at location: CGPoint) {
        //Implement in subclass
    }
    
    func touchUp() {
        //Implement in subclass
    }
}
