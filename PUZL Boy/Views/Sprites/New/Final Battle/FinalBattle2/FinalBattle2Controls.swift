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
    func didVillainAttack(attackType: FinalBattle2Controls.VillainAttackType, position: K.GameboardPosition?)
    func handleShield(willDamage: Bool, didDamage: Bool, willBreak: Bool, didBreak: Bool, fadeDuration: TimeInterval?, villainPosition: K.GameboardPosition?)
}

class FinalBattle2Controls {
    
    // MARK: - Properties
    
    private var gameboard: GameboardSprite
    private var player: Player
    private var villain: Player
    private(set) var playerPosition: K.GameboardPosition
    private(set) var villainPosition: K.GameboardPosition
    private var chosenSword: ChosenSword
    private var magmoorShield: MagmoorShield
    
    //These get set every time in handleControls()
    private var location: CGPoint!
    private var villainPositionNew: K.GameboardPosition!
    private var safePanelFound: Bool!
    
    private var isDisabled: Bool
    private var canAttack: Bool
    private var villainMoveTimer: Timer
    
    //Villain movement and attack properties
    private var villainMovementDelay: TimeInterval = 10
    private var villainAttackNormalSpeed: TimeInterval = 0.5
    private var villainAttackTimedCount: Int = 3
    private var villainAttackTimedCanHurtPlayer: Bool = true
    private var villainAttackTimedCanHurtVillain: Bool = true
    
    enum VillainAttackType {
        case normal, timed
    }
    
    weak var delegate: FinalBattle2ControlsDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, player: Player, villain: Player, playerPosition: K.GameboardPosition, villainPosition: K.GameboardPosition) {
        self.gameboard = gameboard
        self.player = player
        self.villain = villain
        self.playerPosition = playerPosition
        self.villainPosition = villainPosition
        
        self.isDisabled = false
        self.canAttack = true
        self.villainMoveTimer = Timer()
        
        chosenSword = ChosenSword(didPursueMagmoor: FIRManager.didPursueMagmoor,
                                  didGiveAwayFeather: FIRManager.didGiveAwayFeather,
                                  bravery: FIRManager.bravery)
        chosenSword.spriteNode.setScale(gameboard.panelSize / chosenSword.spriteNode.size.width)
        chosenSword.spriteNode.zPosition = K.ZPosition.itemsAndEffects
        
        magmoorShield = MagmoorShield(hitPoints: 0)
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
        
        generateVillainPositionNew()
        
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
    
    
    // MARK: - Villain Attack Setters
    
    func setVillainMovementDelay(_ newValue: TimeInterval) {
        self.villainMovementDelay = newValue
    }
    
    
    func setVillainAttackNormalSpeed(_ newValue: CGFloat) {
        self.villainAttackNormalSpeed = newValue
    }
    
    func setVillainAttackTimedCount(_ newValue: Int) {
        self.villainAttackTimedCount = newValue
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
        
        var bottomBound: CGFloat = CGFloat(playerPosition.row) + 1
        var rightBound: CGFloat = CGFloat(playerPosition.col) + 1
        var topBound: CGFloat = CGFloat(playerPosition.row) {
            didSet { topBound = max(0, topBound) }
        }
        var leftBound: CGFloat = CGFloat(playerPosition.col) {
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
            nextPanel = (row: playerPosition.row - 1, col: playerPosition.col)
        case .down:
            nextPanel = (row: playerPosition.row + 1, col: playerPosition.col)
        case .left:
            nextPanel = (row: playerPosition.row, col: playerPosition.col - 1)
            player.sprite.xScale = -abs(player.sprite.xScale)
        case .right:
            nextPanel = (row: playerPosition.row, col: playerPosition.col + 1)
            player.sprite.xScale = abs(player.sprite.xScale)
        default:
            nextPanel = (row: playerPosition.row, col: playerPosition.col)
        }
        
        return nextPanel
    }
    
    private func canAttackVillain(_ direction: Controls) -> Bool {
        let attackPanel: K.GameboardPosition = getNextPanel(direction: direction)
        
        guard attackPanel == villainPosition else { return false }
        guard playerOnSafePanel() && canAttack else { return true }
        
        isDisabled = true
        canAttack = false
        villainMoveTimer.invalidate()
        
        gameboard.sprite.addChild(chosenSword.spriteNode)
        
        chosenSword.spriteNode.position = gameboard.getLocation(at: villainPosition)
        chosenSword.attack(shouldParry: magmoorShield.hasHitPoints) { [weak self] in
            guard let self = self else { return }
            
            isDisabled = false
            
            if magmoorShield.hasHitPoints {
                magmoorShield.decrementShield(villain: villain, villainPosition: villainPosition) {
                    self.canAttack = true
                }
                
                if magmoorShield.hasHitPoints {
                    moveVillainFlee(shouldDisappear: false, completion: nil)
                }
                
                AudioManager.shared.playSound(for: "villainpain\(Int.random(in: 1...2))")
            }
            else {
                moveVillainFlee(shouldDisappear: true, completion: nil)
                
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
        return safePanelFound || playerPosition == FinalBattle2Spawner.startPosition || playerPosition == FinalBattle2Spawner.endPosition
    }
    
    /**
     Physically move the player in the intended direction.
     - parameters:
        - direction: The direction the player would like to move to
        - completion: handler to perform functions upon animation completion
     */
    private func movePlayerHelper(_ direction: Controls, completion: (() -> Void)?) {
        let nextPanel: K.GameboardPosition = getNextPanel(direction: direction)
        let panelType = gameboard.getUserDataForLevelType(sprite: gameboard.getPanelSprite(at:playerPosition).terrain!)
        let movementMultiplier: TimeInterval = playerOnSafePanel() ? 1 : 2
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
        playerPosition = nextPanel
        
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
        generateVillainPositionNew()
        
        moveVillainFlee(shouldDisappear: false, fadeDuration: 0) { [weak self] in
            // FIXME: - Change attack type based on spawner speed? Or battle progression?
            self?.villainAttack(type: Bool.random() ? .normal : .timed)
        }
    }
    
    /**
     Resets the timer and begins a new one.
     - parameter delay: time in between until timer fires again
     */
    private func resetTimer() {
        villainMoveTimer.invalidate()
        villainMoveTimer = Timer.scheduledTimer(timeInterval: villainMovementDelay,
                                                target: self,
                                                selector: #selector(moveVillain(_:)),
                                                userInfo: nil,
                                                repeats: false)
    }
    
    /**
     Generates a new position for the villain.
     */
    private func generateVillainPositionNew() {
        //Villain's new spawn position cannot be where player position or start position are!
        repeat {
            villainPositionNew = (Int.random(in: 0...gameboard.panelCount - 1), Int.random(in: 0...gameboard.panelCount - 1))
        } while villainPositionNew == playerPosition || villainPositionNew == FinalBattle2Spawner.startPosition
    }
    
    /**
     Helper function to assist with moving the villain after he's been attacked by the hero.
     */
    private func moveVillainFlee(shouldDisappear: Bool, fadeDuration: TimeInterval = 2, completion: (() -> Void)?) {
        let moveDirection = villain.sprite.xScale / abs(villain.sprite.xScale)
        let moveDistance: CGFloat = 20
        let fadeDistance = CGPoint(x: 0, y: shouldDisappear ? gameboard.panelSize : 0)
        let waitDuration = TimeInterval.random(in: 3...8)
        let villainDirection: CGFloat = villainPositionNew.col < playerPosition.col ? 1 : -1
        
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
            
            resetTimer()
            completion?()
            
            guard shouldDisappear else { return }
            
            canAttack = true
            delegate?.didVillainReappear()
            
            magmoorShield.resetShield(villain: villain)
            villain.sprite.run(Player.animate(player: villain, type: .attack, repeatCount: 1))
        }
        
        
        //Set important properties!!
        villainPosition = villainPositionNew
        
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
    
    
    // MARK: - Villain Attacks

    /**
     Decrement villain shield if he's in the blast radius of the timed bomb. Call this within FinalBattle2Engine.
     */
    func villainAttackTimedBombHurtVillain() {
        guard magmoorShield.hitPoints > 1 && villainAttackTimedCanHurtVillain else { return }
        
        villainAttackTimedCanHurtVillain = false
        magmoorShield.decrementShield(villain: villain, villainPosition: villainPosition, completion: nil)
        AudioManager.shared.playSound(for: "villainpain\(Int.random(in: 1...2))")
    }
    
    func villainAttackTimedBombCanHurtPlayer() -> Bool {
        guard villainAttackTimedCanHurtPlayer else { return false}
        
        villainAttackTimedCanHurtPlayer = false
        
        return true
    }
    
    private func villainAttack(type: VillainAttackType) {
        let villainDirection: CGFloat = villain.sprite.xScale > 0 ? -1 : 1
        
        villain.sprite.run(SKAction.sequence([
            Player.animate(player: villain, type: .attack, repeatCount: 1)
        ]))
        
        villainAttackTimedCanHurtPlayer = true
        villainAttackTimedCanHurtVillain = true
        
        AudioManager.shared.playSound(for: "villainattack\(Int.random(in: 1...2))")
        
        switch type {
        case .normal:
            //MUST preserve original position here before player moves out of the way!
            let originalPosition = playerPosition
            let fireballAngle = SpriteMath.Trigonometry.getAngles(startPoint: villain.sprite.position,
                                                                  endPoint: gameboard.getLocation(at: originalPosition))

            //Assuming original image is upwards (pointing downwards)!
            let fireballAngleOffset: CGFloat
            
            switch (row: villainPosition.row - originalPosition.row, col: villainPosition.col - originalPosition.col)  {
            case let position where position.row < 0 && position.col < 0:
                fireballAngleOffset = fireballAngle.alpha + 0
            case let position where position.row < 0 && position.col > 0:
                fireballAngleOffset = fireballAngle.beta - .pi / 2
            case let position where position.row > 0 && position.col < 0:
                fireballAngleOffset = fireballAngle.beta + .pi / 2
            case let position where position.row > 0 && position.col > 0:
                fireballAngleOffset = fireballAngle.alpha + .pi
            case let position where position.row > 0 && position.col == 0:
                fireballAngleOffset = fireballAngle.alpha + .pi
            case let position where position.row == 0 && position.col > 0:
                fireballAngleOffset = fireballAngle.alpha + .pi
            default:
                fireballAngleOffset = fireballAngle.alpha
            }
            
            let rowSquared = pow(TimeInterval(villainPosition.row) - TimeInterval(originalPosition.row), 2)
            let colSquared = pow(TimeInterval(villainPosition.col) - TimeInterval(originalPosition.col), 2)
            let distanceVillainToPlayer = sqrt(rowSquared + colSquared)
            let fireballMovementDuration = max(distanceVillainToPlayer * villainAttackNormalSpeed, 0.25)
            
            let fireball = SKSpriteNode(imageNamed: FireIceTheme.isFire ? "villainProjectile1" : "villainProjectile2")
            fireball.position = villain.sprite.position + Player.mysticWandOrigin * villainDirection
            fireball.setScale(0.25 / UIDevice.spriteScale)
            fireball.color = FireIceTheme.overlayColor
            fireball.zRotation = fireballAngleOffset
            fireball.zPosition = K.ZPosition.itemsAndEffects
            
            gameboard.sprite.addChild(fireball)
            
            fireball.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.colorize(withColorBlendFactor: 1, duration: 0.1),
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
            ])))
            
            fireball.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: gameboard.getLocation(at: originalPosition), duration: fireballMovementDuration),
                    SKAction.scale(to: 0.5 / UIDevice.spriteScale, duration: fireballMovementDuration)
                ]),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    delegate?.didVillainAttack(attackType: .normal, position: originalPosition)
                },
                SKAction.group([
                    SKAction.fadeOut(withDuration: 0.25),
                    SKAction.scale(to: 1 / UIDevice.spriteScale, duration: 0.25)
                ]),
                SKAction.removeFromParent()
            ]))
            
            if let attackAudio = AudioManager.shared.getAudioItem(filename: FireIceTheme.isFire ? "enemyflame" : "enemyice") {
                let delayDuration = FireIceTheme.isFire ? fireballMovementDuration : max(0, fireballMovementDuration - 0.25)
                
                AudioManager.shared.playSound(for: attackAudio.fileName, delay: delayDuration)
            }
        case .timed:
            func pulseTimedBomb(speed: TimeInterval, canPlaySound: Bool) -> SKAction {
                return SKAction.sequence([
                    SKAction.group([
                        SKAction.colorize(withColorBlendFactor: 1, duration: speed / 2),
                        SKAction.scale(to: 1 / UIDevice.spriteScale, duration: speed / 2)
                    ]),
                    SKAction.run {
                        if canPlaySound {
                            AudioManager.shared.playSound(for: "villainattackbombtick")
                        }
                    },
                    SKAction.group([
                        SKAction.colorize(withColorBlendFactor: 0, duration: speed / 2),
                        SKAction.scale(to: 0.75 / UIDevice.spriteScale, duration: speed / 2)
                    ])
                ])
            }
            
            for i in 0..<villainAttackTimedCount {
                let moveDuration: TimeInterval = 1
                let fadeOutDuration: TimeInterval = 0.25
                let explodeDistance: CGFloat = 20
                var randomPosition: K.GameboardPosition
                
                repeat {
                    randomPosition = (Int.random(in: 0..<gameboard.panelCount), Int.random(in: 0..<gameboard.panelCount))
                } while randomPosition == villainPosition
                
                let fireball = SKSpriteNode(imageNamed: "villainProjectile3")
                fireball.position = villain.sprite.position + Player.mysticWandOrigin * villainDirection
                fireball.setScale(0.25 / UIDevice.spriteScale)
                fireball.color = .red
                fireball.colorBlendFactor = 0
                fireball.zPosition = K.ZPosition.player - 2
                
                gameboard.sprite.addChild(fireball)
                
                fireball.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.move(to: gameboard.getLocation(at: randomPosition), duration: moveDuration),
                        SKAction.scale(to: 0.75 / UIDevice.spriteScale, duration: moveDuration),
                        SKAction.rotate(byAngle: 4 * .pi * villainDirection, duration: moveDuration)
                    ]),
                    SKAction.repeat(pulseTimedBomb(speed: 1, canPlaySound: i == 0), count: 3),
                    SKAction.repeat(pulseTimedBomb(speed: 0.75, canPlaySound: i == 0), count: 3),
                    SKAction.repeat(pulseTimedBomb(speed: 0.5, canPlaySound: i == 0), count: 3),
                    SKAction.run {
                        if i == 0 {
                            AudioManager.shared.playSound(for: "villainattackspecialbomb")
                        }
                    },
                    SKAction.repeat(pulseTimedBomb(speed: 0.35, canPlaySound: i == 0), count: 3),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        delegate?.didVillainAttack(attackType: .timed, position: randomPosition)
                    },
                    SKAction.group([
                        SKAction.colorize(withColorBlendFactor: 1, duration: fadeOutDuration),
                        SKAction.scale(to: 3, duration: fadeOutDuration),
                        SKAction.fadeOut(withDuration: fadeOutDuration),
                        SKAction.sequence([
                            SKAction.moveBy(x: -explodeDistance, y: 0, duration: fadeOutDuration / 5),
                            SKAction.moveBy(x: explodeDistance * 2, y: 0, duration: fadeOutDuration / 5),
                            SKAction.moveBy(x: -explodeDistance * 2, y: 0, duration: fadeOutDuration / 5),
                            SKAction.moveBy(x: explodeDistance * 2, y: 0, duration: fadeOutDuration / 5),
                            SKAction.moveBy(x: -explodeDistance, y: 0, duration: fadeOutDuration / 5),
                        ])
                    ]),
                    SKAction.removeFromParent()
                ]))
            }//end for
        }//end switch
    }//end villainAttack()
    
    
}


// MARK: - MagmoorShieldDelegate

extension FinalBattle2Controls: MagmoorShieldDelegate {
    func willDamageShield() {
        delegate?.handleShield(willDamage: true, didDamage: false, willBreak: false, didBreak: false, fadeDuration: nil, villainPosition: nil)
    }
    
    func didDamageShield() {
        delegate?.handleShield(willDamage: false, didDamage: true, willBreak: false, didBreak: false, fadeDuration: nil, villainPosition: nil)
    }
    
    func willBreakShield(fadeDuration: TimeInterval) {
        delegate?.handleShield(willDamage: false, didDamage: false, willBreak: true, didBreak: false, fadeDuration: fadeDuration, villainPosition: nil)
    }
    
    func didBreakShield(at villainPosition: K.GameboardPosition) {
        delegate?.handleShield(willDamage: false, didDamage: false, willBreak: false, didBreak: true, fadeDuration: nil, villainPosition: villainPosition)
    }
    
    
}
