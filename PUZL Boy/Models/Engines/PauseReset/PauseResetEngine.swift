//
//  PauseResetEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/12/23.
//

import SpriteKit

protocol PauseResetEngineDelegate: AnyObject {
    func didTapPause(isPaused: Bool)
    func didTapButtonSpecial()
}


class PauseResetEngine {
    
    // MARK: - Properties
    
    private let pauseResetName = "pauseresetbutton"
    private let buttonSize: CGFloat = 180
    private let settingsButtonHeight: CGFloat = 80
    private var position: CGPoint {
        CGPoint(x: (K.ScreenDimensions.iPhoneWidth - buttonSize) / 2, y: K.ScreenDimensions.bottomMargin)
    }
    
    private let resetAnimationKey = "resetAnimationKey"
    private let resetThreshold: Int = 3
    private var resetInitial = Date()
    private var resetFinal = Date()
    private var resetElapsed: TimeInterval {
        TimeInterval(resetFinal.timeIntervalSinceNow - resetInitial.timeIntervalSinceNow)
    }
    
    private var buttonSprite: SKSpriteNode
    private var foregroundSprite: SKShapeNode
    private var backgroundSprite: SKShapeNode
    private var superScene: SKScene?
    private var comingSoonLabel: SKLabelNode
    private var countdownLabel: SKLabelNode
    
    private var isPressed: Bool = false
    private var isAnimating: Bool = false

    var specialFunctionEnabled: Bool = false {
        didSet {
            buttonSprite.texture = SKTexture(imageNamed: specialFunctionEnabled ? "\(pauseResetName)3" : (isPaused ? "\(pauseResetName)2" : pauseResetName))
        }
    }
    var isPaused: Bool = false {
        didSet {
            buttonSprite.texture = SKTexture(imageNamed: isPaused ? "\(pauseResetName)2" : pauseResetName)
        }
    }
    
    weak var delegate: PauseResetEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        let settingsSize: CGFloat = K.ScreenDimensions.iPhoneWidth
        let settingsScale: CGFloat = GameboardSprite.spriteScale
        let padding: CGFloat = GameboardSprite.padding
        
        // FIXME: - This is atrocious
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: settingsSize, height: settingsSize + ChatEngine.avatarSizeNew + settingsButtonHeight),
                                       cornerRadius: 20)
        backgroundSprite.position = CGPoint(x: settingsScale * (settingsSize + padding) / 2 + GameboardSprite.xPosition, y: 0)
        backgroundSprite.fillColor = .gray
        backgroundSprite.fillTexture = SKTexture(image: UIImage.chatGradientTexture)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(0)
        backgroundSprite.zPosition = K.ZPosition.messagePrompt
        
        foregroundSprite = SKShapeNode(rectOf: CGSize(width: settingsSize, height: settingsSize + ChatEngine.avatarSizeNew - settingsButtonHeight))
        foregroundSprite.position = CGPoint(x: 0, y: settingsButtonHeight)
        foregroundSprite.fillColor = .clear
        foregroundSprite.lineWidth = 0
        foregroundSprite.setScale(1)
        
        // FIXME: - Temporary label
        comingSoonLabel = SKLabelNode(text: "        SETTINGS\n(Coming Soon...)")
        comingSoonLabel.numberOfLines = 0
        comingSoonLabel.horizontalAlignmentMode = .center
        comingSoonLabel.verticalAlignmentMode = .center
        comingSoonLabel.fontName = UIFont.gameFont
        comingSoonLabel.fontSize = UIFont.gameFontSizeMedium
        comingSoonLabel.fontColor = .yellow
        
        countdownLabel = SKLabelNode(text: "3")
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.fontSize = UIFont.gameFontSizeExtraLarge
        countdownLabel.fontName = UIFont.gameFont
        countdownLabel.fontColor = .white
        countdownLabel.zPosition = K.ZPosition.messagePrompt
        countdownLabel.name = pauseResetName
        countdownLabel.alpha = 0
        
        buttonSprite = SKSpriteNode(imageNamed: pauseResetName)
        buttonSprite.scale(to: CGSize(width: buttonSize, height: buttonSize))
        buttonSprite.anchorPoint = .zero
        buttonSprite.position = position
        buttonSprite.name = pauseResetName
        buttonSprite.zPosition = K.ZPosition.buttons

        countdownLabel.position = CGPoint(x: position.x + buttonSize / 2, y: position.y + buttonSize * 1.5)

        resetAll()
    }
    
    
    // MARK: - Move Functions
    
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene
        
        superScene.addChild(buttonSprite)
        superScene.addChild(countdownLabel)
    }
    
    
    // MARK: - Reset Functions
    
    private func resetAll() {
        resetInitial = Date()
        resetFinal = Date()
    }
    
    
    // MARK: - Touch Functions
    
    /**
     Helper function that checks that superScene has been set up, and that the tap occured within the pauseResetButton node name. Call this, then pass the touch function in the function parameter. Don't use for touchDown due to different parameter list.
     - parameters:
     - location: location of the touch
     - function: the passed in function to be executed once the node has ben found
     */
    func touch(in location: CGPoint?, function: () -> Void) {
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        
        if let location = location {
            for nodeTapped in superScene.nodes(at: location) {
                guard nodeTapped.name == pauseResetName else { break }
                
                function()
            }
        }
        else {
            function()
        }
    }
    
    /**
     Handles the actual logic for when the user taps the button. Pass this in the touch helper function because it doesn't contain any setup to handle location of the tap.
     */
    func handleControls() {
        guard !isAnimating else { return print("isAnimating is true. Aborting.") }

        if !specialFunctionEnabled {
            openSettingsMenu()
        }
        else {
            callSpecialFunc()
        }
    }
    
    private func openSettingsMenu() {
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard isPressed else { return }
        
        isPaused.toggle()
        
        
        

        // TODO: - Handle actual pause screen here.
        isAnimating = true
        
        if isPaused {
            backgroundSprite.run(SKAction.group([
                SKAction.moveTo(y: GameboardSprite.spriteScale * (K.ScreenDimensions.iPhoneWidth - ChatEngine.avatarSizeNew - settingsButtonHeight + GameboardSprite.padding * 4 + 2) / 2 + GameboardSprite.yPosition, duration: 0.2),
                SKAction.sequence([
                    SKAction.scale(to: GameboardSprite.spriteScale + 0.05, duration: 0.2),
                    SKAction.scale(to: GameboardSprite.spriteScale - 0.01, duration: 0.1),
                    SKAction.scale(to: GameboardSprite.spriteScale, duration: 0.2)
                ])
            ])) {
                self.isAnimating = false
            }
            
            foregroundSprite.addChild(comingSoonLabel)
            backgroundSprite.addChild(foregroundSprite)
            superScene.addChild(backgroundSprite)
        }
        else {
            backgroundSprite.run(SKAction.sequence([
                SKAction.scale(to: GameboardSprite.spriteScale + 0.05, duration: 0.1),
                SKAction.group([
                    SKAction.moveTo(y: 0, duration: 0.2),
                    SKAction.scale(to: 0, duration: 0.2)
                ])
            ])) {
                self.isAnimating = false
                
                self.comingSoonLabel.removeFromParent()
                self.foregroundSprite.removeFromParent()
                self.backgroundSprite.removeFromParent()
            }
        }
        
        
        
        
        AudioManager.shared.playSound(for: "buttontap")
        Haptics.shared.addHapticFeedback(withStyle: .soft)

        delegate?.didTapPause(isPaused: self.isPaused)
    }
    
    private func callSpecialFunc() {
        delegate?.didTapButtonSpecial()
    }
    
    /**
     Handles when user lifts finger off the button. Pass this in the touch helper function because it doesn't contain any setup to handle location of the tap.
     */
    func touchUp() {
        buttonSprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))

        if isPressed {
            Haptics.shared.addHapticFeedback(withStyle: .light)
        }
        
        //Prevents touch drag exit keeping it stuck on the refresh button.
        if !specialFunctionEnabled {
            buttonSprite.texture = SKTexture(imageNamed: isPaused ? "\(pauseResetName)2" : "\(pauseResetName)")
        }

        isPressed = false
        resetFinal = Date()
        
        //Reset settings from touchDown animation
        countdownLabel.alpha = 0
        countdownLabel.setScale(1.0)
        countdownLabel.removeAllActions()
        countdownLabel.run(SKAction.rotate(toAngle: 0, duration: 0))

        buttonSprite.removeAction(forKey: resetAnimationKey)
    }
    
    /**
     Handles when button is tapped down. Call this on it's own; don't use the touch() helper function.
     - parameters:
     - location: location of the tap
     - resetCompletion: if user has button held down for count of the resetThreshold, then the completion gets executed, otherwise it's short circuited in touchUp.
     */
    func touchDown(in location: CGPoint?, resetCompletion: (() -> Void)?) {
        guard let superScene = superScene else { return print("superScene not set in PauseResetEngine!") }
        guard let location = location else { return print("Location nil. Unable to pauseReset.") }
        
        for nodeTapped in superScene.nodes(at: location) {
            guard nodeTapped.name == pauseResetName else { break }
            
            
            buttonSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
            
            isPressed = true
            resetAll()
            Haptics.shared.addHapticFeedback(withStyle: .light)

            
            guard !specialFunctionEnabled else { return }
            
            //Counts down to see if should reset the level
            let animateCountdown = SKAction.run { [unowned self] in
                resetFinal = Date()
                
                countdownLabel.text = "\(resetThreshold - Int(resetElapsed))"
                
                if resetElapsed >= 0.4 {
                    buttonSprite.texture = SKTexture(imageNamed: "\(pauseResetName)4")
                    
                    countdownLabel.alpha = 1.0
                    
                    //All this to animate the countdown timer, make it more exciting.
                    if floor(resetElapsed) == resetElapsed.truncate(placesAfterDecimal: 1) {
                        countdownLabel.run(SKAction.group([
                            SKAction.sequence([
                                SKAction.scale(to: ceil(resetElapsed) * 0.75, duration: 0.25),
                                SKAction.scale(to: ceil(resetElapsed) * 0.65, duration: 0.25)
                            ]),
                            SKAction.repeatForever(SKAction.sequence([
                                SKAction.rotate(toAngle: .pi / 32 * resetElapsed, duration: 0.1),
                                SKAction.rotate(toAngle: -.pi / 32 * resetElapsed, duration: 0.1)
                            ]))
                        ]))
                    }
                }
            } //animateCountdown
            
            let repeatAction = SKAction.repeat(SKAction.sequence([
                animateCountdown,
                SKAction.wait(forDuration: 1.0 / 10)
            ]), count: resetThreshold * 10)
            
            let completionAction = SKAction.run {
                if self.isPaused {
                    self.handleControls()
                }
                else {
                    AudioManager.shared.playSound(for: "buttontap")
                    Haptics.shared.addHapticFeedback(withStyle: .soft)
                }

                self.buttonSprite.texture = SKTexture(imageNamed: "\(self.pauseResetName)")
                self.touchUp()
                
                resetCompletion?()
            }
            
            let sequenceAction = SKAction.sequence([
                repeatAction,
                completionAction
            ])
            
            buttonSprite.run(sequenceAction, withKey: resetAnimationKey)
        }
    }
    
    
}