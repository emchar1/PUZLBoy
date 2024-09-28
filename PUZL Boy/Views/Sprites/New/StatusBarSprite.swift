//
//  StatusBarSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/24.
//

import SpriteKit

class StatusBarSprite: SKNode {
    
    // MARK: - Properties
    
    static let statusBarName = "StatusBarSprite"
    private let containerLineWidth: CGFloat = 6
    private let cornerRadius: CGFloat = 16
    private let barSize: CGSize
    private let statusString: String
    private let backgroundPosition: CGPoint
    private var currentPercentage: CGFloat = 1

    //SKNode
    private var backgroundNode: SKShapeNode!
    private var containerNode: SKShapeNode!
    private var containerFrameNode: SKShapeNode!
    private var statusNode: SKSpriteNode!
    private var statusLabel: SKLabelNode!
    
    
    // MARK: - Initialization
    
    init(label: String, shouldHide: Bool, position: CGPoint = .zero, size: CGSize = CGSize(width: K.ScreenDimensions.size.width / 2, height: 44)) {
        self.statusString = label
        self.backgroundPosition = position
        self.barSize = size
        
        super.init()
        
        alpha = shouldHide ? 0 : 1
        name = StatusBarSprite.statusBarName + statusString
        
        setupNodes()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit StatusBarSprite - \(statusString)")
    }
    
    private func setupNodes() {
        backgroundNode = SKShapeNode(rectOf: CGSize(width: barSize.width, height: barSize.height + 140))
        backgroundNode.position = backgroundPosition
        backgroundNode.lineWidth = 0
        
        containerNode = SKShapeNode(rectOf: CGSize(width: barSize.width, height: barSize.height), cornerRadius: cornerRadius)
        containerNode.fillColor = .darkGray
        containerNode.fillTexture = SKTexture(image: UIImage.gradientTextureLoadingContainer)
        containerNode.lineWidth = 0
        containerNode.zPosition = 1
        
        containerFrameNode = SKShapeNode(rectOf: CGSize(width: barSize.width, height: barSize.height), cornerRadius: cornerRadius)
        containerFrameNode.fillColor = .clear
        containerFrameNode.lineWidth = containerLineWidth
        containerFrameNode.strokeColor = .white
        containerFrameNode.zPosition = 3
        
        statusNode = SKSpriteNode(texture: SKTexture(image: UIImage.gradientLoadingBar))
        statusNode.size = CGSize(width: barSize.width, height: barSize.height - containerLineWidth)
        statusNode.color = .green
        statusNode.colorBlendFactor = 1
        statusNode.zPosition = 2
        
        statusLabel = SKLabelNode(text: statusString.uppercased())
        statusLabel.position = CGPoint(x: -barSize.width / 2 + 10, y: barSize.height)
        statusLabel.fontName = UIFont.gameFont
        statusLabel.fontSize = UIFont.gameFontSizeMedium
        statusLabel.fontColor = .yellow
        statusLabel.horizontalAlignmentMode = .left
        statusLabel.zPosition = 3
        statusLabel.addDropShadow()
    }
    
    
    // MARK: - Functions
    
    /**
     Adds the whole node and children to the parent node.
     */
    func addToParent(_ parentNode: SKNode) {
        backgroundNode.addChild(containerNode)
        backgroundNode.addChild(containerFrameNode)
        backgroundNode.addChild(statusNode)
        backgroundNode.addChild(statusLabel)

        addChild(backgroundNode)
        
        parentNode.addChild(self)
    }
    
    /**
     Animates to alpha = 1 the entire status bar.
     */
    func showStatus() {
        run(SKAction.fadeIn(withDuration: 1))
    }

    /**
     Animates to alpha = 0 the entire status bar.
     */

    func hideStatus() {
        run(SKAction.fadeOut(withDuration: 1))
    }
    
    /**
     Animates to alpha = 0, and removes from the parentNode, the entire status bar.
     */
    func removeStatus() {
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ]))
    }
    
    /**
     Animates to the specified percentage, and updates the percentage property.
     **/
    func animateAndUpdate(percentage: CGFloat) {
        let animationDuration: TimeInterval = 0.25
        let animationGroup = SKAction.group([
            SKAction.scaleX(to: percentage, duration: animationDuration),
            SKAction.moveTo(x: -barSize.width * (1 - percentage) / 2, duration: animationDuration),
            SKAction.colorize(with: UIColor(red: percentage > 0.5 ? 2 * (1 - percentage) : 1,
                                            green: percentage < 0.5 ? 2 * percentage : 1,
                                            blue: 0, alpha: 1), colorBlendFactor: 1, duration: animationDuration)
        ])
        
        statusNode.run(animationGroup)
        
        updatePercentage(percentage)
    }
    
    /**
     Updates the percentage.
     */
    func updatePercentage(_ newValue: CGFloat) {
        currentPercentage = newValue.clamp(min: 0, max: 1)
    }
    
    /**
     Returns the percentage.
     */
    func getPercentage() -> CGFloat {
        return currentPercentage
    }
    
    
}
