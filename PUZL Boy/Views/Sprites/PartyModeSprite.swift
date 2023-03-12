//
//  PartyModeSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/7/23.
//

import SpriteKit

class PartyModeSprite: SKNode {

    // MARK: - Properties
    
    static var shared: PartyModeSprite = {
        let party = PartyModeSprite()

        //Add'l setup

        return party
    }()
    
    let quarterNote: TimeInterval = 0.48 //DON'T CHANGE THIS!!! 0.48 works perfectly with party music
    let backgroundKey: String = "BackgroundKey"
    let foregroundKey: String = "ForegroundKey"

    var isPartying: Bool = false {
        didSet {
            if isPartying {
                AudioManager.shared.changeTheme(newTheme: AudioManager.shared.overworldPartyTheme)
            }
            else {
                AudioManager.shared.changeTheme(newTheme: AudioManager.shared.overworldTheme)
            }
        }
    }
    
    private(set) var speedMultiplier: TimeInterval = 1
    
    private let speedMultipliers: [TimeInterval] = [0.5, 0.75, 1.5, 2.0]
    private let baseColor: UIColor = .clear
    private var backgroundSprite: SKSpriteNode
    private var foregroundSprite: SKSpriteNode

    
    // MARK: - Initialization
    
    private override init() {
        let gameboardSize = K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale
        
        backgroundSprite = SKSpriteNode(color: baseColor, size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        backgroundSprite.alpha = 0.5
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.position = .zero
        backgroundSprite.zPosition = K.ZPosition.partyBackgroundOverlay
        
        foregroundSprite = SKSpriteNode(color: baseColor, size: CGSize(width: gameboardSize, height: gameboardSize))
        foregroundSprite.alpha = 0.75
        foregroundSprite.anchorPoint = .zero
        foregroundSprite.position = CGPoint(x: GameboardSprite.xPosition, y: GameboardSprite.yPosition)
        foregroundSprite.zPosition = K.ZPosition.partyForegroundOverlay
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func stopParty(partyBoy: PlayerSprite) {
        speedMultiplier = 1

        backgroundSprite.removeFromParent()
        backgroundSprite.removeAllActions()
        
        foregroundSprite.removeFromParent()
        foregroundSprite.removeAllActions()
        
        removeFromParent()

        partyBoy.stopPartyAnimation()
    }
    
    func startParty(to superScene: SKScene, partyBoy: PlayerSprite) {
        //Stop the party, first...
        stopParty(partyBoy: partyBoy)
        
        
        //...then you can start the party!
        speedMultiplier = speedMultipliers.randomElement() ?? 1.0
        
        var foregroundSequence: [SKAction] = []
        
        foregroundSequence += verseSection()
        foregroundSequence += chorusSection()
        foregroundSequence += breakSection()
        foregroundSequence += chorusSection()

        backgroundSprite.run(SKAction.repeatForever(SKAction.sequence(mainBeatSection())), withKey: backgroundKey)
        foregroundSprite.run(SKAction.repeatForever(SKAction.sequence(foregroundSequence)), withKey: foregroundKey)
        
        addChild(backgroundSprite)
        addChild(foregroundSprite)

        superScene.addChild(self)
        partyBoy.startPartyAnimation()
        
        print("Startying the party... partySpeedMultiplier: \(speedMultiplier)")
    }
    
    
    // MARK: - Helper Functions
    
    private func offBeat(noteLength: TimeInterval) -> SKAction {
        return SKAction.colorize(with: baseColor, colorBlendFactor: 1.0, duration: noteLength * quarterNote)
    }
    
    private func onBeat(color: UIColor) -> SKAction {
        return SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.0)
    }
    
    private func fullBeat(color: UIColor, noteLength: TimeInterval) -> [SKAction] {
        return [onBeat(color: color), offBeat(noteLength: noteLength)]
    }
    
    private func mainBeatSection() -> [SKAction] {
        var sequence: [SKAction] = []
        
        for i in 0..<4 {
            for _ in 0..<8 {
                if i != 2 {
                    sequence += fullBeat(color: .yellow, noteLength: 1)
                    sequence += fullBeat(color: .green, noteLength: 1)
                    sequence += fullBeat(color: .cyan, noteLength: 1)
                    sequence += fullBeat(color: .systemPink, noteLength: 1)
                }
                else {
                    sequence.append(onBeat(color: .yellow))
                    sequence.append(SKAction.wait(forDuration: quarterNote))
                    sequence.append(onBeat(color: .systemGreen))
                    sequence.append(SKAction.wait(forDuration: quarterNote))
                    sequence.append(onBeat(color: .cyan))
                    sequence.append(SKAction.wait(forDuration: quarterNote))
                    sequence.append(onBeat(color: .systemPink))
                    sequence.append(SKAction.wait(forDuration: quarterNote))
                }
            }
        }
        
        return sequence
    }
    
    private func verseSection() -> [SKAction] {
        var sequence: [SKAction] = []
        
        for i in 0..<2 {
            //1st measure
            if i % 2 == 0 {
                sequence += fullBeat(color: .systemPink, noteLength: 4)
            }
            else {
                sequence += fullBeat(color: .systemPink, noteLength: 1)
                sequence.append(offBeat(noteLength: 3))
            }
            
            //2nd measure
            if i % 2 == 0 {
                sequence.append(offBeat(noteLength: 2))
                sequence.append(offBeat(noteLength: 1))
                sequence += fullBeat(color: .yellow, noteLength: 1)
            }
            else {
                sequence.append(offBeat(noteLength: 2))
                sequence += fullBeat(color: .purple, noteLength: 1)
                sequence += fullBeat(color: .orange, noteLength: 1)
            }
            
            //3rd measure
            if i % 2 == 0 {
                sequence += fullBeat(color: .green, noteLength: 3/2)
                sequence += fullBeat(color: .orange, noteLength: 3/2)
                sequence += fullBeat(color: .purple, noteLength: 1)
            }
            else {
                sequence += fullBeat(color: .yellow, noteLength: 3/2)
                sequence += fullBeat(color: .green, noteLength: 3/2)
                sequence += fullBeat(color: .systemPink, noteLength: 1)
            }
            
            //4th measure
            if i % 2 == 0 {
                sequence += fullBeat(color: .cyan, noteLength: 3/2)
                sequence += fullBeat(color: .blue, noteLength: 1)
                sequence.append(offBeat(noteLength: 1/2))
                sequence.append(offBeat(noteLength: 1))
            }
            else {
                sequence += fullBeat(color: .cyan, noteLength: 3/2)
                sequence += fullBeat(color: .blue, noteLength: 1)
                sequence.append(offBeat(noteLength: 1/2))
                sequence += fullBeat(color: .cyan, noteLength: 1)
            }
        }

        return sequence
    }
    
    private func breakSection() -> [SKAction] {
        var sequence: [SKAction] = []
        
        for _ in 0..<16 {
            sequence += fullBeat(color: .systemPink, noteLength: 1)
            sequence += fullBeat(color: .blue, noteLength: 1)
        }
        
        return sequence
    }
    
    private func chorusSection() -> [SKAction] {
        var sequence: [SKAction] = []
        
        for i in 0..<4 {
            //1st measure
            sequence.append(offBeat(noteLength: 1/4))
            sequence += fullBeat(color: .systemPink, noteLength: 3/4)
            sequence.append(offBeat(noteLength: 1/2))
            sequence += fullBeat(color: .systemPink, noteLength: 1)
            sequence += fullBeat(color: .purple, noteLength: 1/2)
            sequence += fullBeat(color: .purple, noteLength: 1/4)
            sequence += fullBeat(color: .blue, noteLength: 1/4)
            sequence += fullBeat(color: .orange, noteLength: 1/4)
            sequence += fullBeat(color: .blue, noteLength: 1/4)
            
            //2nd measure
            if i < 3 {
                sequence.append(offBeat(noteLength: 1/4))
                sequence += fullBeat(color: .green, noteLength:  3/4)
                sequence.append(offBeat(noteLength: 1/2))
                sequence += fullBeat(color: .green, noteLength: 1)
                sequence += fullBeat(color: .purple, noteLength: 1/2)
                sequence += fullBeat(color: .blue, noteLength: 1)
            }
            else {
                sequence.append(offBeat(noteLength: 1/4))
                sequence += fullBeat(color: .orange, noteLength:  3/4)
                sequence.append(offBeat(noteLength: 1/4))
                sequence += fullBeat(color: .orange, noteLength: 3/4)
                sequence += fullBeat(color: .blue, noteLength: 3/4)
                sequence += fullBeat(color: .green, noteLength: 3/4)
                sequence += fullBeat(color: .blue, noteLength: 1/2)
            }
        }

        return sequence
    }
}
