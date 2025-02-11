//
//  DetonationShield.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/10/25.
//

import SpriteKit

class DetonationShield: SKNode {
    
    // MARK: - Properties
    
    private let maxHitPoints: Int = 6
    private var hitPoints: Int
    private var shieldColor: UIColor {
        let shieldColor: UIColor
        
        switch hitPoints {
        case 1:     shieldColor = .red
        case 2:     shieldColor = .orange
        case 3:     shieldColor = .yellow
        case 4:     shieldColor = .green
        case 5:     shieldColor = .cyan
        default:    shieldColor = .magenta
        }
        
        return shieldColor
    }
    
    private var bottomNode: SKSpriteNode
    private var topNode: SKSpriteNode
    
    
    // MARK: - Initialization
    
    override init() {
        hitPoints = maxHitPoints
        
        bottomNode = SKSpriteNode(imageNamed: "magmoorShieldBottom")
        topNode = SKSpriteNode(imageNamed: "magmoorShieldTop")
        
        super.init()
        
        bottomNode.color = shieldColor
        bottomNode.colorBlendFactor = 1
        bottomNode.zPosition = -2
        
        topNode.color = shieldColor
        topNode.colorBlendFactor = 1
        topNode.zPosition = 2
        
        addChild(bottomNode)
        addChild(topNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func addToPlayerSprite(_ sprite: SKSpriteNode) {
        removeAllActions()
        setScale(16)
        alpha = 0
        
        bottomNode.color = shieldColor
        topNode.color = shieldColor
        
        sprite.addChild(self)
        
        run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi / 2, duration: 1)))
        run(scaleAndFade(size: 8, alpha: 0.5, duration: 0.5))
    }
    
    func decrementShield() {
        guard hitPoints > 0 else { return }
        
        let originalShieldColor = shieldColor
        let fadeDuration: TimeInterval = 3
        
        hitPoints -= 1
        
        let changeColorAction = SKAction.repeat(SKAction.sequence([
            SKAction.colorize(with: originalShieldColor, colorBlendFactor: 1, duration: 0.1),
            SKAction.colorize(with: shieldColor, colorBlendFactor: 1, duration: 0.1)
        ]), count: Int(fadeDuration / 0.2))
        
        bottomNode.run(changeColorAction)
        topNode.run(changeColorAction)
        
        run(SKAction.group([
            shieldShake(magnitude: 8 / (CGFloat(hitPoints) / CGFloat(maxHitPoints)), duration: fadeDuration),
            scaleAndFade(size: max(3.5, 8 * CGFloat(hitPoints) / CGFloat(maxHitPoints)), alpha: 0.5, duration: fadeDuration)
        ]))
        
        AudioManager.shared.playSound(for: "villainattackbombtick")
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Helper function that scales to a particular size, and fades to a particular alpha over the duration.
     - parameters:
        - size: size of scale
        - alpha: the alpha of the fade
        - duration: time it takes to perform the action
     - returns: the action group.
     */
    private func scaleAndFade(size: CGFloat = 5, alpha: CGFloat = 0.5, duration: TimeInterval = 1) -> SKAction {
        print("scaleAndFade(size: \(size)")
        
        return SKAction.group([
            SKAction.scale(to: size, duration: duration),
            SKAction.fadeAlpha(to: alpha, duration: duration)
        ])
    }
    
    /**
     Shakes the shield left and right.
     - parameter duration: duration of the shake
     - returns: the shaking SKAction
     */
    private func shieldShake(magnitude: CGFloat, duration: TimeInterval) -> SKAction {
        let moveAction = SKAction.moveBy(x: magnitude, y: 0, duration: 0.05)
        
        return SKAction.repeat(SKAction.sequence([
            moveAction,
            moveAction.reversed()
        ]), count: Int(duration / 0.1))
    }
    
    
}
