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
    
    private let baseColor: UIColor = .clear
    private let speedMultipliers: [TimeInterval] = [2.0, 1.5, 1.0, 0.75, 0.5]
    private var currentMultiplier = 2
    private(set) var speedMultiplier: TimeInterval = 1.0
    var multiplierMinReached: Bool { currentMultiplier <= 0 }
    var multiplierMaxReached: Bool { currentMultiplier >= speedMultipliers.count - 1 }

    private var backgroundSprite: SKSpriteNode!
    private var lightsSprite: SKSpriteNode!
    private var backgroundLights: SKSpriteNode!
    private var foregroundLights: SKSpriteNode!

    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        let gameboardSize = K.ScreenDimensions.size.width * UIDevice.spriteScale
        
        backgroundSprite = SKSpriteNode(color: .black, size: K.ScreenDimensions.size)
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.position = .zero
        backgroundSprite.zPosition = K.ZPosition.partyBackgroundOverlay
        
        lightsSprite = SKSpriteNode(color: .clear, size: K.ScreenDimensions.size)
        lightsSprite.anchorPoint = .zero
        lightsSprite.position = .zero
        
        backgroundLights = SKSpriteNode(color: baseColor, size: K.ScreenDimensions.size)
        backgroundLights.alpha = 0.5
        backgroundLights.anchorPoint = .zero
        backgroundLights.position = .zero
        
        foregroundLights = SKSpriteNode(color: baseColor, size: CGSize(width: gameboardSize, height: gameboardSize))
        foregroundLights.alpha = 0.5
        foregroundLights.anchorPoint = .zero
        foregroundLights.position = CGPoint(x: GameboardSprite.offsetPosition.x + GameboardSprite.padding / 2,
                                            y: GameboardSprite.offsetPosition.y + GameboardSprite.padding / 2)
        foregroundLights.zPosition = K.ZPosition.partyForegroundOverlay
    }
    
    
    // MARK: - Functions
    
    func toggleIsPartying() {
        isPartying.toggle()
    }
    
    func setIsPartying(_ isPartying: Bool) {
        self.isPartying = isPartying
    }
    
    func increaseSpeedMultiplier(shouldDecrease: Bool) {
        if shouldDecrease {
            if !multiplierMinReached {
                currentMultiplier = currentMultiplier - 1
                speedMultiplier = speedMultipliers[currentMultiplier]
            }
        }
        else {
            if !multiplierMaxReached {
                currentMultiplier = currentMultiplier + 1
                speedMultiplier = speedMultipliers[currentMultiplier]
            }
        }
    }
    
    func stopParty(partyBoy: PlayerSprite, hasSword: Bool, hasHammer: Bool) {
        currentMultiplier = 2
        speedMultiplier = speedMultipliers[currentMultiplier]
        
        backgroundLights.removeAllChildren()
        backgroundLights.removeAllActions()
        foregroundLights.removeAllActions()
        lightsSprite.removeAllChildren()
        backgroundSprite.removeAllChildren()
        
        backgroundSprite.color = .black
        backgroundSprite.removeFromParent()

        removeFromParent()
        removeAllActions()

        partyBoy.stopPartyAnimation(hasSword: hasSword, hasHammer: hasHammer)
    }
    
    func startParty(to superScene: SKScene, partyBoy: PlayerSprite, hasSword: Bool, hasHammer: Bool) {
        currentMultiplier = 2
        speedMultiplier = speedMultipliers[currentMultiplier]
        
        var foregroundSequence: [SKAction] = []
        
        foregroundSequence += verseSection()
        foregroundSequence += chorusSection()
        foregroundSequence += breakSection()
        foregroundSequence += chorusSection()

        backgroundLights.run(SKAction.repeatForever(SKAction.sequence(mainBeatSection())))
        foregroundLights.run(SKAction.repeatForever(SKAction.sequence(foregroundSequence)))
        
        startLights()
        
        if UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic) {
            removeLights()
        }
        else {
            addLights()
        }

        superScene.addChild(self)
        addChild(backgroundSprite)
        backgroundSprite.addChild(lightsSprite)
        partyBoy.startPartyAnimation(hasSword: hasSword, hasHammer: hasHammer)
        
        print("Starting the party... partySpeedMultiplier: \(speedMultiplier)")
    }
    
    private func startLights() {
        guard backgroundLights.parent == nil && foregroundLights.parent == nil else { return }
        
        lightsSprite.addChild(backgroundLights)
        lightsSprite.addChild(foregroundLights)
        
        startPartyBubbles()
    }
    
    private func startPartyBubbles() {
        let bubbleFun = SKAction.run { [unowned self] in
            let partyBubble = PartyEffectSprite()
            partyBubble.animateEffect(to: backgroundLights) //adds partyBubble child nodes to backgroundLights
        }
        
        backgroundLights.run(SKAction.repeatForever(SKAction.group([
            bubbleFun,
            SKAction.wait(forDuration: 0.25)
        ])))
    }
    
    func addLights(duration: TimeInterval = 0) {
        lightsSprite.run(SKAction.fadeIn(withDuration: duration))
    }
    
    func removeLights(duration: TimeInterval = 0) {
        lightsSprite.run(SKAction.fadeOut(withDuration: duration))
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
