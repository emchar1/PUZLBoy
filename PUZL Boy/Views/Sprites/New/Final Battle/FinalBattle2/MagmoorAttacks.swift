//
//  MagmoorAttacks.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/11/25.
//

import SpriteKit

protocol MagmoorAttacksDelegate: AnyObject {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition)
    func didDuplicateAttack(playerPosition: K.GameboardPosition)
    func didDuplicateTimerFire(duplicate: MagmoorDuplicate)
}

class MagmoorAttacks {
    
    // MARK: - Properties
    
    private var gameboard: GameboardSprite
    private var villain: Player
    
    private var fireballSpeed: TimeInterval
    private var timedBombCount: (normal: Int, large: Int)
    private var timedCanHurtPlayer: Bool
    private var timedCanHurtVillain: Bool
    private(set) var villainIsVisible: Bool
    
    private var villainDirection: CGFloat { villain.sprite.xScale > 0 ? -1 : 1 }
    private var fireballPosition: CGPoint {
        villain.sprite.position + CGPoint(x: Player.mysticWandOrigin.x * villainDirection, y: Player.mysticWandOrigin.y)
    }
    
    enum AttackPattern: CaseIterable {
        case normal, freeze, poison, timed, timedLarge, duplicates
    }
    
    weak var delegateAttacks: MagmoorAttacksDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, villain: Player) {
        self.gameboard = gameboard
        self.villain = villain
        
        fireballSpeed = 0.5
        timedBombCount = (normal: 3, large: 1)
        timedCanHurtPlayer = true
        timedCanHurtVillain = true
        villainIsVisible = true
    }
    
    deinit {
        print("deinit MagmoorAttacks")
    }
    
    
    // MARK: - Functions
    
    /**
     Generates an attack pattern based on probability.
     - parameters:
        - enrage: if true, always returns normal attack
        - level: determines attack pattern
        - isFeatured: if attackRound just started, default to this attack to showcase the new attack
     - returns: the attack pattern generated
     */
    static func getAttackPattern(enrage: Bool, level: Int, isFeatured: Bool) -> AttackPattern {
        let attackPattern: AttackPattern
        let normalPattern: AttackPattern
        let poisonPattern: AttackPattern
        var randomInts: [Randomizer] = []
        
        for _ in 0..<3 {
            randomInts.append(Randomizer())
        }
        
        normalPattern = randomInts[0].isMultiple(of: 5) ? .freeze : .normal                 //20% : 80%
        poisonPattern = randomInts[0].isMultiple(of: 5) ? .freeze : (randomInts[0].isMultiple(of: [2, 3]) ? .normal : .poison)  //20% : 54% : 26%
        
        //Enrage short-circuit case
        guard !enrage else { return level <= 3 ? normalPattern : poisonPattern }
        
        switch level {
        case let levelCheck where levelCheck <= 1:
            attackPattern = normalPattern
        case 2:
            guard !isFeatured else { attackPattern = .poison; break }
            
            attackPattern = poisonPattern
        case 3:
            guard !isFeatured else { attackPattern = Bool.random() ? .timed : .timedLarge; break }
            
            if randomInts[0].isMultiple(of: 5) { attackPattern = .freeze }                  //20%
            else if randomInts[0].isMultiple(of: 2) { attackPattern = .normal }             //40%
            else if randomInts[0].isMultiple(of: 3) { attackPattern = .poison }             //14%
            else {                                                                          //26%
                if randomInts[1].isMultiple(of: [2, 3]) { attackPattern = .timed }              //67%
                else { attackPattern = .timedLarge }                                            //33%
            }
        case let levelCheck where levelCheck >= 4:
            guard !isFeatured else { attackPattern = .duplicates; break }
            
            if randomInts[0].isMultiple(of: 5) { attackPattern = .freeze }                  //20%
            else if randomInts[0].isMultiple(of: 2) { attackPattern = .normal }             //40%
            else if randomInts[0].isMultiple(of: 3) { attackPattern = .poison }             //14%
            else {                                                                          //26%
                if randomInts[1].isMultiple(of: [2, 3]) { attackPattern = .duplicates }         //67%
                else { attackPattern = Bool.random() ? .timed : .timedLarge }                   //17% : 16%
            }
        default:
            attackPattern = .normal
        }
        
        return attackPattern
    }
    
    func timedBombCanHurtVillain() -> Bool {
        guard timedCanHurtVillain else { return false }
        
        timedCanHurtVillain = false
        
        return true
    }
    
    func timedBombCanHurtPlayer() -> Bool {
        guard timedCanHurtPlayer else { return false }
        
        timedCanHurtPlayer = false
        
        return true
    }
    
    /**
     Initiates one of Magmoor's various wand attacks.
     - parameters:
        - pattern: attack pattern type
        - playSFX: determines whether to play villain attack and sound FXs or to mute them
        - positions: the player and villain gameboard positions.
     */
    func attack(pattern: AttackPattern, playSFX: Bool = true, positions: FinalBattle2Controls.PlayerPositions) {
        timedCanHurtPlayer = true
        timedCanHurtVillain = true
        
        let wandColor: UIColor
        
        switch pattern {
        case .normal:
            wandColor = .yellow
            helperNormal(pattern: .normal, positions: positions)
        case .freeze:
            wandColor = .cyan
            helperNormal(pattern: .freeze, positions: positions)
        case .poison:
            wandColor = .green
            helperNormal(pattern: .poison, positions: positions)
        case .timed:
            wandColor = .magenta
            helperTimed(positions: positions, isLarge: false)
        case .timedLarge:
            wandColor = .purple
            helperTimed(positions: positions, isLarge: true)
        case .duplicates:
            wandColor = .black
            helperDuplicates(count: 4, positions: positions)
        }
        
        executeAttackAnimation(color: wandColor, playSFX: playSFX)
    }
    
    /**
     Executes an attack animation with sound and particles.
     - parameters:
        - color: color of the wand particle
        - playSFX: if true, play villainattack and villainattackwand SFX's
     */
    private func executeAttackAnimation(color: UIColor, playSFX: Bool) {
        let colorSequence = SKKeyframeSequence(keyframeValues: [
            UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
            color
        ], times: [0, 1])
        
        villain.sprite.run(Player.animate(player: villain, type: .attack, repeatCount: 1))
        villain.castSpell(color: color)
        
        if playSFX {
            AudioManager.shared.playSound(for: "villainattack\(Int.random(in: 1...2))")
            AudioManager.shared.playSound(for: "villainattackwand")
        }
        
        ParticleEngine.shared.animateParticles(type: .magicBlastPoof,
                                               toNode: gameboard.sprite,
                                               position: fireballPosition,
                                               scale: 1,
                                               colorSequence: colorSequence,
                                               zPosition: K.ZPosition.player + 4,
                                               duration: 2)
        
        ParticleEngine.shared.animateParticles(type: .warp,
                                               toNode: gameboard.sprite,
                                               position: fireballPosition,
                                               scale: 1,
                                               zPosition: K.ZPosition.player + 2,
                                               duration: 2)
    }
    
    
    // MARK: - Setter Functions
    
    func setFireballSpeed(_ newValue: CGFloat) {
        fireballSpeed = newValue
    }
    
    func setTimedBombNormalCount(_ newValue: Int) {
        timedBombCount.normal = newValue
    }
    
    func setTimedBombLargeCount(_ newValue: Int) {
        timedBombCount.large = newValue
    }
    
    
    // MARK: - Magmoor Duplicate Functions
    
    func explodeDuplicate(at position: K.GameboardPosition, completion: @escaping (Bool) -> Void) {
        guard let duplicate = MagmoorDuplicate.getDuplicateAt(position: position, on: gameboard) else { return }
        
        let fadeDuration: TimeInterval = 1
        
        duplicate.explode { [weak self] in
            guard let self = self else { return }
            
            //Bring back Magmoor once all the duplicates have been exploded
            if MagmoorDuplicate.getDuplicatesCount(on: gameboard) <= 0 {
                villainIsVisible = true
                villain.sprite.run(SKAction.fadeIn(withDuration: fadeDuration))
            }
            
            completion(self.villainIsVisible)
        }
    }
    
    
    // MARK: - Attack Helper Functions
    
    /**
     Helper function to setup and launch normal, freeze and poison fireballs.
     */
    private func helperNormal(pattern: AttackPattern, positions: FinalBattle2Controls.PlayerPositions) {
        let fireball = Fireball(type: pattern, rotationOrigin: villain.sprite.position, positions: positions, gameboard: gameboard)
        fireball.position = fireballPosition
        fireball.zPosition = K.ZPosition.itemsAndEffects
        
        fireball.setFireballSpeed(fireballSpeed)
        fireball.playFireballAudio()
        
        fireball.launchFireball(facingDirection: villainDirection) { [weak self] in
            self?.delegateAttacks?.didVillainAttack(pattern: pattern, position: positions.player)
        }
    }
    
    /**
     Helper function to setup and launch timed bombs.
     */
    private func helperTimed(positions: FinalBattle2Controls.PlayerPositions, isLarge: Bool) {
        for i in 0..<(isLarge ? timedBombCount.large : timedBombCount.normal) {
            let bomb = Fireball(type: isLarge ? .timedLarge : .timed, rotationOrigin: villain.sprite.position, positions: positions, gameboard: gameboard)
            bomb.position = fireballPosition
            bomb.zPosition = K.ZPosition.player - 10
            
            bomb.launchTimed(facingDirection: villainDirection, canPlaySound: i == 0) { [weak self] randomPosition in
                self?.delegateAttacks?.didVillainAttack(pattern: isLarge ? .timedLarge : .timed, position: randomPosition)
            }
        }
    }
    
    /**
     Employs the duplicate attack pattern.
     */
    private func helperDuplicates(count: Int, positions: FinalBattle2Controls.PlayerPositions) {
        villainIsVisible = false
        
        villain.sprite.run(SKAction.fadeOut(withDuration: 1))
        delegateAttacks?.didVillainAttack(pattern: .duplicates, position: positions.villain)
        
        for i in 0..<count {
            let duplicate = MagmoorDuplicate(on: gameboard, index: i, modelAfter: villain)
            duplicate.animate(with: positions)
            duplicate.delegateDuplicate = self
        }
    }
    
    
}


// MARK: - MagmoorDuplicateDelegate

extension MagmoorAttacks: MagmoorDuplicateDelegate {
    func didDuplicateAttack(playerPosition: K.GameboardPosition) {
        delegateAttacks?.didDuplicateAttack(playerPosition: playerPosition)
    }
    
    func didAttackTimerFire(duplicate: MagmoorDuplicate) {
        delegateAttacks?.didDuplicateTimerFire(duplicate: duplicate)
    }
    
    
}
