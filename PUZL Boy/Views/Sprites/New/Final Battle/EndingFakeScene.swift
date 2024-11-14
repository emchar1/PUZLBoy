//
//  EndingFakeScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/12/24.
//

import SpriteKit

class EndingFakeScene: SKScene {
    
    // MARK: - Properties
    
    private var fadeNode: SKShapeNode!
    private var letterbox: LetterboxSprite!
    
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
        backgroundColor = .white
        
        fadeNode = SKShapeNode(rectOf: size)
        fadeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        fadeNode.fillColor = .black.lightenColor(factor: 2)
        fadeNode.lineWidth = 0
        fadeNode.alpha = 0
        fadeNode.zPosition = K.ZPosition.fadeTransitionNode
        
        letterbox = LetterboxSprite(color: .black, height: size.height + 40)
        
        titleLabel = SKLabelNode(text: "CONGRATULATIONS!!")
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 3/4)
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeExtraLarge
        titleLabel.fontColor = .orange.lightenColor(factor: 12)
        titleLabel.alpha = 0
        titleLabel.addHeavyDropShadow()
        titleLabel.updateShadowColor(.lightGray)
        
        messageLabel = SKLabelNode(text: "You have successfully completed 500 levels of mind-bending puzzles. But the game isn't over yet...\n\nAs PUZL Boy and the Elders make their way to Earth's core, they must confront Magmoor in a final showdown to rescue their friends, Marlin and Princess Olivia, and prevent the Mad Mystic from unleashing the Age of Ruin.\n\nAre you ready to face the ultimate challenge and save the universe from total destruction?")
        messageLabel.position = CGPoint(x: size.width / 2, y: titleLabel.position.y - UIFont.gameFontSizeExtraLarge)
        messageLabel.fontName = UIFont.chatFont
        messageLabel.fontSize = UIFont.chatFontSizeLarge
        messageLabel.fontColor = titleLabel.fontColor
        messageLabel.preferredMaxLayoutWidth = size.width * 0.8
        messageLabel.verticalAlignmentMode = .top
        messageLabel.numberOfLines = 0
        messageLabel.alpha = 0
        messageLabel.addDropShadow()
        messageLabel.updateShadowColor(.lightGray)
                
        //Yes. | YES!!!!!
        //Be prepared!

//        titleLabel = SKLabelNode(text: "GAME OVER!!")
//        messageLabel = SKLabelNode(text: "...or is it??\n\nIn a dazzling display of unbridled power, Princess Olivia transforms into the mighty Dragon Queen to defeat Magmoor once and for all. Unfortunately, it is not enough to stop the Malevolent Mystic. With the universe in disarray, PUZL Boy must make one final desperate attempt to reverse the spell and restore balance to the realms.\n\nAre you ready to re-enter the PUZZLE REALM one last time and save the world?")
//        //Let's do it!!! | Fine, I guess..
//        //Let's begin!
    }
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(fadeNode)
        addChild(letterbox)
        
        addChild(titleLabel)
        addChild(messageLabel)
    }
    
    func animateScene(completion: (() -> Void)?) {
        let fadeDuration: TimeInterval = 2
        
        fadeNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                backgroundColor = fadeNode.fillColor
            },
            SKAction.removeFromParent()
        ]))
        
        titleLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: fadeDuration),
            SKAction.fadeIn(withDuration: fadeDuration)
        ]))
        
        messageLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: fadeDuration * 2),
            SKAction.fadeIn(withDuration: fadeDuration * 2)
        ]))
        
        letterbox.show(duration: fadeDuration * 4, delay: fadeDuration * 8, completion: completion)
    }
}
