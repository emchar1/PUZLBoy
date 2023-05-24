//
//  HowToPlayPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/10/23.
//

import SpriteKit

class HowToPlayPage: ParentPage {
    
    // MARK: - Properties
    
    private(set) var tableView: HowToPlayTableView!
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize, level: Int) {
        super.init(contentSize: contentSize, titleText: "How To Play")

        self.nodeName = "howToPlayPage"
        self.contentSize = contentSize
        tableView = HowToPlayTableView(frame: .zero, style: .grouped)
        name = nodeName
        
        addChild(contentNode)
        contentNode.addChild(super.titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
