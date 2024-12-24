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
    static let defaultBarHeight: CGFloat = 44
    private let containerLineWidth: CGFloat = 6
    private let cornerRadius: CGFloat = 16
    private let barSize: CGSize
    private let statusString: String
    private let backgroundPosition: CGPoint
    private var currentPercentage: CGFloat

    //SKNode
    private var backgroundNode: SKShapeNode!
    private var containerNode: SKShapeNode!
    private var containerFrameNode: SKShapeNode!
    private var statusNode: SKSpriteNode!
    private var statusLabel: SKLabelNode!
    
    
    // MARK: - Initialization
    
    init(label: String, shouldHide: Bool, percentage: CGFloat = 1, position: CGPoint = .zero, size: CGSize = CGSize(width: K.ScreenDimensions.size.width / 2, height: StatusBarSprite.defaultBarHeight)) {
        self.statusString = label
        self.backgroundPosition = position
        self.barSize = size
        self.currentPercentage = percentage.clamp(min: 0, max: 1)
        
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
        let padding: CGFloat = 20
        
        backgroundNode = SKShapeNode(rectOf: CGSize(width: barSize.width + 2 * padding, 
                                                    height: barSize.height + UIFont.gameFontSizeMedium + 3 * padding),
                                     cornerRadius: cornerRadius)
        backgroundNode.position = backgroundPosition + CGPoint(x: 0, y: UIFont.gameFontSizeMedium / 2)
        backgroundNode.fillColor = .black
        backgroundNode.lineWidth = 0
        backgroundNode.alpha = 0.75

        containerNode = SKShapeNode(rectOf: barSize, cornerRadius: cornerRadius)
        containerNode.position = backgroundPosition
        containerNode.fillColor = .darkGray
        containerNode.fillTexture = SKTexture(image: UIImage.gradientTextureLoadingContainer)
        containerNode.lineWidth = 0
        containerNode.zPosition = 1
        
        containerFrameNode = SKShapeNode(rectOf: barSize, cornerRadius: cornerRadius)
        containerFrameNode.position = backgroundPosition
        containerFrameNode.fillColor = .clear
        containerFrameNode.lineWidth = containerLineWidth
        containerFrameNode.strokeColor = .white
        containerFrameNode.zPosition = 3
        
        statusNode = SKSpriteNode(texture: SKTexture(image: UIImage.gradientLoadingBar))
        statusNode.position = CGPoint(x: backgroundPosition.x - barSize.width * (1 - currentPercentage) / 2, y: backgroundPosition.y)
        statusNode.size = CGSize(width: barSize.width, height: barSize.height - containerLineWidth)
        statusNode.xScale = currentPercentage
        statusNode.color = getColor(from: currentPercentage)
        statusNode.colorBlendFactor = 1
        statusNode.zPosition = 2
        
        statusLabel = SKLabelNode(text: statusString.uppercased())
        statusLabel.position = backgroundPosition + CGPoint(x: -barSize.width / 2, y: barSize.height / 2 + padding)
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
        addChild(backgroundNode)
        addChild(containerNode)
        addChild(containerFrameNode)
        addChild(statusNode)
        addChild(statusLabel)
        
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
    func removeStatus(flashMaxBravery: Bool, completion: @escaping () -> Void) {
        let blinkCount: Int = 4
        let blinkDuration: TimeInterval = 0.25
        let waitDuration: TimeInterval = flashMaxBravery ? CGFloat(blinkCount) * blinkDuration : 0
        
        if flashMaxBravery {
            statusNode.run(SKAction.repeat(SKAction.sequence([
                SKAction.colorize(with: .yellow, colorBlendFactor: 1, duration: 0),
                SKAction.colorize(with: .cyan, colorBlendFactor: 1, duration: blinkDuration)
            ]), count: blinkCount))
            
            AudioManager.shared.playSound(for: "gemcollectpartylife")
            AudioManager.shared.playSound(for: "boywin")
            Haptics.shared.addHapticFeedback(withStyle: .heavy)
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ]), completion: completion)
    }
    
    /**
     Animates to the specified percentage, and updates the percentage property.
     **/
    func animateAndUpdate(percentage: CGFloat) {
        let animationDuration: TimeInterval = 0.25
        let animationGroup = SKAction.group([
            SKAction.scaleX(to: percentage, duration: animationDuration),
            SKAction.moveTo(x: backgroundPosition.x - barSize.width * (1 - percentage) / 2, duration: animationDuration),
            SKAction.colorize(with: getColor(from: percentage), colorBlendFactor: 1, duration: animationDuration)
        ])
        
        statusNode.run(animationGroup)
        
        updatePercentage(percentage)
    }
    
    /**
     Gets the bar color based on the percentage.
     */
    private func getColor(from percentage: CGFloat) -> UIColor {
        return UIColor(red: percentage > 0.5 ? 2 * (1 - percentage) : 1, green: percentage < 0.5 ? 2 * percentage : 1, blue: 0, alpha: 1)
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
