//
//  LevelSkipEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/2/23.
//

import SpriteKit
import FirebaseAuth

protocol LevelSkipEngineDelegate: AnyObject {
    func fowardPressed(_ node: SKSpriteNode)
    func reversePressed(_ node: SKSpriteNode)
    func viewAchievementsPressed(_ node: SKSpriteNode)
    func partyModePressed(_ node: SKSpriteNode)
}

class LevelSkipEngine {
    
    // MARK: - Properties
    
    private var forwardSprite: SKSpriteNode
    private var reverseSprite: SKSpriteNode
    private var viewAchievements: SKSpriteNode
    private var partyMode: SKSpriteNode
    private var superScene: SKScene?
    private var user: User?
    
    weak var delegate: LevelSkipEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(user: User?) {
        let buttonScale: CGFloat = 0.5
        let buttonSpacing: CGFloat = 180
        let padding: CGFloat = 20
        
        self.user = user
        
        forwardSprite = SKSpriteNode(texture: SKTexture(imageNamed: "forwardButton"))
        forwardSprite.name = "forwardButton"
        forwardSprite.color = .systemGreen
        forwardSprite.colorBlendFactor = 1
        forwardSprite.setScale(buttonScale)
        forwardSprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - K.ScreenDimensions.lrMargin - forwardSprite.size.width - padding,
                                         y: forwardSprite.size.height + padding)
        forwardSprite.anchorPoint = .zero
        forwardSprite.zPosition = K.ZPosition.pauseButton
        
        reverseSprite = SKSpriteNode(texture: SKTexture(imageNamed: "reverseButton"))
        reverseSprite.name = "reverseButton"
        reverseSprite.color = .systemRed
        reverseSprite.colorBlendFactor = 1
        reverseSprite.setScale(buttonScale)
        reverseSprite.position = CGPoint(x: K.ScreenDimensions.lrMargin + padding, y: reverseSprite.size.height + padding)
        reverseSprite.anchorPoint = .zero
        reverseSprite.zPosition = K.ZPosition.pauseButton
        
        viewAchievements = SKSpriteNode(texture: SKTexture(imageNamed: "leaderboards"))
        viewAchievements.name = "achievementButton"
        viewAchievements.setScale(buttonScale)
        viewAchievements.position = CGPoint(x: reverseSprite.position.x + buttonSpacing, y: viewAchievements.size.height + padding)
        viewAchievements.anchorPoint = .zero
        viewAchievements.zPosition = K.ZPosition.pauseButton
        
        partyMode = SKSpriteNode(texture: SKTexture(imageNamed: "party"))
        partyMode.name = "partyModeButton"
        partyMode.setScale(buttonScale)
        partyMode.position = CGPoint(x: forwardSprite.position.x - buttonSpacing / 2, y: partyMode.size.height + padding)
        partyMode.anchorPoint = .zero
        partyMode.zPosition = K.ZPosition.pauseButton
        
        showButtons()
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
                delegate?.fowardPressed(forwardSprite)
                ButtonTap.shared.tap(type: .buttontap1)
                break
            }
            else if nodeTapped.name == "reverseButton" {
                delegate?.reversePressed(reverseSprite)
                ButtonTap.shared.tap(type: .buttontap1)
                break
            }
            else if nodeTapped.name == "achievementButton" {
                delegate?.viewAchievementsPressed(viewAchievements)
                ButtonTap.shared.tap(type: .buttontap1)
                break
            }
            else if nodeTapped.name == "partyModeButton" {
                delegate?.partyModePressed(partyMode)
                ButtonTap.shared.tap(type: .buttontap1)
                break
            }
        }
    }
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene

        superScene.addChild(forwardSprite)
        superScene.addChild(reverseSprite)
//        superScene.addChild(viewAchievements)
        
//        if let user = user, user.uid == "3SeIWmlATmbav7jwCDjXyiA0TgA3" {
//            superScene.addChild(partyMode)
//        }
    }
    
    
    // MARK: - Helper Functions
    
    private func showButtons() {
        forwardSprite.removeAllActions()
        reverseSprite.removeAllActions()
        viewAchievements.removeAllActions()
        partyMode.removeAllActions()
                
        let showHideAction = SKAction.sequence([
            SKAction.moveTo(y: forwardSprite.size.height + 20, duration: 0.25),
            SKAction.wait(forDuration: 3.0),
            SKAction.moveTo(y: -forwardSprite.size.height, duration: 0.25)
        ])

        forwardSprite.run(showHideAction)
        reverseSprite.run(showHideAction)
        viewAchievements.run(showHideAction)
        partyMode.run(showHideAction)
    }
}
