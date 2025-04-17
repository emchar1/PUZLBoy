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
    static let keyLowPercentageAction = "LowPercentageAction"
    static let defaultBarHeight: CGFloat = 44
    static let lowPercentage: CGFloat = 0.25
    
    private let containerLineWidth: CGFloat = 6
    private let cornerRadius: CGFloat = 16
    private let barSize: CGSize
    private let statusString: String
    private let backgroundPosition: CGPoint
    private var currentPercentage: CGFloat
    private var lowPercentageBlinkDuration: TimeInterval = 0

    //SKNode
    private var backgroundNode: SKShapeNode!
    private var containerNode: SKShapeNode!
    private var containerLowPercentageNode: SKShapeNode!
    private var containerFrameNode: SKShapeNode!
    private var statusNode: SKSpriteNode!
    private var statusLabel: SKLabelNode!
    
    
    // MARK: - Initialization
    
    init(label: String,
         shouldHide: Bool,
         showBackground: Bool,
         percentage: CGFloat = 1,
         position: CGPoint = .zero,
         size: CGSize = CGSize(width: 7/8 * K.ScreenDimensions.size.width * UIDevice.spriteScale, height: StatusBarSprite.defaultBarHeight)) {
        
        self.statusString = label
        self.backgroundPosition = position + CGPoint(x: 0, y: StatusBarSprite.defaultBarHeight)
        self.barSize = size
        self.currentPercentage = percentage.clamp(min: 0, max: 1)
        
        super.init()
        
        alpha = shouldHide ? 0 : 1
        name = StatusBarSprite.statusBarName + statusString
        
        setupNodes(showBackground: showBackground)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit StatusBarSprite - \(statusString)")
    }
    
    private func setupNodes(showBackground: Bool) {
        let padding: CGFloat = 20
        
        backgroundNode = SKShapeNode(rectOf: CGSize(width: barSize.width + 2 * padding, 
                                                    height: barSize.height + UIFont.gameFontSizeMedium + 3 * padding),
                                     cornerRadius: cornerRadius)
        backgroundNode.position = backgroundPosition + CGPoint(x: 0, y: UIFont.gameFontSizeMedium / 2)
        backgroundNode.fillColor = .black
        backgroundNode.lineWidth = 0
        backgroundNode.alpha = showBackground ? 0.75 : 0

        containerNode = SKShapeNode(rectOf: barSize, cornerRadius: cornerRadius)
        containerNode.position = backgroundPosition
        containerNode.fillColor = .darkGray
        containerNode.fillTexture = SKTexture(image: UIImage.gradientTextureLoadingContainer)
        containerNode.lineWidth = 0
        containerNode.zPosition = 1
        
        containerLowPercentageNode = SKShapeNode(rectOf: barSize, cornerRadius: cornerRadius)
        containerLowPercentageNode.position = backgroundPosition
        containerLowPercentageNode.fillColor = .systemPink
        containerLowPercentageNode.lineWidth = 0
        containerLowPercentageNode.alpha = 0
        containerLowPercentageNode.zPosition = 2
        
        containerFrameNode = SKShapeNode(rectOf: barSize, cornerRadius: cornerRadius)
        containerFrameNode.position = backgroundPosition
        containerFrameNode.fillColor = .clear
        containerFrameNode.lineWidth = containerLineWidth
        containerFrameNode.strokeColor = .white
        containerFrameNode.zPosition = 4
        
        statusNode = SKSpriteNode(texture: SKTexture(image: UIImage.gradientLoadingBar))
        statusNode.position = CGPoint(x: backgroundPosition.x - barSize.width * (1 - currentPercentage) / 2, y: backgroundPosition.y)
        statusNode.size = CGSize(width: barSize.width, height: barSize.height - containerLineWidth)
        statusNode.xScale = currentPercentage
        statusNode.color = getColor(from: currentPercentage)
        statusNode.colorBlendFactor = 1
        statusNode.zPosition = 3
        
        statusLabel = SKLabelNode(text: statusString.uppercased())
        statusLabel.position = backgroundPosition + CGPoint(x: -barSize.width / 2 + padding, y: 0)
        statusLabel.fontName = UIFont.gameFont
        statusLabel.fontSize = UIFont.gameFontSizeMedium
        statusLabel.fontColor = .darkGray
        statusLabel.horizontalAlignmentMode = .left
        statusLabel.verticalAlignmentMode = .center
        statusLabel.zPosition = 4
        statusLabel.addDropShadow()
    }
    
    
    // MARK: - Functions
    
    /**
     Adds the whole node and children to the parent node.
     */
    func addToParent(_ parentNode: SKNode) {
        addChild(backgroundNode)
        addChild(containerNode)
        addChild(containerLowPercentageNode)
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

        blinkLowPercentage()
    }
    
    /**
     Returns the percentage.
     */
    func getPercentage() -> CGFloat {
        return currentPercentage
    }
    
    private func blinkLowPercentage() {
        switch currentPercentage {
        case let percent where percent < StatusBarSprite.lowPercentage / 5:
            guard lowPercentageBlinkDuration != 0.5 else { return }
            
            lowPercentageBlinkDuration = 0.5
        case let percent where percent < StatusBarSprite.lowPercentage / 2.5:
            guard lowPercentageBlinkDuration != 1 else { return }
            
            lowPercentageBlinkDuration = 1
        case let percent where percent < StatusBarSprite.lowPercentage:
            guard lowPercentageBlinkDuration != 1.5 else { return }
            
            lowPercentageBlinkDuration = 1.5
        default:
            containerLowPercentageNode.removeAction(forKey: StatusBarSprite.keyLowPercentageAction)
            containerLowPercentageNode.run(SKAction.fadeOut(withDuration: lowPercentageBlinkDuration))
            lowPercentageBlinkDuration = 0 //Reset this!!!
            return
        }
        
        containerLowPercentageNode.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.75, duration: 0),
            .run {
                AudioManager.shared.playSound(for: "ylowhealth", interruptPlayback: true)
                Haptics.shared.addHapticFeedback(withStyle: .soft)
            },
            .fadeOut(withDuration: lowPercentageBlinkDuration),
        ])), withKey: StatusBarSprite.keyLowPercentageAction)
    }
    
    
}
