//
//  OfflinePlaySprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/6/23.
//

import SpriteKit

class OfflinePlaySprite: SKNode {

    // MARK: - Properties
    
    var shouldShowOfflinePlay: Bool
    private var sprite: SKLabelNode

    
    // MARK: - Initialization
    
    init(shouldShowOfflinePlay: Bool) {
        self.shouldShowOfflinePlay = shouldShowOfflinePlay

        sprite = SKLabelNode(text: "OFFLINE PLAY")
        sprite.horizontalAlignmentMode = .center
        sprite.verticalAlignmentMode = .top
        sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height - K.ScreenDimensions.topMargin - 59)
        sprite.fontName = UIFont.gameFont
        sprite.fontSize = UIFont.gameFontSizeSmall
        sprite.fontColor = .yellow
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func refreshStatus() {
        if shouldShowOfflinePlay {
            showOfflinePlay()
        }
        else {
            hideOfflinePlay()
        }
    }
    
    func showOfflinePlay() {
        //MUST reset everything first!
        hideOfflinePlay()
        
        //Then can proceed as usual
        addChild(sprite)

        sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 1.5),
            SKAction.fadeIn(withDuration: 1.5)
        ])))
    }
    
    func hideOfflinePlay() {
        sprite.removeFromParent()
        sprite.removeAllActions()
    }
}
