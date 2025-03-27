//
//  CircularProgressBar.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/26/25.
//

import SpriteKit

class CircularProgressBar: SKNode {
    
    // MARK: - Properties
    
    typealias NotificationNames = (initialize: Notification.Name, expire: Notification.Name)
    
    static let radius: CGFloat = 90
    static let lineWidth: CGFloat = 24
    
    private let timerIncrement: TimeInterval
    private let maxTimerIncrement: TimeInterval
    private var remainingTime: TimeInterval
    private var timer: Timer?
    
    private(set) var isShowing: Bool = true
    var isRunning: Bool { remainingTime > 0 }
    
    private var circleNode: SKShapeNode
    private var iconImage: SKSpriteNode
    private var multiplierLabel: SKLabelNode
    private var notificationNames: NotificationNames?
    
    
    // MARK: - Initialization
    
    init(image: String, multiplier: Int, multiplierColor: UIColor, multiplierAlpha: CGFloat, timerIncrement: TimeInterval, maxTimerIncrement: TimeInterval, notificationNames: NotificationNames?) {
        
        self.timerIncrement = timerIncrement
        self.maxTimerIncrement = maxTimerIncrement
        remainingTime = 0
        timer = nil
        
        circleNode = SKShapeNode(circleOfRadius: 0)
        circleNode.lineWidth = CircularProgressBar.lineWidth
        circleNode.lineCap = .round
        circleNode.strokeColor = .green
        circleNode.alpha = 0
        circleNode.zPosition = 0
        
        iconImage = SKSpriteNode(imageNamed: image)
        iconImage.alpha = 0
        iconImage.zPosition = 5
        
        let isInfiniteMultiplier = multiplier == Int(ChosenSword.infiniteMultiplier)
        
        multiplierLabel = SKLabelNode(text: isInfiniteMultiplier ? "∞" : "\(multiplier)X")
        multiplierLabel.fontColor = multiplierColor
        multiplierLabel.fontName = isInfiniteMultiplier ? UIFont.infiniteFont : UIFont.gameFont
        multiplierLabel.fontSize = isInfiniteMultiplier ? UIFont.infiniteSizeExtraLarge : UIFont.gameFontSizeExtraLarge
        multiplierLabel.verticalAlignmentMode = .center
        multiplierLabel.setScale(0)
        multiplierLabel.alpha = multiplierAlpha
        multiplierLabel.zPosition = 10
        multiplierLabel.addHeavyDropShadow()
        
        if isInfiniteMultiplier {
            multiplierLabel.run(SKAction.repeatForever(SKAction.colorizeWithRainbowColorSequence(blendFactor: 0.75, duration: 0.2)), withKey: "colorizeMultiplier")
        }
        else {
            multiplierLabel.removeAction(forKey: "colorizeMultiplier")
        }
        
        self.notificationNames = notificationNames
        
        super.init()
        
        let circlePath = SKShapeNode(circleOfRadius: CircularProgressBar.radius)
        circlePath.lineWidth = CircularProgressBar.lineWidth
        circlePath.alpha = 0.2
        circlePath.zPosition = -5
        
        circleNode.addChild(circlePath)
        
        addChild(circleNode)
        addChild(iconImage)
        addChild(multiplierLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        
        print("deinit CircularProgressBar")
    }
    
    
    // MARK: - Functions
    
    ///Hides the progress bar's alpha component
    func hideProgressBar() {
        isShowing = false
        run(SKAction.fadeOut(withDuration: 0))
    }
    
    ///Shows the progress bar with an optional pulsing of the multiplier value.
    func showProgressBar(shouldPulseMultiplier: Bool) {
        isShowing = true
        
        if shouldPulseMultiplier {
            pulseMultiplier(scaleTo: 1)
        }
        
        run(SKAction.fadeIn(withDuration: 0))
    }
    
    /**
     Updates the remaining time of the progress bar as a percentage. If percentage goes from 0 to less than 0, or 1 to less than 1, then also fade alpha and scale the multiplier in the process.
     */
    func updateRemainingTime() {
        let percentage = getRemainingTime() / maxTimerIncrement
        
        if self.remainingTime <= 0 && percentage > 0 {
            didAdjustAlpha(1)
            pulseMultiplier(scaleTo: 1)
            pulseIcon()
        }
        else if self.remainingTime > 0 && percentage <= 0 {
            didAdjustAlpha(0.25)
            pulseMultiplier(scaleTo: 0)
            pulseIcon()
            
            if isShowing {
                AudioManager.shared.playSound(for: "powerdownitem")
            }
        }
        
        circleNode.strokeColor = getColor(from: percentage)
        circleNode.path = UIBezierPath(arcCenter: .zero,
                                       radius: CircularProgressBar.radius,
                                       startAngle: .pi / 2,
                                       endAngle: .pi / 2 - 2 * .pi * percentage,
                                       clockwise: false).cgPath
        
        //Set this last
        self.remainingTime = percentage
    }
    
    func getRemainingTime() -> TimeInterval {
        return timer != nil ? abs(Date().timeIntervalSince(timer!.fireDate)) : 0
    }
    
    func setTimer() {
        let remainingTime = getRemainingTime()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: min(remainingTime + timerIncrement, maxTimerIncrement),
                                     target: self,
                                     selector: #selector(setTimerHelper),
                                     userInfo: nil,
                                     repeats: true)
        
        if let notificationNames = notificationNames {
            NotificationCenter.default.post(name: notificationNames.initialize, object: nil)
        }
    }
    
    @objc private func setTimerHelper() {
        if let notificationNames = notificationNames {
            NotificationCenter.default.post(name: notificationNames.expire, object: nil)
        }
        
        timer?.invalidate()
        timer = nil
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Adjusts the alpha of the HUD (circleNode and image only) to the requested alpha value, with a slight fade animation..
     - parameter alpha: the alpha value to set.
     */
    private func didAdjustAlpha(_ alpha: CGFloat) {
        let fadeDuration: TimeInterval = 0.25
        
        circleNode.run(SKAction.fadeAlpha(to: alpha, duration: fadeDuration))
        iconImage.run(SKAction.fadeAlpha(to: alpha, duration: fadeDuration))
    }
    
    /**
     Pulses the multiplier label's text value and "pop's" a little animation in the process.
     - parameter scaleTo: the scale of the resultant multiplier value
     */
    private func pulseMultiplier(scaleTo: CGFloat) {
        let scaleDuration: TimeInterval = 0.25
        
        multiplierLabel.run(SKAction.sequence([
            SKAction.scale(to: 2, duration: scaleDuration),
            SKAction.scale(to: scaleTo, duration: scaleDuration)
        ]))
    }
    
    /**
     Pulses the icon image and "pop's" a little animation in the process.
     */
    private func pulseIcon() {
        let scaleDuration: TimeInterval = 0.25
        
        iconImage.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: scaleDuration),
            SKAction.scale(to: 1, duration: scaleDuration)
        ]))
    }
    
    /**
     Gets the bar color based on the percentage. Copied from StatusBarSprite.
     */
    private func getColor(from percentage: CGFloat) -> UIColor {
        return UIColor(red: percentage > 0.5 ? 2 * (1 - percentage) : 1, green: percentage < 0.5 ? 2 * percentage : 1, blue: 0, alpha: 1)
    }
    
    
}
