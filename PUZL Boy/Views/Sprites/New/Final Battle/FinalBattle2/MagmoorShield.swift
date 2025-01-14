//
//  MagmoorShield.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/6/25.
//

import SpriteKit

protocol MagmoorShieldDelegate: AnyObject {
    func willDamageShield()
    func didDamageShield()
    func willBreakShield(fadeDuration: TimeInterval)
    func didBreakShield(at villainPosition: K.GameboardPosition)
}

class MagmoorShield: SKNode {
    
    // MARK: - Properties
    
    private let maxHitPoints: Int = 3
    private(set) var hitPoints: Int {
        didSet {
            setShieldColor()
            hitPoints = max(0, hitPoints)
        }
    }
    
    private var shieldColor: UIColor
    private var bottomNode: SKSpriteNode
    private var topNode: SKSpriteNode
    
    var hasHitPoints: Bool {
        return hitPoints > 0
    }
    
    var isEnraged: Bool {
        return !hasHitPoints
    }
    
    weak var delegate: MagmoorShieldDelegate?
    
    
    // MARK: - Initialization
    
    init(hitPoints: Int = 0) {
        self.shieldColor = .red //will get overwritten
        self.hitPoints = hitPoints
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
    
    deinit {
        print("deinit MagmoorShield")
    }
    
    
    // MARK: - Functions
    
    /**
     Resets the shield to the max, i.e. 3 and apply a quick animation.
     */
    func resetShield(villain: Player) {
        hitPoints = maxHitPoints
        
        removeAllActions()
        setScale(0)
        alpha = 1
        
        bottomNode.color = shieldColor
        topNode.color = shieldColor
        
        villain.sprite.addChild(self)
        
        //Actions
        shieldThrob(waitDuration: 2.5)
        
        run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 2, duration: 4)))
        run(SKAction.sequence([
            scaleAndFade(size: 6, alpha: 0.5, duration: 0.25),
            scaleAndFade(size: 2.5, alpha: 1, duration: 0.5),
            scaleAndFade(duration: 1.75)
        ]))
        
        //SFX
        AudioManager.shared.playSound(for: "shieldcast")
        AudioManager.shared.playSound(for: "shieldcast2")
        AudioManager.shared.playSound(for: "shieldpulse")
        Haptics.shared.addHapticFeedback(withStyle: .soft)
    }
    
    /**
     Decrements the shield and applies a quick animation, depending on if the shield breaks or not.
     - parameters:
        - increment: amount to decrement (should be a positive value)
        - villain: the villain Player, i.e. Magmoor
        - villainPosition: Magmoor's position on the gameboard
        - completion: completion handler, e.g. to set values, cleanup, etc.
     */
    func decrementShield(_ increment: Int = 1, villain: Player, villainPosition: K.GameboardPosition, completion: (() -> Void)?) {
        let colorizeDuration: TimeInterval = 2.5
        let originalShieldColor = shieldColor
        
        hitPoints -= increment
        
        //Initialize AFTER decrementing hitPoints due to side effect of shieldColor changing in didSet!
        let changeColorAction = SKAction.repeat(SKAction.sequence([
            SKAction.colorize(with: originalShieldColor, colorBlendFactor: 1, duration: 0.1),
            SKAction.colorize(with: shieldColor, colorBlendFactor: 1, duration: 0.1)
        ]), count: Int(colorizeDuration / 0.2))
        
        bottomNode.run(changeColorAction)
        topNode.run(changeColorAction)
        
        delegate?.willDamageShield()
        
        if hasHitPoints {
            let fadeDuration: TimeInterval = colorizeDuration
            
            removeAction(forKey: "shieldThrobAction")
            shieldThrob(waitDuration: fadeDuration + 0.5)
            
            run(SKAction.sequence([
                SKAction.group([
                    scaleAndFade(size: 3.5, alpha: 1, duration: fadeDuration),
                    shieldShake(duration: fadeDuration)
                ]),
                SKAction.run { [weak self] in
                    self?.delegate?.didDamageShield()
                },
                scaleAndFade(size: 5, alpha: 0.5, duration: 0.5)
            ])) {
                completion?()
            }
        }
        else {
            let fadeDuration: TimeInterval = 4.5
            
            AudioManager.shared.playSound(for: "magicdisappear", delay: fadeDuration)
            
            removeAction(forKey: "shieldThrobAction")
            run(SKAction.sequence([
                SKAction.group([
                    scaleAndFade(size: 2.5, alpha: 1, duration: fadeDuration + 0.5),
                    shieldShake(duration: fadeDuration + 0.5),
                    SKAction.sequence([
                        SKAction.run {
                            AudioManager.shared.playSound(for: "villainattack3", delay: fadeDuration - 1.1) //DON'T CHANGE - 1.1!!
                        },
                        SKAction.wait(forDuration: fadeDuration + 0.25),
                        SKAction.run { [weak self] in
                            guard let self = self else { return }
                            
                            delegate?.willBreakShield(fadeDuration: 0.25)
                            
                            AudioManager.shared.stopSound(for: "shieldpulse")
                            ParticleEngine.shared.animateParticles(type: .magicExplosion,
                                                                   toNode: villain.sprite,
                                                                   position: .zero,
                                                                   scale: 1,
                                                                   duration: 1)
                        }
                    ])
                ]),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    delegate?.didBreakShield(at: villainPosition)
                },
                scaleAndFade(size: 16, alpha: 1, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.removeFromParent()
            ])) {
                completion?()
            }
        }
    }
    
    
    // MARK: - Animation Helper Functions
    
    /**
     Sets the shield color based on hitPoints.
     */
    private func setShieldColor() {
        switch hitPoints {
        case let hp where hp <= 1:
            shieldColor = .red
        case 2:
            shieldColor = .orange
        case 3:
            shieldColor = .yellow
        case 4:
            shieldColor = .green
        case 5:
            shieldColor = .cyan
        default:
            shieldColor = .magenta
        }
    }
    
    /**
     Helper function that scales to a particular size, and fades to a particular alpha over the duration.
     - parameters:
        - size: size of scale
        - alpha: the alpha of the fade
        - duration: time it takes to perform the action
     - returns: the action group.
     */
    private func scaleAndFade(size: CGFloat = 5, alpha: CGFloat = 0.5, duration: TimeInterval = 1) -> SKAction {
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
    private func shieldShake(duration: TimeInterval) -> SKAction {
        let moveAction = SKAction.moveBy(x: -40, y: 0, duration: 0.05)
        
        return SKAction.repeat(SKAction.sequence([
            moveAction,
            moveAction.reversed()
        ]), count: Int(duration / 0.1))
    }
    
    /**
     Performs a shield throbbing action on the shield object
     - parameter waitDuration: pause before throbbing action
     */
    private func shieldThrob(waitDuration: TimeInterval) {
        run(SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.repeatForever(SKAction.sequence([
                scaleAndFade(size: 4, alpha: 1, duration: 2),
                scaleAndFade(size: 5, alpha: 0.5, duration: 2)
            ]))
        ]), withKey: "shieldThrobAction")
    }
    
    
}
