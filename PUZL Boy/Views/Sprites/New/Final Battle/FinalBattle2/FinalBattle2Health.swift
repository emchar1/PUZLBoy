//
//  FinalBattle2Health.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/25/24.
//

import SpriteKit

protocol FinalBattle2HealthDelegate: AnyObject {
    func didUpdateHealth(_ healthCounter: Counter, increment: TimeInterval, damping: TimeInterval)
}

class FinalBattle2Health {
    
    // MARK: - Properties
    
    //Action Keys
    static let keyPlayerBlink: String = "playerBlink"
    static let keyPlayerColorFade: String = "playerColorFade"
    
    //Timers
    private var timer: Timer?
    private var drainTimer: Timer?
    private var poisonTimer: Timer?
    
    //Poisoned/Drained status
    private var isDraining: Bool = false
    private var poisonCounter: Int?
    var isPoisoned: Bool { return poisonCounter != nil }
    
    //Misc.
    var isRunningSword8: Bool = false
    private var player: Player
    private var bar: StatusBarSprite!
    private var dmgMultiplier: CGFloat?
    private(set) var counter: Counter! {
        // TODO: - This determines whether or not you beat Magmoor, essentially winning or losing the game.
        didSet {
            if counter.counterDidReachMin {
                NotificationCenter.default.post(name: .completeGameDidLose, object: nil)
            }
        }
    }
    
    enum HealthType {
        case drain, drainPoison, stopDrain, heroAttack, villainAttackNormal, villainAttackFreeze, villainAttackPoison, villainAttackTimed, villainShieldExplode, destroyDuplicate, healthUp
    }
    
    weak var delegateHealth: FinalBattle2HealthDelegate?
    
    
    // MARK: - Initialization
    
    init(player: Player, position: CGPoint) {
        self.player = player
        
        timer = Timer()
        drainTimer = Timer()
        poisonTimer = Timer()
        
        counter = Counter(maxCount: 1, step: 0.01, shouldLoop: false)
        counter.setCount(to: 0.5)
        
        bar = StatusBarSprite(label: "Courage", shouldHide: true, showBackground: false, percentage: counter.getCount(), position: position)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        
        drainTimer?.invalidate()
        drainTimer = nil
        
        poisonTimer?.invalidate()
        poisonTimer = nil
        
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
        func drainPoison() {
            poisonCounter = 0
            poisonTimer?.invalidate()
            poisonTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(helperPoisonDrain), userInfo: nil, repeats: true)
            makePlayerHurt(color: .green)
        }
        
        self.dmgMultiplier = dmgMultiplier
        
        resetPlayerActions()
        
        switch type {
        case .drain:
            isDraining = true
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(helperDrain), userInfo: nil, repeats: true)
            makePlayerHurt()
        case .drainPoison:
            guard !isPoisoned else { return } //prevents stacking of poison damage!
            drainPoison()
            AudioManager.shared.playSound(for: "movepoisoned2")
        case .stopDrain:
            isDraining = false
            drainTimer?.invalidate()
            drainTimer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(stopDrain), userInfo: nil, repeats: false)
        case .heroAttack:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperHeroAttack), userInfo: nil, repeats: false)
        case .villainAttackNormal:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperVillainAttackNormal), userInfo: nil, repeats: false)
            makePlayerHurt()
        case .villainAttackFreeze:
            playBoyHurtSFX()
        case .villainAttackPoison:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperVillainAttackPoison), userInfo: nil, repeats: false)
            drainPoison()
        case .villainAttackTimed:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperVillainAttackTimed), userInfo: nil, repeats: false)
            makePlayerHurt()
        case .villainShieldExplode:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperVillainShield), userInfo: nil, repeats: false)
            makePlayerHurt()
        case .destroyDuplicate:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperDestroyDuplicate), userInfo: nil, repeats: false)
        case .healthUp:
            timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(helperHealthUp), userInfo: nil, repeats: false)
        }
    }
    
    /**
     Call this to deinitialize the object. The actions, or the attachment to parent prevents it from deinitializing properly...
     */
    func cleanup() {
        timer?.invalidate()
        timer = nil
        
        drainTimer?.invalidate()
        drainTimer = nil
        
        poisonTimer?.invalidate()
        poisonTimer = nil
    }
    
    
    // MARK: - Helper @objc Functions
    
    private func objcHelper(damage: CGFloat, increment: Bool) {
        guard !counter.counterDidReachMin && !counter.counterDidReachMax else { return }
        
        var health: CGFloat { counter.getCount() }
        var healthDiff: CGFloat { counter.maxCount - health }
        
        let incrementValue: CGFloat = health < 0.5 ? max(2 * healthDiff, 1) : max(min(2 * healthDiff, 1), 0.1) //[0.1, 1], [1, 2]
        let decrementValue: CGFloat = max(min(4 * health, 1), 0.1) //[0.1, 1]
        let rateDamping: CGFloat = increment ? incrementValue : decrementValue
        let damageAdjusted = damage * (dmgMultiplier ?? 1)
                
        counter.increment(by: (increment ? 1 : -1) * damageAdjusted * rateDamping)
        bar.animateAndUpdate(percentage: health)
        
        // TODO: - I'm only using this protocol function to report back the damage.
        delegateHealth?.didUpdateHealth(counter, increment: (increment ? 1 : -1) * damageAdjusted, damping: rateDamping)
    }
    
    @objc private func helperDrain() {
        guard counter.getCount() > 0.01 else {
            drainTimer?.invalidate()
            return
        }
        
        objcHelper(damage: 0.01, increment: false)
    }
    
    @objc private func stopDrain() {
        guard counter.getCount() < 0.99 else {
            drainTimer?.invalidate()
            return
        }
        
        objcHelper(damage: 0.00, increment: true)
    }
    
    @objc private func helperPoisonDrain() {
        guard let poisonCounter = poisonCounter, poisonCounter < 5, counter.getCount() > 0.02 else {
            self.poisonCounter = nil
            poisonTimer?.invalidate()
            resetPlayerActions()
            return
        }
        
        self.poisonCounter! += 1
        objcHelper(damage: 0.02, increment: false)
    }
    
    @objc private func helperHeroAttack() {
        objcHelper(damage: 0.2, increment: true)
        
        // TODO: - This determines whether or not you beat Magmoor, essentially winning or losing the game.
        if counter.counterDidReachMax {
            bar.removeStatus(flashMaxBravery: true, completion: {})
            
            NotificationCenter.default.post(name: .completeGameDidWin, object: nil)
        }
    }
    
    @objc private func helperVillainAttackNormal() {
        objcHelper(damage: 0.1, increment: false)
    }
    
    @objc private func helperVillainAttackPoison() {
        objcHelper(damage: 0.08, increment: false)
    }
    
    @objc private func helperVillainAttackTimed() {
        objcHelper(damage: 0.2, increment: false)
    }
    
    @objc private func helperVillainShield() {
        objcHelper(damage: 0.25, increment: false)
    }
    
    @objc private func helperDestroyDuplicate() {
        objcHelper(damage: 0.005, increment: true)
    }
    
    @objc private func helperHealthUp() {
        objcHelper(damage: 0.1, increment: true)
    }
    
    
    // MARK: - Other Helper Functions
    
    private func resetPlayerActions() {
        //Don't run hurt actions if a freeze action is in place!!
        guard player.sprite.action(forKey: FinalBattle2Controls.keyPlayerFreezeAction) == nil else { return }
        guard !isPoisoned else { return } //..or if poisoned!!
        
        if player.sprite.action(forKey: FinalBattle2Health.keyPlayerBlink) != nil {
            player.sprite.colorBlendFactor = 1
        }
        
        player.sprite.removeAction(forKey: FinalBattle2Health.keyPlayerBlink)
        player.sprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.5), withKey: FinalBattle2Health.keyPlayerColorFade)
    }
    
    private func makePlayerHurt(color: UIColor = .red) {
        playBoyHurtSFX()
        
        //Don't run hurt actions if a freeze action is in place, or if holding infinity sword!!
        guard player.sprite.action(forKey: FinalBattle2Controls.keyPlayerFreezeAction) == nil else { return }
        guard !isRunningSword8 else { return }
        
        let colorBlinkDuration: TimeInterval = 0.05
        let colorBlinkAction = SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 0, duration: colorBlinkDuration),
            SKAction.colorize(with: color, colorBlendFactor: 1, duration: colorBlinkDuration)
        ])
        let colorBlinkRepeat = isDraining || isPoisoned ? SKAction.repeatForever(colorBlinkAction) : SKAction.repeat(colorBlinkAction, count: 20)
        
        player.sprite.removeAction(forKey: FinalBattle2Health.keyPlayerColorFade)
        player.sprite.removeAction(forKey: FinalBattle2Health.keyPlayerBlink) //I think this prevents stacking?? Especially if colorBlinkAction is repeatForever..
        player.sprite.run(SKAction.sequence([
            colorBlinkRepeat,
            SKAction.colorize(with: color, colorBlendFactor: 0, duration: 0.5)
        ]), withKey: FinalBattle2Health.keyPlayerBlink)
    }
    
    private func playBoyHurtSFX() {
        //Prevents multiple voices overlaying if makePlayerHurt() stacks, e.g. from drain + villainAttack
        guard !AudioManager.shared.isPlaying(audioKey: "boypain1")
                && !AudioManager.shared.isPlaying(audioKey: "boypain2")
                && !AudioManager.shared.isPlaying(audioKey: "boypain3")
                && !AudioManager.shared.isPlaying(audioKey: "boypain4")
                && !AudioManager.shared.isPlaying(audioKey: "boyattack1")
                && !AudioManager.shared.isPlaying(audioKey: "boyattack2")
                && !AudioManager.shared.isPlaying(audioKey: "boyattack3") else { return }
        
        AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
        Haptics.shared.executeCustomPattern(pattern: FireIceTheme.isFire ? .lava : .water)
    }
    
    
}
