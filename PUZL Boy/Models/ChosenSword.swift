//
//  ChosenSword.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/3/24.
//

import SpriteKit

class ChosenSword {
    
    // MARK: - Properties
    
    static let namePrefix: String = "chosenSword_"
    var chosenSwordName: String { "\(ChosenSword.namePrefix)\(type.rawValue)" }
    
    
    //Stats Properties
    
    ///Percentage out of 100. Simple.
    private(set) var attackRating: CGFloat
    
    ///The lower the number, the greater the defense, i.e. damage received. Standard = 1.
    private(set) var defenseRating: CGFloat
    
    ///Magmoor's shield decrement amount. Higher number = more shield damage. Standard = 1.
    private(set) var piercingBonus: Int
    
    ///Movement speed in the final battle 2. Higher = faster.
    private(set) var speedRating: TimeInterval
    
    
    //Required properties
    private(set) var type: SwordType
    private(set) var imageName: String
    private(set) var swordTitle: String
    private(set) var elderCommentary: String
    private(set) var statsString: String
    private(set) var spriteNode: SKSpriteNode

    enum SwordType: Int, CaseIterable {
        case celestialBroadsword = 0, heavenlySaber, cosmicCleaver, eternalBlade, plainSword
    }
    
    
    // MARK: - Initialization
    
    init(type: Int?) {
        self.type = SwordType(rawValue: type ?? 4) ?? .eternalBlade
        
        switch self.type {
        case .celestialBroadsword:
            attackRating = 0.97
            defenseRating = 0.5
            piercingBonus = 1
            speedRating = 1.0
            
            imageName = "sword1Celestial"
            swordTitle = "Celestial Broadsword of Justice"
            elderCommentary = "Spectacular! This sword will get you through the toughest of fights. Thrust downward for maximum damage!"
        case .heavenlySaber:
            attackRating = 0.82
            defenseRating = 0.8
            piercingBonus = 1
            speedRating = 1.5
            
            imageName = "sword2Heavenly"
            swordTitle = "Heavenly Saber of Redemption"
            elderCommentary = "Ooh, that is a good sword! Had to use it on a wraith last week... nasty little buggers!"
        case .cosmicCleaver:
            attackRating = 0.74
            defenseRating = 1.0
            piercingBonus = 2
            speedRating = 1.0
            
            imageName = "sword3Cosmic"
            swordTitle = "Cosmic Cleaver of Purification"
            elderCommentary = "This sword packs a mean punch! Careful!! It's heavy and somewhat cumbersome to wield."
        case .eternalBlade:
            attackRating = 0.61
            defenseRating = 1.0
            piercingBonus = 2
            speedRating = 1.0
            
            imageName = "sword4Eternal"
            swordTitle = "Blade of Eternal Might"
            elderCommentary = "Not bad at all! Only a few handful of swords are considered mightier than this one..."
        case .plainSword:
            attackRating = 0.5
            defenseRating = 1.0
            piercingBonus = 1
            speedRating = 1.0
            
            imageName = "sword"
            swordTitle = "Plain Sword"
            elderCommentary = "A plain sword... Well, you've got an uphill battle to climb with this mediocre weapon."
        }
        
        let attackPercentString: String = "\(Int(attackRating * 100))"
        let defensePercentString: String = "\(Int(48.0 / defenseRating))"
        let piercingBonusString: String = "+\(piercingBonus)"
        let speedRatingString: String = "\(String(format: "%.1f", speedRating))x"
        
        statsString = "Attack: \(attackPercentString)          Defense: \(defensePercentString)"
        statsString += "\nPiercing: \(piercingBonusString)      Speed: \(speedRatingString)"
        
        spriteNode = SKSpriteNode(imageNamed: imageName)
        spriteNode.name = chosenSwordName
    }
    
    deinit {
        print("deinit ChosenSword")
    }
    
    
    // MARK: - Functions
    
    /**
     Checks availability of the sword based on storyline decisions and bravery.
     */
    static func isAvailable(type: ChosenSword.SwordType) -> Bool {
        let swordAvailable: Bool
        let bravery = FIRManager.bravery ?? 0

        switch type {
        case .celestialBroadsword:
            swordAvailable = !FIRManager.didPursueMagmoor && FIRManager.didGiveAwayFeather && bravery >= MagmoorCreepyMinion.maxBravery
        case .heavenlySaber:
            swordAvailable = !FIRManager.didPursueMagmoor
        case .cosmicCleaver:
            swordAvailable = FIRManager.didPursueMagmoor && FIRManager.didGiveAwayFeather
        case .eternalBlade:
            swordAvailable = FIRManager.didPursueMagmoor && bravery > 0
        case .plainSword:
            swordAvailable = true
        }
        
        return swordAvailable
    }
    
    func throwSword(endOffset: CGPoint, direction: Controls, rotations: CGFloat, throwDuration: TimeInterval, delay: TimeInterval?) {
        spriteNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.group([
                SKAction.rotate(byAngle: rotations * (direction == .up || direction == .right ? -1 : 1), duration: throwDuration),
                SKAction.moveBy(x: endOffset.x, y: endOffset.y, duration: throwDuration),
            ]),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))", delay: delay ?? 0)
        AudioManager.shared.playSound(for: "swordthrow", delay: delay ?? 0)
    }
    
    /**
     Actually execute the completion earlier, i.e. before the sword fades away. This helps with timing of heath drop/increase, etc.
     > Warning: spriteNode will not remove itself from parent node until after the sword is done fading out, i.e. 0.5s after completion handler is ready to execute.
     */
    func attack(shouldParry: Bool, completion: (() -> Void)?) {
        spriteNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: 0.25),
            SKAction.rotate(byAngle: -3 * .pi / 2, duration: 0.25),
            SKAction.run {
                completion?()
            },
            SKAction.fadeAlpha(to: 0, duration: 0.5),
            SKAction.rotate(toAngle: 0, duration: 0),
            SKAction.removeFromParent()
        ]))
        
        if shouldParry {
            AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...2))")
            AudioManager.shared.playSound(for: "swordparry")
            Haptics.shared.addHapticFeedback(withStyle: .heavy)
        }
        else {
            AudioManager.shared.playSound(for: "boyattack3")
            AudioManager.shared.playSound(for: "swordslash")
            Haptics.shared.executeCustomPattern(pattern: .killEnemy)
        }
    }
    
    
}
