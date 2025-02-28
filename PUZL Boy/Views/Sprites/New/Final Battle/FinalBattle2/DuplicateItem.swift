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
    private let sword2xTimerIncrement: TimeInterval = 60
    private let sword3xTimerIncrement: TimeInterval = 50
    private let maxSwordTimerIncrement: TimeInterval = 150
    private(set) var spawnTimerDuration: TimeInterval
    
    private(set) var spawnedItems: [LevelType]
    private(set) var collectedItems: [LevelType]
    private var progressBar: CircularProgressBar
    
    private var timer: Timer
    private var timerSword2x: Timer?
    private var timerSword3x: Timer?
    
    static let shared: DuplicateItem = {
        let instance = DuplicateItem()
        
        return instance
    }()
    
    
    // MARK: - Initialization
    
    private init() {
        spawnTimerDuration = 5
        spawnedItems = []
        collectedItems = []
        
        progressBar = CircularProgressBar(chosenSword: ChosenSword(type: FIRManager.chosenSword))
        
        timer = Timer()
        timerSword2x = nil
        timerSword3x = nil
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: true)
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
            spawnTimerDuration = 4
            items = [(.sword2x, 0.25), (.sword3x, 0.15), (.gem, 0.60), (.heart, 0.00)]
        case let amt where amt <= 0.50:
            spawnTimerDuration = 5
            items = [(.sword2x, 0.30), (.sword3x, 0.20), (.gem, 0.40), (.heart, 0.10)]
        case let amt where amt <= 0.75:
            spawnTimerDuration = 6
            items = [(.sword2x, 0.35), (.sword3x, 0.25), (.gem, 0.25), (.heart, 0.15)]
        case let amt where amt <= 0.85:
            spawnTimerDuration = 8
            items = [(.sword2x, 0.40), (.sword3x, 0.35), (.gem, 0.00), (.heart, 0.25)]
        default:
            spawnTimerDuration = 4
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
            
            let remainingTime: TimeInterval = getRemainingTime(timer: timerSword2x)
            
            timerSword2x?.invalidate()
            timerSword2x = Timer.scheduledTimer(timeInterval: min(remainingTime + sword2xTimerIncrement, maxSwordTimerIncrement),
                                                target: self,
                                                selector: #selector(setSword2xTimer(_:)),
                                                userInfo: nil,
                                                repeats: false)
            
            NotificationCenter.default.post(name: Notification.Name.didSword2xTimerInitialize, object: nil)
        case .sword3x:
            soundFX = "gemcollectparty3x"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
            
            let remainingTime: TimeInterval = getRemainingTime(timer: timerSword3x)
            
            timerSword3x?.invalidate()
            timerSword3x = Timer.scheduledTimer(timeInterval: min(remainingTime + sword3xTimerIncrement, maxSwordTimerIncrement),
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
    
    func displaySwordMultiplierHUD(on node: SKNode, at position: CGPoint) {
        guard progressBar.parent == nil else { return }
        
        progressBar.updatePosition(position)
        
        node.addChild(progressBar)
    }
    
    
    // MARK: - Helper Functions
    
    private func getItem(at position: K.GameboardPosition, on gameboard: GameboardSprite) -> (sprite: SKSpriteNode, levelType: LevelType)? {
        guard let itemSprite = gameboard.getPanelSprite(at: position).overlay, let itemName = itemSprite.texture?.getFilename() else { return nil }
        
        return (itemSprite, LevelType.getLevelType(from: itemName))
    }
    
    private func setTimer(at position: K.GameboardPosition, on gameboard: GameboardSprite) {
        guard let item = getItem(at: position, on: gameboard) else { return }
        
        item.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: spawnTimerDuration),
            SKAction.run {
                item.sprite.removeAction(forKey: GameboardSprite.keyOverlayAnimation)
            },
            SKAction.scale(by: 1.25, duration: 1),
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    private func getRemainingTime(timer: Timer?) -> TimeInterval {
        return timer != nil ? abs(Date().timeIntervalSince(timer!.fireDate)) : 0
    }
    
    @objc private func updateTimer(_ sender: Any) {
        let remainingTime2x: TimeInterval = getRemainingTime(timer: timerSword2x)
        let remainingTime3x: TimeInterval = getRemainingTime(timer: timerSword3x)
        let remainingTime: TimeInterval = remainingTime3x > 0 ? remainingTime3x : remainingTime2x
        
        progressBar.setRemainingTime(remainingTime / maxSwordTimerIncrement)
        
        if remainingTime3x > 0 {
            progressBar.setMultiplier(3)
        }
        else if remainingTime2x > 0 {
            progressBar.setMultiplier(2)
        }
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
