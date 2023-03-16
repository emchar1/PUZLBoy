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
    }
    
    
    // MARK: - Functions
    
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(sprite)
    }
    
    func handleControls(in location: CGPoint) {
        guard let superScene = sprite.parent else { return print("superScene not set in PauseResetEngine!")}
                
        for nodeTapped in superScene.nodes(at: location) {
            if nodeTapped.name == "pauseResetButton" {
                print("didTapButton PauseResetEngine at: \(location)")
                
                
                
                
                //Handle pause/reset here
                isPaused.toggle()
                AudioManager.shared.playSound(for: "buttontap")
                Haptics.shared.addHapticFeedback(withStyle: .soft)
                delegate?.didTapPause(isPaused: self.isPaused)
                
                
                
                
                break
            }
        }
    }
    
}
