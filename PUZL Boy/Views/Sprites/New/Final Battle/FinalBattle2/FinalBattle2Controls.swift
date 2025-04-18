//
//  FinalBattle2Controls.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/24.
//

import SpriteKit

protocol FinalBattle2ControlsDelegate: AnyObject {
    func didHeroAttack(chosenSword: ChosenSword)
    func didVillainDisappear(fadeDuration: TimeInterval)
    func willVillainReappear()
    func didVillainFlee(didReappear: Bool)
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, chosenSword: ChosenSword, position: K.GameboardPosition)
    func didDuplicateAttack(pattern: MagmoorAttacks.AttackPattern, chosenSword: ChosenSword, playerPosition: K.GameboardPosition)
    func didExplodeDuplicate(chosenSword: ChosenSword)
    func didVillainAttackBecomeVisible()
    func didCollectDuplicateDroppedItem(item: LevelType, chosenSword: ChosenSword)
    func notifyUpdateSword8(isRunningSword8: Bool)
    func handleShield(willDamage: Bool, didDamage: Bool, willBreak: Bool, didBreak: Bool, fadeDuration: TimeInterval?, chosenSword: ChosenSword, villainPosition: K.GameboardPosition?)
}

class FinalBattle2Controls {
    
    // MARK: - Properties
    
    typealias PlayerPositions = (player: K.GameboardPosition, villain: K.GameboardPosition)
    
    static let keyPlayerIdleAnimation = "playerIdleAnimation"
    static let keyPlayerRunAnimation = "playerRunAnimation"
    static let keyPlayerMoveAction = "playerMoveAction"
    static let keyPlayerFreezeAction = "playerFreezeAction"
    static let keyPlayerCloudAction = "playerCloudAction"
    static let keyPlayerRainbowAction = "playerRainbowAction"
    static let keyBootExpiringAction = "bootExpiringAction"
    static let keyShieldExpiringAction = "shieldExpiringAction"

    private var gameboard: GameboardSprite
    private var player: Player
    private var villain: Player
    private(set) var positions: PlayerPositions
        
    //These get set every time in handleControls()
    private var location: CGPoint!
    private var villainPositionNew: K.GameboardPosition!
    private var safePanelFound: Bool!
    private var poisonPanelFound: Bool!
    
    // FIXME: - I don't like how player's health, aka FinalBattle2Health.counter.getCount() needs to be passed around classes. Should this be static prop? 3/14/25
    private var playerHealth: CGFloat?
    
    private var isDisabled: Bool
    private var canAttack: Bool
    private var isFrozen: Bool
    private var isPoisoned: Bool
    private var villainMoveTimer: Timer?
    private(set) var villainMovementDelay: (normal: TimeInterval, enraged: TimeInterval)
    
    private(set) var chosenSword: ChosenSword!
    private var magmoorAttacks: MagmoorAttacks!
    private(set) var magmoorShield: MagmoorShield!
    private(set) var duplicateItemTimerManager: DuplicateItemTimerManager!
    
    weak var delegateControls: FinalBattle2ControlsDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, player: Player, villain: Player, positions: PlayerPositions) {
        self.gameboard = gameboard
        self.player = player
        self.villain = villain
        self.positions = positions
        
        self.isDisabled = false
        self.canAttack = true
        self.isFrozen = false
        self.isPoisoned = false
        self.villainMoveTimer = Timer()
        self.villainMovementDelay = (normal: 12, enraged: 2)
        
        chosenSword = ChosenSword(type: FIRManager.chosenSword)
        chosenSword.setScale(gameboard.panelSize / chosenSword.spriteNode.size.width)
        chosenSword.zPosition = K.ZPosition.itemsAndEffects
        gameboard.sprite.addChild(chosenSword)
        
        magmoorAttacks = MagmoorAttacks(gameboard: gameboard, villain: villain)
        magmoorShield = MagmoorShield(hitPoints: 0)
        duplicateItemTimerManager = DuplicateItemTimerManager()
        
        //These need to come AFTER initializing their respective objects!
        magmoorAttacks.delegateAttacks = self
        magmoorAttacks.delegateAttacksDuplicate = self
        magmoorShield.delegate = self
        duplicateItemTimerManager.addObserver(self)
        duplicateItemTimerManager.delegate = self
                
        setTimerFirstTime()
    }
    
    deinit {
        print("deinit FinalBattle2Controls")
        
        chosenSword = nil
        magmoorAttacks = nil
        magmoorShield = nil
        
        villainMoveTimer?.invalidate()
        villainMoveTimer = nil
        
        duplicateItemTimerManager.removeObserver(self)
        AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 2)
    }
    
    
    // MARK: - Functions
    
    /**
     Handles player movement based on control input.
     - parameters:
        - location: location for which comparison is to occur
        - safePanelFound: returns true if a safe panel i.e. sand/snow is found in the player's position
        - poisonPanelFound: returns true if a poison panel is found in the player's position
        - isPoisoned: returns true if player is in the poisoned state at time of checking. Different from poisonPanelFound because isPoisoned reports on player's poisoned duration, not the panel itself.
        - playerHealth: an updated health of the player, i.e. PUZL Boy
        - completion: handler to perform tasks upon completion
     */
    func handleControls(in location: CGPoint, safePanelFound: Bool, poisonPanelFound: Bool, isPoisoned: Bool, playerHealth: CGFloat, completion: (() -> Void)?) {
        guard !isDisabled else { return }
        guard !isFrozen else { return }
        
        self.location = location
        self.safePanelFound = safePanelFound
        self.poisonPanelFound = poisonPanelFound
        self.isPoisoned = isPoisoned
        
        //By updating playerHealth every time handleControls() is called, i.e. via touchesEnded(), you pass in the latest playerHealth value always.
        self.playerHealth = playerHealth
        
        //Now check for movement/attack!
        if inBounds(.up) && !canAttackVillain(.up) && !canAttackDuplicate(.up) && !checkForTimedBomb(.up) {
            movePlayerHelper(.up, completion: completion)
        }
        else if inBounds(.down) && !canAttackVillain(.down) && !canAttackDuplicate(.down) && !checkForTimedBomb(.down) {
            movePlayerHelper(.down, completion: completion)
        }
        else if inBounds(.left) && !canAttackVillain(.left) && !canAttackDuplicate(.left) && !checkForTimedBomb(.left) {
            movePlayerHelper(.left, completion: completion)
        }
        else if inBounds(.right) && !canAttackVillain(.right) && !canAttackDuplicate(.right) && !checkForTimedBomb(.right) {
            movePlayerHelper(.right, completion: completion)
        }
        else {
            //handle default cases here...
        }
    }
    
    func updateVillainMovementAndAttacks(speed: FinalBattle2Spawner.SpawnerSpeed) {
        switch speed {
        case .slow:
            villainMovementDelay = (normal: 12 - magmoorShield.speedReduction, enraged: 2)
            magmoorAttacks.setFireballSpeed(0.5)
        case .medium:
            villainMovementDelay = (normal: 10 - magmoorShield.speedReduction, enraged: 2)
            magmoorAttacks.setFireballSpeed(0.35)
        case .fast:
            villainMovementDelay = (normal: 8 - magmoorShield.speedReduction, enraged: 1)
            magmoorAttacks.setFireballSpeed(0.25)
        }
    }
    
    /**
     Decrement villain shield if he's in the blast radius of the timed bomb.
     - note: Call this within FinalBattle2Engine.
     */
    func villainAttackTimedBombHurtVillain() {
        guard magmoorShield.hasHitPoints && magmoorAttacks.timedBombCanHurtVillain() && magmoorAttacks.villainIsVisible && canAttack else { return }
        
        canAttack = false
        villainMoveTimer?.invalidate()
        AudioManager.shared.playSound(for: "villainpain\(Int.random(in: 1...2))")
        
        magmoorShield.decrementShield(villain: villain, villainPosition: positions.villain) { [weak self] in
            guard let self = self else { return }
            
            canAttack = true
            generateVillainPositionNew(enrage: magmoorShield.isEnraged)
            
            if magmoorShield.hasHitPoints {
                moveVillainFlee(shouldDisappear: false) { [weak self] in
                    guard let self = self else { return }
                    
                    let attackPattern: MagmoorAttacks.AttackPattern = magmoorShield.hitPoints < 3 ? .normal : .sNormal
                    
                    magmoorAttacks.attack(pattern: attackPattern, level: magmoorShield.resetCount, positions: positions)
                }
            }
            else {
                resetTimer(forceDelay: 3)
            }
        }
    }
    
    /**
     Returns true if you can harm the player due to a timed bomb attack.
     - returns: true if can harm player
     - note: Call from within FinalBattle2Engine.
     */
    func villainAttackTimedBombCanHurtPlayer() -> Bool {
        return magmoorAttacks.timedBombCanHurtPlayer()
    }
    
    
    // MARK: - Controls Helper Functions
    
    /**
     Takes a tap location and compares it to the player's next position.
     - parameter direction: The player's next position, either up, down, left, or right
     - returns: true or false, depending on if the requested direction of movement is within the gameboard bounds
     */
    private func inBounds(_ direction: Controls) -> Bool {
        let maxDistance: CGFloat = CGFloat(gameboard.panelCount)
        let panelSize: CGFloat = gameboard.panelSize * UIDevice.spriteScale
        let gameboardSize: CGFloat = panelSize * CGFloat(maxDistance)
        let gameboardOffset: CGPoint = GameboardSprite.offsetPosition
        
        var bottomBound: CGFloat = CGFloat(positions.player.row) + 1
        var rightBound: CGFloat = CGFloat(positions.player.col) + 1
        var topBound: CGFloat = CGFloat(positions.player.row) {
            didSet { topBound = max(0, topBound) }
        }
        var leftBound: CGFloat = CGFloat(positions.player.col) {
            didSet { leftBound = max(0, leftBound) }
        }
        
        switch direction {
        case .up:
            topBound = -maxDistance
            bottomBound -= 1
        case .down:
            topBound += 1
            bottomBound = maxDistance
        case .left:
            leftBound = -maxDistance
            rightBound -= 1
        case .right:
            leftBound += 1
            rightBound = maxDistance
        default:
            print("Unknown direction in FinalBattle2Controls.inBounds()")
        }
        
        //Finally...
        let locationInsideLeftBound = location.x > gameboardOffset.x + leftBound * panelSize
        let locationInsideRightBound = location.x < gameboardOffset.x + rightBound * panelSize
        let locationInsideBottomBound = location.y > gameboardOffset.y + gameboardSize - bottomBound * panelSize
        let locationInsideTopBound = location.y < gameboardOffset.y + gameboardSize - topBound * panelSize
        
        return locationInsideLeftBound && locationInsideRightBound && locationInsideBottomBound && locationInsideTopBound
    }
    
    private func getNextPanel(direction: Controls) -> K.GameboardPosition {
        let nextPanel: K.GameboardPosition
        
        switch direction {
        case .up:
            nextPanel = (row: positions.player.row - 1, col: positions.player.col)
        case .down:
            nextPanel = (row: positions.player.row + 1, col: positions.player.col)
        case .left:
            nextPanel = (row: positions.player.row, col: positions.player.col - 1)
            player.sprite.xScale = -abs(player.sprite.xScale)
        case .right:
            nextPanel = (row: positions.player.row, col: positions.player.col + 1)
            player.sprite.xScale = abs(player.sprite.xScale)
        default:
            nextPanel = (row: positions.player.row, col: positions.player.col)
        }
        
        return nextPanel
    }
    
    private func canAttackVillain(_ direction: Controls) -> Bool {
        let attackPanel: K.GameboardPosition = getNextPanel(direction: direction)
        
        guard attackPanel == positions.villain && magmoorAttacks.villainIsVisible else { return false }
        
        guard canAttackCheck() else {
            ButtonTap.shared.tap(type: .buttontap6)
            return true
        }
        
        isDisabled = true
        canAttack = false
        villainMoveTimer?.invalidate()
        
        chosenSword.attack(at: gameboard.getLocation(at: attackPanel),
                           facing: player.sprite.xScale,
                           showMultiplier: !magmoorShield.hasHitPoints && chosenSword.attackMultiplier != 1,
                           shouldParry: magmoorShield.hasHitPoints) { [weak self] in
            guard let self = self else { return }
            
            isDisabled = false
            
            if magmoorShield.hasHitPoints {
                magmoorShield.decrementShield(decrementAmount: chosenSword.piercingBonus, villain: villain, villainPosition: attackPanel) {
                    self.canAttack = true
                    self.generateVillainPositionNew(enrage: self.magmoorShield.isEnraged)
                    
                    if self.magmoorShield.hasHitPoints {
                        self.moveVillainFlee(shouldDisappear: false) { [weak self] in
                            guard let self = self else { return }
                            
                            let attackPattern: MagmoorAttacks.AttackPattern = magmoorShield.hitPoints < 3 ? .normal : .sNormal
                            
                            magmoorAttacks.attack(pattern: attackPattern, level: magmoorShield.resetCount, positions: positions)
                        }
                    }
                    else {
                        self.resetTimer(forceDelay: 3)
                    }
                }
                
                AudioManager.shared.playSound(for: "villainpain\(Int.random(in: 1...2))")
            }
            else {
                //FIXME: - need to test, should be fine because canAttack will immediately be set to false in next line, moveVillainFlee().
                canAttack = true
                
                generateVillainPositionNew(enrage: false)
                moveVillainFlee(shouldDisappear: true, completion: nil)
                delegateControls?.didHeroAttack(chosenSword: chosenSword)
                AudioManager.shared.playSound(for: "villainpain3")
            }
        }
        
        return true
    }
    
    private func canAttackCheck() -> Bool {
        let chosenSwordHeavenly: Bool = chosenSword.type == .heavenlySaber
        let playerSafe: Bool = (playerOnSafePanel() || duplicateItemTimerManager.isRunningBoot) && !poisonPanelFound
        
        return canAttack && (chosenSwordHeavenly || playerSafe)
    }
    
    private func canAttackDuplicate(_ direction: Controls) -> Bool {
        let attackPanel: K.GameboardPosition = getNextPanel(direction: direction)
        
        guard let duplicate = MagmoorDuplicate.getDuplicateAt(position: attackPanel, on: gameboard), !magmoorAttacks.villainIsVisible else {
            return false
        }
        
        guard canAttackCheck() else {
            ButtonTap.shared.tap(type: .buttontap6)
            return true
        }
        
        isDisabled = true
        canAttack = false
        
        chosenSword.attack(at: gameboard.getLocation(at: attackPanel),
                           facing: player.sprite.xScale,
                           showMultiplier: false,
                           shouldParry: duplicate.invincibleShield?.hasHitPoints ?? false) { [weak self] in
            guard let self = self else { return }
            
            isDisabled = false
            
            if duplicate.invincibleShield?.hasHitPoints ?? false {
                duplicate.invincibleShield?.attackInvincibleShield {
                    self.canAttack = true
                }
            }
            else {
                let itemSpawnLevel: DuplicateItem.ItemSpawnLevel
                
                switch magmoorShield.resetCount {
                case let lvl where lvl <= 4:    itemSpawnLevel = .low
                case 5:                         itemSpawnLevel = .medium
                default:                        itemSpawnLevel = .high
                }
                
                // FIXME: - 2nd time passing playerHealth around...
                magmoorAttacks.explodeDuplicate(at: attackPanel,
                                                playerHealth: playerHealth ?? 0.5,
                                                chosenSwordLuck: chosenSword.luckRating,
                                                itemSpawnLevel: itemSpawnLevel,
                                                resetCount: magmoorShield.resetCount) { villainIsVisible in
                    self.canAttack = true
                    
                    guard villainIsVisible else { return }
                    
                    self.delegateControls?.didVillainAttackBecomeVisible()
                    self.resetTimer(forceDelay: nil)
                }
            }
        }
        
        return true
    }
    
    /**
     Checks for the existence of a timed bomb using Fireball.checkForTimedBomb(), and if so returns true.
     */
    private func checkForTimedBomb(_ direction: Controls) -> Bool {
        let possibleBombPanel: K.GameboardPosition = getNextPanel(direction: direction)
        let timedBombFound = Fireball.checkForTimedBomb(at: possibleBombPanel, on: gameboard)
        
        if timedBombFound {
            ButtonTap.shared.tap(type: .buttontap6)
        }
        
        return timedBombFound
    }
    
    /**
     Returns true if playerPosition is on a safe panel, start panel, or end panel.
     */
    private func playerOnSafePanel() -> Bool {
        return safePanelFound || positions.player == FinalBattle2Spawner.startPosition || positions.player == FinalBattle2Spawner.endPosition
    }
    
    /**
     Physically move the player in the intended direction.
     - parameters:
        - direction: The direction the player would like to move to
        - completion: handler to perform functions upon animation completion
     */
    private func movePlayerHelper(_ direction: Controls, completion: (() -> Void)?) {
        func getMoveSoundFX() {
            var count = 0
            
            repeat {
                if duplicateItemTimerManager.isRunningBoot {
                    runSound = "movesnow\(Int.random(in: 1...3))"
                }
                else if safePanelFound {
                    runSound = "movesand\(Int.random(in: 1...3))"
                }
                else {
                    switch panelType {
                    case .lava, .water:
                        runSound = "movemarsh\(Int.random(in: 1...3))"
                    default:
                        runSound = "movetile\(Int.random(in: 1...3))"
                    }
                }
                
                count += 1
                
                if count > 20 { break }
            } while AudioManager.shared.isPlaying(audioKey: runSound)
        }
        
        let nextPanel: K.GameboardPosition = getNextPanel(direction: direction)
        let panelType = gameboard.getUserDataForLevelType(sprite: gameboard.getPanelSprite(at: positions.player).terrain!)
        let playerSafe: Bool = (playerOnSafePanel() || duplicateItemTimerManager.isRunningBoot) && !poisonPanelFound && !isPoisoned
        let movementMultiplier: TimeInterval = (playerSafe ? 1 : 2) / chosenSword.speedRating
        
        var runSound: String = "movetile1"
        
        isDisabled = true
        positions.player = nextPanel
        
        getMoveSoundFX()
        
        AudioManager.shared.playSound(for: runSound)
        
        //First, run animation...
        player.sprite.run(Player.animate(player: player, type: .run, timePerFrameMultiplier: movementMultiplier), withKey: FinalBattle2Controls.keyPlayerRunAnimation)
        
        //Wait, then idle animation...
        player.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: Player.Texture.run.movementSpeed * movementMultiplier),
            Player.animate(player: player, type: .idle)
        ]), withKey: FinalBattle2Controls.keyPlayerIdleAnimation)
        
        player.sprite.removeAction(forKey: FinalBattle2Controls.keyPlayerCloudAction)
        
        //In between, move player and completion...
        player.sprite.run(SKAction.sequence([
            SKAction.move(to: gameboard.getLocation(at: nextPanel), duration: Player.Texture.run.movementSpeed * movementMultiplier),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                isDisabled = false
                
                if duplicateItemTimerManager.isRunningBoot {
                    playerFloatCloud()
                }
                
                // TODO: - Testing of DuplicateItem collection
                if let spoils = DuplicateItem.shared.collectItem(at: nextPanel, on: gameboard) {
                    delegateControls?.didCollectDuplicateDroppedItem(item: spoils, chosenSword: chosenSword)
                }
                
                AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
                completion?()
            }
        ]), withKey: FinalBattle2Controls.keyPlayerMoveAction)
    }
    
    
    // MARK: - Villain Movement
    
    /**
     Moves the villain to a new, random spot on the board. Use this to periodically move the villain, via a timer, for example.
     */
    @objc private func moveVillain(_ sender: Any) {
        moveVillainFlee(shouldDisappear: false) { [weak self] in
            guard let self = self else { return }
            
            let attackPattern = MagmoorAttacks.getAttackPattern(enrage: magmoorShield.isEnraged,
                                                                level: magmoorShield.resetCount,
                                                                shieldHP: magmoorShield.hitPoints,
                                                                isFeatured: false)
            
            magmoorAttacks.attack(pattern: attackPattern, level: magmoorShield.resetCount, positions: positions)
        }
    }
    
    @objc private func moveVillainFirstTime(_ sender: Any) {
        moveVillainFlee(shouldDisappear: true, showPain: false, completion: nil)
    }
    
    /**
     Resets the timer and begins a new one.
     - parameter forceDelay: a forced time that overrides villainMovementDelay. Set when villain doesn't have a shield, for example.
     */
    private func resetTimer(forceDelay: TimeInterval?) {
        let timeInterval = forceDelay ?? (magmoorShield.isEnraged ? villainMovementDelay.enraged : villainMovementDelay.normal)
        
        villainMoveTimer?.invalidate()
        villainMoveTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                target: self,
                                                selector: #selector(moveVillain(_:)),
                                                userInfo: nil,
                                                repeats: false)
    }
    
    /**
     Sets the timer for the first time. Call once in initialization.
     */
    private func setTimerFirstTime() {
        generateVillainPositionNew(enrage: false)
        
        villainMoveTimer?.invalidate()
        villainMoveTimer = Timer.scheduledTimer(timeInterval: 30,
                                                target: self,
                                                selector: #selector(moveVillainFirstTime(_:)),
                                                userInfo: nil,
                                                repeats: false)
    }
    
    /**
     Generates a new position for the villain.
     */
    private func generateVillainPositionNew(enrage: Bool) {
        //IMPORTANT: THESE LOCAL VARIABLES MUST BE COMPUTED VARIABLES BECAUSE THEY NEED TO CHANGE WITHIN THE repeat-while LOOP!!!
        
        //Villain's new spawn position cannot be where player, villain, or start positions are!
        var mainCheck: Bool {
            villainPositionNew == positions.player ||
            villainPositionNew == positions.villain ||
            villainPositionNew == FinalBattle2Spawner.startPosition
        }
        
        //Create a boundary such that new spawn point can't be more than 1 tile away.
        let boundary: Int = 1
        var leftBounds: Bool { villainPositionNew.row < positions.villain.row - boundary }
        var rightBounds: Bool { villainPositionNew.row > positions.villain.row + boundary }
        var bottomBounds: Bool { villainPositionNew.col < positions.villain.col - boundary }
        var topBounds: Bool { villainPositionNew.col > positions.villain.col + boundary }
        var allBounds: Bool { leftBounds || rightBounds || bottomBounds || topBounds }
        
        var boundsCheck: Bool { enrage ? allBounds : false }
        
        repeat {
            villainPositionNew = (Int.random(in: 0...gameboard.panelCount - 1), Int.random(in: 0...gameboard.panelCount - 1))
        } while mainCheck || boundsCheck
    }
    
    /**
     Helper function to assist with moving the villain after he's been attacked by the hero.
     - parameters:
        - shouldDisappear: if true, Magmoor disappears and ascends upwards in a black smoke.
        - showPain: if true, show a quick hit animation before ascending. Defaults to true
        - completion: optional completion handler
     */
    private func moveVillainFlee(shouldDisappear: Bool, showPain: Bool = true, completion: (() -> Void)?) {
        guard magmoorAttacks.villainIsVisible else { return }
        
        let moveDirection: CGFloat = positions.player.col <= positions.villain.col ? -1 : 1
        let moveDistance: CGFloat = 20
        let fadeDistance = CGPoint(x: 0, y: shouldDisappear ? gameboard.panelSize : 0)
        let fadeDuration: TimeInterval = shouldDisappear ? 2 : 0
        let waitDuration = TimeInterval.random(in: 3...8)
        let villainDirection: CGFloat = villainPositionNew.col < positions.player.col ? 1 : -1
        
        let flipVillainAction = SKAction.scaleX(to: moveDirection * abs(villain.sprite.xScale), duration: 0)
        let painAnimation = Player.animate(player: villain, type: .glide, repeatCount: 1)
        let painAction = SKAction.sequence([
            SKAction.moveBy(x: -moveDirection * moveDistance, y: 0, duration: 0),
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.5),
            SKAction.moveBy(x: moveDirection * moveDistance, y: 0, duration: 0)
        ])
        
        let disappearAction = SKAction.sequence([
            showPain ? SKAction.group([flipVillainAction, painAction, painAnimation]) : SKAction.wait(forDuration: 0),
            SKAction.group([
                SKAction.moveBy(x: fadeDistance.x, y: fadeDistance.y, duration: fadeDuration),
                SKAction.fadeOut(withDuration: fadeDuration)
            ]),
            SKAction.run {
                AudioManager.shared.playSound(for: "scarylaugh", delay: waitDuration - 1)
            },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [weak self] in
                self?.delegateControls?.willVillainReappear()
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 1)
            }
        ])
        
        let waitAction = SKAction.sequence([
            SKAction.wait(forDuration: fadeDuration),
            SKAction.fadeOut(withDuration: 0)
        ])
        
        let actionToTake = shouldDisappear ? disappearAction : waitAction
        
        //FIXME: - Need to test... should this always start out false?
        canAttack = false
        
        villain.sprite.run(SKAction.sequence([
            actionToTake,
            Player.moveWithIllusions(playerNode: villain.sprite,
                                     backgroundNode: gameboard.sprite,
                                     color: .red.darkenColor(factor: 12),
                                     playSound: true,
                                     fierce: true,
                                     startPoint: villain.sprite.position + fadeDistance,
                                     endPoint: gameboard.getLocation(at: villainPositionNew),
                                     startScale: 1,
                                     endScale: 1),
            SKAction.move(to: gameboard.getLocation(at: villainPositionNew), duration: 0),
            SKAction.scaleX(to: villainDirection * abs(villain.sprite.xScale), duration: 0),
            SKAction.fadeIn(withDuration: 0)
        ])) { [weak self] in
            guard let self = self else { return }
            
            //FIXME: - Need to test. This was originally below second guard shouldDisappear
            canAttack = true
            
            if shouldDisappear {
                magmoorShield.resetShield(villain: villain)
                
                //IMPORTANT!! Must come after resetShield()!! (But before resetTimer())
                delegateControls?.didVillainFlee(didReappear: true)
                
                let attackPattern = MagmoorAttacks.getAttackPattern(enrage: false,
                                                                    level: magmoorShield.resetCount,
                                                                    shieldHP: magmoorShield.hitPoints,
                                                                    isFeatured: true)
                
                magmoorAttacks.attack(pattern: attackPattern, level: magmoorShield.resetCount, positions: positions)
                
                generateVillainPositionNew(enrage: false)
                resetTimer(forceDelay: nil) //call AFTER resetShield()!!
            }
            else {
                delegateControls?.didVillainFlee(didReappear: false)
                
                generateVillainPositionNew(enrage: magmoorShield.isEnraged)
                resetTimer(forceDelay: nil)
            }
            
            completion?()
        }
        
        
        //Set important properties!!
        positions.villain = villainPositionNew
        
        if shouldDisappear {
            delegateControls?.didVillainDisappear(fadeDuration: fadeDuration)
            
            if playerHealth ?? 0 >= StatusBarSprite.lowPercentage {
                AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: fadeDuration)
            }
            
            AudioManager.shared.playSound(for: "magicwarp")
            AudioManager.shared.playSound(for: "magicwarp2")
            ParticleEngine.shared.animateParticles(type: .magmoorBamf,
                                                   toNode: villain.sprite,
                                                   position: .zero,
                                                   scale: 3,
                                                   zPosition: 2,
                                                   duration: 2)
        }
    } //end moveVillainFlee()
    
    
}


// MARK: - MagmoorAttacksDelegate

extension FinalBattle2Controls: MagmoorAttacksDelegate {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition) {
        delegateControls?.didVillainAttack(pattern: pattern, chosenSword: chosenSword, position: position)
        
        if pattern == .freeze || pattern == .sFreeze {
            didPlayerFreeze(position: position)
        }
    }
    
    func didPlayerFreeze(position: K.GameboardPosition, shouldBypassShield: Bool = false, freezeDuration: TimeInterval = 3) {
        guard position == positions.player else { return }
        guard shouldBypassShield || !duplicateItemTimerManager.isRunningShield else { return }
        
        isFrozen = true
        
        player.sprite.action(forKey: FinalBattle2Controls.keyPlayerRunAnimation)?.speed = 0
        player.sprite.action(forKey: FinalBattle2Controls.keyPlayerIdleAnimation)?.speed = 0
        player.sprite.action(forKey: FinalBattle2Controls.keyPlayerMoveAction)?.speed = 0
        player.sprite.action(forKey: FinalBattle2Controls.keyPlayerCloudAction)?.speed = 0
        
        player.sprite.removeAction(forKey: FinalBattle2Health.keyPlayerBlink)
        player.sprite.removeAction(forKey: FinalBattle2Health.keyPlayerColorFade)
        player.sprite.removeAction(forKey: FinalBattle2Controls.keyPlayerFreezeAction)
        
        player.sprite.run(SKAction.sequence([
            SKAction.colorize(with: .systemBlue, colorBlendFactor: 1, duration: 0),
            SKAction.wait(forDuration: freezeDuration),
            SKAction.run { [weak self] in
                self?.isFrozen = false
                self?.player.sprite.action(forKey: FinalBattle2Controls.keyPlayerRunAnimation)?.speed = 1
                self?.player.sprite.action(forKey: FinalBattle2Controls.keyPlayerIdleAnimation)?.speed = 1
                self?.player.sprite.action(forKey: FinalBattle2Controls.keyPlayerMoveAction)?.speed = 1
                self?.player.sprite.action(forKey: FinalBattle2Controls.keyPlayerCloudAction)?.speed = 1
            },
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.5),
            SKAction.colorize(with: .red, colorBlendFactor: 0, duration: 0)
        ]), withKey: FinalBattle2Controls.keyPlayerFreezeAction)
    }
}


// MARK: - MagmoorAttacks(Duplicate)Delegate

extension FinalBattle2Controls: MagmoorAttacksDuplicateDelegate {
    func didDuplicateAttack(pattern: MagmoorAttacks.AttackPattern, playerPosition: K.GameboardPosition) {
        delegateControls?.didDuplicateAttack(pattern: pattern, chosenSword: chosenSword, playerPosition: playerPosition)
        
        if pattern == .freeze || pattern == .sFreeze {
            didPlayerFreeze(position: playerPosition)
        }
    }
    
    func didDuplicateTimerFire(duplicate: MagmoorDuplicate) {
        duplicate.attack(playerPosition: positions.player)
    }
    
    func didExplodeDuplicate() {
        delegateControls?.didExplodeDuplicate(chosenSword: chosenSword)
    }
}


// MARK: - MagmoorShieldDelegate

extension FinalBattle2Controls: MagmoorShieldDelegate {
    func willDamageShield() {
        delegateControls?.handleShield(willDamage: true, didDamage: false, willBreak: false, didBreak: false, fadeDuration: nil, chosenSword: chosenSword, villainPosition: nil)
    }
    
    func didDamageShield() {
        delegateControls?.handleShield(willDamage: false, didDamage: true, willBreak: false, didBreak: false, fadeDuration: nil, chosenSword: chosenSword, villainPosition: nil)
    }
    
    func willBreakShield(fadeDuration: TimeInterval) {
        delegateControls?.handleShield(willDamage: false, didDamage: false, willBreak: true, didBreak: false, fadeDuration: fadeDuration, chosenSword: chosenSword, villainPosition: nil)
    }
    
    func didBreakShield(at villainPosition: K.GameboardPosition) {
        delegateControls?.handleShield(willDamage: false, didDamage: false, willBreak: false, didBreak: true, fadeDuration: nil, chosenSword: chosenSword, villainPosition: villainPosition)
    }
    
    
}


// MARK: - DuplicateItemTimerManagerDelegate

extension FinalBattle2Controls: DuplicateItemTimerManagerDelegate {
    func didInitializeSword2x(_ manager: DuplicateItemTimerManager) {
        guard !manager.isRunningSword3x && !manager.isRunningSword8 else { return }
        
        chosenSword.setAttackMultiplier(2)
    }
    
    func didExpireSword2x(_ manager: DuplicateItemTimerManager) {
        guard !manager.isRunningSword3x && !manager.isRunningSword8 else { return }
        
        chosenSword.setAttackMultiplier(1)
    }
    
    func didInitializeSword3x(_ manager: DuplicateItemTimerManager) {
        guard !manager.isRunningSword8 else { return }
        
        chosenSword.setAttackMultiplier(3)
    }
    
    func didExpireSword3x(_ manager: DuplicateItemTimerManager) {
        guard !manager.isRunningSword8 else { return }
        
        chosenSword.setAttackMultiplier(manager.isRunningSword2x ? 2 : 1)
    }
    
    func didInitializeSword8(_ manager: DuplicateItemTimerManager) {
        delegateControls?.notifyUpdateSword8(isRunningSword8: true)
        
        chosenSword.setAttackMultiplier(ChosenSword.infiniteMultiplier)
        
        player.sprite.run(SKAction.repeatForever(SKAction.colorizeWithRainbowColorSequence(duration: 0.2)), withKey: FinalBattle2Controls.keyPlayerRainbowAction)
    }
    
    func didExpireSword8(_ manager: DuplicateItemTimerManager) {
        delegateControls?.notifyUpdateSword8(isRunningSword8: false)
        
        chosenSword.setAttackMultiplier(manager.isRunningSword3x ? 3 : (manager.isRunningSword2x ? 2 : 1))
        
        player.sprite.removeAction(forKey: FinalBattle2Controls.keyPlayerRainbowAction)
        player.sprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 1))
    }
    
    func didInitializeBoot(_ manager: DuplicateItemTimerManager) {
        //If cloudNode is attached...
        if let cloudNode = player.sprite.childNode(withName: "cloudNode") {
            if cloudNode.action(forKey: FinalBattle2Controls.keyBootExpiringAction) != nil {
                //...but is in the process of being removed, then remove it
                cloudNode.removeAction(forKey: FinalBattle2Controls.keyBootExpiringAction)
                cloudNode.removeFromParent()
            }
            else {
                //...but is not in the process of being removed, i.e. timer is active, then quit early
                return
            }
        }
        
        
        let cloudNode = SKSpriteNode(imageNamed: "cloud")
        cloudNode.position = CGPoint(x: 0, y: -1.5 * player.sprite.size.height * UIDevice.spriteScale)
        cloudNode.setScale(0)
        cloudNode.zPosition = -1
        cloudNode.name = "cloudNode"
        
        cloudNode.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3.5, duration: 0.5),
                SKAction.fadeIn(withDuration: 0.5)
            ]),
            SKAction.group([
                SKAction.scale(to: 2.5, duration: 1),
                SKAction.fadeAlpha(to: 0.75, duration: 1)
            ])
        ])))
        
        player.sprite.addChild(cloudNode)
        playerFloatCloud()
    }
    
    /**
     Creates a repeating, floating cloud animation. Add this when boot is active in boot initialization and movePlayerHelper().
     */
    private func playerFloatCloud() {
        player.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.5),
            SKAction.moveBy(x: 0, y: -20, duration: 1)
        ])), withKey: FinalBattle2Controls.keyPlayerCloudAction)
    }
    
    func didExpireBoot(_ manager: DuplicateItemTimerManager) {
        if let cloudNode = player.sprite.childNode(withName: "cloudNode") {
            cloudNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 1),
                SKAction.removeFromParent()
            ]), withKey: FinalBattle2Controls.keyBootExpiringAction)
        }
        
        player.sprite.removeAction(forKey: FinalBattle2Controls.keyPlayerCloudAction)
        player.sprite.run(SKAction.moveTo(y: gameboard.getLocation(at: positions.player).y, duration: 0.1))
    }
    
    func didInitializeShield(_ manager: DuplicateItemTimerManager) {
        //If littleShield is attached...
        if let littleShield = player.sprite.childNode(withName: "littleShieldNode") {
            if littleShield.action(forKey: FinalBattle2Controls.keyShieldExpiringAction) != nil {
                //...but is in the process of being removed, then remove it
                littleShield.removeAction(forKey: FinalBattle2Controls.keyShieldExpiringAction)
                littleShield.removeFromParent()
            }
            else {
                //...but is not in the process of being removed, i.e. timer is active, then quit early
                return
            }
        }
        
        
        let littleShield = SKSpriteNode(imageNamed: "shield")
        littleShield.position = CGPoint(x: 60, y: -60) / UIDevice.spriteScale
        littleShield.setScale(0)
        littleShield.zPosition = 2
        littleShield.name = "littleShieldNode"
        
        littleShield.run(SKAction.scale(to: 3, duration: 0.5))
        
        player.sprite.addChild(littleShield)
    }
    
    func didExpireShield(_ manager: DuplicateItemTimerManager) {
        guard let littleShield = player.sprite.childNode(withName: "littleShieldNode") else { return }

        littleShield.run(SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.5),
            SKAction.removeFromParent()
        ]), withKey: FinalBattle2Controls.keyShieldExpiringAction)
    }
    
    
}
