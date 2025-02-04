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
}

class MagmoorDuplicate: SKNode {
    
    // MARK: - Properties
    
    static let duplicateNamePrefix: String = "duplicateMagmoor"
    
    private var gameboard: GameboardSprite
    private var duplicate: Player!
    private var duplicatePosition: K.GameboardPosition?
    private var duplicateAttacks: MagmoorAttacks!
    private var attackType: DuplicateAttackPattern
    private var lastAttackPosition: K.GameboardPosition
    private var attackTimer: Timer
    
    enum DuplicateAttackPattern: CaseIterable {
        case player, random, sweeping
    }
    
    weak var delegateDuplicate: MagmoorDuplicateDelegate?
    
    
    // MARK: - Initialization
    
    init(on gameboard: GameboardSprite, index: Int, duplicateAttackType: DuplicateAttackPattern, modelAfter villain: Player) {
        self.gameboard = gameboard
        self.attackType = duplicateAttackType
        self.lastAttackPosition = (0, 0)
        self.attackTimer = Timer()
        
        super.init()
        
        let attackSpeed: TimeInterval
        
        switch attackType {
        case .player:
            attackSpeed = 5
        case .random:
            attackSpeed = 3
        case .sweeping:
            attackSpeed = 2
        }
        
        self.name = MagmoorDuplicate.getNodeName(at: index)
        
        setupSprites(modelAfter: villain)
        layoutSprites()
        setAttackTimer(speed: attackSpeed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
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
                                     fierce: true,
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
                                               duration: 0)
    }
    
    /**
     Initiates a wand attack from the duplicate to the playerPosition.
     - parameter playerPosition: the position where the player is.
     */
    func attack(playerPosition: K.GameboardPosition) {
        guard let duplicatePosition = duplicatePosition else { return }
        
        let randomAttackPattern: MagmoorAttacks.AttackPattern
        let positionToAttack: K.GameboardPosition
        
        switch attackType {
        case .player:
            positionToAttack = playerPosition
        case .random:
            positionToAttack = (Int.random(in: 0..<gameboard.panelCount), Int.random(in: 0..<gameboard.panelCount))
        case .sweeping:
            positionToAttack = lastAttackPosition
            advanceNextAttackPosition()
        }
        
        switch Int.random(in: 1...3) {
        case 1:     randomAttackPattern = .normal
        case 2:     randomAttackPattern = .freeze
        case 3:     randomAttackPattern = .poison
        default:    randomAttackPattern = .normal
        }
        
        facePlayer(playerPosition: positionToAttack)
        duplicateAttacks.attack(pattern: .normal, playSFX: false, positions: (player: positionToAttack, villain: duplicatePosition))
    }
    
    /**
     Destroys the duplicate and removes it from the gameboard.
     - parameters:
        - direction: direction of the attack
        - completion: completion handler, executes at end of explosion action.
     */
    func explode(completion: @escaping () -> Void) {
        let waitDuration: TimeInterval = 0.25
        let fadeDuration: TimeInterval = 0.25
        
        attackTimer.invalidate()
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ]), completion: completion)
        
        AudioManager.shared.playSound(for: "enemydeath")
        ParticleEngine.shared.animateParticles(type: .magicElderFire3,
                                               toNode: gameboard.sprite,
                                               position: duplicate.sprite.position,
                                               scale: UIDevice.spriteScale / CGFloat(gameboard.panelCount),
                                               zPosition: duplicate.sprite.zPosition - 2,
                                               duration: 2)
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
        } while positionNew == FinalBattle2Spawner.startPosition || positionNew == FinalBattle2Spawner.endPosition || positionNew == positions.player || positionNew == positions.villain || MagmoorDuplicate.getDuplicateAt(position: positionNew, on: gameboard) != nil
        
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
        attackTimer.invalidate()
        attackTimer = Timer.scheduledTimer(timeInterval: speed,
                                           target: self,
                                           selector: #selector(attackTimerFire(_:)),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    private func advanceNextAttackPosition() {
        guard lastAttackPosition.row < gameboard.panelCount - 1 || lastAttackPosition.col < gameboard.panelCount - 1 else {
            lastAttackPosition = (0, 0)
            return
        }
        
        //Set row BEFORE setting col!
        lastAttackPosition.row = lastAttackPosition.col >= gameboard.panelCount - 1 ? lastAttackPosition.row + 1 : lastAttackPosition.row
        lastAttackPosition.col = lastAttackPosition.col >= gameboard.panelCount - 1 ? 0 : lastAttackPosition.col + 1
    }
    
    
}


// MARK: - MagmoorAttacksDelegate

extension MagmoorDuplicate: MagmoorAttacksDelegate {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition) {
        delegateDuplicate?.didDuplicateAttack(pattern: pattern, playerPosition: position)
    }
    
    func didDuplicateAttack(pattern: MagmoorAttacks.AttackPattern, playerPosition: K.GameboardPosition) {
        fatalError("MagmoorDuplicate.didDuplicateAttack() [MagmoorAttacksDelegate] called. This func should never be called (theoretically). If you see this message, something has gone wrong.")
    }
    
    func didDuplicateTimerFire(duplicate: MagmoorDuplicate) {
        fatalError("MagmoorDuplicate.didDuplicateTimerFire() [MagmoorAttacksDelegate] called. This func should never be called (theoretically). If you see this message, something has gone wrong.")
    }
    
    
}
