//
//  DuplicateItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/12/25.
//

import SpriteKit

class DuplicateItem {
    
    // MARK: - Properties
    
    private var progressHUD: ProgressHUDManager
    private var duplicateItemTimerManager: DuplicateItemTimerManager
    
    private var spawnTimerDuration: TimeInterval
    private var timer: Timer?
    
    private(set) var spawnedItems: [LevelType]
    private(set) var collectedItems: [LevelType]
    
    static let shared: DuplicateItem = {
        let instance = DuplicateItem()
        
        return instance
    }()
    
    enum ItemSpawnLevel {
        case low, medium, high
    }
    
    
    // MARK: - Initialization
    
    private init() {
        spawnTimerDuration = 5
        progressHUD = ProgressHUDManager()
        duplicateItemTimerManager = DuplicateItemTimerManager()
        
        spawnedItems = []
        collectedItems = []
        
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        duplicateItemTimerManager.addObserver(self)
    }
    
    deinit {
        print("deinit DuplicateItem")
        
        timer?.invalidate()
        timer = nil
        
        duplicateItemTimerManager.removeObserver(self)
    }
    
    @objc private func updateTimer() {
        progressHUD.updateTimers()
    }
    
    func resetTimers() {
        progressHUD.resetTimers()
    }
    
    
    // MARK: - Functions
    
    /**
     Re-populates the spawnedItems array by assessing player's health and chosen sword's luck score each time the function is called.
     - parameters:
        - playerHealth: player's current health
        - chosenSwordLuck: chosen sword's luck score
        - itemSpawnLevel: indicates the type of item that will drop
        - resetCount: number of times Magmoor's shield was broken
     - note: Call this function periodically, so you capture the latest player's health value, which affects the probability of dropped items.
     */
    func populateSpawnedItems(playerHealth: CGFloat, chosenSwordLuck: CGFloat, itemSpawnLevel: ItemSpawnLevel, resetCount: Int) {
        //Total items to be added to the spawnArray[]
        let mTotal: CGFloat = 2 * 100
        let mLuck = CGFloat(mTotal * chosenSwordLuck)
        let mLuckDiff = CGFloat(mTotal * (1 - chosenSwordLuck))
        
        //Health multiplier to determine heart spawn probability
        let mHeart: CGFloat
        
        //Counts for each of the spawned items
        let cGem: Int
        let cHeart: Int
        let cBoot: Int
        let cShield: Int
        let cSword2x: Int
        let cSword3x: Int
        let cSword8: Int
        
        if resetCount < 7 {
            switch playerHealth {
            case let amt where amt <= 0.25: mHeart = chosenSwordLuck
            case let amt where amt <= 0.50: mHeart = chosenSwordLuck / 2
            default:                        mHeart = 0
            }
            
            cHeart = Int(mHeart * mLuckDiff)
            cGem = Int(mLuckDiff) - cHeart
            
            switch itemSpawnLevel {
            case .low:
                cBoot = Int(mLuck * 2/3)
                cShield = 0
                cSword2x = Int(mLuck * 1/3)
                cSword3x = 0
                cSword8 = 0
            case .medium:
                cBoot = Int(mLuck * 1/2)
                cShield = Int(mLuck * 1/3)
                
                let swordCount = Int(mLuck * 1/6)
                
                if duplicateItemTimerManager.isRunningSword2x {
                    cSword2x = swordCount * 2/3
                    cSword3x = swordCount * 1/3
                    cSword8 = 0
                }
                else {
                    cSword2x = swordCount
                    cSword3x = 0
                    cSword8 = 0
                }
            case .high:
                cBoot = Int(mLuck * 1/4)
                cShield = Int(mLuck * 1/4)
                
                let swordCount = Int(mLuck * 1/2)
                
                if duplicateItemTimerManager.isRunningSword3x {
                    cSword2x = 0
                    cSword3x = swordCount * 2/3
                    cSword8 = swordCount * 1/3
                }
                else if duplicateItemTimerManager.isRunningSword2x {
                    cSword2x = swordCount * 2/3
                    cSword3x = swordCount * 1/3
                    cSword8 = 0
                }
                else {
                    cSword2x = swordCount
                    cSword3x = 0
                    cSword8 = 0
                }
            }
        }
        else {
            
            //Desperation mode.. just give it to the player!
            cGem = 0
            cHeart = 0
            cBoot = Int(mTotal * 1/3)
            cShield = Int(mTotal * 1/3)
            cSword8 = Int(mTotal * 1/3)
            cSword3x = 0
            cSword2x = 0
        }
        
        spawnTimerDuration = floor(max(10 * chosenSwordLuck, 3))
        
        spawnedItems = []
        spawnedItems += Array(repeating: .gem, count: cGem)
        spawnedItems += Array(repeating: .heart, count: cHeart)
        spawnedItems += Array(repeating: .wingedboot, count: cBoot)
        spawnedItems += Array(repeating: .shield, count: cShield)
        spawnedItems += Array(repeating: .sword2x, count: cSword2x)
        spawnedItems += Array(repeating: .sword3x, count: cSword3x)
        spawnedItems += Array(repeating: .swordInf, count: cSword8)
        spawnedItems.shuffle()
        
//        print("populateSpawnedItems(): health: \(Int(playerHealth * 100)), luck: \(Int(chosenSwordLuck * 100)), itemSpawnLevel: \(itemSpawnLevel), resetCount: \(resetCount)\n\t💎: \(cGem)\t❤️: \(cHeart)\n\t👢: \(cBoot)\t🛡️: \(cShield)\n\t🗡️: \(cSword2x)\t⚔️: \(cSword3x)\t♾️: \(cSword8)")
    }
    
    /**
     Spawn a power up item. Use when Magmoor duplicate is defeated.
     - parameters:
        - position: position on gameboard of where to spawn
        - gameboard: the gameboard where spawning occurs
        - delay: add a delay before spawning
        - playerHealth: latest read from the player's health
        - chosenSwordLuck: technically, this shouldn't change throughout the battle, but it can read the chosen sword's luck value every time
        - itemSpawnLevel: levels from 1 to 3 indicating the type of drop you'll get.
        - resetCount: number of times broke magmoor shield
     */
    func spawnItem(at position: K.GameboardPosition, on gameboard: GameboardSprite, delay: TimeInterval, playerHealth: CGFloat, chosenSwordLuck: CGFloat, itemSpawnLevel: ItemSpawnLevel, resetCount: Int) {
        
        //Re-populates spawn items based on updated health.
        populateSpawnedItems(playerHealth: playerHealth, chosenSwordLuck: chosenSwordLuck, itemSpawnLevel: itemSpawnLevel, resetCount: resetCount)
        
        //Guard to make sure everything was ok..
        guard !spawnedItems.isEmpty else { return print("DuplicateItem.spawnedItems not populated.") }
        
        let randomIndex = Int.random(in: 0..<spawnedItems.count)
        let item: LevelType = spawnedItems.remove(at: randomIndex)
        let itemSpawnName = GameboardSprite.getNodeName(position: position, includeOverlayTag: true)
        
        //You get NOTHING! Good day, sir! 3/29/25
        guard item != .gem else {
            ParticleEngine.shared.animateParticles(type: .warp, toNode: gameboard.sprite, position: gameboard.getLocation(at: position), duration: 2)
            AudioManager.shared.playSoundThenStop(for: "scarylaugh", playForDuration: 1.5, fadeOut: 1)
            
            return
        }
        
        gameboard.spawnItem(at: position, with: item, delay: delay, completion: {})
        
        if let spawnedItem = gameboard.sprite.childNode(withName: itemSpawnName) {
            let arrow = SKSpriteNode(imageNamed: "hintarrowcyan")
            arrow.position = CGPoint(x: 0, y: arrow.size.height / 2)
            arrow.zRotation = .pi / 2
            arrow.zPosition = K.ZPosition.hintArrow
            arrow.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 80, duration: 0.25),
                SKAction.moveBy(x: 0, y: -80, duration: 0.5)
            ])))
            
            spawnedItem.addChild(arrow)
        }
        
        AudioManager.shared.playSound(for: "arrowblink", delay: 0.25)
        
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
