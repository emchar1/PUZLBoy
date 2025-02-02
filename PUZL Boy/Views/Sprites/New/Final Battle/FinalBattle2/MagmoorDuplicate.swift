//
//  MagmoorDuplicate.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/1/25.
//

import SpriteKit

class MagmoorDuplicate: SKNode {
    
    // MARK: - Properties
    
    static let duplicateNamePrefix: String = "duplicateMagmoor"
    
    private var duplicate: Player!
    private var gameboard: GameboardSprite
    
    
    // MARK: - Initialization
    
    init(on gameboard: GameboardSprite, modelAfter villain: Player) {
        self.gameboard = gameboard
        
        super.init()
        
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
    }
    
    private func layoutSprites() {
        gameboard.sprite.addChild(self)
        
        self.addChild(duplicate.sprite)
    }
    
    
    // MARK: - Static Functions
    
    /**
     Gets the duplicate node name with the given position.
     - parameter position: the gameboard position for which to buiild the name.
     - returns: the String containing the duplicate prefix and position row, col.
     */
    static func getNodeName(at position: K.GameboardPosition) -> String {
        return "\(MagmoorDuplicate.duplicateNamePrefix)\(position.row)\(GameboardSprite.delimiter)\(position.col)"
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
    
    
    // MARK: - Animation Functions
    
    /**
     Animates the appearance of the duplicate to a random location, and begins the animation sequence.
     - parameter positions: PlayerPositions for which duplicates operates on.
     */
    func animate(with positions: FinalBattle2Controls.PlayerPositions) {
        let randomPosition = generateRandomPosition(checkingAgainst: positions)
        let randomPoint = gameboard.getLocation(at: randomPosition)
        let nodeName = MagmoorDuplicate.getNodeName(at: randomPosition)
        
        //Flips the duplicate to face player
        duplicate.sprite.xScale = (randomPosition.col <= positions.player.col ? 1 : -1) * abs(duplicate.sprite.xScale)
        
        // FIXME: - Not sure if I want to have name dependent on it's original gameboard position???
        //Don't forget to set the node name on the base object itself! (not duplicate.sprite)
        self.name = nodeName
                
        duplicate.sprite.run(Player.animateIdleLevitate(player: duplicate))
        duplicate.sprite.run(SKAction.sequence([
            Player.moveWithIllusions(playerNode: duplicate.sprite,
                                     backgroundNode: gameboard.sprite,
                                     tag: nodeName,
                                     color: .red.darkenColor(factor: 12),
                                     playSound: false,
                                     fierce: true,
                                     startPoint: duplicate.sprite.position,
                                     endPoint: randomPoint,
                                     startScale: 1,
                                     endScale: 1),
            SKAction.move(to: randomPoint, duration: 0),
            SKAction.fadeIn(withDuration: 0)
        ]))
        
        ParticleEngine.shared.animateParticles(type: .magmoorSmoke,
                                               toNode: duplicate.sprite,
                                               position: .zero,
                                               duration: 0)
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
        var possibleDuplicate: MagmoorDuplicate?
        
        repeat {
            positionNew = (row: Int.random(in: 0..<gameboard.panelCount), col: Int.random(in: 0..<gameboard.panelCount))
            possibleDuplicate = gameboard.sprite.childNode(withName: MagmoorDuplicate.getNodeName(at: positionNew)) as? MagmoorDuplicate
        } while positionNew == FinalBattle2Spawner.startPosition || positionNew == FinalBattle2Spawner.endPosition || positionNew == positions.player || positionNew == positions.villain || possibleDuplicate != nil
        
        return positionNew
    }
    
    
}
