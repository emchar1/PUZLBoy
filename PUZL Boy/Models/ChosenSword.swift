//
//  ChosenSword.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/3/24.
//

import SpriteKit

class ChosenSword: SKNode {
    
    // MARK: - Properties
    
    static let namePrefix: String = "chosenSword_"
    var chosenSwordName: String { "\(ChosenSword.namePrefix)\(type.rawValue)" }
    
    
    //Stats Properties
    
    ///Percentage out of 100. Simple. Use totalAttackRating, which takes into account the attackMultiplier.
    private var attackRating: CGFloat
    
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
    
    
    //Attack Multiplier
    static let infiniteMultiplier: CGFloat = 99
    private var numberFormatter: NumberFormatter
    private var attackMultiplierSprite: SKSpriteNode
    private(set) var attackMultiplier: CGFloat = 1
    var totalAttackRating: CGFloat { attackRating * attackMultiplier }
    
    
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
            attackRating = 0.59
            defenseRating = 0.56 //86
            piercingBonus = 2
            speedRating = 0.75
            luckRating = 0.46
            
            imageName = "sword3Cosmic"
            swordTitle = "Cosmic Cleaver of Purification"
            elderCommentary = "This intimidating sword packs a mean punch! It can slice through armor like butter. Careful!! It's heavy and somewhat cumbersome to wield in battle."
        case .eternalBlade:
            attackRating = 0.5
            defenseRating = 0.66 //72
            piercingBonus = 1
            speedRating = 1.0
            luckRating = 0.82
            
            imageName = "sword4Eternal"
            swordTitle = "Blade of Eternal Might"
            elderCommentary = "Not bad at all! Only a few handful of swords are considered mightier than this one... You might even get lucky now and then!"
        case .plainSword:
            attackRating = 0.3
            defenseRating = 1.0 //48
            piercingBonus = 1
            speedRating = 1.0
            luckRating = 0.25
            
            imageName = "sword"
            swordTitle = "Plain Sword"
            elderCommentary = "A plain sword... Well, you've got an uphill battle to climb with this sad little weapon."
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
        spriteNode.alpha = 0
        
        attackMultiplierSprite = SKSpriteNode(texture: SKTexture(imageNamed: "multiplier2x"))
        attackMultiplierSprite.alpha = 0
        attackMultiplierSprite.zPosition = 50
        
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1
        
        super.init()
        
        name = chosenSwordName
        
        addChild(spriteNode)
        addChild(attackMultiplierSprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.group([
                SKAction.rotate(byAngle: rotations * (direction == .up || direction == .right ? -1 : 1), duration: throwDuration),
                SKAction.moveBy(x: endOffset.x, y: endOffset.y, duration: throwDuration),
            ]),
            SKAction.fadeOut(withDuration: 0.5)
        ]))
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))", delay: delay ?? 0)
        AudioManager.shared.playSound(for: "swordthrow", delay: delay ?? 0)
    }
    
    /**
     Actually execute the completion earlier, i.e. before the sword fades away. This helps with timing of heath drop/increase, etc.
     - parameters:
        - position: point on the gameboard to load the sprite
        - facing: the direction the player is facing. Typically just send in xScale and the function will determine which direction it's facing if xScale is negative or positive.
        - showMultiplier: show the attackMultiplier after the sword animation.
        - shouldParry: if true, don't rotate the sprite but shake it, and add a parry sound fx
        - completion: completion handler once (most of) the action is complete (see warning)
     > Warning: spriteNode will not remove itself from parent node until after the sword is done fading out, i.e. 0.5s after completion handler has executed.
     */
    func attack(at position: CGPoint, facing: CGFloat, showMultiplier: Bool, shouldParry: Bool, completion: (() -> Void)?) {
        let facingCoefficient: CGFloat = facing < 0 ? -1 : 1
        let spriteScale: CGFloat = type == .plainSword ? 1 : 1.5
        let parryAction: SKAction = shouldParry ? SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05)
        ]) : SKAction.rotate(byAngle: -3 * .pi / 2 * facingCoefficient, duration: 0.25)
        
        self.position = position
        spriteNode.xScale = facingCoefficient * spriteScale
        spriteNode.yScale = spriteScale
        
        spriteNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: 0.25),
            parryAction,
            SKAction.run {
                completion?()
            },
            SKAction.fadeAlpha(to: 0, duration: 0.5),
            SKAction.rotate(toAngle: 0, duration: 0)
        ]))
        
        if showMultiplier {
            attackMultiplierSprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.fadeIn(withDuration: 0),
                SKAction.group([
                    SKAction.scale(to: 2, duration: 0.5),
                    SKAction.sequence([
                        attackMultiplier == ChosenSword.infiniteMultiplier ? SKAction.rotate(byAngle: 2 * .pi, duration: 0.4) : SKAction.wait(forDuration: 0.4),
                        SKAction.group([
                            SKAction.scale(to: 6, duration: 0.1),
                            SKAction.fadeOut(withDuration: 0.1)
                        ])
                    ])
                ]),
                SKAction.scale(to: 1, duration: 0)
            ]))
        }
        
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
    
    func setAttackMultiplier(_ multiplier: CGFloat) {
        attackMultiplier = multiplier
        
        switch multiplier {
        case 2:                                 attackMultiplierSprite.texture = SKTexture(imageNamed: "multiplier2x")
        case 3:                                 attackMultiplierSprite.texture = SKTexture(imageNamed: "multiplier3x")
        case ChosenSword.infiniteMultiplier:    attackMultiplierSprite.texture = SKTexture(imageNamed: "multiplier8")
        default:                                break
        }
    }
    
    
}
