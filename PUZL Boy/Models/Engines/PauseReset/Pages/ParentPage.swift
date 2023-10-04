//
//  ParentPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/11/23.
//

import SpriteKit

class ParentPage: SKNode {
    
    // MARK: - Properties
    
    static let padding: CGFloat = 40
    var nodeName = "parentPage"
    var contentSize: CGSize
    var titleText: String
    
    var contentNode: SKSpriteNode!
    var titleLabel: SKLabelNode!
    var superScene: SKScene?

    
    // MARK: - Initialization
    
    init(contentSize: CGSize, titleText: String) {
        self.contentSize = contentSize
        self.titleText = titleText

        super.init()

        name = nodeName
        
        setupSprites()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        contentNode = SKSpriteNode(color: .clear, size: contentSize)
        contentNode.anchorPoint = CGPoint(x: 0, y: 1)
        contentNode.position = CGPoint(x: -contentSize.width / 2, y: contentSize.height / 2)
        
        titleLabel = SKLabelNode(text: titleText.uppercased())
        titleLabel.position = CGPoint(x: contentSize.width / 2, y: -ParentPage.padding)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .top
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeLarge
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.addHeavyDropShadow()
        titleLabel.zPosition = 10
        
        addChild(contentNode)
        contentNode.addChild(titleLabel)
    }
    
    deinit {
        print("deinit ParentPage: \(nodeName)")
    }
    
    
    // MARK: - Touch Functions
    
    func touchDown(for touches: Set<UITouch>) {
        //Implement in subclass
    }
    
    func touchUp() {
        //Implement in subclass
    }
    
    func touchMove(for touches: Set<UITouch>) {
        //Implement in subclass
    }
    
    func touchNode(for touches: Set<UITouch>) {
        //Implement in subclass
    }
}
