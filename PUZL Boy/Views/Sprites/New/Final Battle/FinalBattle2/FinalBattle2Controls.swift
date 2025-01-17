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
    func didVillainReappear()
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, chosenSword: ChosenSword, position: K.GameboardPosition)
    func handleShield(willDamage: Bool, didDamage: Bool, willBreak: Bool, didBreak: Bool, fadeDuration: TimeInterval?, chosenSword: ChosenSword, villainPosition: K.GameboardPosition?)
}

class FinalBattle2Controls {
    
    // MARK: - Properties
    
    typealias PlayerPositions = (player: K.GameboardPosition, villain: K.GameboardPosition)
    
    private var gameboard: GameboardSprite
    private var player: Player
    private var villain: Player
    private(set) var positions: PlayerPositions
        
    //These get set every time in handleControls()
    private var location: CGPoint!
    private var villainPositionNew: K.GameboardPosition!
    private var safePanelFound: Bool!
    
    private var isDisabled: Bool
    private var canAttack: Bool
    private var villainMoveTimer: Timer
    private var villainMovementDelay: (normal: TimeInterval, enraged: TimeInterval)
    
    private(set) var chosenSword: ChosenSword
    private var magmoorAttacks: MagmoorAttacks
    private var magmoorShield: MagmoorShield
    
    weak var delegate: FinalBattle2ControlsDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, player: Player, villain: Player, positions: PlayerPositions) {
        self.gameboard = gameboard
        self.player = player
        self.villain = villain
        self.positions = positions
        
        self.isDisabled = false
        self.canAttack = true
        self.villainMoveTimer = Timer()
        self.villainMovementDelay = (normal: 12, enraged: 2)
        
        chosenSword = ChosenSword(type: FIRManager.chosenSword)
        chosenSword.spriteNode.setScale(gameboard.panelSize / chosenSword.spriteNode.size.width)
        chosenSword.spriteNode.zPosition = K.ZPosition.itemsAndEffects
        
        magmoorAttacks = MagmoorAttacks(gameboard: gameboard, villain: villain)
        magmoorShield = MagmoorShield(hitPoints: 0)
        
        //These need to come AFTER initializing their respective objects!
        magmoorAttacks.delegate = self
        magmoorShield.delegate = self
    }
    
    deinit {
        print("deinit FinalBattle2Controls")
    }
    
    
    // MARK: - Functions
    
    /**
     Handles player movement based on control input.
     - parameters:
        - location: location for which comparison is to occur
        - safePanelFound: returns true if a safe panel i.e. sand/snow is found in the player's position
        - completion: handler to perform tasks upon completion
     */
    func handleControls(in location: CGPoint, safePanelFound: Bool, completion: (() -> Void)?) {
        guard !isDisabled else { return }
        
        self.location = location
        self.safePanelFound = safePanelFound
        
        //Now check for movement/attack!
        if inBounds(.up) && !canAttackVillain(.up) {
            movePlayerHelper(.up, completion: completion)
        }
        else if inBounds(.down) && !canAttackVillain(.down) {
            movePlayerHelper(.down, completion: completion)
        }
        else if inBounds(.left) && !canAttackVillain(.left) {
            movePlayerHelper(.left, completion: completion)
        }
        else if inBounds(.right) && !canAttackVillain(.right) {
            movePlayerHelper(.right, completion: completion)
        }
        else {
            //handle default cases here...
        }
    }
    
    func updateVillainMovementAndAttacks(speed: FinalBattle2Spawner.SpawnerSpeed) {
        switch speed {
        case .slow:
            villainMovementDelay = (normal: 12, enraged: 2)
            magmoorAttacks.setNormalFireballSpeed(0.5)
        case .medium:
            villainMovementDelay = (normal: 10, enraged: 2)
            magmoorAttacks.setNormalFireballSpeed(0.35)
        case .fast:
            villainMovementDelay = (normal: 8, enraged: 1)
            magmoorAttacks.setNormalFireballSpeed(0.25)
        }
    }
    
    /**
     Decrement villain shield if he's in the blast radius of the timed bomb.
     - note: Call this within FinalBattle2Engine.
     */
    func villainAttackTimedBombHurtVillain() {
        guard magmoorShield.hasHitPoints && magmoorAttacks.timedBombCanHurtVillain() && canAttack else { return }
        
        canAttack = false
        villainMoveTimer.invalidate()
        AudioManager.shared.playSound(for: "villainpain\(Int.random(in: 1...2))")
        
        magmoorShield.decrementShield(villain: villain, villainPosition: positions.villain) { [weak self] in
            guard let self = self else { return }
            
            canAttack = true
            generateVillainPositionNew(enrage: magmoorShield.isEnraged)
            
            if magmoorShield.hasHitPoints {
                moveVillainFlee(shouldDisappear: false, fadeDuration: 0, completion: nil)
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
        
        guard attackPanel == positions.villain else { return false }
        guard playerOnSafePanel() && canAttack else {
            ButtonTap.shared.tap(type: .buttontap6)
            return true
        }
        
        isDisabled = true
        canAttack = false
        villainMoveTimer.invalidate()
        
        gameboard.sprite.addChild(chosenSword.spriteNode)
        
        chosenSword.spriteNode.position = gameboard.getLocation(at: positions.villain)
        chosenSword.attack(shouldParry: magmoorShield.hasHitPoints) { [weak self] in
            guard let self = self else { return }
            
            isDisabled = false
            
            if magmoorShield.hasHitPoints {
                magmoorShield.decrementShield(decrementAmount: chosenSword.piercingBonus, villain: villain, villainPosition: positions.villain) {
                    self.canAttack = true
                    self.generateVillainPositionNew(enrage: self.magmoorShield.isEnraged)
                    
                    if self.magmoorShield.hasHitPoints {
                        self.moveVillainFlee(shouldDisappear: false, fadeDuration: 0, completion: nil)
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
                moveVillainFlee(shouldDisappear: true, fadeDuration: 2, completion: nil)
                delegate?.didHeroAttack(chosenSword: chosenSword)
                AudioManager.shared.playSound(for: "villainpain3")
            }
        }
        
        return true
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
        let nextPanel: K.GameboardPosition = getNextPanel(direction: direction)
        let panelType = gameboard.getUserDataForLevelType(sprite: gameboard.getPanelSprite(at: positions.player).terrain!)
        let movementMultiplier: TimeInterval = (playerOnSafePanel() ? 1 : 2) / chosenSword.speedRating
        let runSound: String
        
        if safePanelFound {
            runSound = FireIceTheme.isFire ? "movesand\(Int.random(in: 1...3))" : "movesnow\(Int.random(in: 1...3))"
        }
        else {
            switch panelType {
            case .lava, .water:
                runSound = "movemarsh\(Int.random(in: 1...3))"
            default:
                runSound = "movetile\(Int.random(in: 1...3))"
            }
        }
        
        isDisabled = true
        positions.player = nextPanel
        
        AudioManager.shared.playSound(for: runSound)
        
        //First, run animation...
        player.sprite.run(Player.animate(player: player, type: .run, timePerFrameMultiplier: movementMultiplier))
        
        //Wait, then idle animation...
        player.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: Player.Texture.run.movementSpeed * movementMultiplier),
            Player.animate(player: player, type: .idle)
        ]))
        
        //In between, move player and completion...
        player.sprite.run(SKAction.move(to: gameboard.getLocation(at: nextPanel), duration: Player.Texture.run.movementSpeed * movementMultiplier)) { [weak self] in
            self?.isDisabled = false
            
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
            completion?()
        }
    }
    
    
    // MARK: - Villain Movement
    
    /**
     Moves the villain to a new, random spot on the board. Use this to periodically move the villain, via a timer, for example.
     */
    @objc private func moveVillain(_ sender: Any) {
        moveVillainFlee(shouldDisappear: false, fadeDuration: 0) { [weak self] in
            guard let self = self else { return }
            
            magmoorAttacks.attack(pattern: MagmoorAttacks.getAttackPattern(enrage: magmoorShield.isEnraged), positions: positions)
        }
    }
    
    /**
     Resets the timer and begins a new one.
     - parameter forceDelay: a forced time that overrides villainMovementDelay. Set when villain doesn't have a shield, for example.
     */
    private func resetTimer(forceDelay: TimeInterval?) {
        let timeInterval = forceDelay ?? (magmoorShield.isEnraged ? villainMovementDelay.enraged : villainMovementDelay.normal)
        
        villainMoveTimer.invalidate()
        villainMoveTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                target: self,
                                                selector: #selector(moveVillain(_:)),
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
     */
    private func moveVillainFlee(shouldDisappear: Bool, fadeDuration: TimeInterval, completion: (() -> Void)?) {
        let moveDirection = villain.sprite.xScale / abs(villain.sprite.xScale)
        let moveDistance: CGFloat = 20
        let fadeDistance = CGPoint(x: 0, y: shouldDisappear ? gameboard.panelSize : 0)
        let waitDuration = TimeInterval.random(in: 3...8)
        let villainDirection: CGFloat = villainPositionNew.col < positions.player.col ? 1 : -1
        
        let disappearAction = SKAction.sequence([
            SKAction.moveBy(x: -moveDirection * moveDistance, y: 0, duration: 0),
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.5),
            SKAction.moveBy(x: moveDirection * moveDistance, y: 0, duration: 0),
            SKAction.group([
                SKAction.moveBy(x: fadeDistance.x, y: fadeDistance.y, duration: fadeDuration),
                SKAction.fadeOut(withDuration: fadeDuration)
            ]),
            SKAction.run {
                AudioManager.shared.playSound(for: "scarylaugh", delay: waitDuration - 1)
            },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [weak self] in
                self?.delegate?.willVillainReappear()
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
                delegate?.didVillainReappear()
                
                magmoorShield.resetShield(villain: villain)
                magmoorAttacks.executeAttackAnimation(color: magmoorShield.shieldColor, playSFX: false)
                
                generateVillainPositionNew(enrage: false)
                resetTimer(forceDelay: nil) //call AFTER setting shield!!
            }
            else {
                generateVillainPositionNew(enrage: magmoorShield.isEnraged)
                resetTimer(forceDelay: nil)
            }
            
            completion?()
        }
        
        
        //Set important properties!!
        positions.villain = villainPositionNew
        
        if shouldDisappear {
            delegate?.didVillainDisappear(fadeDuration: fadeDuration)
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: fadeDuration)
            AudioManager.shared.playSound(for: "magicwarp")
            AudioManager.shared.playSound(for: "magicwarp2")
            ParticleEngine.shared.animateParticles(type: .magmoorBamf,
                                                   toNode: villain.sprite,
                                                   position: .zero,
                                                   scale: 3,
                                                   duration: 2)
        }
    } //end moveVillainFlee()
    
    
}


// MARK: - MagmoorAttacksDelegate

extension FinalBattle2Controls: MagmoorAttacksDelegate {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition) {
        delegate?.didVillainAttack(pattern: pattern, chosenSword: chosenSword, position: position)
    }
}


// MARK: - MagmoorShieldDelegate

extension FinalBattle2Controls: MagmoorShieldDelegate {
    func willDamageShield() {
        delegate?.handleShield(willDamage: true, didDamage: false, willBreak: false, didBreak: false, fadeDuration: nil, chosenSword: chosenSword, villainPosition: nil)
    }
    
    func didDamageShield() {
        delegate?.handleShield(willDamage: false, didDamage: true, willBreak: false, didBreak: false, fadeDuration: nil, chosenSword: chosenSword, villainPosition: nil)
    }
    
    func willBreakShield(fadeDuration: TimeInterval) {
        delegate?.handleShield(willDamage: false, didDamage: false, willBreak: true, didBreak: false, fadeDuration: fadeDuration, chosenSword: chosenSword, villainPosition: nil)
    }
    
    func didBreakShield(at villainPosition: K.GameboardPosition) {
        delegate?.handleShield(willDamage: false, didDamage: false, willBreak: false, didBreak: true, fadeDuration: nil, chosenSword: chosenSword, villainPosition: villainPosition)
    }
    
    
}
