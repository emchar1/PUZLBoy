//
//  SpeechBubbleSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/12/23.
//

import SpriteKit

class SpeechBubbleSprite: SKNode {
    
    // MARK: - Properties
    
    //Speech Bubble Properties
    private let bubbleDimensions = CGSize(width: 512, height: 384)
    private var bubbleText: String
    private var bubbleWidth: CGFloat
    private var bubblePosition: CGPoint
    
    //Speech Animation Properties
    private let animationSpeedOrig: TimeInterval = 0.08
    private var animationSpeed: TimeInterval
    private var animationIndex = 0
    private var animationTimer = Timer()

    private var bubbleSprite: SKSpriteNode!
    private var textSprite: SKLabelNode!
    
    
    // MARK: - Initialization
    
    init(text: String, width: CGFloat = 512, position: CGPoint = .zero) {
        self.bubbleText = text
        self.bubbleWidth = width
        self.bubblePosition = position
        self.animationSpeed = animationSpeedOrig
        
        super.init()
        
        setupSprites()
        beginAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    private func setupSprites() {
        let paddingPercentage: CGFloat = 0.9
        let bubbleHeight = (bubbleWidth / bubbleDimensions.width) * bubbleDimensions.height
        
        bubbleSprite = SKSpriteNode(imageNamed: "speechBubble")
//        bubbleSprite.anchorPoint = CGPoint(x: bubbleBorder, y: 1 - bubbleBorder)
//        bubbleSprite.position = CGPoint(x: bubbleWidth / 2, y: -bubbleHeight / 2)
        bubbleSprite.size = CGSize(width: bubbleWidth, height: bubbleHeight)
        bubbleSprite.setScale(0)
        
        textSprite = SKLabelNode(text: "")
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSize
        textSprite.fontColor = .black
        textSprite.position = paddingPercentage * CGPoint(x: -bubbleWidth / 2, y: bubbleHeight / 2)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = bubbleSprite.size.width * paddingPercentage
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.zPosition = 5
        
        position = bubblePosition
        zPosition = K.ZPosition.speechBubble
        
        addChild(bubbleSprite)
        bubbleSprite.addChild(textSprite)
    }
    
    
    // MARK: - Functions
    
    func setText(text: String) {
        self.bubbleText = text
        
        beginAnimation()
    }
    
    private func beginAnimation() {
        bubbleSprite.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.9, duration: 0.25),
            SKAction.scale(to: 1, duration: 0.5)
        ])) { [unowned self] in
            animationTimer = Timer.scheduledTimer(timeInterval: animationSpeed,
                                                  target: self,
                                                  selector: #selector(animateText(_:)),
                                                  userInfo: nil,
                                                  repeats: true)
            
        }
    }
    
    @objc private func animateText(_ sender: Timer) {
        if animationIndex < bubbleText.count {
            let speechBubbleChar = bubbleText[bubbleText.index(bubbleText.startIndex, offsetBy: animationIndex)]
            
            textSprite.text! += "\(speechBubbleChar)"
            
            animationIndex += 1
        }
        else {
            animationTimer.invalidate()
            removeFromParent()
        }
    }
    
    
}
