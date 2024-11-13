//
//  EndingFakeScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/12/24.
//

import SpriteKit

class EndingFakeScene: SKScene {
    
    // MARK: - Properties
    
    private var titleLabel: SKLabelNode!
    private var messageLabel: SKLabelNode!
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        titleLabel = SKLabelNode(text: "Congratulations!!")
        messageLabel = SKLabelNode(text: "Thank you for playing PUZL Boy! You have successfully completed 500 levels of dungeon torture Or is it?? No it's not. ")
    }
}
