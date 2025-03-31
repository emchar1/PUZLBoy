//
//  MagmoorAttacks.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/11/25.
//

import SpriteKit

protocol MagmoorAttacksDelegate: AnyObject {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition)
}

protocol MagmoorAttacksDuplicateDelegate: AnyObject {
    func didDuplicateAttack(pattern: MagmoorAttacks.AttackPattern, playerPosition: K.GameboardPosition)
    func didDuplicateTimerFire(duplicate: MagmoorDuplicate)
    func didExplodeDuplicate()
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
    
    private let wandAnimationDelay: TimeInterval = 0.25
    private var fireballPosition: CGPoint { villain.sprite.position + getWandOffset(villain) }
    
    enum AttackPattern: CaseIterable {
        case normal, freeze, poison, sNormal, sFreeze, sPoison, timed, timedLarge, duplicates, castInvincible
    }
    
    weak var delegateAttacks: MagmoorAttacksDelegate?
    weak var delegateAttacksDuplicate: MagmoorAttacksDuplicateDelegate?
    
    
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
//        print("deinit MagmoorAttacks")
    }
    
    
    // MARK: - Functions
    
    /**
     Generates an attack pattern based on probability.
     - parameters:
        - enrage: if true, always returns normal attack
        - level: determines attack pattern
        - shieldHP: Magmoor shield's current level
        - isFeatured: if attackRound just started, default to this attack to showcase the new attack
     - returns: the attack pattern generated
     */
    static func getAttackPattern(enrage: Bool, level: Int, shieldHP: Int, isFeatured: Bool) -> AttackPattern {
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
            guard !isFeatured else { attackPattern = .timed; break }
            
            if randomInts[0].isMultiple(of: 5) { attackPattern = .freeze }                  //20%
            else if randomInts[0].isMultiple(of: 2) {                                       //40%
                if randomInts[1].isMultiple(of: 2) { attackPattern = .normal }                  //50%
                else { attackPattern = .sNormal }                                               //50%
            }
            else if randomInts[0].isMultiple(of: 3) { attackPattern = .poison }             //14%
            else { attackPattern = .timed }                                                 //26%
        case let levelCheck where levelCheck >= 4:
            guard !isFeatured else { attackPattern = .duplicates; break }
            
            if levelCheck == 4 || shieldHP > 3 {
                if randomInts[0].isMultiple(of: 5) { attackPattern = .sFreeze }                 //20%
                else if randomInts[0].isMultiple(of: 2) { attackPattern = .sNormal }            //40%
                else if randomInts[0].isMultiple(of: 3) { attackPattern = .sPoison }            //14%
                else {                                                                          //26%
                    if randomInts[1].isMultiple(of: [2, 3]) { attackPattern = .duplicates }         //67%
                    else { attackPattern = Bool.random() ? .timed : .timedLarge }                   //17% : 16%
                }
            }
            else {
                if randomInts[0].isMultiple(of: 3) { attackPattern = .duplicates }              //33%
                else if shieldHP > 1 { attackPattern = Bool.random() ? .normal : .timed }       //33% : 34%
                else { attackPattern = Bool.random() ? .sNormal : .timedLarge }                 //34% : 33%
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
    func attack(pattern: AttackPattern, level: Int, playSFX: Bool = true, positions: FinalBattle2Controls.PlayerPositions) {
        timedCanHurtPlayer = true
        timedCanHurtVillain = true
        
        let wandColor: UIColor
        
        switch pattern {
        case .normal, .sNormal:
            wandColor = .orange
            
            villain.sprite.run(SKAction.wait(forDuration: wandAnimationDelay)) { [weak self] in
                if pattern == .normal {
                    self?.helperNormal(pattern: .normal, positions: positions)
                }
                else {
                    self?.helperSpread(pattern: .sNormal, positions: positions)
                }
            }
        case .freeze, .sFreeze:
            wandColor = .cyan
            
            villain.sprite.run(SKAction.wait(forDuration: wandAnimationDelay)) { [weak self] in
                if pattern == .freeze {
                    self?.helperNormal(pattern: .freeze, positions: positions)
                }
                else {
                    self?.helperSpread(pattern: .sFreeze, positions: positions)
                }
            }
        case .poison, .sPoison:
            wandColor = .green
            
            villain.sprite.run(SKAction.wait(forDuration: wandAnimationDelay)) { [weak self] in
                if pattern == .poison {
                    self?.helperNormal(pattern: .poison, positions: positions)
                }
                else {
                    self?.helperSpread(pattern: .sPoison, positions: positions)
                }
            }
        case .timed:
            wandColor = .magenta
            
            villain.sprite.run(SKAction.wait(forDuration: wandAnimationDelay)) { [weak self] in
                self?.helperTimed(positions: positions, isLarge: false)
            }
        case .timedLarge:
            wandColor = .purple
            
            villain.sprite.run(SKAction.wait(forDuration: wandAnimationDelay)) { [weak self] in
                self?.helperTimed(positions: positions, isLarge: true)
            }
        case .duplicates:
            wandColor = .black
            
            villain.sprite.run(SKAction.wait(forDuration: wandAnimationDelay)) { [weak self] in
                let duplicateCount = max(3, min((level - 1), 6))
                
                self?.helperDuplicates(count: duplicateCount, positions: positions)
            }
        case .castInvincible:
            wandColor = .purple
            
            villain.sprite.run(SKAction.wait(forDuration: wandAnimationDelay)) { [weak self] in
                self?.helperCastInvincibleShields(positions: positions)
            }
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
        
        villain.castSpell(color: color)
        villain.sprite.run(Player.animate(player: villain, type: .attack, repeatCount: 1))
        villain.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: wandAnimationDelay),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                                
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
        ]))
        
        if playSFX {
            AudioManager.shared.playSound(for: "villainattack\(Int.random(in: 1...2))", interruptPlayback: false)
        }
        
        AudioManager.shared.playSound(for: "villainattackwand", interruptPlayback: false)
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
    
    func explodeDuplicate(at position: K.GameboardPosition, playerHealth: CGFloat, chosenSwordLuck: CGFloat, itemSpawnLevel: DuplicateItem.ItemSpawnLevel, resetCount: Int, completion: @escaping (Bool) -> Void) {
        guard let duplicate = MagmoorDuplicate.getDuplicateAt(position: position, on: gameboard) else { return }
        
        let fadeDuration: TimeInterval = 1
        
        // FIXME: - 3rd pass through of player health
        duplicate.explode(playerHealth: playerHealth, chosenSwordLuck: chosenSwordLuck, itemSpawnLevel: itemSpawnLevel, resetCount: resetCount) { [weak self] in
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
     Returns the direction (xScale) that the passed in villain Player is facing.
     - parameter villain: really any Player object passed in
     - returns: the direction facing, either left or right, -1 or 1 (or vice versa I can't remember lol)
     */
    private func getFacingDirection(_ villain: Player) -> CGFloat {
        return villain.sprite.xScale > 0 ? -1 : 1
    }
    
    /**
     Returns the CGPoint offset from the origin of the tip of the wand of the villain.
     - parameter villain: really any Player object passed in
     - returns: the offset from the wand tip
     */
    private func getWandOffset(_ villain: Player) -> CGPoint {
        return CGPoint(x: Player.mysticWandOrigin.x * getFacingDirection(villain), y: Player.mysticWandOrigin.y)
    }
    
    /**
     Helper function to setup and launch normal, freeze and poison fireballs.
     */
    private func helperNormal(pattern: AttackPattern, positions: FinalBattle2Controls.PlayerPositions) {
        let fireball = Fireball(type: pattern, rotationOrigin: villain.sprite.position, positions: positions, gameboard: gameboard)
        fireball.position = fireballPosition
        fireball.zPosition = K.ZPosition.itemsAndEffects
        
        fireball.setFireballSpeed(fireballSpeed)
        fireball.playFireballAudio()
        
        fireball.launchFireball(facingDirection: getFacingDirection(villain)) { [weak self] in
            self?.delegateAttacks?.didVillainAttack(pattern: pattern, position: positions.player)
        }
    }
    
    /**
     Helper function to set up and launch a spread of normal fireballs.
     */
    private func helperSpread(pattern: AttackPattern, positions: FinalBattle2Controls.PlayerPositions) {
        let spreadSize: Int = 5
        var explodePositions: [K.GameboardPosition] = []
        
        for i in 0..<spreadSize {
            let midpoint: Int = Int(floor(Float(spreadSize) / 2))
            let rowOffset: Int
            let colOffset: Int
            let row: Int
            let col: Int
            
            switch positions.villain.row - positions.player.row {
            case let diff where diff < 0:   colOffset = midpoint - i
            case let diff where diff > 0:   colOffset = i - midpoint
            default:                        colOffset = 0
            }
            
            switch positions.villain.col - positions.player.col {
            case let diff where diff < 0:   rowOffset = i - midpoint
            case let diff where diff > 0:   rowOffset = midpoint - i
            default:                        rowOffset = 0
            }

            row = min(max(positions.player.row + rowOffset, 0), gameboard.panelCount - 1)
            col = min(max(positions.player.col + colOffset, 0), gameboard.panelCount - 1)
            
            let explodePosition: K.GameboardPosition = (row, col)
            
            //Don't add if the fireball position is already in the array
            if !explodePositions.contains(where: { $0.row == explodePosition.row && $0.col == explodePosition.col }) {
                explodePositions.append(explodePosition)
            }
        }
        
        for (i, explodePosition) in explodePositions.enumerated() {
            let fireball = Fireball(type: pattern,
                                    rotationOrigin: villain.sprite.position,
                                    positions: (explodePosition, positions.villain),
                                    gameboard: gameboard)
            fireball.position = fireballPosition
            fireball.zPosition = K.ZPosition.itemsAndEffects
            
            fireball.setFireballSpeed(fireballSpeed)
            
            if i == 0 {
                fireball.playFireballAudio()
            }
            
            fireball.launchFireball(facingDirection: getFacingDirection(villain)) { [weak self] in
                self?.delegateAttacks?.didVillainAttack(pattern: pattern, position: explodePosition)
            }
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
            
            bomb.launchTimed(facingDirection: getFacingDirection(villain), canPlaySound: i == 0) { [weak self] randomPosition in
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
        
        var duplicates: [MagmoorDuplicate] = []
        
        for i in 0..<count {
            let duplicateSetup: (duplicatePattern: MagmoorDuplicate.DuplicateAttackPattern, attackType: AttackPattern, attackSpeed: TimeInterval)
            
            switch i {
            case 0:     duplicateSetup = (.player, count > 4 ? .sNormal : .normal, 3)
            case 1:     duplicateSetup = (.player, .freeze, 4)
            case 2:     duplicateSetup = (.random, .poison, 2)
            default:    duplicateSetup = (.invincible, .castInvincible, 1.5)
            }
            
            let duplicate = MagmoorDuplicate(on: gameboard,
                                             index: i,
                                             duplicatePattern: duplicateSetup.duplicatePattern,
                                             attackType: duplicateSetup.attackType,
                                             attackSpeed: duplicateSetup.attackSpeed,
                                             modelAfter: villain)
            duplicate.animate(with: positions)
            duplicate.delegateDuplicate = self
            
            duplicates.append(duplicate)
        }
        
        //Need to run this AFTER setting up, above due to invincible duplicate initializing not at the 0th index!
        for i in 0..<count {
            duplicates[i].addInvincibleShield()
        }
    }
    
    private func helperCastInvincibleShields(positions: FinalBattle2Controls.PlayerPositions) {
        guard let duplicate = MagmoorDuplicate.getDuplicateAt(position: positions.villain, on: gameboard),
              duplicate.duplicatePattern == .invincible,
              let duplicatePosition = duplicate.duplicatePosition else { return }
        
        let shieldDuration: TimeInterval = 0.25
        
        let tinyPurpleShield = SKSpriteNode(imageNamed: "magmoorShieldTop")
        tinyPurpleShield.position = gameboard.getLocation(at: duplicatePosition) + getWandOffset(duplicate.duplicate)
        tinyPurpleShield.color = .magenta
        tinyPurpleShield.colorBlendFactor = 1
        tinyPurpleShield.setScale(0)
        tinyPurpleShield.zPosition = K.ZPosition.itemsAndEffects
        
        gameboard.sprite.addChild(tinyPurpleShield)
        
        tinyPurpleShield.run(SKAction.rotate(byAngle: (getFacingDirection(duplicate.duplicate) > 0 ? -1 : 1) * .pi, duration: 4 * shieldDuration))
        tinyPurpleShield.run(SKAction.sequence([
            SKAction.scale(to: 0.75, duration: shieldDuration),
            SKAction.wait(forDuration: shieldDuration),
            SKAction.group([
                SKAction.fadeAlpha(to: 0, duration: 2 * shieldDuration),
                SKAction.scale(to: 0.5, duration: 2 * shieldDuration)
            ]),
            SKAction.removeFromParent()
        ]))
        
        AudioManager.shared.playSound(for: "shieldcast2")
    }
    
    
}


// MARK: - MagmoorDuplicateDelegate

extension MagmoorAttacks: MagmoorDuplicateDelegate {
    func didDuplicateAttack(pattern: MagmoorAttacks.AttackPattern, playerPosition: K.GameboardPosition) {
        delegateAttacksDuplicate?.didDuplicateAttack(pattern: pattern, playerPosition: playerPosition)
    }
    
    func didDuplicateTimerFire(duplicate: MagmoorDuplicate) {
        delegateAttacksDuplicate?.didDuplicateTimerFire(duplicate: duplicate)
    }
    
    func didExplodeDuplicate() {
        delegateAttacksDuplicate?.didExplodeDuplicate()
    }
}
