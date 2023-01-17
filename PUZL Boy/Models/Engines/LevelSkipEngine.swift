//
//  LevelSkipEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/2/23.
//

import SpriteKit

protocol LevelSkipEngineDelegate: AnyObject {
    func fowardPressed(_ node: SKSpriteNode)
    func reversePressed(_ node: SKSpriteNode)
    func viewAchievementsPressed( node: SKSpriteNode)
}

class LevelSkipEngine {
    
    // MARK: - Properties
    
    private var forwardSprite: SKSpriteNode
    private var reverseSprite: SKSpriteNode
    private var viewAchievements: SKSpriteNode
    private var superScene: SKScene?
    
    weak var delegate: LevelSkipEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        let buttonScale: CGFloat = 0.5
        
        forwardSprite = SKSpriteNode(texture: SKTexture(imageNamed: "forwardButton"))
        forwardSprite.name = "forwardButton"
        forwardSprite.color = .systemGreen
        forwardSprite.colorBlendFactor = 1
        forwardSprite.setScale(buttonScale)
        forwardSprite.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth - forwardSprite.size.width - 20, y: forwardSprite.size.height + 20)
        forwardSprite.anchorPoint = .zero
        
        reverseSprite = SKSpriteNode(texture: SKTexture(imageNamed: "reverseButton"))
        reverseSprite.name = "reverseButton"
        reverseSprite.color = .systemRed
        reverseSprite.colorBlendFactor = 1
        reverseSprite.setScale(buttonScale)
        reverseSprite.position = CGPoint(x: 20, y: reverseSprite.size.height + 20)
        reverseSprite.anchorPoint = .zero
        
        viewAchievements = SKSpriteNode(texture: SKTexture(imageNamed: "forwardButton"))
        viewAchievements.name = "achievementButton"
        viewAchievements.color = .systemBlue
        viewAchievements.colorBlendFactor = 1
        viewAchievements.setScale(buttonScale)
        viewAchievements.position = CGPoint(x: (K.ScreenDimensions.iPhoneWidth - viewAchievements.size.width) / 2,
                                            y: viewAchievements.size.height + 20)
        viewAchievements.anchorPoint = .zero
    }
    
    
    // MARK: - Necessary Functions
    
    func handleControls(in location: CGPoint) {
        guard let superScene = superScene else { return print("superScene not set!") }
        
        let buttonPressAction = SKAction.sequence([SKAction.colorize(withColorBlendFactor: 0, duration: 0),
                                                   SKAction.wait(forDuration: 0.5),
                                                   SKAction.colorize(withColorBlendFactor: 1, duration: 1.0)])
        
        for nodeTapped in superScene.nodes(at: location) {
            if nodeTapped.name == "forwardButton" {
                forwardSprite.run(buttonPressAction)
                delegate?.fowardPressed(forwardSprite)
                Haptics.shared.addHapticFeedback(withStyle: .soft)
                break
            }
            else if nodeTapped.name == "reverseButton" {
                reverseSprite.run(buttonPressAction)
                delegate?.reversePressed(reverseSprite)
                Haptics.shared.addHapticFeedback(withStyle: .soft)
                break
            }
            else if nodeTapped.name == "achievementButton" {
                viewAchievements.run(buttonPressAction)
                delegate?.viewAchievementsPressed(node: viewAchievements)
                Haptics.shared.addHapticFeedback(withStyle: .soft)
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
        superScene.addChild(viewAchievements)
    }
}
