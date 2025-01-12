//
//  MagmoorAttacks.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/11/25.
//

import SpriteKit

protocol MagmoorAttacksDelegate: AnyObject {
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, position: K.GameboardPosition?)
}

class MagmoorAttacks {
    
    // MARK: - Properties
    
    private var gameboard: GameboardSprite
    private var villain: Player
    
    private var normalFireballSpeed: TimeInterval
    private var timedBombCount: Int
    private var timedCanHurtPlayer: Bool
    private var timedCanHurtVillain: Bool
    
    private var villainDirection: CGFloat { villain.sprite.xScale > 0 ? -1 : 1 }
    private var fireballPosition: CGPoint { villain.sprite.position + Player.mysticWandOrigin * villainDirection }
    
    enum AttackPattern {
        case normal, timed
    }
    
    weak var delegate: MagmoorAttacksDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, villain: Player) {
        self.gameboard = gameboard
        self.villain = villain
        
        normalFireballSpeed = 0.5
        timedBombCount = 3
        timedCanHurtPlayer = true
        timedCanHurtVillain = true
    }
    
    
    // MARK: - Functions
    
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
    
    func attack(pattern: AttackPattern, positions: FinalBattle2Controls.PlayerPositions) {
        timedCanHurtPlayer = true
        timedCanHurtVillain = true
        
        villain.sprite.run(SKAction.sequence([
            Player.animate(player: villain, type: .attack, repeatCount: 1)
        ]))
        
        AudioManager.shared.playSound(for: "villainattack\(Int.random(in: 1...2))")
        
        switch pattern {
        case .normal:
            helperNormal(positions: positions)
        case .timed:
            helperTimed(positions: positions)
        case .sticky:
            helperSticky(positions: positions)
        }//end switch
    }//end villainAttack()
    
    
    // MARK: - Setter Functions
    
    func setNormalFireballSpeed(_ newValue: CGFloat) {
        normalFireballSpeed = newValue
    }
    
    func setTimedBombCount(_ newValue: Int) {
        timedBombCount = newValue
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
    
    private func helperTimed(positions: FinalBattle2Controls.PlayerPositions) {
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
        
        for i in 0..<timedBombCount {
            let moveDuration: TimeInterval = 1
            let fadeOutDuration: TimeInterval = 0.25
            let explodeDistance: CGFloat = 20
            var randomPosition: K.GameboardPosition
            
            repeat {
                randomPosition = (Int.random(in: 0..<gameboard.panelCount), Int.random(in: 0..<gameboard.panelCount))
            } while randomPosition == positions.villain
            
            let fireball = createFireball(positions: positions,
                                          imageName: "villainProjectile3",
                                          color: .red,
                                          zPosition: K.ZPosition.player - 2,
                                          shouldRotate: false)
            
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
                    delegate?.didVillainAttack(pattern: .timed, position: randomPosition)
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
        } //end for
    }
    
    
}
