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
    
    static let keyShieldThrobAction = "shieldThrobAction"
    static let keyRotateAction = "rotateAction"

    private(set) var resetCount: Int = 0
    private(set) var speedReduction: TimeInterval = 0
    private var maxHitPoints: Int = 3
    private(set) var hitPoints: Int {
        didSet {
            setShieldColor()
            hitPoints = max(0, hitPoints)
        }
    }
    
    private(set) var shieldColor: UIColor
    private var bottomNode: SKSpriteNode
    private var topNode: SKSpriteNode
    
    var hasHitPoints: Bool { return hitPoints > 0 }
    var isEnraged: Bool { return !hasHitPoints }
    var isMaxed: Bool { return hitPoints == maxHitPoints }
    
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
    
    /**
     Convenience init to be used by Duplicates only!
     - parameters:
        - makeInvincible: if true, cast the shield, if false, it's probably the invicible caster
        - duplicate: the Duplicate to add the shield to
     */
    convenience init(makeInvincible: Bool, duplicate: Player) {
        self.init()
        
        if makeInvincible {
            resetShieldInvincible(duplicate: duplicate)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit MagmoorShield")
    }
    
    
    // MARK: - Functions
    
    /**
     Call this to deinitialize the object. The actions, or the attachment to parent prevents it from deinitializing properly...
     */
    func cleanup() {
        removeAllActions()
        removeFromParent()
        
        AudioManager.shared.stopSound(for: "shieldpulse", fadeDuration: 2)
    }
    
    /**
     Resets the shield to the max, i.e. 3 and apply a quick animation.
     */
    func resetShield(villain: Player) {
        maxHitPoints = min(3 + resetCount, 6)
        hitPoints = maxHitPoints
        resetCount += 1
        speedReduction = 0
        
        helperResetShield(villain: villain, asInvincible: false)
    }
    
    /**
     For use specifically with convenience init() when setting up for Duplicate invincibility shield.
     */
    private func resetShieldInvincible(duplicate: Player) {
        hitPoints = 6
        
        helperResetShield(villain: duplicate, asInvincible: true)
    }
    
    /**
     Decrements the shield and applies a quick animation, depending on if the shield breaks or not.
     - parameters:
        - increment: amount to decrement (should be a positive value)
        - villain: the villain Player, i.e. Magmoor
        - villainPosition: Magmoor's position on the gameboard
        - completion: completion handler, e.g. to set values, cleanup, etc.
     */
    func decrementShield(decrementAmount: Int = 1, villain: Player, villainPosition: K.GameboardPosition, completion: @escaping () -> Void) {
        let colorizeDuration: TimeInterval = 2.5
        let originalShieldColor = shieldColor
        
        hitPoints -= decrementAmount
        speedReduction += TimeInterval(decrementAmount)
        
        //Initialize AFTER decrementing hitPoints due to side effect of shieldColor changing in didSet!
        let changeColorAction = SKAction.repeat(SKAction.sequence([
            SKAction.colorize(with: originalShieldColor, colorBlendFactor: 1, duration: 0.1),
            SKAction.colorize(with: shieldColor, colorBlendFactor: 1, duration: 0.1)
        ]), count: Int(colorizeDuration / 0.2))
        
        bottomNode.run(changeColorAction)
        topNode.run(changeColorAction)
        villain.castSpell(color: shieldColor, colorDuration: colorizeDuration)
        
        delegate?.willDamageShield()
        
        if hasHitPoints {
            damageShield(colorizeDuration: colorizeDuration, completion: completion)
        }
        else {
            breakShield(villain: villain, villainPosition: villainPosition, completion: completion)
        }
    }
    
    
    // MARK: - Decrement Shield Helper Functions
    
    private func damageShield(colorizeDuration: TimeInterval, completion: @escaping () -> Void) {
        let fadeDuration: TimeInterval = colorizeDuration
        
        removeAction(forKey: MagmoorShield.keyShieldThrobAction)
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
        ]), completion: completion)
    }
    
    private func breakShield(villain: Player, villainPosition: K.GameboardPosition, completion: @escaping () -> Void) {
        let fadeDuration: TimeInterval = 4.5
        
        AudioManager.shared.playSound(for: "magicdisappear", delay: fadeDuration)
        
        removeAction(forKey: MagmoorShield.keyShieldThrobAction)
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
                        ParticleEngine.shared.animateParticles(type: .magicExplosion0,
                                                               toNode: villain.sprite,
                                                               position: .zero,
                                                               scale: UIDevice.spriteScale,
                                                               zPosition: 1,
                                                               duration: 1) //keep at 1
                        ParticleEngine.shared.animateParticles(type: .magicExplosion1,
                                                               toNode: villain.sprite,
                                                               position: .zero,
                                                               scale: UIDevice.spriteScale,
                                                               zPosition: 2,
                                                               duration: 2)
                        ParticleEngine.shared.animateParticles(type: .magicExplosion2,
                                                               toNode: villain.sprite,
                                                               position: .zero,
                                                               scale: UIDevice.spriteScale,
                                                               zPosition: 3,
                                                               duration: 2)
                    }
                ])
            ]),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                delegate?.didBreakShield(at: villainPosition)
                villain.sprite.run(SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.25))
            },
            scaleAndFade(size: 16, alpha: 1, duration: 0.25),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]), completion: completion)
    }
    
    
    // MARK: - Invincible Shield (Duplicate) Functions
    
    /**
     Execute this when attempting to attack an invincible shield on a Duplicate.
     */
    func attackInvincibleShield(completion: @escaping () -> Void) {
        let fadeDuration: TimeInterval = 0.5
        
        removeAction(forKey: MagmoorShield.keyShieldThrobAction)
        run(SKAction.sequence([
            SKAction.group([
                scaleAndFade(size: 3, alpha: 1, duration: fadeDuration),
                shieldShake(duration: fadeDuration)
            ]),
            scaleAndFade(size: 3.5, alpha: 0.25, duration: 0.5)
        ]), completion: completion)
    }
    
    /**
     Execute this on remaining Duplicates when the invincible Duplicate gets destroyed.
     */
    func breakInvincibleShield(completion: @escaping () -> Void) {
        hitPoints = 0
        
        let shakeDuration: TimeInterval = 2
        let fadeDuration: TimeInterval = 0.5
        let scaleDuration: TimeInterval = 0.25
        
        AudioManager.shared.playSound(for: "shieldcast", delay: shakeDuration, interruptPlayback: false)
        
        removeAction(forKey: MagmoorShield.keyShieldThrobAction)
        run(SKAction.sequence([
            SKAction.group([
                scaleAndFade(size: 3, alpha: 1, duration: fadeDuration),
                shieldShake(duration: shakeDuration)
            ]),
            scaleAndFade(size: 7, alpha: 1, duration: scaleDuration),
            SKAction.run { [weak self] in
                self?.removeAction(forKey: MagmoorShield.keyRotateAction)
            },
            shieldShake(duration: scaleDuration),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ]), completion: completion)
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
     Helper function used by resetShield() and resetShieldInvincible().
     - parameters:
        - villain: the Player to add the shield to
        - asInvincible: if true, set the shield up as an invincible shield (to be used by Duplicates only!)
     */
    private func helperResetShield(villain: Player, asInvincible: Bool) {
        removeAllActions()
        setScale(0)
        alpha = 1
        
        bottomNode.color = shieldColor
        topNode.color = shieldColor
        
        villain.sprite.addChild(self)
        
        //Actions
        if !asInvincible {
            villain.castSpell(color: shieldColor)
            shieldThrob(waitDuration: 2.5)
        }
        
        run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 2, duration: 4)), withKey: MagmoorShield.keyRotateAction)
        run(SKAction.sequence([
            scaleAndFade(size: 6, alpha: 0.5, duration: 0.25),
            scaleAndFade(size: 2.5, alpha: 1, duration: 0.5),
            scaleAndFade(size: !asInvincible ? 5 : 3.5, alpha: !asInvincible ? 0.5 : 0.25, duration: 1.75)
        ]))
        
        if !asInvincible {
            //SFX
            AudioManager.shared.playSound(for: "shieldcast")
            AudioManager.shared.playSound(for: "shieldcast2")
            AudioManager.shared.playSound(for: "shieldpulse")
            Haptics.shared.addHapticFeedback(withStyle: .soft)
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
        ]), withKey: MagmoorShield.keyShieldThrobAction)
    }
    
    
}
