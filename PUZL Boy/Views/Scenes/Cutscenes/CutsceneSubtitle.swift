//
//  CutsceneSubtitle.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/23/24.
//

import SpriteKit

class CutsceneSubtitle: SKLabelNode {
    
    // MARK: - Properties

    private var subtitleString: String
    private var subtitleColor: UIColor
    private var subtitlePosition: CGPoint
    
    
    // MARK: - Initialization
    
    init(text: String, color: UIColor, position: CGPoint) {
        self.subtitleString = text.uppercased()
        self.subtitleColor = color
        self.subtitlePosition = position
        
        super.init()

        setupNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNode() {
        text = subtitleString
        position = subtitlePosition
        fontColor = subtitleColor
        fontName = UIFont.gameFont
        fontSize = UIFont.gameFontSizeLarge
        alpha = 0
        zPosition = K.ZPosition.itemsAndEffects + 10
        addHeavyDropShadow()
    }
    
    
    // MARK: - Functions
    
    func showSubtitle(to parentNode: SKNode, waitDuration: TimeInterval, fadeDuration: TimeInterval = 1, delay: TimeInterval = 0) {
        removeFromParent()
        parentNode.addChild(self)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ]))
    }
}
