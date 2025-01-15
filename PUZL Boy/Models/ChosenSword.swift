//
//  ChosenSword.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/3/24.
//

import SpriteKit

class ChosenSword {
    
    // MARK: - Properties
    
    //Stats properties
    private(set) var type: SwordType
    private(set) var attackRating: CGFloat
    private(set) var shieldDamage: Int = 1
    var attackRatingPercentage: CGFloat { attackRating / 100 }
    
    //Required properties
    private(set) var imageName: String
    private(set) var description: String
    private(set) var elderCommentary: String
    private(set) var spriteNode: SKSpriteNode

    enum SwordType {
        case celestialBroadsword, heavenlySaber, cosmicCleaver, eternalBlade, plainSword
    }
    
    
    // MARK: - Initialization
    
    init(didPursueMagmoor: Bool, didGiveAwayFeather: Bool, bravery: Int?) {
        if !didPursueMagmoor && didGiveAwayFeather && (bravery ?? 0) >= MagmoorCreepyMinion.maxBravery {
            type = .celestialBroadsword
            attackRating = 97
            imageName = "sword1Celestial"
            description = "Celestial Broadsword of Justice"
            elderCommentary = "This sword will get you through the toughest of fights. Thrust downward for maximum damage!"
        }
        else if !didPursueMagmoor {
            type = .heavenlySaber
            attackRating = 82
            imageName = "sword2Heavenly"
            description = "Heavenly Saber of Redemption"
            elderCommentary = "Ooh, that is a good sword! Had to use it on a wraith last week... nasty little buggers!"
        }
        else if didPursueMagmoor && didGiveAwayFeather {
            type = .cosmicCleaver
            attackRating = 74
            shieldDamage = 2
            imageName = "sword3Cosmic"
            description = "Cosmic Cleaver of Purification"
            elderCommentary = "This sword packs a mean punch! Careful!! It's heavy and somewhat cumbersome to wield."
        }
        else if didPursueMagmoor && !didGiveAwayFeather && (bravery ?? 0) > 0 {
            type = .eternalBlade
            attackRating = 61
            shieldDamage = 2
            imageName = "sword4Eternal"
            description = "Blade of Eternal Might"
            elderCommentary = "Not bad at all! Only a few handful of swords are considered mightier than this one..."
        }
        else {
            type = .plainSword
            attackRating = 50
            imageName = "sword"
            description = "Plain Sword"
            elderCommentary = "A plain sword... Well, you've got an uphill battle to climb with this mediocre weapon."
        }
        
        spriteNode = SKSpriteNode(imageNamed: imageName)
    }
    
    
    // MARK: - Functions
    
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
