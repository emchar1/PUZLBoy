//
//  PauseResetEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/12/23.
//

import SpriteKit

protocol PauseResetEngineDelegate: AnyObject {
    func didTapPause(isPaused: Bool)
}


class PauseResetEngine {
    
    // MARK: - Properties
    
    private let pauseResetName = "pauseresetbutton"
    private let buttonSize: CGFloat = K.ScreenDimensions.iPhoneWidth / 5
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
    
    private var sprite: SKSpriteNode
    private var isPressed: Bool = false
    private(set) var isPaused: Bool = false {
        didSet {
            sprite.texture = SKTexture(imageNamed: isPaused ? "\(pauseResetName)2" : pauseResetName)
        }
    }
    
    weak var delegate: PauseResetEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        sprite = SKSpriteNode(imageNamed: pauseResetName)
        sprite.scale(to: CGSize(width: buttonSize, height: buttonSize))
        sprite.anchorPoint = .zero
        sprite.position = position
        sprite.name = pauseResetName
        
        resetAll()
    }
    
    
    // MARK: - Move Functions
    
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(sprite)
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
    func touch(in location: CGPoint?, function: (CGPoint?) -> Void) {
        guard let superScene = sprite.parent else { return print("superScene not set in PauseResetEngine!") }
        
        if let location = location {
            for nodeTapped in superScene.nodes(at: location) {
                guard nodeTapped.name == pauseResetName else { break }
                
                function(location)
            }
        }
        else {
            function(location)
        }
    }
    
    /**
     Handles the actual logic for when the user taps the button. Pass this in the touch helper function because it doesn't contain any setup to handle location of the tap.
     - parameter location: location of the tap.
     */
    func handleControls(_ location: CGPoint?) {
        guard isPressed else { return }
        
        isPaused.toggle()
        AudioManager.shared.playSound(for: "buttontap")
        Haptics.shared.addHapticFeedback(withStyle: .soft)
        delegate?.didTapPause(isPaused: self.isPaused)
    }
    
    /**
     Handles when user lifts finger off the button. Pass this in the touch helper function because it doesn't contain any setup to handle location of the tap.
     - parameter location: location of the tap.
     */
    func touchUp(_ location: CGPoint?) {
        sprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))

        if isPressed {
            Haptics.shared.addHapticFeedback(withStyle: .light)
        }

        isPressed = false
        resetFinal = Date()
        
        sprite.removeAction(forKey: resetAnimationKey)
    }
    
    /**
     Handles when button is tapped down. Call this on it's own; don't use the touch() helper function.
     - parameters:
     - location: location of the tap
     - resetCompletion: if user has button held down for count of the resetThreshold, then the completion gets executed, otherwise it's short circuited in touchUp.
     */
    func touchDown(in location: CGPoint?, resetCompletion: (() -> Void)?) {
        guard let superScene = sprite.parent else { return print("superScene not set in PauseResetEngine!") }
        guard let location = location else { return print("Location nil. Unable to pauseReset.") }
        
        for nodeTapped in superScene.nodes(at: location) {
            guard nodeTapped.name == pauseResetName else { break }
            
            
            sprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
            
            isPressed = true
            resetAll()
            Haptics.shared.addHapticFeedback(withStyle: .light)

            
            //Counts down to see if should reset the level
            let block = SKAction.run {
                self.resetFinal = Date()
                print("Touch down... \(self.resetElapsed)")
            }
            
            let repeatAction = SKAction.repeat(SKAction.sequence([
                block,
                SKAction.wait(forDuration: 1.0)
            ]), count: resetThreshold)
            
            let completionAction = SKAction.run {
                // TODO: - Handle what happens once Reset has been activated, i.e. reset level and subtract a life
                self.isPaused = true
                self.handleControls(location)
                self.touchUp(nil)
                
                resetCompletion?()
            }
            
            let sequenceAction = SKAction.sequence([
                repeatAction,
                completionAction
            ])
            
            sprite.run(sequenceAction, withKey: resetAnimationKey)
        }
    }
    
    
}
