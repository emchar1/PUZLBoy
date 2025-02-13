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
    
    ///Chances of receiving better drops when defeating Magmoor's Duplicates in Final Battle 2. Out of 1.
    private(set) var luckRating: CGFloat
    
    
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
            defenseRating = 0.6 //80
            piercingBonus = 1
            speedRating = 1.0
            luckRating = 0.61
            
            imageName = "sword1Celestial"
            swordTitle = "Celestial Broadsword of Justice"
            elderCommentary = "Spectacular! This sword will get you through the toughest of fights. Had to use it on a wraith last week... nasty little buggers!"
        case .heavenlySaber:
            attackRating = 0.42
            defenseRating = 0.85 //56
            piercingBonus = 1
            speedRating = 1.5
            luckRating = 0.48
            
            imageName = "sword2Heavenly"
            swordTitle = "Heavenly Saber of Redemption"
            elderCommentary = "Ooh, that is a good blade! Swift and deft. A lightweight weapon that you can swing from any terrain!"
        case .cosmicCleaver:
            attackRating = 0.89
            defenseRating = 0.56 //86
            piercingBonus = 2
            speedRating = 0.75
            luckRating = 0.46
            
            imageName = "sword3Cosmic"
            swordTitle = "Cosmic Cleaver of Purification"
            elderCommentary = "This intimidating sword packs a mean punch! Careful!! It's heavy and somewhat cumbersome to wield in battle."
        case .eternalBlade:
            attackRating = 0.72
            defenseRating = 0.66 //72
            piercingBonus = 1
            speedRating = 1.0
            luckRating = 0.82
            
            imageName = "sword4Eternal"
            swordTitle = "Blade of Eternal Might"
            elderCommentary = "Not bad. Not bad at all! Only a few handful of swords are considered mightier than this one..."
        case .plainSword:
            attackRating = 0.5
            defenseRating = 1.0 //48
            piercingBonus = 1
            speedRating = 1.0
            luckRating = 0.25
            
            imageName = "sword"
            swordTitle = "Plain Sword"
            elderCommentary = "A plain sword... Well, you've got an uphill battle to climb with this mediocre weapon."
        }
        
        let attackPercentString: String = "\(Int(attackRating * 100))"
        let defensePercentString: String = "\(Int(48.0 / defenseRating))"
        let piercingBonusString: String = "+\(piercingBonus)"
        let speedRatingString: String = "\(String(format: "%.1f", speedRating))x"
        let luckRatingString: String = "\(Int(luckRating * 100))"
        
        statsString = "Attack: \(attackPercentString)          Defense: \(defensePercentString)"
        statsString += "\nPiercing: \(piercingBonusString)      Speed: \(speedRatingString)"
        statsString += "\nLuck: \(luckRatingString)"
        
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
     - parameters:
        - facing: the direction the player is facing. Typically just send in xScale and the function will determine which direction it's facing if xScale is negative or positive.
        - shouldParry: if true, don't rotate the sprite but shake it, and add a parry sound fx
        - completion: completion handler once (most of) the action is complete (see warning)
     > Warning: spriteNode will not remove itself from parent node until after the sword is done fading out, i.e. 0.5s after completion handler has executed.
     */
    func attack(facing: CGFloat, shouldParry: Bool, completion: (() -> Void)?) {
        let facingCoefficient: CGFloat = facing < 0 ? -1 : 1
        let parryAction: SKAction = shouldParry ? SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05)
        ]) : SKAction.rotate(byAngle: -3 * .pi / 2 * facingCoefficient, duration: 0.25)
        
        spriteNode.xScale = facingCoefficient * abs(spriteNode.xScale)
        
        spriteNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: 0.25),
            parryAction,
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
