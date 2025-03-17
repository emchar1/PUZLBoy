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
    private var progressHUD: ProgressHUDManager
    
    private var spawnTimerDuration: TimeInterval
    private var timer: Timer
    
    private(set) var spawnedItems: [LevelType]
    private(set) var collectedItems: [LevelType]
    
    static let shared: DuplicateItem = {
        let instance = DuplicateItem()
        
        return instance
    }()
    
    
    // MARK: - Initialization
    
    private init() {
        spawnTimerDuration = 5
        progressHUD = ProgressHUDManager()
        
        spawnedItems = []
        collectedItems = []
        
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    deinit {
        print("deinit DuplicateItem")
    }
    
    @objc private func updateTimer() {
        progressHUD.updateTimers()
    }
    
    
    // MARK: - Functions
    
    /**
     Re-populates the spawnedItems array by assessing player's health and chosen sword's luck score each time the function is called.
     - parameters:
        - playerHealth: player's current health
        - chosenSwordLuck: chosen sword's luck score
     - note: Call this function periodically, so you capture the latest player's health value, which affects the probability of dropped items.
     */
    func populateSpawnedItems(playerHealth: CGFloat, chosenSwordLuck: CGFloat) {
        let items: [(item: LevelType, probability: CGFloat)]
        
        switch chosenSwordLuck {
        case let amt where amt <= 0.25:
            spawnTimerDuration = 4
            items = [(.sword2x, 0.25), (.sword3x, 0.15), (.swordInf, 0.00), (.wingedboot, 0.00), (.shield, 0.00), (.heart, 0.00), (.gem, 0.60)]
        case let amt where amt <= 0.50:
            spawnTimerDuration = 5
            items = [(.sword2x, 0.30), (.sword3x, 0.20), (.swordInf, 0.00), (.wingedboot, 0.00), (.shield, 0.00), (.heart, 0.10), (.gem, 0.40)]
        case let amt where amt <= 0.75:
            spawnTimerDuration = 6
            items = [(.sword2x, 0.35), (.sword3x, 0.25), (.swordInf, 0.00), (.wingedboot, 0.00), (.shield, 0.00), (.heart, 0.15), (.gem, 0.25)]
        case let amt where amt <= 0.85:
            spawnTimerDuration = 8
            items = [(.sword2x, 0.35), (.sword3x, 0.25), (.swordInf, 0.00), (.wingedboot, 0.00), (.shield, 0.00), (.heart, 0.15), (.gem, 0.25)]
        default:
            spawnTimerDuration = 4
            items = [(.sword2x, 0.00), (.sword3x, 0.00), (.swordInf, 0.00), (.wingedboot, 0.00), (.shield, 0.00), (.heart, 1.00), (.gem, 0.00)]
        }
        
        spawnedItems = []
        
        for (item, probability) in items {
            spawnedItems += Array(repeating: item, count: Int(probability * CGFloat(itemsCount)))
        }
        
        spawnedItems.shuffle()
    }
    
    /**
     Spawn a power up item. Use when Magmoor duplicate is defeated.
     - parameters:
        - position: position on gameboard of where to spawn
        - gameboard: the gameboard where spawning occurs
        - delay: add a delay before spawning
        - playerHealth: latest read from the player's health
        - chosenSwordLuck: technically, this shouldn't change throughout the battle, but it can read the chosen sword's luck value every time
     */
    func spawnItem(at position: K.GameboardPosition, on gameboard: GameboardSprite, delay: TimeInterval, playerHealth: CGFloat, chosenSwordLuck: CGFloat) {
        
        //Re-populates spawn items based on updated health.
        populateSpawnedItems(playerHealth: playerHealth, chosenSwordLuck: chosenSwordLuck)
        
        //Guard to make sure everything was ok..
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
            
            progressHUD.setTimer(for: .sword2x)
        case .sword3x:
            soundFX = "gemcollectparty3x"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
            
            progressHUD.setTimer(for: .sword3x)
        case .swordInf:
            soundFX = "gemcollectpartylife"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
            
            progressHUD.setTimer(for: .swordInf)
        case .wingedboot:
            soundFX = "pickupitem"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
            
            progressHUD.setTimer(for: .wingedboot)
        case .shield:
            soundFX = "pickupitem"
            feedbackStyle = .rigid
            gameboard.addParticles(type: .itemPickup, at: position)
            
            progressHUD.setTimer(for: .shield)
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
    
    func displayProgressBarHUD(on node: SKNode, at position: CGPoint) {
        progressHUD.displayProgressBars(on: node, at: position)
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
    
    
}
