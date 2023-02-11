//
//  NumMovesSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/9/23.
//

import SpriteKit

class NumMovesSprite: SKNode {
    
    // MARK: - Properties
    
    private var sprite: SKShapeNode
    private var bigText: SKLabelNode
    private var littleText: SKLabelNode

    
    // MARK: - Initialization

    init(numMoves: Int, position: CGPoint) {
        sprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale,
                                            height: K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale))
        sprite.lineWidth = 0
        sprite.zPosition = K.ZPosition.messagePrompt

        bigText = SKLabelNode(text: "\(numMoves)")
        bigText.fontName = UIFont.chatFont
        bigText.fontSize = UIFont.gameFontSizeExtraLarge
        bigText.fontColor = UIFont.chatFontColor
        bigText.setScale(4)
        
        littleText = SKLabelNode(text: "Moves")
        littleText.fontName = UIFont.chatFont
        littleText.fontSize = UIFont.gameFontSizeExtraLarge
        littleText.fontColor = UIFont.chatFontColor
        littleText.position.y -= 140
        
        super.init()
        
        self.position = position

        addChild(sprite)
        sprite.addChild(bigText)
        sprite.addChild(littleText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func play(completion: @escaping (() -> Void)) {
        let animationGroup = SKAction.group([
            SKAction.move(to: CGPoint(x: position.x, y: position.y + 250), duration: 1),
            SKAction.fadeAlpha(to: 0, duration: 1)
        ])
        
        let animationSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            animationGroup
        ])
        
        self.run(animationSequence, completion: completion)
    }
}
