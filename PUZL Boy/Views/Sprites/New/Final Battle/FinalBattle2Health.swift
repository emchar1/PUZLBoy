//
//  FinalBattle2Health.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/25/24.
//

import SpriteKit

class FinalBattle2Health {
    
    // MARK: - Properties
    
    private var timer: Timer?
    private var drainTimer: Timer?            //a separate timer is needed for the drain health function
    
    private var counter: Counter!
    private var bar: StatusBarSprite!
    
    enum HealthType {
        case drain, regen, lavaHit, enemyAttack, heroAttack
    }
    
    
    // MARK: - Initialization
    
    init(position: CGPoint) {
        timer = Timer()
        drainTimer = Timer()
        
        counter = Counter(maxCount: 1, step: 0.01, shouldLoop: false)
        counter.setCount(to: 0.5)
        
        bar = StatusBarSprite(label: "Determination",
                              shouldHide: true,
                              percentage: counter.getCount(),
                              position: position + CGPoint(x: 0, y: StatusBarSprite.defaultBarHeight + 16))
    }
    
    
    // MARK: - Functions
    
    func addToParent(_ parent: SKNode) {
        bar.addToParent(parent)
    }
    
    func showHealth() {
        bar.showStatus()
    }
    
    func updateHealth(type: HealthType, player: Player) {
        // FIXME: - Does the hit animation on the player belong here, or should it go in the Engine?
        if player.sprite.action(forKey: "playerBlink") != nil {
            player.sprite.colorBlendFactor = 1
        }
        
        player.sprite.removeAction(forKey: "playerBlink")
        player.sprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.5), withKey: "playerColorFade")
        
        switch type {
        case .drain:
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(helperDrain(_:)), userInfo: nil, repeats: true)
            
            // FIXME: - Does the hit animation on the player belong here, or should it go in the Engine?
            player.sprite.removeAction(forKey: "playerColorFade")
            player.sprite.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.05),
                SKAction.colorize(withColorBlendFactor: 1, duration: 0.05)
            ])), withKey: "playerBlink")
            
            AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
        case .regen:
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(helperRegen(_:)), userInfo: nil, repeats: true)
        case .lavaHit:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperLavaHit(_:)), userInfo: nil, repeats: false)
        case .enemyAttack:
            break
        case .heroAttack:
            break
        }
    }
    
    
    // MARK: - Helper @objc Functions
    
    @objc private func helperDrain(_ sender: Any) {
        var depletionRate: TimeInterval {
            switch counter.getCount() {
            case let num where num > 0.5:   0.01
            default:                        0.005
            }
        }
        
        counter.decrement(by: depletionRate)
        bar.animateAndUpdate(percentage: counter.getCount())
    }
    
    @objc private func helperRegen(_ sender: Any) {
        var regenerationRate: TimeInterval {
            switch counter.getCount() {
            case let num where num > 0.75:  0.005
            default:                        0.01
            }
        }
        
        counter.increment(by: regenerationRate)
        bar.animateAndUpdate(percentage: counter.getCount())
    }
    
    @objc private func helperLavaHit(_ sender: Any) {
        var lavaHit: TimeInterval {
            switch counter.getCount() {
            case let num where num > 0.5:   0.1
            default:                        0.05
            }
        }
        
        counter.decrement(by: lavaHit)
        bar.animateAndUpdate(percentage: counter.getCount())
    }
    
    @objc private func helperEnemyAttack(_ sender: Any) {
        
    }
    
    @objc private func helperHeroAttack(_ sender: Any) {
        
    }
    
    
}
