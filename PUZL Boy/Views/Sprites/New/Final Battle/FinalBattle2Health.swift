//
//  FinalBattle2Health.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/25/24.
//

import SpriteKit

protocol FinalBattle2HealthDelegate: AnyObject {
    func didDrainHealth()
    func didRegenHealth()
}

class FinalBattle2Health {
    
    // MARK: - Properties
    
    private var timer: Timer?
    private var drainTimer: Timer?            //a separate timer is needed for the drain health function
    
    private var counter: Counter!
    private var bar: StatusBarSprite!
    
    enum HealthType {
        case drain, regen, lavaHit, villainAttack, heroAttack
    }
    
    weak var delegate: FinalBattle2HealthDelegate?
    
    
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
            drainTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(helperDrain), userInfo: nil, repeats: true)
            
            delegate?.didDrainHealth()
            
            // FIXME: - Does the hit animation on the player belong here, or should it go in the Engine?
            player.sprite.removeAction(forKey: "playerColorFade")
            player.sprite.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.05),
                SKAction.colorize(withColorBlendFactor: 1, duration: 0.05)
            ])), withKey: "playerBlink")
            
            AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
        case .regen:
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(helperRegen), userInfo: nil, repeats: true)
            
            delegate?.didRegenHealth()
        case .lavaHit:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperLavaHit), userInfo: nil, repeats: false)
        case .villainAttack:
            break
        case .heroAttack:
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperHeroAttack), userInfo: nil, repeats: false)
        }
    }
    
    
    // MARK: - Helper @objc Functions
    
    private func objcHelper(rateDivisions: [CGFloat], rates: [TimeInterval], increment: Bool) {
        guard rates.count > 0 && rates.count > rateDivisions.count else { return }
        
        var rate: TimeInterval {
            //default value is last element in rates array; must be non-zero due to guard check
            var rateReturn: TimeInterval = rates.last!
            
            for (i, rateDivision) in rateDivisions.enumerated() {
                if counter.getCount() > rateDivision {
                    rateReturn = rates[i]
                    break
                }
            }
            
            return rateReturn
        }
        
        if increment {
            counter.increment(by: rate)
        }
        else {
            counter.decrement(by: rate)
        }
        
        bar.animateAndUpdate(percentage: counter.getCount())
    }
    
    @objc private func helperDrain() { objcHelper(rateDivisions: [0.5], rates: [0.01, 0.005], increment: false) }
    @objc private func helperRegen() { objcHelper(rateDivisions: [0.75], rates: [0.005, 0.01], increment: true) }
    @objc private func helperLavaHit() { objcHelper(rateDivisions: [0.5], rates: [0.1, 0.05], increment: false) }
    @objc private func helperVillainAttack() { }
    @objc private func helperHeroAttack() { objcHelper(rateDivisions: [0.5], rates: [0.1, 0.05], increment: true) }
    
    
}
