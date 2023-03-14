//
//  PauseResetEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/12/23.
//

import SpriteKit

class PauseResetEngine {
    
    // MARK: - Properties
    
    private var sprite: SKSpriteNode
    
    
    // MARK: - Initialization
    
    init() {
        let buttonSize: CGFloat = K.ScreenDimensions.iPhoneWidth / 5
        
        sprite = SKSpriteNode(imageNamed: "pauseresetbutton")
        sprite.scale(to: CGSize(width: buttonSize, height: buttonSize))
        sprite.anchorPoint = .zero
        sprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2 - buttonSize / 2, y: K.ScreenDimensions.bottomMargin)
        sprite.name = "pauseResetButton"
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

                break
            }
        }
    }
    
}
