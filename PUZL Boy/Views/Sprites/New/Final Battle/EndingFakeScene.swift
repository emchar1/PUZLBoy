//
//  EndingFakeScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/12/24.
//

import SpriteKit

class EndingFakeScene: SKScene {
    
    // MARK: - Properties
    
    private var letterbox: LetterboxSprite!
    private var tapPointerEngine: TapPointerEngine!
    private var fadeNode: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var messageLabel: SKLabelNode!
    
    private var timer: Timer
    private let titleText: String
    private let messageText: String
    private let messageSpeed: TimeInterval = 0.04
    private var messageIndex: Int = 0
    
    
    // MARK: - Initialization
    
    init(size: CGSize, titleText: String, messageText: String) {
        self.timer = Timer()
        self.titleText = titleText
        self.messageText = messageText
        
        super.init(size: size)
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("EndingFakeScene deinit")
    }
    
    private func cleanupScene() {
        letterbox = nil
        tapPointerEngine = nil
    }
    
    private func setupNodes() {
        backgroundColor = .white
        
        fadeNode = SKShapeNode(rectOf: size)
        fadeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        fadeNode.fillColor = .black.lightenColor(factor: 3)
        fadeNode.lineWidth = 0
        fadeNode.alpha = 0
        fadeNode.zPosition = K.ZPosition.fadeTransitionNode
        
        letterbox = LetterboxSprite(color: .black, height: size.height + 40)
        tapPointerEngine = TapPointerEngine()
        
        titleLabel = SKLabelNode(text: titleText.uppercased())
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 3/4)
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeExtraLarge
        titleLabel.fontColor = .orange.lightenColor(factor: 12)
        titleLabel.alpha = 0
        titleLabel.addHeavyDropShadow()
        titleLabel.updateShadowColor(.lightGray)
        
        messageLabel = SKLabelNode(text: "")
        messageLabel.position = CGPoint(x: size.width * 0.1, y: titleLabel.position.y - UIFont.gameFontSizeExtraLarge)
        messageLabel.fontName = UIFont.chatFont
        messageLabel.fontSize = UIFont.chatFontSizeLarge
        messageLabel.fontColor = titleLabel.fontColor
        messageLabel.preferredMaxLayoutWidth = size.width * 0.8
        messageLabel.verticalAlignmentMode = .top
        messageLabel.horizontalAlignmentMode = .left
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
    }
    
    func animateScene(music: String, completion: (() -> Void)?) {
        let fadeDuration: TimeInterval = 2
        let readMessageDuration: TimeInterval = fadeDuration * 2 + messageSpeed * TimeInterval(messageText.count) + 6.0
        let musicDuration: TimeInterval = readMessageDuration + fadeDuration * 2
        let musicStart: TimeInterval = max((AudioManager.shared.getAudioItem(filename: music)?.player.duration ?? 0) - musicDuration - 1, 0)

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
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                timer = Timer.scheduledTimer(timeInterval: messageSpeed,
                                             target: self,
                                             selector: #selector(animateMessage(_:)),
                                             userInfo: nil,
                                             repeats: true)
            },
            SKAction.fadeIn(withDuration: fadeDuration)
        ]))
        
        letterbox.show(duration: fadeDuration * 2, delay: readMessageDuration, completion: nil)
                
        AudioManager.shared.playSound(for: music, currentTime: musicStart, fadeIn: fadeDuration * 2, shouldLoop: false)

        run(SKAction.wait(forDuration: musicDuration + fadeDuration)) { [weak self] in
            self?.cleanupScene()
            completion?()
        }
    }
    
    
    // MARK: - Helper Functions
    
    @objc private func animateMessage(_ sender: Timer) {
        if messageIndex < messageText.count {
            let messageChar = messageText[messageText.index(messageText.startIndex, offsetBy: messageIndex)]
            
            messageLabel.text! += "\(messageChar)"
            messageLabel.updateShadow()
            
            messageIndex += 1
        }
        else {
            timer.invalidate()
        }
    }
    
    
}
