//
//  OfflinePlaySprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/6/23.
//

import SpriteKit

class OfflinePlaySprite: SKNode {

    // MARK: - Properties
    
    private var sprite: SKLabelNode!
//    private var memoryTest: [Int]

    
    // MARK: - Initialization
    
    override init() {
        // FIXME: - Uncomment to test Memory Size
//        memoryTest = Array(repeating: 0, count: 10000000)
        
        super.init()
        
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit OfflinePlaySprite")
    }
    
    private func setupSprites() {
        sprite = SKLabelNode(text: "OFFLINE PLAY")
        sprite.horizontalAlignmentMode = .center
        sprite.verticalAlignmentMode = .top
        sprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height - K.ScreenDimensions.topMargin - 59)
        sprite.fontName = UIFont.gameFont
        sprite.fontSize = UIFont.gameFontSizeSmall
        sprite.fontColor = .yellow
        sprite.zPosition = K.ZPosition.display
        sprite.addDropShadow()
        
        addChild(sprite)
    }
    
    
    // MARK: - Functions
    
    func animateSprite() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])))
    }
    
    func deanimateSprite() {
        removeAllActions()
        removeFromParent()
    }
}
