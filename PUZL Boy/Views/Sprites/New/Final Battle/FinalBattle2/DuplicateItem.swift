//
//  DuplicateItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/12/25.
//

import SpriteKit

class DuplicateItem {
    
    // MARK: - Properties
    
    private let itemsCount: Int = 200
    private(set) var timerDuration: TimeInterval
    private(set) var spawnedItems: [LevelType]
    private(set) var collectedItems: [LevelType]
    
    static let shared: DuplicateItem = {
        let instance = DuplicateItem()

        return instance
    }()
    
    
    // MARK: - Initialization
    
    private init() {
        timerDuration = 5
        spawnedItems = []
        collectedItems = []
    }
    
    
    // MARK: - Functions
    
    /**
     Call this function once, once the chosenSword has been selected!
     */
    func populateSpawnedItems(luck: CGFloat) {
        let items: [(item: LevelType, probability: CGFloat)]
        
        switch luck {
        case let amt where amt <= 0.25:
            timerDuration = 4
            items = [(.sword, 0.20), (.hammer, 0.25), (.gem, 0.50), (.partyFast, 0.05), (.heart, 0.00)]
        case let amt where amt <= 0.50:
            timerDuration = 5
            items = [(.sword, 0.25), (.hammer, 0.25), (.gem, 0.20), (.partyFast, 0.25), (.heart, 0.05)]
        case let amt where amt <= 0.75:
            timerDuration = 6
            items = [(.sword, 0.25), (.hammer, 0.35), (.gem, 0.10), (.partyFast, 0.20), (.heart, 0.10)]
        case let amt where amt <= 0.85:
            timerDuration = 8
            items = [(.sword, 0.10), (.hammer, 0.15), (.gem, 0.00), (.partyFast, 0.50), (.heart, 0.25)]
        default:
            timerDuration = 4
            items = [(.sword, 0.00), (.hammer, 0.00), (.gem, 0.00), (.partyFast, 0.00), (.heart, 1.00)]
        }
        
        spawnedItems = []
        
        for (item, probability) in items {
            spawnedItems += Array(repeating: item, count: Int(probability * CGFloat(itemsCount)))
        }
        
        spawnedItems.shuffle()
    }
    
    /**
     Spawn a power up item. Use when Magmoor duplicate is defeated.
     */
    func spawnItem(at position: K.GameboardPosition, on gameboard: GameboardSprite, delay: TimeInterval) {
        guard !spawnedItems.isEmpty else { return print("DuplicateItem.spawnedItems not populated.") }
        
        let randomIndex = Int.random(in: 0..<spawnedItems.count)
        let item = spawnedItems.remove(at: randomIndex)
        
        gameboard.spawnItem(at: position, with: item, delay: delay, completion: {})
        
        setTimer(at: position, on: gameboard)
    }
    
    /**
     Collects an item [dropped by a defeated duplicate.]
     - parameters:
        - position: the gameboard position in which to check
        - gameboard: the gameboard in question
     - returns: the overlay object found, or nil if none.
     */
    @discardableResult func collectItem(at position: K.GameboardPosition, on gameboard: GameboardSprite) -> LevelType? {
        guard let item = getItem(at: position, on: gameboard) else { return nil }
        
        let itemSprite = item.sprite.copy() as! SKSpriteNode
        itemSprite.zPosition = K.ZPosition.itemsAndEffects
        itemSprite.removeAllActions()
        itemSprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(by: 2, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
        
        gameboard.sprite.addChild(itemSprite)
        
        item.sprite.removeAllActions()
        item.sprite.removeFromParent()
                
        let soundFX: String
        let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
        
        switch item.levelType {
        case .heart:        
            soundFX = "pickupheart"
            feedbackStyle = .soft
            gameboard.addParticles(type: .hearts, at: position)
        case .sword:
            soundFX = "pickupitem"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
        case .hammer:
            soundFX = "pickupitem"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
        case .partyFast:
            soundFX = "gemcollectparty2x"
            feedbackStyle = .medium
        default:
            soundFX = "gemcollect"
            feedbackStyle = .light
            gameboard.addParticles(type: .gemCollect, at: position)
        }
        
        Haptics.shared.addHapticFeedback(withStyle: feedbackStyle)
        AudioManager.shared.playSound(for: soundFX)
        collectedItems.append(item.levelType)
        
        return item.levelType
    }
    
    
    // MARK: - Helper Functions
    
    private func getItem(at position: K.GameboardPosition, on gameboard: GameboardSprite) -> (sprite: SKSpriteNode, levelType: LevelType)? {
        guard let itemSprite = gameboard.getPanelSprite(at: position).overlay, let itemName = itemSprite.texture?.getFilename() else { return nil }
        
        return (itemSprite, LevelType.getLevelType(from: itemName))
    }
    
    private func setTimer(at position: K.GameboardPosition, on gameboard: GameboardSprite) {
        guard let item = getItem(at: position, on: gameboard) else { return }
        
        item.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: timerDuration),
            SKAction.run {
                item.sprite.removeAction(forKey: GameboardSprite.keyOverlayAnimation)
            },
            SKAction.scale(by: 1.25, duration: 1),
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    
}
