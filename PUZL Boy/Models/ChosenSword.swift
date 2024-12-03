//
//  ChosenSword.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/3/24.
//

import SpriteKit

struct ChosenSword {
    private(set) var spriteNode: SKSpriteNode
    private(set) var type: SwordType
    private(set) var attackRating: CGFloat
    private(set) var description: String
    private(set) var elderCommentary: String

    enum SwordType {
        case celestialSword, heavenlySaber, cosmicCleaver, eternalBlade
    }
    
    init(didPursueMagmoor: Bool, didGiveAwayFeather: Bool) {
        if !didPursueMagmoor && didGiveAwayFeather {
            spriteNode = SKSpriteNode(imageNamed: "sword1Celestial")
            type = .celestialSword
            attackRating = 97
            description = "Celestial Sword of Justice"
            elderCommentary = "This sword will get you through the toughest of fights. Thrust downward for maximum damage!"
        }
        else if !didPursueMagmoor && !didGiveAwayFeather {
            spriteNode = SKSpriteNode(imageNamed: "sword2Heavenly")
            type = .heavenlySaber
            attackRating = 82
            description = "Heavenly Saber of Redemption"
            elderCommentary = "Ooh, that is a good sword! Had to use it on a wraith last week... nasty little buggers!"
        }
        else if didPursueMagmoor && didGiveAwayFeather {
            spriteNode = SKSpriteNode(imageNamed: "sword3Cosmic")
            type = .cosmicCleaver
            attackRating = 74
            description = "Cosmic Cleaver of Purification"
            elderCommentary = "This sword packs a mean punch! Careful!! It's heavy and somewhat cumbersome to wield."
        }
        else if didPursueMagmoor && !didGiveAwayFeather {
            spriteNode = SKSpriteNode(imageNamed: "sword4Eternal")
            type = .eternalBlade
            attackRating = 61
            description = "Blade of Eternal Might"
            elderCommentary = "Not bad. Not bad at all! Though there are other swords that are mightier than this one..."
        }
        else {
            spriteNode = SKSpriteNode(imageNamed: "sword")
            type = .heavenlySaber
            attackRating = 0
            description = "Default Sword"
            elderCommentary = "Default case, should not reach here."
        }
        
        print("Pursue: \(didPursueMagmoor), Give: \(didGiveAwayFeather)")
    }
    
    
    
}
