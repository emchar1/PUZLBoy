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
    var titleLabel: ParentTitleLabel!
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
        
        titleLabel = ParentTitleLabel(contentSize: contentSize, titleText: titleText)

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
