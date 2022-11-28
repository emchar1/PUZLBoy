//
//  ContinueScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/27/22.
//

import SpriteKit

class ContinueScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(color: .yellow, size: CGSize(width: K.iPhoneWidth, height: K.height))
        
        addChild(background)
    }
}
