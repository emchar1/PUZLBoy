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
    func willDamageShield()
    func didDamageShield()
    func willBreakShield(fadeDuration: TimeInterval)
    func didBreakShield(at villainPosition: K.GameboardPosition)
}

class FinalBattle2Controls {
    
    // MARK: - Properties
    
    private var gameboard: GameboardSprite
    private var player: Player
    private var villain: Player
    private var playerPosition: K.GameboardPosition
    private var villainPosition: K.GameboardPosition
    private var chosenSword: ChosenSword
    
    //These get set every time in handleControls()
    private var location: CGPoint!
    private var villainPositionNew: K.GameboardPosition!
    private var safePanelFound: Bool!
    
    private var villainShield: Int
    private var isDisabled: Bool
    private var canAttack: Bool
    
    weak var delegate: FinalBattle2ControlsDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, player: Player, villain: Player, playerPosition: K.GameboardPosition, villainPosition: K.GameboardPosition) {
        self.gameboard = gameboard
        self.player = player
        self.villain = villain
        self.playerPosition = playerPosition
        self.villainPosition = villainPosition
        
        self.villainShield = 0
        self.isDisabled = false
        self.canAttack = true
        
        chosenSword = ChosenSword(didPursueMagmoor: FIRManager.didPursueMagmoor,
                                  didGiveAwayFeather: FIRManager.didGiveAwayFeather,
                                  bravery: FIRManager.bravery)
        chosenSword.spriteNode.setScale(gameboard.panelSize / chosenSword.spriteNode.size.width)
        chosenSword.spriteNode.zPosition = K.ZPosition.itemsAndEffects
    }
    
    deinit {
        print("deinit FinalBattle2Controls")
    }
    
    
    // MARK: - Functions
    
    /**
     Handles player movement based on control input.
     - parameters:
        - location: location for which comparison is to occur
        - playerPosition: the player's position, which will be overridden becuase it's an inout parameter
        - villainPosition: the villain's (inout) position
        - safePanelFound: returns true if a safe panel i.e. sand/snow is found in the player's position
        - completion: handler to perform tasks upon completion
     */
    func handleControls(in location: CGPoint, playerPosition: inout K.GameboardPosition, villainPosition: inout K.GameboardPosition, safePanelFound: Bool, completion: (() -> Void)?) {
        guard !isDisabled else { return }
        
        self.location = location
        self.safePanelFound = safePanelFound
        
        //Villain's new spawn position cannot be where player position or start position are!
        repeat {
            villainPositionNew = (Int.random(in: 0...gameboard.panelCount - 1), Int.random(in: 0...gameboard.panelCount - 1))
        } while villainPositionNew == playerPosition || villainPositionNew == FinalBattle2Engine.startPosition
        
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
        
        //Since these arguments are inout, remember to set the global variables! Put these lines last!!!
        playerPosition = self.playerPosition
        villainPosition = villainPositionNew
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
        
        if (safePanelFound || playerPosition == FinalBattle2Engine.startPosition || playerPosition == FinalBattle2Engine.endPosition) && canAttack {
            isDisabled = true
            canAttack = false
            
            gameboard.sprite.addChild(chosenSword.spriteNode)
            
            chosenSword.spriteNode.position = gameboard.getLocation(at: villainPosition)
            chosenSword.attack(shouldParry: villainShield > 0) { [weak self] in
                guard let self = self else { return }
                
                isDisabled = false
                
                if villainShield > 0 {
                    villainShieldDecrement()
                }
                else {
                    moveVillainFlee()
                    
                    delegate?.didHeroAttack(chosenSword: chosenSword)
                }
            }
        }
        
        return true
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
        let movementMultiplier: TimeInterval = (safePanelFound || playerPosition == FinalBattle2Engine.startPosition || playerPosition == FinalBattle2Engine.endPosition) ? 1 : 2
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
            Player.animate(player: player, type: .idle, timePerFrame: movementMultiplier)
        ]))
        
        //In between, move player and completion...
        player.sprite.run(SKAction.move(to: gameboard.getLocation(at: nextPanel), duration: Player.Texture.run.movementSpeed * movementMultiplier)) { [weak self] in
            self?.isDisabled = false
            
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
            completion?()
        }
    }
    
    
    // MARK: - Villain Movement and Attacks
    
    /**
     Helper function to assist with moving the villain after he's been attacked by the hero.
     */
    private func moveVillainFlee() {
        let moveDirection = villain.sprite.xScale / abs(villain.sprite.xScale)
        let moveDistance: CGFloat = 20
        let fadeDistance = CGPoint(x: 0, y: gameboard.panelSize) + FinalBattle2Engine.villainFloatOffset
        let fadeDuration: TimeInterval = 2
        let waitDuration = TimeInterval.random(in: 3...8)
        let villainDirection: CGFloat = villainPositionNew.col < gameboard.panelCount / 2 ? 1 : -1
        
        villainPosition = villainPositionNew
        
        delegate?.didVillainDisappear(fadeDuration: fadeDuration)
        
        AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: fadeDuration)
        AudioManager.shared.playSound(for: "villainpain\(Int.random(in: 1...3))")
        
        villain.sprite.run(SKAction.sequence([
            SKAction.moveBy(x: -moveDirection * moveDistance, y: 0, duration: 0),
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.5),
            SKAction.moveBy(x: moveDirection * moveDistance, y: 0, duration: 0),
            SKAction.group([
                SKAction.moveBy(x: fadeDistance.x, y: fadeDistance.y, duration: fadeDuration),
                SKAction.fadeOut(withDuration: fadeDuration)
            ]),
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [weak self] in
                self?.delegate?.willVillainReappear()
                AudioManager.shared.playSound(for: "scarylaugh")
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 1)
            },
            Player.moveWithIllusions(playerNode: villain.sprite,
                                     backgroundNode: gameboard.sprite,
                                     color: .red.darkenColor(factor: 12),
                                     playSound: true,
                                     fierce: true,
                                     startPoint: villain.sprite.position + fadeDistance,
                                     endPoint: gameboard.getLocation(at: villainPositionNew) + FinalBattle2Engine.villainFloatOffset,
                                     startScale: 1,
                                     endScale: 1),
            SKAction.move(to: gameboard.getLocation(at: villainPositionNew) + FinalBattle2Engine.villainFloatOffset, duration: 0),
            SKAction.scaleX(to: villainDirection * abs(villain.sprite.xScale), duration: 0),
            SKAction.fadeIn(withDuration: 0)
        ])) { [weak self] in
            self?.canAttack = true
            self?.moveVillainCastShield()

            self?.delegate?.didVillainReappear()
        }
        
        AudioManager.shared.playSound(for: "magicwarp")
        AudioManager.shared.playSound(for: "magicwarp2")
        ParticleEngine.shared.animateParticles(type: .magmoorBamf,
                                               toNode: villain.sprite,
                                               position: .zero,
                                               scale: 3,
                                               duration: 2)
    }
    
    /**
     Resets the shield to the max, i.e. 3 and apply a quick animation.
     */
    private func villainShieldReset() {
        let magmoorShield = SKSpriteNode(imageNamed: "magmoorShieldBottom")
        magmoorShield.color = .red
        magmoorShield.colorBlendFactor = 1
        magmoorShield.setScale(0)
        magmoorShield.zPosition = -1
        magmoorShield.name = "magmoorShield"
        
        let magmoorShieldTop = SKSpriteNode(imageNamed: "magmoorShieldTop")
        magmoorShieldTop.color = .red
        magmoorShieldTop.colorBlendFactor = 1
        magmoorShieldTop.zPosition = 2
        
        magmoorShield.addChild(magmoorShieldTop)
        villain.sprite.addChild(magmoorShield)
        
        villainShield = 3
        
        AudioManager.shared.playSound(for: "shieldcast")
        AudioManager.shared.playSound(for: "shieldcast2")
        Haptics.shared.addHapticFeedback(withStyle: .soft)
        
        shieldThrob(node: magmoorShield, waitDuration: 2.5)
        magmoorShield.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 2, duration: 4)))
        magmoorShield.run(SKAction.sequence([
            scaleAndFade(size: 6, alpha: 0.5, duration: 0.25),
            scaleAndFade(size: 2.5, alpha: 1, duration: 0.5),
            SKAction.run {
                AudioManager.shared.playSound(for: "shieldpulse")
            },
            scaleAndFade(duration: 1.75)
        ]))
    }
    
    /**
     Decrements the shield and applies a quick animation, depending on if the shield breaks or not.
     - parameter increment: amount to decrement (should be a positive value)
     */
    private func villainShieldDecrement(_ increment: Int = 1) {
        guard let magmoorShield = villain.sprite.childNode(withName: "magmoorShield") else { return }
        
        villainShield -= increment
        villainShield = max(villainShield, 0)
        
        delegate?.willDamageShield()
        
        if villainShield > 0 {
            let fadeDuration: TimeInterval = 2.5
            
            magmoorShield.removeAction(forKey: "shieldThrobAction")
            shieldThrob(node: magmoorShield, waitDuration: fadeDuration + 0.5)
            
            magmoorShield.run(SKAction.sequence([
                SKAction.group([
                    scaleAndFade(size: 3.5, alpha: 1, duration: fadeDuration),
                    shieldShake(duration: fadeDuration)
                ]),
                SKAction.run { [weak self] in
                    self?.delegate?.didDamageShield()
                },
                scaleAndFade(size: 5, alpha: 0.5, duration: 0.5)
            ])) { [weak self] in
                self?.canAttack = true
            }
        }
        else {
            let fadeDuration: TimeInterval = 4.5
            
            AudioManager.shared.playSound(for: "magicdisappear", delay: fadeDuration)
            
            magmoorShield.removeAction(forKey: "shieldThrobAction")
            magmoorShield.run(SKAction.sequence([
                SKAction.group([
                    scaleAndFade(size: 2.5, alpha: 1, duration: fadeDuration + 0.5),
                    shieldShake(duration: fadeDuration + 0.5),
                    SKAction.sequence([
                        SKAction.wait(forDuration: fadeDuration + 0.25),
                        SKAction.run { [weak self] in
                            guard let self = self else { return }
                            
                            delegate?.willBreakShield(fadeDuration: 0.25)
                            
                            AudioManager.shared.stopSound(for: "shieldpulse")
                            ParticleEngine.shared.animateParticles(type: .magicExplosion,
                                                                   toNode: villain.sprite,
                                                                   position: .zero,
                                                                   scale: 1,
                                                                   duration: 1)
                        }
                    ])
                ]),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    delegate?.didBreakShield(at: villainPosition)
                },
                scaleAndFade(size: 16, alpha: 1, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.removeFromParent()
            ])) { [weak self] in
                self?.canAttack = true
            }
        }
    }
    
    /**
     Helper function that scales to a particular size, and fades to a particular alpha over the duration.
     - parameters:
        - size: size of scale
        - alpha: the alpha of the fade
        - duration: time it takes to perform the action
     - returns: the action group.
     */
    private func scaleAndFade(size: CGFloat = 5, alpha: CGFloat = 0.5, duration: TimeInterval = 1) -> SKAction {
        return SKAction.group([
            SKAction.scale(to: size, duration: duration),
            SKAction.fadeAlpha(to: alpha, duration: duration)
        ])
    }
    
    /**
     Shakes the shield left and right.
     - parameter duration: duration of the shake
     - returns: the shaking SKAction
     */
    private func shieldShake(duration: TimeInterval) -> SKAction {
        let moveAction = SKAction.moveBy(x: -40, y: 0, duration: 0.05)
        
        return SKAction.repeat(SKAction.sequence([
            moveAction,
            moveAction.reversed()
        ]), count: Int(duration / 0.1))
    }
    
    /**
     Performs a shield throbbing action on the node passed in
     - parameters:
        - node: the node to which to perform the action
        - waitDuration: pause before throbbing action
     */
    private func shieldThrob(node: SKNode, waitDuration: TimeInterval) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.repeatForever(SKAction.sequence([
                scaleAndFade(size: 4, alpha: 1, duration: 2),
                scaleAndFade(size: 5, alpha: 0.5, duration: 2)
            ]))
        ]), withKey: "shieldThrobAction")
    }
    
    /**
     Casts a protective shield around the villain that requires X hits before breaking.
     */
    private func moveVillainCastShield() {
        villainShieldReset()
        
        //Animations
        villain.sprite.run(Player.animate(player: villain, type: .attack, repeatCount: 1))
    }
    
    
    
}
