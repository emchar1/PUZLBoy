//
//  SpeechOverlaySprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/31/23.
//

import SpriteKit

class SpeechOverlaySprite: SKNode {

    // MARK: - Properties
    
    private let padding: CGFloat = 20
    private let nodeHeight: CGFloat = 200
    private var text: String
    
    //Animation Properties
    private let animationSpeedOrig: TimeInterval = 0.04
    private var animationSpeed: TimeInterval
    private var animationIndex = 0
    private var timer = Timer()
    private var dispatchWorkItem = DispatchWorkItem(block: {})
    private var completion: (() -> Void)?
    
    private var backgroundNode: SKShapeNode!
    private var speechNode: SKLabelNode!
    
    
    // MARK: - Initialization

    override init() {
        self.text = ""
        self.animationSpeed = animationSpeedOrig

        super.init()
        
        self.position = CGPoint(x: padding, y: K.ScreenDimensions.size.height - K.ScreenDimensions.topMargin - padding)
        self.zPosition = K.ZPosition.speechBubble
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        dispatchWorkItem.cancel() //MUST DO THIS!! Otherwise app crashes if you skip intro while this is playing. BUGFIX# 230910E01
        
        print("deinit SpeechOverlaySprite. Cancelled DispatchWorkItem.")
    }
    
    private func setupNodes() {
        backgroundNode = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.size.width - 2 * padding, height: nodeHeight))
        backgroundNode.fillColor = .clear
        backgroundNode.lineWidth = 0
        
        speechNode = SKLabelNode(text: text)
        speechNode.fontName = UIFont.chatFont
        speechNode.fontSize = UIFont.chatFontSizeLarge
        speechNode.fontColor = .white
        speechNode.position = .zero
        speechNode.numberOfLines = 0
        speechNode.preferredMaxLayoutWidth = backgroundNode.frame.size.width
        speechNode.horizontalAlignmentMode = .left
        speechNode.verticalAlignmentMode = .top
        speechNode.addDropShadow(shadowOffset: CGPoint(x: -6, y: -6))
        speechNode.zPosition = 5
        
        addChild(backgroundNode)
        backgroundNode.addChild(speechNode)
    }
    
    
    // MARK: - Animation Functions
    
    func setText(text: String, superScene: SKScene, completion: (() -> Void)?) {
        self.text = text
        speechNode.text = ""
        animationIndex = 0
        self.completion = completion

        superScene.addChild(self)
        
        beginAnimation()
    }
    
    private func beginAnimation() {
        animateText()
    }
        
    private func animateText() {
        timer = Timer.scheduledTimer(timeInterval: animationSpeed,
                                     target: self,
                                     selector: #selector(animateTextHelper(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func animateTextHelper(_ sender: Timer) {
        guard animationIndex < self.text.count else {
            timer.invalidate()
            
            endAnimation()

            return
        }
        
        let animationPause: TimeInterval = 0.75
        let delimiterPause: Character = "|"
        let delimiterClear: Character = "/"
        let speechBubbleChar = self.text[self.text.index(self.text.startIndex, offsetBy: animationIndex)]
        
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
            speechNode.text! += "\(speechBubbleChar)"
            
            //Clears the text bubble, like it's starting over
            if speechBubbleChar == delimiterClear {
                speechNode.text = ""
            }
        }
    }
    
    private func endAnimation() {
        completion?()
    }

    
}
