//
//  MagmoorDuplicate.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/1/25.
//

import SpriteKit

protocol MagmoorDuplicateDelegate: AnyObject {
    func didDuplicateAttack(playerPosition: K.GameboardPosition)
    func didAttackTimerFire(duplicate: MagmoorDuplicate)
}

class MagmoorDuplicate: SKNode {
    
    // MARK: - Properties
    
    static let duplicateNamePrefix: String = "duplicateMagmoor"
    
    private var gameboard: GameboardSprite
    private var duplicate: Player!
    private(set) var duplicatePosition: K.GameboardPosition?
    private var duplicateAttacks: MagmoorAttacks!
    private var attackTimer: Timer!
    
    weak var delegateDuplicate: MagmoorDuplicateDelegate?
    
    
    // MARK: - Initialization
    
    init(on gameboard: GameboardSprite, index: Int, modelAfter villain: Player) {
        self.gameboard = gameboard
        
        super.init()
        
        self.name = MagmoorDuplicate.getNodeName(at: index)
        setupSprites(modelAfter: villain)
        layoutSprites()
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
        duplicate.sprite.zPosition = K.ZPosition.player + 2
        
        duplicateAttacks = MagmoorAttacks(gameboard: gameboard, villain: duplicate)
        duplicateAttacks.delegateAttacks = self
        
        attackTimer = Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 2...12),
                                           target: self,
                                           selector: #selector(attackTimerFire(_:)),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    private func layoutSprites() {
        gameboard.sprite.addChild(self)
        
        self.addChild(duplicate.sprite)
    }
    
    @objc private func attackTimerFire(_ sender: Any) {
        delegateDuplicate?.didAttackTimerFire(duplicate: self)
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
     - returns: true if so
     - note: yes, you're passing in gameboard here again, even though you initialize it with the object, but because this is a static function, you can't check against the local variable gameboard.
     */
    static func checkIfDuplicatesExist(on gameboard: GameboardSprite) -> Bool {
        for node in gameboard.sprite.children {
            guard let name = node.name, name.hasPrefix(MagmoorDuplicate.duplicateNamePrefix) else { continue }
            
            return true
        }
        
        return false
    }
    
    /**
     Returns the Magmoor duplicate, if it exists at the given position on the gameboard.
     - parameters:
        - position: position to check for existing duplicate
        - gameboard: the gameboard sprite on which to check
     - returns: either the duplicate if found, or nil.
     */
    static func checkForDuplicateAt(position: K.GameboardPosition, on gameboard: GameboardSprite) -> MagmoorDuplicate? {
        let possibleDuplicates = gameboard.sprite.children.filter { $0.name != nil && $0.name!.hasPrefix(MagmoorDuplicate.duplicateNamePrefix) }
        
        guard let magmoorDuplicates = possibleDuplicates as? [MagmoorDuplicate] else { return nil }
        
        return magmoorDuplicates.filter { $0.duplicatePosition != nil && $0.duplicatePosition! == position }.first
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
    
    func attack(playerPosition: K.GameboardPosition) {
        guard let duplicatePosition = duplicatePosition else { return }
        
        facePlayer(playerPosition: playerPosition)
        duplicateAttacks.attack(pattern: .normal, positions: (player: playerPosition, villain: duplicatePosition))
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
        } while positionNew == FinalBattle2Spawner.startPosition || positionNew == FinalBattle2Spawner.endPosition || positionNew == positions.player || positionNew == positions.villain || MagmoorDuplicate.checkForDuplicateAt(position: positionNew, on: gameboard) != nil
        
        return positionNew
    }
    
    ///Flips the duplicate to face player
    private func facePlayer(playerPosition: K.GameboardPosition) {
        guard let duplicatePosition = duplicatePosition else { return }
        
        duplicate.sprite.xScale = (duplicatePosition.col <= playerPosition.col ? 1 : -1) * abs(duplicate.sprite.xScale)
    }
    
    
}


// MARK: - MagmoorAttacksDelegate

extension MagmoorDuplicate: MagmoorAttacksDelegate {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition) {
        delegateDuplicate?.didDuplicateAttack(playerPosition: position)
    }
    
    func didDuplicateAttack(playerPosition: K.GameboardPosition) {
        fatalError("MagmoorDuplicate.didDuplicateAttack() [MagmoorAttacksDelegate] called. This func should never be called (theoretically). If you see this message, something has gone wrong.")
    }
    
    func didDuplicateTimerFire(duplicate: MagmoorDuplicate) {
        fatalError("MagmoorDuplicate.didDuplicateTimerFire() [MagmoorAttacksDelegate] called. This func should never be called (theoretically). If you see this message, something has gone wrong.")
    }
    
    
}
