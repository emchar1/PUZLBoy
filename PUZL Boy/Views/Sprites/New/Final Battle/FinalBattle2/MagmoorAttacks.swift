//
//  MagmoorAttacks.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/11/25.
//

import SpriteKit

protocol MagmoorAttacksDelegate: AnyObject {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition)
}

class MagmoorAttacks {
    
    // MARK: - Properties
    
    private var gameboard: GameboardSprite
    private var villain: Player
    
    private var normalFireballSpeed: TimeInterval
    private var timedBombCount: (normal: Int, large: Int)
    private var timedCanHurtPlayer: Bool
    private var timedCanHurtVillain: Bool
    
    private var villainDirection: CGFloat { villain.sprite.xScale > 0 ? -1 : 1 }
    private var fireballPosition: CGPoint {
        villain.sprite.position + CGPoint(x: Player.mysticWandOrigin.x * villainDirection, y: Player.mysticWandOrigin.y)
    }
    
    enum AttackPattern: CaseIterable {
        case normal, timed, timedLarge
    }
    
    weak var delegate: MagmoorAttacksDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, villain: Player) {
        self.gameboard = gameboard
        self.villain = villain
        
        normalFireballSpeed = 0.5
        timedBombCount = (normal: 3, large: 1)
        timedCanHurtPlayer = true
        timedCanHurtVillain = true
    }
    
    deinit {
        print("deinit MagmoorAttacks")
    }
    
    
    // MARK: - Functions
    
    /**
     Generates an attack pattern based on probability.
     - parameter enrage: if true, always returns normal attack
     - returns: the attack pattern generated
     */
    static func getAttackPattern(enrage: Bool) -> AttackPattern {
        guard !enrage else { return .normal }
        
        let attackPattern: AttackPattern
        let randomInt = Int.random(in: 0...99)
//        print("randomInt|\(randomInt)", terminator: "||")
        
        if randomInt % 2 == 0 || randomInt % 3 == 0 {
            attackPattern = .normal
        }
        else {
            let randomInt2 = Int.random(in: 0...99)
//            print("randomInt2|\(randomInt2)", terminator: "||")
            
            if randomInt2 % 2 == 0 || randomInt2 % 3 == 0 {
                attackPattern = .timed
            }
            else {
                attackPattern = .timedLarge
            }
        }
                
//        print("attackPattern|\(attackPattern)")
        return attackPattern
    }
    
    func timedBombCanHurtVillain() -> Bool {
        guard timedCanHurtVillain else { return false }
        
        timedCanHurtVillain = false
        
        return true
    }
    
    func timedBombCanHurtPlayer() -> Bool {
        guard timedCanHurtPlayer else { return false }
        
        timedCanHurtPlayer = false
        
        return true
    }
    
    /**
     Initiates one of Magmoor's various wand attacks.
     - parameters:
        - pattern: attack pattern type
        - positions: the player and villain gameboard positions.
     */
    func attack(pattern: AttackPattern, positions: FinalBattle2Controls.PlayerPositions) {
        timedCanHurtPlayer = true
        timedCanHurtVillain = true
        
        let wandColor: UIColor
        
        switch pattern {
        case .normal:
            wandColor = FireIceTheme.isFire ? .systemPink : .cyan
            helperNormal(positions: positions)
        case .timed:
            wandColor = .magenta
            helperTimed(positions: positions, isLarge: false)
        case .timedLarge:
            wandColor = .purple
            helperTimed(positions: positions, isLarge: true)
        }
        
        executeAttackAnimation(color: wandColor, playSFX: true)
    }
    
    /**
     Executes an attack animation with sound and particles.
     - parameters:
        - color: color of the wand particle
        - playSFX: if true, play villainattack and villainattackwand SFX's
     */
    func executeAttackAnimation(color: UIColor, playSFX: Bool) {
        let colorSequence = SKKeyframeSequence(keyframeValues: [
            UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
            color
        ], times: [0, 1])

        villain.sprite.run(Player.animate(player: villain, type: .attack, repeatCount: 1))
        
        if playSFX {
            AudioManager.shared.playSound(for: "villainattack\(Int.random(in: 1...2))")
            AudioManager.shared.playSound(for: "villainattackwand")
        }
        
        ParticleEngine.shared.animateParticles(type: .magicBlastPoof,
                                               toNode: gameboard.sprite,
                                               position: fireballPosition,
                                               scale: 1,
                                               colorSequence: colorSequence,
                                               zPosition: K.ZPosition.player + 4,
                                               duration: 2)
        
        ParticleEngine.shared.animateParticles(type: .warp,
                                               toNode: gameboard.sprite,
                                               position: fireballPosition,
                                               scale: 1,
                                               zPosition: K.ZPosition.player + 2,
                                               duration: 2)
    }
    
    
    // MARK: - Setter Functions
    
    func setNormalFireballSpeed(_ newValue: CGFloat) {
        normalFireballSpeed = newValue
    }
    
    func setTimedBombNormalCount(_ newValue: Int) {
        timedBombCount.normal = newValue
    }

    func setTimedBombLargeCount(_ newValue: Int) {
        timedBombCount.large = newValue
    }

    
    // MARK: - Attack Helper Functions
    
    private func createFireball(positions: FinalBattle2Controls.PlayerPositions, imageName: String, color: UIColor, zPosition: CGFloat, shouldRotate: Bool) -> SKSpriteNode {
        
        let fireball = SKSpriteNode(imageNamed: imageName)
        fireball.position = fireballPosition
        fireball.setScale(0.25 / UIDevice.spriteScale)
        fireball.color = color
        fireball.colorBlendFactor = 0
        fireball.zPosition = zPosition
        
        //Calculate angle of fireball, assuming original image is pointing downwards, if rotation is requested.
        if shouldRotate {
            let fireballAngleOffset: CGFloat
            let fireballAngle = SpriteMath.Trigonometry.getAngles(startPoint: villain.sprite.position,
                                                                  endPoint: gameboard.getLocation(at: positions.player))
            
            switch (row: positions.villain.row - positions.player.row, col: positions.villain.col - positions.player.col) {
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
            
            fireball.zRotation = fireballAngleOffset
        }
        
        return fireball
    }
    
    private func helperNormal(positions: FinalBattle2Controls.PlayerPositions) {
        let rowSquared = pow(TimeInterval(positions.villain.row) - TimeInterval(positions.player.row), 2)
        let colSquared = pow(TimeInterval(positions.villain.col) - TimeInterval(positions.player.col), 2)
        let distanceVillainToPlayer = sqrt(rowSquared + colSquared)
        let fireballMovementDuration = max(distanceVillainToPlayer * normalFireballSpeed, 0.25)
        
        let fireball = createFireball(positions: positions,
                                      imageName: FireIceTheme.isFire ? "villainProjectile1" : "villainProjectile2",
                                      color: FireIceTheme.overlayColor,
                                      zPosition: K.ZPosition.itemsAndEffects,
                                      shouldRotate: true)
        
        gameboard.sprite.addChild(fireball)
        
        if !FireIceTheme.isFire {
            fireball.run(SKAction.rotate(toAngle: distanceVillainToPlayer * .pi * villainDirection, duration: fireballMovementDuration))
        }
        
        fireball.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.colorize(withColorBlendFactor: 1, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
        ])))
        
        fireball.run(SKAction.sequence([
            SKAction.group([
                SKAction.move(to: gameboard.getLocation(at: positions.player), duration: fireballMovementDuration),
                SKAction.scale(to: 0.5 / UIDevice.spriteScale, duration: fireballMovementDuration)
            ]),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                delegate?.didVillainAttack(pattern: .normal, position: positions.player)
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
    }
    
    private func helperTimed(positions: FinalBattle2Controls.PlayerPositions, isLarge: Bool) {
        func pulseTimedBomb(speed: TimeInterval, canPlaySound: Bool) -> SKAction {
            return SKAction.sequence([
                SKAction.group([
                    SKAction.colorize(withColorBlendFactor: 1, duration: speed / 2),
                    SKAction.scale(to: (isLarge ? 2 : 1) / UIDevice.spriteScale, duration: speed / 2)
                ]),
                SKAction.run {
                    if canPlaySound {
                        AudioManager.shared.playSound(for: isLarge ? "villainattackbombticklarge" : "villainattackbombtick")
                    }
                },
                SKAction.group([
                    SKAction.colorize(withColorBlendFactor: 0, duration: speed / 2),
                    SKAction.scale(to: (isLarge ? 1.5 : 0.75) / UIDevice.spriteScale, duration: speed / 2)
                ])
            ])
        }
        
        for i in 0..<(isLarge ? timedBombCount.large : timedBombCount.normal) {
            let moveDuration: TimeInterval = 1
            let fadeOutDuration: TimeInterval = isLarge ? 0.5 : 0.25
            let explodeDistance: CGFloat = isLarge ? 30 : 20
            var randomPosition: K.GameboardPosition
            var largeBombRestriction: Bool {
                guard isLarge else { return false }
                
                return randomPosition.col * Int(villainDirection) > positions.villain.col * Int(villainDirection)
            }
            
            repeat {
                randomPosition = (Int.random(in: 0..<gameboard.panelCount), Int.random(in: 0..<gameboard.panelCount))
            } while randomPosition == positions.villain || largeBombRestriction
            
            let fireball = createFireball(positions: positions,
                                          imageName: isLarge ? "villainProjectile3L" : "villainProjectile3",
                                          color: .red,
                                          zPosition: K.ZPosition.player - 2,
                                          shouldRotate: false)
            
            gameboard.sprite.addChild(fireball)
            
            fireball.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: gameboard.getLocation(at: randomPosition), duration: moveDuration),
                    SKAction.scale(to: (isLarge ? 1.5 : 0.75) / UIDevice.spriteScale, duration: moveDuration),
                    SKAction.rotate(byAngle: (isLarge ? 2 : 4) * .pi * villainDirection, duration: moveDuration)
                ]),
                SKAction.repeat(pulseTimedBomb(speed: 1, canPlaySound: i == 0), count: isLarge ? 4 : 3),
                SKAction.repeat(pulseTimedBomb(speed: 0.75, canPlaySound: i == 0), count: isLarge ? 4 : 3),
                SKAction.repeat(pulseTimedBomb(speed: 0.5, canPlaySound: i == 0), count: isLarge ? 4 : 3),
                SKAction.repeat(pulseTimedBomb(speed: 0.35, canPlaySound: i == 0), count: isLarge ? 1 : 0),
                SKAction.run {
                    if i == 0 {
                        AudioManager.shared.playSound(for: "villainattackspecialbomb")
                    }
                },
                SKAction.repeat(pulseTimedBomb(speed: 0.35, canPlaySound: i == 0), count: 3),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    delegate?.didVillainAttack(pattern: isLarge ? .timedLarge : .timed, position: randomPosition)
                },
                SKAction.group([
                    SKAction.colorize(withColorBlendFactor: 1, duration: fadeOutDuration),
                    SKAction.scale(to: isLarge ? 4 : 3, duration: fadeOutDuration),
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
        } //end for
    }
    
    
}
