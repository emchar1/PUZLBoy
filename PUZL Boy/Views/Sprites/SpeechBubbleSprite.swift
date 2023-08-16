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
    private let bubbleDimensionsOrig = CGSize(width: 512, height: 384)
    private(set) var bubbleDimensions: CGSize
    private var bubbleText: String
    private var shouldFlipTail: Bool
    
    //Animation Properties
    private let animationSpeedOrig: TimeInterval = 0.08
    private var animationSpeed: TimeInterval
    private var animationIndex = 0
    private var timer = Timer()
    private var dispatchWorkItem = DispatchWorkItem(block: {})
    private var completion: (() -> Void)?

    //Nodes
    private var backgroundSprite: SKShapeNode!
    private var bubbleSprite: SKSpriteNode!
    private var textSprite: SKLabelNode!
    
    
    // MARK: - Initialization
    
    init(width: CGFloat = 512, position: CGPoint = .zero, shouldFlipTail: Bool = false) {
        self.bubbleText = ""
        self.shouldFlipTail = shouldFlipTail
        self.bubbleDimensions = CGSize(width: width, height: (width / bubbleDimensionsOrig.width) * bubbleDimensionsOrig.height)
        self.animationSpeed = animationSpeedOrig
        
        super.init()
        
        self.position = position
        self.zPosition = K.ZPosition.speechBubble

        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit SpeechBubbleSprite")
    }
    
    private func setupSprites() {
        let paddingPercentage: CGFloat = 0.9
        
        backgroundSprite = SKShapeNode(rectOf: bubbleDimensions)
        backgroundSprite.fillColor = .clear
        backgroundSprite.lineWidth = 0
        backgroundSprite.setScale(0)
        
        bubbleSprite = SKSpriteNode(imageNamed: "speechBubble")
        bubbleSprite.size = bubbleDimensions
        bubbleSprite.xScale = shouldFlipTail ? -1 : 1
        
        textSprite = SKLabelNode(text: "")
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSize
        textSprite.fontColor = .black
        textSprite.position = paddingPercentage * CGPoint(x: -bubbleDimensions.width / 2, y: bubbleDimensions.height / 2)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = bubbleDimensions.width * paddingPercentage
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.zPosition = 5
        
        addChild(backgroundSprite)
        backgroundSprite.addChild(bubbleSprite)
        backgroundSprite.addChild(textSprite)
    }
    
    
    // MARK: - Animation Functions
    
    func setText(text: String, superScene: SKScene, completion: (() -> Void)?) {
        bubbleText = text
        textSprite.text = ""
        animationIndex = 0
        self.completion = completion

        superScene.addChild(self)
        
        beginAnimation()
    }
    
    private func beginAnimation() {
        AudioManager.shared.playSound(for: "speechbubble")
        
        backgroundSprite.run(SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.25),
            SKAction.scale(to: 0.85, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2)
        ])) { [unowned self] in
            animateText()
        }
    }
        
    private func animateText() {
        timer = Timer.scheduledTimer(timeInterval: animationSpeed,
                                     target: self,
                                     selector: #selector(animateTextHelper(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func animateTextHelper(_ sender: Timer) {
        guard animationIndex < bubbleText.count else {
            timer.invalidate()
            
            endAnimation()

            return
        }
        
        let animationPause: TimeInterval = 0.25
        let delimiterPause: Character = "|"
        let delimiterClear: Character = "/"
        let speechBubbleChar = bubbleText[bubbleText.index(bubbleText.startIndex, offsetBy: animationIndex)]
        
        animationIndex += 1
        
        if speechBubbleChar == delimiterPause {
            timer.invalidate()
            
            dispatchWorkItem = DispatchWorkItem(block: { [unowned self] in
                animateText()
            })
            
            //Adds a little pause when it comes across the delimiterPause character.
            DispatchQueue.main.asyncAfter(deadline: .now() + animationPause, execute: dispatchWorkItem)
        }
        else {
            textSprite.text! += "\(speechBubbleChar)"
            
            //Clears the text bubble, like it's starting over
            if speechBubbleChar == delimiterClear {
                textSprite.text = ""
            }
        }
    }
    
    private func endAnimation() {
        backgroundSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 0, duration: 0.2)
        ])) { [unowned self] in
            removeFromParent()
            
            completion?()
        }
    }

    
}
