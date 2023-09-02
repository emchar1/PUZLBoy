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

    init(numMoves: Int, position: CGPoint, isPartyLevel: Bool) {
        sprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale,
                                            height: K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale))
        sprite.lineWidth = 0
        sprite.zPosition = K.ZPosition.messagePrompt

        bigText = SKLabelNode(text: "\(numMoves)")
        bigText.fontName = UIFont.chatFont
        bigText.fontSize = UIFont.chatFontSizeExtraLarge
        bigText.fontColor = UIFont.chatFontColor
        bigText.setScale(4)
        bigText.position.y += UIDevice.isiPad ? 200 : 0
        bigText.zPosition = 10
        bigText.addDropShadow()
        
        littleText = SKLabelNode(text: isPartyLevel ? "✨Bonus Level✨" : "Move\(numMoves == 1 ? "" : "s")")
        littleText.fontName = UIFont.chatFont
        littleText.fontSize = UIFont.chatFontSizeExtraLarge
        littleText.fontColor = UIFont.chatFontColor
        littleText.position.y += UIDevice.isiPad ? 200 : 0
        littleText.position.y += isPartyLevel ? 80 : -140
        littleText.zPosition = 10
        littleText.addHeavyDropShadow()
        
        super.init()
        
        self.position = position

        addChild(sprite)

        if !isPartyLevel {
            sprite.addChild(bigText)
        }

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
        
        run(animationSequence, completion: completion)
    }
}
