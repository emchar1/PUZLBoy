//
//  MagmoorDuplicate.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/1/25.
//

import SpriteKit

protocol MagmoorDuplicateDelegate: AnyObject {
    func didDuplicateAttack(pattern: MagmoorAttacks.AttackPattern, playerPosition: K.GameboardPosition)
    func didDuplicateTimerFire(duplicate: MagmoorDuplicate)
    func didExplodeDuplicate()
}

class MagmoorDuplicate: SKNode {
    
    // MARK: - Properties
    
    static let duplicateNamePrefix: String = "duplicateMagmoor"
    
    private var gameboard: GameboardSprite
    private(set) var duplicatePattern: DuplicateAttackPattern
    private var attackType: MagmoorAttacks.AttackPattern
    private var attackTimer: Timer?
    
    private(set) var duplicate: Player!
    private var duplicateAttacks: MagmoorAttacks!
    private(set) var invincibleShield: MagmoorShield?
    private(set) var duplicatePosition: K.GameboardPosition?
    
    enum DuplicateAttackPattern: CaseIterable {
        case player, random, invincible
    }
    
    weak var delegateDuplicate: MagmoorDuplicateDelegate?
    
    
    // MARK: - Initialization
    
    init(on gameboard: GameboardSprite, index: Int, duplicatePattern: DuplicateAttackPattern, attackType: MagmoorAttacks.AttackPattern, attackSpeed: TimeInterval, modelAfter villain: Player) {
        self.gameboard = gameboard
        self.duplicatePattern = duplicatePattern
        self.attackType = attackType
        self.attackTimer = Timer()
        
        super.init()
        
        self.name = MagmoorDuplicate.getNodeName(at: index)
        
        setupSprites(modelAfter: villain)
        layoutSprites()
        setAttackTimer(speed: attackSpeed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        attackTimer?.invalidate()
        attackTimer = nil
        
        print("deinit \(self.name ?? "MagmoorDuplicate")")
    }
    
    private func setupSprites(modelAfter villain: Player) {
        duplicate = Player(type: .villain)
        duplicate.sprite.position = villain.sprite.position
        duplicate.sprite.xScale = villain.sprite.xScale
        duplicate.sprite.yScale = villain.sprite.yScale
        duplicate.sprite.alpha = 0
        duplicate.sprite.zPosition = K.ZPosition.player + 1
        
        duplicateAttacks = MagmoorAttacks(gameboard: gameboard, villain: duplicate)
        duplicateAttacks.delegateAttacks = self
    }
    
    private func layoutSprites() {
        gameboard.sprite.addChild(self)
        
        self.addChild(duplicate.sprite)
    }
    
    @objc private func attackTimerFire(_ sender: Any) {
        delegateDuplicate?.didDuplicateTimerFire(duplicate: self)
    }
    
    
    // MARK: - Static Functions
    
    /**
     Gets the duplicate node name at the given index.
     - parameter index: the index for which to buiild the name.
     - returns: the String containing the duplicate prefix and index.
     */
    static func getNodeName(at index: Int) -> String {
        return "\(MagmoorDuplicate.duplicateNamePrefix)\(index)"
    }
    
    /**
     Checks if gameboard has a duplicate anywhere on its board.
     - parameter gameboard: the gameboard sprite on which to check
     - returns: count of duplicates, 0 if none found
     */
    static func getDuplicatesCount(on gameboard: GameboardSprite) -> Int {
        guard let magmoorDuplicates = getMagmoorDuplicates(on: gameboard) else { return 0 }
        
        return magmoorDuplicates.count
    }
    
    /**
     Returns the Magmoor duplicate, if it exists at the given position on the gameboard.
     - parameters:
        - position: position to check for existing duplicate
        - gameboard: the gameboard sprite on which to check
     - returns: either the duplicate if found, or nil.
     */
    static func getDuplicateAt(position: K.GameboardPosition, on gameboard: GameboardSprite) -> MagmoorDuplicate? {
        guard let magmoorDuplicates = getMagmoorDuplicates(on: gameboard) else { return nil }
        
        return magmoorDuplicates.filter { $0.duplicatePosition != nil && $0.duplicatePosition! == position }.first
    }
    
    /**
     Returns all the Magmoor duplicates on the gameboard, if they exist.
     - parameter gameboard: the gameboard sprite on which to check
     - returns: the list of duplicates, or nil if there are none.
     */
    static func getMagmoorDuplicates(on gameboard: GameboardSprite) -> [MagmoorDuplicate]? {
        let possibleDuplicates = gameboard.sprite.children.filter { $0.name != nil && $0.name!.hasPrefix(MagmoorDuplicate.duplicateNamePrefix) }
        let magmoorDuplicates = possibleDuplicates as? [MagmoorDuplicate]
        
        return magmoorDuplicates
    }
    
    /**
     Checks if there's at least one invincible duplicate on the gameboard, if not, update hasInvincible property.
     - parameter gameboard: the gameboard sprite on which to check
     */
    static func hasInvincibles(on gameboard: GameboardSprite) -> Bool {
        guard let magmoorDuplicates = getMagmoorDuplicates(on: gameboard) else { return false }
        
        return magmoorDuplicates.filter { $0.duplicatePattern == .invincible }.first != nil
    }
    
    /**
     Given a position on the gameboard, ensures there is an exit (unobstructed) panel adjacent to it, for PUZL Boy to get to.
     - parameters:
        - position: position to check for exit path
        - gameboard: the gameboard sprite on which to check
     - returns: true if an exit path exists.
     */
    static func hasAnExit(at position: K.GameboardPosition, on gameboard: GameboardSprite) -> Bool {
        func isPanelFree(_ position: K.GameboardPosition) -> Bool {
            let outOfBounds = position.row < 0 || position.row >= gameboard.panelCount || position.col < 0 || position.col >= gameboard.panelCount
            let noDuplicate = getDuplicateAt(position: position, on: gameboard) == nil
            
            return !outOfBounds && noDuplicate
        }
        
        let positionAbove: K.GameboardPosition = (position.row, position.col - 1)
        let positionBelow: K.GameboardPosition = (position.row, position.col + 1)
        let positionLeft: K.GameboardPosition = (position.row - 1, position.col)
        let positionRight: K.GameboardPosition = (position.row + 1, position.col)
        
        return isPanelFree(positionAbove) || isPanelFree(positionBelow) || isPanelFree(positionLeft) || isPanelFree(positionRight)
    }
    
    
    // MARK: - Animation Functions
    
    /**
     Animates the appearance of the duplicate to a random location, and begins the animation sequence.
     - parameter positions: PlayerPositions for which duplicates operates on.
     */
    func animate(with positions: FinalBattle2Controls.PlayerPositions) {
        duplicatePosition = generateRandomPosition(checkingAgainst: positions)
        let duplicatePoint = gameboard.getLocation(at: duplicatePosition!)
        
        facePlayer(playerPosition: positions.player)
        
        duplicate.sprite.run(Player.animateIdleLevitate(player: duplicate))
        duplicate.sprite.run(SKAction.sequence([
            Player.moveWithIllusions(playerNode: duplicate.sprite,
                                     backgroundNode: gameboard.sprite,
                                     tag: self.name ?? MagmoorDuplicate.getNodeName(at: -1),
                                     color: .red.darkenColor(factor: 12),
                                     playSound: false,
                                     fierce: false,
                                     startPoint: duplicate.sprite.position,
                                     endPoint: duplicatePoint,
                                     startScale: 1,
                                     endScale: 1),
            SKAction.move(to: duplicatePoint, duration: 0),
            SKAction.fadeIn(withDuration: 0)
        ]))
        
        ParticleEngine.shared.animateParticles(type: .magmoorSmoke,
                                               toNode: duplicate.sprite,
                                               position: .zero,
                                               zPosition: 2,
                                               duration: 0)
    }
    
    /**
     Adds an invincible shield to the duplicate.
     */
    func addInvincibleShield() {
        let hasInvincibleShield = MagmoorDuplicate.hasInvincibles(on: gameboard)
        let isNotItselfInvincible = duplicatePattern != .invincible
        
        invincibleShield = MagmoorShield(makeInvincible: hasInvincibleShield && isNotItselfInvincible, duplicate: duplicate)
    }
    
    /**
     Initiates a wand attack from the duplicate to the playerPosition.
     - parameter playerPosition: the position where the player is.
     */
    func attack(playerPosition: K.GameboardPosition) {
        guard let duplicatePosition = duplicatePosition else { return }
        
        let positionToAttack: K.GameboardPosition
        
        switch duplicatePattern {
        case .player:
            positionToAttack = playerPosition
        case .random:
            positionToAttack = (Int.random(in: 0..<gameboard.panelCount), Int.random(in: 0..<gameboard.panelCount))
        case .invincible:
            positionToAttack = playerPosition
        }
        
        facePlayer(playerPosition: positionToAttack)
        duplicateAttacks.attack(pattern: attackType, level: invincibleShield?.resetCount ?? 0, playSFX: false, positions: (player: positionToAttack, villain: duplicatePosition))
    }
    
    /**
     Destroys the duplicate and removes it from the gameboard.
     - parameters:
        - playerHealth: player's current health
        - chosenSwordLuck: the chosenSword's luck value
        - itemSpawnLevel: indicates the level of items that will drop
        - resetCount: number of times Magmoor's shield was broken
        - completion: completion handler, executes at end of explosion action.
     */
    func explode(playerHealth: CGFloat, chosenSwordLuck: CGFloat, itemSpawnLevel: DuplicateItem.ItemSpawnLevel, resetCount: Int, completion: @escaping () -> Void) {
        let waitDuration: TimeInterval = 0.25
        let fadeDuration: TimeInterval = 0.25
        let hasInvinciblesOriginal = MagmoorDuplicate.hasInvincibles(on: gameboard)
        
        attackTimer?.invalidate()
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ])) { [weak self] in
            guard let self = self else { return }
            
            let hasInvinciblesNew = MagmoorDuplicate.hasInvincibles(on: gameboard)
            
            delegateDuplicate?.didExplodeDuplicate()
            
            //Here you're seeing if the duplicate you're exploding is the one casting the invincible shield spell...
            guard !hasInvinciblesNew && hasInvinciblesOriginal, let duplicates = MagmoorDuplicate.getMagmoorDuplicates(on: gameboard) else {
                completion()
                return
            }
            
            //...and if so, break the invincible shield on all the dupes.
            duplicates.forEach { $0.invincibleShield?.breakInvincibleShield(completion: completion) }
        }
        
        if let duplicatePosition = duplicatePosition {
            // FIXME: - 4th pass through of player health!!!
            DuplicateItem.shared.spawnItem(at: duplicatePosition,
                                           on: gameboard, delay: waitDuration,
                                           playerHealth: playerHealth,
                                           chosenSwordLuck: chosenSwordLuck,
                                           itemSpawnLevel: itemSpawnLevel,
                                           resetCount: resetCount)
        }
        
        AudioManager.shared.playSound(for: "enemydeath")
        ParticleEngine.shared.animateParticles(type: .magicExplosion1_5,
                                               toNode: gameboard.sprite,
                                               position: duplicate.sprite.position,
                                               scale: UIDevice.spriteScale / CGFloat(gameboard.panelCount),
                                               zPosition: duplicate.sprite.zPosition + 2,
                                               duration: 2)
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Generates a new, UNIQUE random position for the duplicate to move to, as long as it doesn't coincide with a start position, end position, player position, villain position, or an existing duplicate position.
     - returns: the new, random position
     */
    private func generateRandomPosition(checkingAgainst positions: FinalBattle2Controls.PlayerPositions) -> K.GameboardPosition {
        var positionNew: K.GameboardPosition
        
        repeat {
            positionNew = (row: Int.random(in: 0..<gameboard.panelCount), col: Int.random(in: 0..<gameboard.panelCount))
        }
        while positionNew == FinalBattle2Spawner.startPosition
                || positionNew == FinalBattle2Spawner.endPosition
                || positionNew == positions.player
                || positionNew == positions.villain
                || MagmoorDuplicate.getDuplicateAt(position: positionNew, on: gameboard) != nil
                || !MagmoorDuplicate.hasAnExit(at: positionNew, on: gameboard)
        
        return positionNew
    }
    
    ///Flips the duplicate to face player
    private func facePlayer(playerPosition: K.GameboardPosition) {
        guard let duplicatePosition = duplicatePosition else { return }
        
        duplicate.sprite.xScale = (duplicatePosition.col <= playerPosition.col ? 1 : -1) * abs(duplicate.sprite.xScale)
    }
    
    /**
     Sets and fires the attackTimer.
     - parameter speed: the new attackTimer interval
     */
    private func setAttackTimer(speed: TimeInterval) {
        attackTimer?.invalidate()
        attackTimer = Timer.scheduledTimer(timeInterval: speed,
                                           target: self,
                                           selector: #selector(attackTimerFire(_:)),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    
}


// MARK: - MagmoorAttacksDelegate

extension MagmoorDuplicate: MagmoorAttacksDelegate {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition) {
        delegateDuplicate?.didDuplicateAttack(pattern: pattern, playerPosition: position)
    }
    
    
}
