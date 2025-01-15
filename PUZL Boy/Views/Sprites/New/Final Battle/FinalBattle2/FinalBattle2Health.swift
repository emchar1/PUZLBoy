//
//  FinalBattle2Health.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/25/24.
//

import SpriteKit

class FinalBattle2Health {
    
    // MARK: - Properties
    
    private let keyPlayerBlink: String = "playerBlink"
    private let keyPlayerColorFade: String = "playerColorFade"
    
    private var timer: Timer?
    private var drainTimer: Timer?            //a separate timer is needed for the drain health function
    private var isDraining: Bool = false
    
    private var player: Player
    private var counter: Counter!
    private var bar: StatusBarSprite!
    private var dmgMultiplier: CGFloat?
    
    enum HealthType {
        case drain, regen, heroAttack, villainAttackNormal, villainAttackTimed, villainShieldExplode
    }
    
    
    // MARK: - Initialization
    
    init(player: Player, position: CGPoint) {
        self.player = player
        
        timer = Timer()
        drainTimer = Timer()
        
        counter = Counter(maxCount: 1, step: 0.01, shouldLoop: false)
        counter.setCount(to: 0.5)
        
        bar = StatusBarSprite(label: "Determination",
                              shouldHide: true,
                              showBackground: false,
                              percentage: counter.getCount(),
                              position: position + CGPoint(x: 0, y: StatusBarSprite.defaultBarHeight + 16))
    }
    
    deinit {
        print("deinit FinalBattle2Health")
    }
    
    
    // MARK: - Functions
    
    func addToParent(_ parent: SKNode) {
        bar.addToParent(parent)
    }
    
    func showHealth() {
        bar.showStatus()
    }
    
    func updateHealth(type: HealthType, dmgMultiplier: CGFloat? = nil) {
        self.dmgMultiplier = dmgMultiplier
        
        resetPlayerActions()
        
        switch type {
        case .drain:
            isDraining = true
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(helperDrain), userInfo: nil, repeats: true)
            makePlayerHurt()
        case .regen:
            isDraining = false
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(helperRegen), userInfo: nil, repeats: false)
        case .heroAttack:
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperHeroAttack), userInfo: nil, repeats: false)
        case .villainAttackNormal:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperVillainAttackNormal), userInfo: nil, repeats: false)
            makePlayerHurt()
        case .villainAttackTimed:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperVillainAttackTimed), userInfo: nil, repeats: false)
            makePlayerHurt()
        case .villainShieldExplode:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperVillainShield), userInfo: nil, repeats: false)
            makePlayerHurt()
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
    
    @objc private func helperDrain() {
        objcHelper(rateDivisions: [0.75, 0.5], rates: [0.02, 0.01, 0.005].map { $0 * (dmgMultiplier ?? 1) }, increment: false)
    }
    
    @objc private func helperRegen() {
        objcHelper(rateDivisions: [], rates: [0.002].map { $0 * (dmgMultiplier ?? 1) }, increment: true)
    }
    
    @objc private func helperHeroAttack() {
        objcHelper(rateDivisions: [], rates: [0.2].map { $0 * (dmgMultiplier ?? 0.5) }, increment: true)
    }
    
    @objc private func helperVillainAttackNormal() {
        objcHelper(rateDivisions: [], rates: [0.1].map { $0 * (dmgMultiplier ?? 1) }, increment: false)
    }
    
    @objc private func helperVillainAttackTimed() {
        objcHelper(rateDivisions: [], rates: [0.05].map { $0 * (dmgMultiplier ?? 1) }, increment: false)
    }
    
    @objc private func helperVillainShield() {
        objcHelper(rateDivisions: [0.5], rates: [0.25, 0.125].map { $0 * (dmgMultiplier ?? 1) }, increment: false)
    }
    
    
    // MARK: - Other Helper Functions
    
    private func resetPlayerActions() {
        if player.sprite.action(forKey: keyPlayerBlink) != nil {
            player.sprite.colorBlendFactor = 1
        }
        
        player.sprite.removeAction(forKey: keyPlayerBlink)
        player.sprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.5), withKey: keyPlayerColorFade)
    }
    
    private func makePlayerHurt() {
        let colorBlinkDuration: TimeInterval = 0.05
        let colorBlinkAction = SKAction.sequence([
            SKAction.colorize(withColorBlendFactor: 0, duration: colorBlinkDuration),
            SKAction.colorize(withColorBlendFactor: 1, duration: colorBlinkDuration)
        ])
        let colorBlinkRepeat = isDraining ? SKAction.repeatForever(colorBlinkAction) : SKAction.repeat(colorBlinkAction, count: 20)
        
        player.sprite.removeAction(forKey: keyPlayerColorFade)
        player.sprite.removeAction(forKey: keyPlayerBlink) //I think this prevents stacking?? Especially if colorBlinkAction is repeatForever..
        player.sprite.run(SKAction.sequence([
            colorBlinkRepeat,
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.5)
        ]), withKey: keyPlayerBlink)
        
        //Prevents multiple voices overlaying if makePlayerHurt() stacks, e.g. from drain + villainAttack
        guard !AudioManager.shared.isPlaying(audioKey: "boypain1") && !AudioManager.shared.isPlaying(audioKey: "boypain2") && !AudioManager.shared.isPlaying(audioKey: "boypain3") && !AudioManager.shared.isPlaying(audioKey: "boypain4") else { return }
        
        AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
        Haptics.shared.executeCustomPattern(pattern: FireIceTheme.isFire ? .lava : .water)
    }
    
    
}
