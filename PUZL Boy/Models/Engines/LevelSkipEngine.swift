//
//  LevelSkipEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/2/23.
//

import SpriteKit
import FirebaseAuth

protocol LevelSkipEngineDelegate: AnyObject {
    func forwardPressed(_ node: SKSpriteNode)
    func reversePressed(_ node: SKSpriteNode)
}

class LevelSkipEngine {
    
    // MARK: - Properties
    
    private let padding: CGFloat = 20
    private var forwardSprite: SKSpriteNode!
    private var reverseSprite: SKSpriteNode!
    private var superScene: SKScene?
    
    weak var delegate: LevelSkipEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        setupSprites()
        showButtons()
    }
    
    private func setupSprites() {
        let buttonScale: CGFloat = 0.5 * 3
        
        forwardSprite = SKSpriteNode(texture: SKTexture(imageNamed: "forwardButton"))
        forwardSprite.name = "forwardButton"
        forwardSprite.color = .systemGreen
        forwardSprite.colorBlendFactor = 1
        forwardSprite.setScale(buttonScale)
        forwardSprite.position = CGPoint(x: K.ScreenDimensions.size.width - K.ScreenDimensions.lrMargin - forwardSprite.size.width - padding,
                                         y: forwardSprite.size.height + padding)
        forwardSprite.anchorPoint = .zero
        forwardSprite.zPosition = K.ZPosition.pauseButton
        
        reverseSprite = SKSpriteNode(texture: SKTexture(imageNamed: "reverseButton"))
        reverseSprite.name = "reverseButton"
        reverseSprite.color = .systemRed
        reverseSprite.colorBlendFactor = 1
        reverseSprite.setScale(buttonScale)
        reverseSprite.position = CGPoint(x: forwardSprite.position.x, y: forwardSprite.position.y + forwardSprite.size.height + padding)
        reverseSprite.anchorPoint = .zero
        reverseSprite.zPosition = K.ZPosition.pauseButton
    }
    
    
    // MARK: - Necessary Functions
    
    func handleControls(in location: CGPoint) {
        guard let superScene = superScene else { return }
        guard GameEngine.livesRemaining >= 0 else { return }
        
        if location.y < UIDevice.modelInfo.bottomSafeArea * 2 + 180 {
            showButtons()
        }
        
        for nodeTapped in superScene.nodes(at: location) {
            if nodeTapped.name == "forwardButton" {
                delegate?.forwardPressed(forwardSprite)
                ButtonTap.shared.tap(type: .buttontap1)
                break
            }
            else if nodeTapped.name == "reverseButton" {
                delegate?.reversePressed(reverseSprite)
                ButtonTap.shared.tap(type: .buttontap1)
                break
            }
        }
    }
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene, level: Int) {
        guard !Level.isPartyLevel(level) else { return }
        guard let uid = FIRManager.uid,
            uid == FIRManager.userEddie ||
            uid == FIRManager.userMichel ||
            uid == FIRManager.userMom
        else {
            return
        }
        
        // FIXME: - Uncomment the below 3 lines to enable level skip debugging.
        self.superScene = superScene
        superScene.addChild(forwardSprite)
        superScene.addChild(reverseSprite)
    }
    
    
    // MARK: - Helper Functions
    
    private func showButtons() {
        forwardSprite.removeAllActions()
        reverseSprite.removeAllActions()
                
        let showHideActionForward = SKAction.sequence([
            SKAction.moveTo(y: forwardSprite.size.height + padding, duration: 0.25),
            SKAction.wait(forDuration: 3.0),
            SKAction.moveTo(y: -forwardSprite.size.height, duration: 0.25)
        ])
        
        let showHideActionReverse = SKAction.sequence([
            SKAction.moveTo(x: forwardSprite.position.x, duration: 0.25),
            SKAction.wait(forDuration: 3.0),
            SKAction.moveTo(x: K.ScreenDimensions.size.width, duration: 0.25)
        ])

        forwardSprite.run(showHideActionForward)
        reverseSprite.run(showHideActionReverse)
    }
}
