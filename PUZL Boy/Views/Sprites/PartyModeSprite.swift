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

    private var isPartyStopping: Bool = false
    private(set) var isPartying: Bool = false {
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
    private let speedMultipliers: [TimeInterval] = [0.75]//[0.5, 0.75, 1.5, 2.0]

    private let baseColor: UIColor = .clear
    private var backgroundSprite: SKSpriteNode
    private var backgroundLights: SKSpriteNode
    private var foregroundLights: SKSpriteNode

    
    // MARK: - Initialization
    
    private override init() {
        let gameboardSize = K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale
        
        backgroundSprite = SKSpriteNode(color: .black, size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.position = .zero
        
        backgroundLights = SKSpriteNode(color: baseColor, size: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height))
        backgroundLights.alpha = 0.5
        backgroundLights.anchorPoint = .zero
        backgroundLights.position = .zero
        backgroundLights.zPosition = K.ZPosition.partyBackgroundOverlay
        
        foregroundLights = SKSpriteNode(color: baseColor, size: CGSize(width: gameboardSize, height: gameboardSize))
        foregroundLights.alpha = 0.5
        foregroundLights.anchorPoint = .zero
        foregroundLights.position = CGPoint(x: GameboardSprite.xPosition, y: GameboardSprite.yPosition)
        foregroundLights.zPosition = K.ZPosition.partyForegroundOverlay
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func toggleIsPartying() {
        guard !isPartyStopping else { return }
        
        isPartying.toggle()
    }
    
    func stopParty(partyBoy: PlayerSprite) {
        guard !isPartyStopping else { return }
        
        isPartyStopping = true
        
        speedMultiplier = 1
        
        backgroundLights.removeAllChildren()
        backgroundLights.removeAllActions()
        foregroundLights.removeAllActions()

        partyBoy.stopPartyAnimation()
        
        backgroundLights.run(SKAction.colorize(with: .clear, colorBlendFactor: 1.0, duration: 1.0))
        foregroundLights.run(SKAction.colorize(with: .clear, colorBlendFactor: 1.0, duration: 1.0)) {
            self.backgroundLights.removeFromParent()
            self.foregroundLights.removeFromParent()
        }

        backgroundSprite.run(SKAction.colorize(with: .clear, colorBlendFactor: 1.0, duration: 1.5)) {
            self.backgroundSprite.color = .black
            self.backgroundSprite.removeFromParent()
            self.removeFromParent()
            self.removeAllActions()
            self.isPartyStopping = false
        }
    }
    
    func startParty(to superScene: SKScene, partyBoy: PlayerSprite) {
        guard !isPartyStopping else { return }
        
        speedMultiplier = speedMultipliers.randomElement() ?? 1.0
        
        var foregroundSequence: [SKAction] = []
        
        foregroundSequence += verseSection()
        foregroundSequence += chorusSection()
        foregroundSequence += breakSection()
        foregroundSequence += chorusSection()

        backgroundLights.run(SKAction.repeatForever(SKAction.sequence(mainBeatSection())), withKey: backgroundKey)
        foregroundLights.run(SKAction.repeatForever(SKAction.sequence(foregroundSequence)), withKey: foregroundKey)
        
        addChild(backgroundSprite)
        backgroundSprite.addChild(backgroundLights)
        backgroundSprite.addChild(foregroundLights)

        superScene.addChild(self)
        partyBoy.startPartyAnimation()
        
        print("Startying the party... partySpeedMultiplier: \(speedMultiplier)")
        
        
        // TODO: - Do I want to keep these bubbles???
        let bubbleFun = SKAction.run {
            let partyBubble = PartyEffectSprite()
            partyBubble.animateEffect(to: self.backgroundLights)
        }
        
        backgroundLights.run(SKAction.repeatForever(SKAction.group([
            bubbleFun,
            SKAction.wait(forDuration: 0.25)
        ])))
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
