//
//  Fireball.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/30/25.
//

import SpriteKit

class Fireball: SKNode {
    
    // MARK: - Properties
    
    private var type: MagmoorAttacks.AttackPattern
    private var positions: FinalBattle2Controls.PlayerPositions
    private var gameboard: GameboardSprite
    
    private var imageName: String
    private var color: UIColor
    private var shouldSetZRotation: Bool
    private var particleMovement: ParticleEngine.ParticleType?
    private var particleExplosion: ParticleEngine.ParticleType?
    private var sfx: [AudioItem?]
    
    private var fireballSpeed: TimeInterval
    private var fireballNode: SKSpriteNode
    
    
    // MARK: - Initialization
    
    /**
     Initialization.
     - parameters:
        - type: Attack Pattern type
        - rotationOrigin: source of the fireball. Should be villain's sprite position for zRotational accuracy
        - positions: begin (villain) and end (player) positions on the gameboard
        - gameboard: the GameboardSprite
     */
    init(type: MagmoorAttacks.AttackPattern, rotationOrigin: CGPoint, positions: FinalBattle2Controls.PlayerPositions, gameboard: GameboardSprite) {
        self.type = type
        self.positions = positions
        self.gameboard = gameboard
        
        fireballSpeed = 0.5
        
        switch type {
        case .freeze:
            imageName = "villainProjectile2"
            color = .blue
            shouldSetZRotation = false
            particleMovement = .magicElderIce2
            particleExplosion = .magicElderIce
            sfx = [AudioManager.shared.getAudioItem(filename: "enemyice")]
        case .poison:
            imageName = "villainProjectile4"
            color = .green
            shouldSetZRotation = false
            particleMovement = .magicElderEarth3
            particleExplosion = .magicElderEarth2
            sfx = [AudioManager.shared.getAudioItem(filename: "movepoisoned1"), AudioManager.shared.getAudioItem(filename: "movepoisoned2")]
        case .timed:
            imageName = "villainProjectile3"
            color = .red
            shouldSetZRotation = false
            particleMovement = nil
            particleExplosion = nil
            sfx = []
        case .timedLarge:
            imageName = "villainProjectile3L"
            color = .red
            shouldSetZRotation = false
            particleMovement = nil
            particleExplosion = nil
            sfx = []
        default: //normal, spread
            imageName = "villainProjectile1"
            color = .red
            shouldSetZRotation = true
            particleMovement = .magicElderFire4
            particleExplosion = .magicElderFire3
            sfx = [AudioManager.shared.getAudioItem(filename: "enemyflame")]
        }
        
        fireballNode = SKSpriteNode(imageNamed: imageName)
        fireballNode.color = color
        fireballNode.colorBlendFactor = 0
        fireballNode.zPosition = 5
        
        super.init()
        
        self.setScale(0.25 / UIDevice.spriteScale)
        
        addChild(fireballNode)
        
        //Calculate angle of fireball, assuming original image is pointing downwards, if rotation is requested.
        let fireballAngleOffset: CGFloat
        let fireballAngle = SpriteMath.Trigonometry.getAngles(startPoint: rotationOrigin, endPoint: gameboard.getLocation(at: positions.player))
        
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
            
        if shouldSetZRotation {
            fireballNode.zRotation = fireballAngleOffset
        }
        
        if let particleMovement = particleMovement {
            ParticleEngine.shared.animateParticles(type: particleMovement,
                                                   toNode: self,
                                                   position: .zero,
                                                   scale: 1,
                                                   angle: fireballAngleOffset,
                                                   zPosition: 2,
                                                   duration: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    /**
     Launches a fireball (non-timed bomb) of either normal, freeze, or poison.
     - parameters:
        - facingDirection: the direction (the villain is facing)
        - completion: completion handler to deal with delegate calls, for example.
     */
    func launchFireball(facingDirection: CGFloat, completion: @escaping () -> Void) {
        self.removeFromParent()
        gameboard.sprite.addChild(self)
        
        switch type {
        case .normal, .freeze, .poison, .spread:
            launchHelperFireball(facingDirection: facingDirection, completion: completion)
        default:
            break
        }
    }
    
    /**
     Launches a timed bomb.
     - parameters:
        - facingDirection: the direction (the villain is facing)
        - canPlaySound: since you can have multiple simultaneouslyk you'll want to play only the first one's sound.
        - completion: completion handler to deal with delegate calls, for example.
     */
    func launchTimed(facingDirection: CGFloat, canPlaySound: Bool, completion: @escaping (K.GameboardPosition) -> Void) {
        self.removeFromParent()
        gameboard.sprite.addChild(self)
        
        switch type {
        case .timed:
            launchHelperTimed(facingDirection: facingDirection, isLarge: false, canPlaySound: canPlaySound, completion: completion)
        case .timedLarge:
            launchHelperTimed(facingDirection: facingDirection, isLarge: true, canPlaySound: canPlaySound, completion: completion)
        default:
            break
        }
    }
    
    /**
     For use with Fireball.
     */
    func playFireballAudio() {
        for audioItem in sfx {
            guard let audioItem = audioItem else { continue }
            
            let stats = getFireballStats()
            let delayDuration: TimeInterval
            
            switch type {
            case .freeze:       delayDuration = max(0, stats.fireballMovementDuration - 0.25)
            default:            delayDuration = stats.fireballMovementDuration
            }
            
            AudioManager.shared.playSound(for: audioItem.fileName, delay: delayDuration, interruptPlayback: false)
        }
    }
    
    /**
     Sets the new fireball speed.
     */
    func setFireballSpeed(_ newValue: TimeInterval) {
        self.fireballSpeed = newValue
    }
    
    
    // MARK: - Helper Functions
    
    private func getFireballStats() -> (distanceVillainToPlayer: TimeInterval, fireballMovementDuration: TimeInterval) {
        let rowSquared = pow(TimeInterval(positions.villain.row) - TimeInterval(positions.player.row), 2)
        let colSquared = pow(TimeInterval(positions.villain.col) - TimeInterval(positions.player.col), 2)
        let distanceVillainToPlayer = sqrt(rowSquared + colSquared)
        let fireballMovementDuration = max(distanceVillainToPlayer * fireballSpeed, 0.25)
        
        return (distanceVillainToPlayer, fireballMovementDuration)
    }
    
    private func launchHelperFireball(facingDirection: CGFloat, completion: @escaping () -> Void) {
        let stats = getFireballStats()
        
        let rotationAngle: CGFloat
        let scaleAction: SKAction
        let particleExplosionDuration: TimeInterval
        
        switch type {
        case .freeze:
            rotationAngle = .pi
            scaleAction = SKAction.scale(to: 0.5 / UIDevice.spriteScale, duration: stats.fireballMovementDuration)
            particleExplosionDuration = 2
        case .poison:
            rotationAngle = .pi / 4
            scaleAction = SKAction.repeat(SKAction.sequence([
                SKAction.scale(to: 0.5 / UIDevice.spriteScale, duration: 0.2),
                SKAction.scale(to: 0.25 / UIDevice.spriteScale, duration: 0.2)
            ]), count: Int(ceil(stats.fireballMovementDuration / 0.4)))
            particleExplosionDuration = 4
        default: //normal, spread
            rotationAngle = 0
            scaleAction = SKAction.scale(to: 0.5 / UIDevice.spriteScale, duration: stats.fireballMovementDuration)
            particleExplosionDuration = 2
        }
        
        //Rotation Action
        fireballNode.run(SKAction.rotate(byAngle: stats.distanceVillainToPlayer * rotationAngle * facingDirection,
                                         duration: stats.fireballMovementDuration))
        
        //Colorblend Action
        fireballNode.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.colorize(withColorBlendFactor: 1, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
        ])))
        
        //Fireball Movement and Effects
        run(SKAction.sequence([
            SKAction.group([
                SKAction.move(to: gameboard.getLocation(at: positions.player), duration: stats.fireballMovementDuration),
                scaleAction
            ]),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                completion()
                
                if let particleExplosion = particleExplosion {
                    ParticleEngine.shared.animateParticles(type: particleExplosion,
                                                           toNode: gameboard.sprite,
                                                           position: gameboard.getLocation(at: positions.player),
                                                           scale: 2 * UIDevice.spriteScale / CGFloat(gameboard.panelCount),
                                                           duration: particleExplosionDuration)
                }
            },
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.scale(to: 1 / UIDevice.spriteScale, duration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func launchHelperTimed(facingDirection: CGFloat, isLarge: Bool, canPlaySound: Bool, completion: @escaping (K.GameboardPosition) -> Void) {
        func pulseTimedBomb(speed: TimeInterval, canPlaySound: Bool) -> SKAction {
            return SKAction.sequence([
                SKAction.group([
                    SKAction.colorize(withColorBlendFactor: 1, duration: speed / 2),
                    SKAction.scale(to: (isLarge ? 2 : 1) / UIDevice.spriteScale, duration: speed / 2)
                ]),
                SKAction.run {
                    if canPlaySound {
                        AudioManager.shared.playSound(for: isLarge ? "villainattackbombticklarge" : "villainattackbombtick", interruptPlayback: false)
                    }
                },
                SKAction.group([
                    SKAction.colorize(withColorBlendFactor: 0, duration: speed / 2),
                    SKAction.scale(to: (isLarge ? 1.5 : 0.75) / UIDevice.spriteScale, duration: speed / 2)
                ])
            ])
        }
        
        let moveDuration: TimeInterval = 1
        let fadeOutDuration: TimeInterval = isLarge ? 0.5 : 0.25
        let explodeDistance: CGFloat = isLarge ? 30 : 20
        
        //BUGFIX #20250301E01 - a counter and limit is needed on safePanel check because once safePanel runs out, the repeat-while loop will run indefinitely!
        let safePanelCheckLimit: Int = 100
        var safePanelCheckCounter: Int = 0
        var randomPosition: K.GameboardPosition
        var largeBombRestriction: Bool
        
        repeat {
            randomPosition = (Int.random(in: 0..<gameboard.panelCount), Int.random(in: 0..<gameboard.panelCount))
            largeBombRestriction = isLarge && randomPosition.col * Int(facingDirection) > positions.villain.col * Int(facingDirection)
            safePanelCheckCounter += 1
        }
        while randomPosition == positions.villain
                || largeBombRestriction
                || (safePanelCheckCounter < safePanelCheckLimit
                    && gameboard.getPanelSprite(at: randomPosition).terrain?.childNode(withName: FinalBattle2Spawner.safePanelName) == nil)
        
        run(SKAction.sequence([
            SKAction.group([
                SKAction.move(to: gameboard.getLocation(at: randomPosition), duration: moveDuration),
                SKAction.scale(to: (isLarge ? 1.5 : 0.75) / UIDevice.spriteScale, duration: moveDuration),
                SKAction.rotate(byAngle: (isLarge ? 2 : 4) * .pi * facingDirection, duration: moveDuration)
            ]),
            SKAction.repeat(pulseTimedBomb(speed: 1, canPlaySound: canPlaySound), count: isLarge ? 4 : 3),
            SKAction.repeat(pulseTimedBomb(speed: 0.75, canPlaySound: canPlaySound), count: isLarge ? 4 : 3),
            SKAction.repeat(pulseTimedBomb(speed: 0.5, canPlaySound: canPlaySound), count: isLarge ? 4 : 3),
            SKAction.repeat(pulseTimedBomb(speed: 0.35, canPlaySound: canPlaySound), count: isLarge ? 1 : 0),
            SKAction.run {
                if canPlaySound {
                    AudioManager.shared.playSound(for: "villainattackspecialbomb", interruptPlayback: false)
                }
            },
            SKAction.repeat(pulseTimedBomb(speed: 0.35, canPlaySound: false), count: 3),
            SKAction.run {
                completion(randomPosition)
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
    }
    
    
}
