//
//  ParentTitleLabel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/7/23.
//

import SpriteKit

class ParentTitleLabel: SKLabelNode {
    
    // MARK: - Properties
    
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize, titleText: String) {
        super.init()
        
        text = titleText.uppercased()
        position = CGPoint(x: contentSize.width / 2, y: -ParentPage.padding)
        horizontalAlignmentMode = .center
        verticalAlignmentMode = .top
        fontName = UIFont.gameFont
        fontSize = UIFont.gameFontSizeLarge
        fontColor = UIFont.gameFontColor
        name = "titleLabel\(titleText)"
        zPosition = 10
        addHeavyDropShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func setText(_ newText: String) {
        text = newText.uppercased()
        updateShadow()
    }
}
