//
//  LoadingSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/24/23.
//

import SpriteKit

class LoadingSprite: SKNode {
    
    // MARK: - Properties
    
    static let loadingDuration: TimeInterval = TimeInterval.random(in: 0.5...7)
    
    private let statusBarHeight: CGFloat = 44
    private let statusBarLength: CGFloat = K.ScreenDimensions.iPhoneWidth * 0.75
    private let statusBarLineWidth: CGFloat = 6
    private let cornerRadius: CGFloat = 16
    private let initialProgress: CGFloat = 10

    private var sprite: SKShapeNode
    private var statusSprite: SKShapeNode
    private var loadingLabel: SKLabelNode
    
    static var funnyQuotes: [String] = [
        "World domination.",
        "Eggs are so freakin' expensive!",
        "Add me on TikTok: @puzlboy",
        "🏳️‍🌈",
        "Why am I soooo tired?",
        "He loves me, he loves me not.",
        "Tell all your friends about PUZL Boy!"
    ]

    
    // MARK: - Initialization
    
    init(position: CGPoint) {
        sprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: 200))
        sprite.fillColor = .clear
        sprite.lineWidth = 0
        sprite.position = position
        
        let statusGradient: UIImage = UIImage.createGradientImage(startPoint: CGPoint(x: 0.5, y: 0.5), endPoint: CGPoint(x: 0.5, y: 1.0),
                                                                  topColorWhiteValue: 250, bottomColorWhiteValue: 200)
        statusSprite = SKShapeNode(rectOf: CGSize(width: initialProgress, height: statusBarHeight - statusBarLineWidth))
        statusSprite.fillColor = .green
        statusSprite.fillTexture = SKTexture(image: statusGradient)
        statusSprite.lineWidth = 0
        statusSprite.position = CGPoint(x: -(statusBarLength - statusBarLineWidth - initialProgress) / 2, y: 0)
        
        loadingLabel = SKLabelNode(text: "Loading...")
        loadingLabel.fontName = UIFont.chatFont
        loadingLabel.fontSize = UIFont.gameFontSizeSmall
        loadingLabel.fontColor = UIFont.chatFontColor
        loadingLabel.horizontalAlignmentMode = .left
        loadingLabel.position = CGPoint(x: -statusBarLength / 2 + 10, y: -statusBarHeight - 20)

        super.init()
        
        let statusBarGradient: UIImage = UIImage.createGradientImage(startPoint: CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint(x: 0.5, y: 1.0),
                                                                     topColorWhiteValue: 0, bottomColorWhiteValue: 150)
        let statusBar = SKShapeNode(rectOf: CGSize(width: statusBarLength, height: statusBarHeight), cornerRadius: cornerRadius)
        statusBar.fillColor = .darkGray
        statusBar.fillTexture = SKTexture(image: statusBarGradient)
        statusBar.lineWidth = 0
        
        let statusBarFrame = SKShapeNode(rectOf: CGSize(width: statusBarLength, height: statusBarHeight), cornerRadius: cornerRadius)
        statusBarFrame.fillColor = .clear
        statusBarFrame.lineWidth = statusBarLineWidth
        statusBarFrame.strokeColor = .white
        
        addChild(sprite)
        sprite.addChild(statusBar)
        sprite.addChild(statusSprite)
        sprite.addChild(statusBarFrame)
        sprite.addChild(loadingLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func animate() {
        let animationGroup = SKAction.group([
            SKAction.scaleX(to: statusBarLength / initialProgress, duration: LoadingSprite.loadingDuration),
            SKAction.moveTo(x: 0, duration: LoadingSprite.loadingDuration)
        ])
        
        statusSprite.run(animationGroup)
        
        
        let animateLabel: [SKAction] = [
            SKAction.run { [unowned self] in loadingLabel.text = "Authenticating to Game Center..." },
            SKAction.run { [unowned self] in loadingLabel.text = "Loading assets..." },
            SKAction.run { [unowned self] in loadingLabel.text = "Building levels..." },
            SKAction.run { [unowned self] in loadingLabel.text = "Rendering animations..." },
            SKAction.run { [unowned self] in loadingLabel.text = "Creating gameboard..." },
            SKAction.run { [unowned self] in loadingLabel.text = "Fetching last saved state..." },
            SKAction.run { [unowned self] in loadingLabel.text = LoadingSprite.funnyQuotes.randomElement() },
            SKAction.run { [unowned self] in loadingLabel.text = "Preparing game scenes..." }
        ]
        
        let minDuration: TimeInterval = 0.1
        let maxDuration = LoadingSprite.loadingDuration / TimeInterval(animateLabel.count / 2)
        let sequence = SKAction.sequence([
            animateLabel[0], SKAction.wait(forDuration: TimeInterval.random(in: minDuration...maxDuration)),
            animateLabel[1], SKAction.wait(forDuration: TimeInterval.random(in: minDuration...maxDuration)),
            animateLabel[2], SKAction.wait(forDuration: TimeInterval.random(in: minDuration...maxDuration)),
            animateLabel[3], SKAction.wait(forDuration: TimeInterval.random(in: minDuration...maxDuration)),
            animateLabel[4], SKAction.wait(forDuration: TimeInterval.random(in: minDuration...maxDuration)),
            animateLabel[5], SKAction.wait(forDuration: TimeInterval.random(in: minDuration...maxDuration)),
            animateLabel[6], SKAction.wait(forDuration: maxDuration),
            animateLabel[7]
        ])
        
        loadingLabel.run(sequence)
    }
}
