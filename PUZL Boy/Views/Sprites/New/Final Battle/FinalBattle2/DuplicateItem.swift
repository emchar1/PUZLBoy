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
    
    private var timerSword2x: Timer?
    private var timerSword3x: Timer?
    
    static let shared: DuplicateItem = {
        let instance = DuplicateItem()

        return instance
    }()
    
    
    // MARK: - Initialization
    
    private init() {
        timerDuration = 5
        spawnedItems = []
        collectedItems = []
        
        timerSword2x = nil
        timerSword3x = nil
    }
    
    deinit {
        timerSword2x = nil
        timerSword3x = nil
        
        print("deinit DuplicateItem")
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
            items = [(.sword2x, 0.25), (.sword3x, 0.15), (.gem, 0.60), (.heart, 0.00)]
        case let amt where amt <= 0.50:
            timerDuration = 5
            items = [(.sword2x, 0.30), (.sword3x, 0.20), (.gem, 0.40), (.heart, 0.10)]
        case let amt where amt <= 0.75:
            timerDuration = 6
            items = [(.sword2x, 0.35), (.sword3x, 0.25), (.gem, 0.25), (.heart, 0.15)]
        case let amt where amt <= 0.85:
            timerDuration = 8
            items = [(.sword2x, 0.40), (.sword3x, 0.35), (.gem, 0.00), (.heart, 0.25)]
        default:
            timerDuration = 4
            items = [(.sword2x, 0.00), (.sword3x, 0.00), (.gem, 0.00), (.heart, 1.00)]
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
        case .sword2x:
            soundFX = "gemcollectparty2x"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
            
            let remainingTime: TimeInterval = timerSword2x != nil ? abs(Date().timeIntervalSince(timerSword2x!.fireDate)) : 0
            
            timerSword2x?.invalidate()
            timerSword2x = Timer.scheduledTimer(timeInterval: remainingTime + 30,
                                                target: self,
                                                selector: #selector(setSword2xTimer(_:)),
                                                userInfo: nil,
                                                repeats: false)
            
            NotificationCenter.default.post(name: Notification.Name.didSword2xTimerInitialize, object: nil)
        case .sword3x:
            soundFX = "gemcollectparty3x"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
            
            let remainingTime: TimeInterval = timerSword3x != nil ? abs(Date().timeIntervalSince(timerSword3x!.fireDate)) : 0
            
            timerSword3x?.invalidate()
            timerSword3x = Timer.scheduledTimer(timeInterval: remainingTime + 20,
                                                target: self,
                                                selector: #selector(setSword3xTimer(_:)),
                                                userInfo: nil,
                                                repeats: false)
            
            NotificationCenter.default.post(name: Notification.Name.didSword3xTimerInitialize, object: nil)
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
    
    @objc private func setSword2xTimer(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.didSword2xTimerExpire, object: nil)
        timerSword2x?.invalidate()
        timerSword2x = nil
    }
    
    @objc private func setSword3xTimer(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.didSword3xTimerExpire, object: nil)
        timerSword3x?.invalidate()
        timerSword3x = nil
    }
    
    
}
