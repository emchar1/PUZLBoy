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
    
    private var sprite: SKSpriteNode
    private var isPressed: Bool
    private(set) var isPaused: Bool {
        didSet {
            sprite.texture = SKTexture(imageNamed: isPaused ? "pauseresetbutton2" : "pauseresetbutton")
        }
    }
    
    weak var delegate: PauseResetEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        let buttonSize: CGFloat = K.ScreenDimensions.iPhoneWidth / 5
        
        sprite = SKSpriteNode(imageNamed: "pauseresetbutton")
        sprite.scale(to: CGSize(width: buttonSize, height: buttonSize))
        sprite.anchorPoint = .zero
        sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2 - buttonSize / 2, y: K.ScreenDimensions.bottomMargin)
        sprite.name = "pauseResetButton"
        
        isPaused = false
        isPressed = false
    }
    
    
    // MARK: - Move Functions
    
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(sprite)
    }
    
    
    // MARK: - Touch Controls
    
    /**
     Helper function that checks that superScene has been set up, and that the tap occured within the pauseResetButton node name. Call this, then pass the touch function in the function parameter.
     - parameters:
        - location: location of the touch
        - function: the passed in function to be executed once the node has ben found
     */
    func touch(location: CGPoint?, function: (CGPoint?) -> Void) {
        guard let superScene = sprite.parent else { return print("superScene not set in PauseResetEngine!") }
        
        if let location = location {
            for nodeTapped in superScene.nodes(at: location) {
                guard nodeTapped.name == "pauseResetButton" else { break }

                function(location)
            }
        }
        else {
            function(location)
        }
    }
    
    func touchDown(_ location: CGPoint?) {
        sprite.run(SKAction.colorize(with: .black, colorBlendFactor: 0.25, duration: 0))
        isPressed = true
    }
    
    func touchUp(_ location: CGPoint?) {
        sprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        isPressed = false
    }
    
    func handleControls(_ location: CGPoint?) {
        guard isPressed else { return }
        
        isPaused.toggle()
        AudioManager.shared.playSound(for: "buttontap")
        Haptics.shared.addHapticFeedback(withStyle: .soft)
        delegate?.didTapPause(isPaused: self.isPaused)
    }
}
