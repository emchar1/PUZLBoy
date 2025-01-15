//
//  PlayerTextures.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/3/23.
//

import SpriteKit

class Player {
    
    // MARK: - Properties: General
    
    ///Dimensions of player, i.e. Hero a.k.a. PUZL Boy
    static let size = CGSize(width: 946, height: 564)
    
    ///To be used in cutscenes
    static let cutsceneScale: CGFloat = 0.75
    
    ///Origin point of wand when a Mystic casts a spell
    static let mysticWandOrigin: CGPoint = CGPoint(x: -60, y: -40) / UIDevice.spriteScale
    
    private(set) var scale = 0.5
    private(set) var scaleMultiplier: CGFloat = 1
    private(set) var type: PlayerType
    
    
    // MARK: - Properties: NEW 9/24/24
    
    private var isAnimatingIllusions2: Bool = false
    
    
    // MARK: - Properties: Sprites
    
    private(set) var sprite: SKSpriteNode!
    private(set) var textures: [[SKTexture]]
    private var atlas: SKTextureAtlas
    
    
    // MARK: - Properties: Enums
    
    enum PlayerType: String, CaseIterable {
        case hero = "hero", trainer, princess, princess2, villain, minion, youngTrainer, youngVillain, elder0, elder1, elder2
    }

    enum Texture: Int, CaseIterable {
        //IMPORTANT: DO NOT CHANGE THIS ORDER!! 8/29/24
        case idle = 0, run, walk, dead, glide, jump, attack,
             
             //IMPORTANT: marsh, sand, party MUST come last! They're not part of textures[[]] so their Int.rawValue will throw off the indexing
             marsh, sand, party
        
        var movementSpeed: TimeInterval {
            var speed: TimeInterval
            
            switch self {
            case .run:              speed = 0.5
            case .walk:             speed = 0.75
            case .glide:            speed = 0.5
            case .marsh:            speed = 1.0
            case .sand:             speed = 0.5
            case .party:            speed = 0.5
            default:                speed = 0.25
            }
            
            return speed * PartyModeSprite.shared.speedMultiplier
        }
    }
    
    
    // MARK: - Initialization
    
    init(type: PlayerType) {
        self.type = type
        
        atlas = SKTextureAtlas(named: type.rawValue)
        
        textures = []
        textures.append([]) //idle
        textures.append([]) //run
        textures.append([]) //walk
        textures.append([]) //dead
        textures.append([]) //glide
        textures.append([]) //jump
        textures.append([]) //attack

        //This must come BEFORE setting up the sprite below!!
        switch type {
            
        // idle = 0, run, walk, dead, glide, jump, attack,
        case .hero:
            setupPlayer(framesRange: [1...15, 1...15, 1...15, 1...15, 5...5, 1...12, nil],
                        framesCommand: [nil, nil, nil, nil, "Run", nil, nil])
        case .trainer:
            setupPlayer(framesRange: [1...6, 1...6, 1...6, 1...7, 2...2, nil, 1...6],
                        framesCommand: [nil, nil, "Run", nil, "RuinDead", nil, nil])
        case .princess:
            setupPlayer(framesRange: [1...16, nil, 1...20, nil, nil, 26...33, nil])
        case .princess2:
            setupPlayer(framesRange: [1...12, 1...8, 1...8, nil, nil, 1...4, 1...8],
                        framesCommand: [nil, nil, "Run", nil, nil, nil, nil])
        case .villain:
            setupPlayer(framesRange: [1...12, 1...12, 1...12, 1...12, 1...4, 1...4, 1...7],
                        framesCommand: [nil, "Idle", "Idle", nil, "Sliding", nil, nil])
        case .minion:
            setupPlayer(framesRange: [1...12, 1...12, 1...12, nil, nil, nil, 1...7],
                        framesCommand: [nil, "Idle", "Idle", nil, nil, nil, nil])
        case .youngTrainer:
            setupPlayer(framesRange: [1...15, 1...15, 1...15, 1...15, 5...5, nil, nil],
                        framesCommand: [nil, nil, nil, nil, "Run", nil, nil])
        case .youngVillain:
            setupPlayer(framesRange: [1...15, nil, 1...15, nil, nil, nil, nil])
        case .elder0, .elder1, .elder2:
            setupPlayer(framesRange: [1...12, 1...8, nil, nil, nil, nil, 1...8])
        }
        
        sprite = SKSpriteNode(texture: textures[Texture.idle.rawValue][0])
        sprite.size = Player.size
        sprite.setScale(scale * scaleMultiplier)
        sprite.zPosition = K.ZPosition.player
    }
    
    /**
     Sets up the player's textures based on the type. When inputting the arguments, make sure it matches the Texture enum cases, minus the last 3 cases (marsh, sand, party).
     - parameters:
        - framesRange: array of closed ranges representing the frames for that texture.
        - framesCommand: array of command Strings, where, if not nil, will use that string, otherwise, use the "default" string, e.g. "Idle"
     > Warning: This is how you use the Warning keyword.
     - note: Initially a mutating function when Player was a struct prior to 9/24/24.
     */
    private func setupPlayer(framesRange: [ClosedRange<Int>?], framesCommand: [String?]? = nil) {
        guard framesRange.count == Texture.allCases.count - 3 else { return print("Player.setupPlayer() out of range for: \(self.type)") }
        
        let prefix: String
        let multiplier: CGFloat
        
        switch self.type {
        case .hero:
            prefix = ""
            multiplier = 1
        case .trainer:
            prefix = "Trainer"
            multiplier = 1.25
        case .princess:
            prefix = "Princess"
            multiplier = 0.75
        case .princess2:
            prefix = "Princess2"
            multiplier = 0.75
        case .villain:
            prefix = "Villain"
            multiplier = 1.5
        case .minion:
            prefix = "Minion"
            multiplier = 1.25
        case .youngTrainer:
            prefix = "YoungMarlin"
            multiplier = 1
        case .youngVillain:
            prefix = "YoungMagmoor"
            multiplier = 1
        case .elder0:
            prefix = "Elder0"
            multiplier = 1.35
        case .elder1:
            prefix = "Elder1"
            multiplier = 1.35
        case .elder2:
            prefix = "Elder2"
            multiplier = 1.35
        }
        
        self.scaleMultiplier = multiplier
        
        func populateTextures(textureIndex: Int, frames: ClosedRange<Int>?, command: String) {
            if let frames = frames {
                for i in frames {
                    textures[textureIndex].append(atlas.textureNamed("\(prefix)\(command) (\(i))"))
                }
            }
        }
        
        populateTextures(textureIndex: 0, frames: framesRange[0], command: framesCommand?[0] ?? "Idle")
        populateTextures(textureIndex: 1, frames: framesRange[1], command: framesCommand?[1] ?? "Run")
        populateTextures(textureIndex: 2, frames: framesRange[2], command: framesCommand?[2] ?? "Walk")
        populateTextures(textureIndex: 3, frames: framesRange[3], command: framesCommand?[3] ?? "Dead")
        populateTextures(textureIndex: 4, frames: framesRange[4], command: framesCommand?[4] ?? "Glide")
        populateTextures(textureIndex: 5, frames: framesRange[5], command: framesCommand?[5] ?? "Jump")
        populateTextures(textureIndex: 6, frames: framesRange[6], command: framesCommand?[6] ?? "Attack")
    }
    
    
    // MARK: - Functions
    
    /**
     Sets the player's scale.
     - note: Initially a mutating function when Player was a struct prior to 9/24/24.
     */
    func setPlayerScale(_ scale: CGFloat) {
        self.scale = scale * scaleMultiplier
    }
    
    /**
     Helper function to ensure two players on the same scene are of the same height, i.e. with player = .hero as the base case.
     - parameter player: the comparing player (to player .hero)
     - returns: the normalized height adjusted to player = .hero
     */
    static func getNormalizedAdjustedHeight(player: Player) -> CGFloat {
        return size.height / 2 * cutsceneScale * (player.scaleMultiplier - 1)
    }
    
    static func getGameboardScale(panelSize: CGFloat) -> CGFloat {
        //Changed scale from 0.5 to 1 to 1.5 due to new hero width size from 313 to original 614 to new 946
        let scale: CGFloat = 1.5

        //GameboardSprite.panelSize = K.ScreenDimensions.size / panelCount. For example, on iPhone 15 Pro, K.ScreenDimensions.size = Player.size.width = 945, therefore function returns 1.5 / panelCount
        return scale * panelSize / Player.size.width
    }
    
    /**
     Provides a simple looped animation of a given texture on a given player.
     - parameters:
        - player: the player in question
        - type: the type of texture in question
        - timePerFrame: the speed of the animation. Optional. If used, it will overwrite the timePerFrameFallback predefined animation speeds.
        - timePerFrameMultiplier: a multiplier that affects the animation speed, defaults to 1
        - repeatCount: number of times to execute the animation
     - returns:the SKAction
     */
    static func animate(player: Player,
                        type: Texture,
                        timePerFrame: TimeInterval? = nil,
                        timePerFrameMultiplier: TimeInterval = 1,
                        repeatCount: Int = -1) -> SKAction {
        
        let defaultTime: TimeInterval = 0.1
        var timePerFrameFallback: TimeInterval
        
        switch type {
        case .idle:
            switch player.type {
            case .hero:             timePerFrameFallback = 0.06
            case .trainer:          timePerFrameFallback = 0.16
            case .villain:          timePerFrameFallback = 0.12
            case .princess:         timePerFrameFallback = 0.09
            case .princess2:        timePerFrameFallback = defaultTime
            case .elder0:           timePerFrameFallback = 0.1
            case .elder1:           timePerFrameFallback = 0.09
            case .elder2:           timePerFrameFallback = 0.05
            case .youngTrainer:     timePerFrameFallback = 0.06
            case .youngVillain:     timePerFrameFallback = 0.06
            case .minion:           timePerFrameFallback = defaultTime
            }
        case .run:
            switch player.type {
            case .hero:             timePerFrameFallback = 0.04
            case .trainer:          timePerFrameFallback = 0.04
            case .villain:          timePerFrameFallback = 0.04
            case .princess:         timePerFrameFallback = 0.04
            case .princess2:        timePerFrameFallback = defaultTime
            case .elder0:           timePerFrameFallback = 0.04
            case .elder1:           timePerFrameFallback = 0.04
            case .elder2:           timePerFrameFallback = 0.04
            case .youngTrainer:     timePerFrameFallback = 0.04
            case .youngVillain:     timePerFrameFallback = defaultTime
            case .minion:           timePerFrameFallback = defaultTime
            }
        case .walk:
            switch player.type {
            case .hero:             timePerFrameFallback = 0.06
            case .trainer:          timePerFrameFallback = 0.12
            case .villain:          timePerFrameFallback = 0.06
            case .princess:         timePerFrameFallback = 0.06
            case .princess2:        timePerFrameFallback = defaultTime
            case .elder0:           timePerFrameFallback = defaultTime
            case .elder1:           timePerFrameFallback = defaultTime
            case .elder2:           timePerFrameFallback = defaultTime
            case .youngTrainer:     timePerFrameFallback = 0.06
            case .youngVillain:     timePerFrameFallback = defaultTime
            case .minion:           timePerFrameFallback = defaultTime
            }
        case .dead:
            switch player.type {
            case .hero:             timePerFrameFallback = 0.02
            case .trainer:          timePerFrameFallback = defaultTime
            case .villain:          timePerFrameFallback = defaultTime
            case .princess:         timePerFrameFallback = defaultTime
            case .princess2:        timePerFrameFallback = defaultTime
            case .elder0:           timePerFrameFallback = defaultTime
            case .elder1:           timePerFrameFallback = defaultTime
            case .elder2:           timePerFrameFallback = defaultTime
            case .youngTrainer:     timePerFrameFallback = 0.02
            case .youngVillain:     timePerFrameFallback = defaultTime
            case .minion:           timePerFrameFallback = defaultTime
            }
        case .glide:
            switch player.type {
            case .hero:             timePerFrameFallback = 0.04
            case .trainer:          timePerFrameFallback = 0.1
            case .villain:          timePerFrameFallback = defaultTime
            case .princess:         timePerFrameFallback = defaultTime
            case .princess2:        timePerFrameFallback = defaultTime
            case .elder0:           timePerFrameFallback = defaultTime
            case .elder1:           timePerFrameFallback = defaultTime
            case .elder2:           timePerFrameFallback = defaultTime
            case .youngTrainer:     timePerFrameFallback = 0.04
            case .youngVillain:     timePerFrameFallback = defaultTime
            case .minion:           timePerFrameFallback = defaultTime
            }
        case .jump:
            switch player.type {
            case .hero:             timePerFrameFallback = defaultTime
            case .trainer:          timePerFrameFallback = defaultTime
            case .villain:          timePerFrameFallback = defaultTime
            case .princess:         timePerFrameFallback = 0.02
            case .princess2:        timePerFrameFallback = defaultTime
            case .elder0:           timePerFrameFallback = defaultTime
            case .elder1:           timePerFrameFallback = defaultTime
            case .elder2:           timePerFrameFallback = defaultTime
            case .youngTrainer:     timePerFrameFallback = defaultTime
            case .youngVillain:     timePerFrameFallback = defaultTime
            case .minion:           timePerFrameFallback = defaultTime
            }
        case .attack:
            switch player.type {
            case .hero:             timePerFrameFallback = defaultTime
            case .trainer:          timePerFrameFallback = defaultTime
            case .villain:          timePerFrameFallback = defaultTime
            case .princess:         timePerFrameFallback = defaultTime
            case .princess2:        timePerFrameFallback = defaultTime
            case .elder0:           timePerFrameFallback = 0.06
            case .elder1:           timePerFrameFallback = 0.06
            case .elder2:           timePerFrameFallback = 0.06
            case .youngTrainer:     timePerFrameFallback = defaultTime
            case .youngVillain:     timePerFrameFallback = defaultTime
            case .minion:           timePerFrameFallback = defaultTime
            }
        case .marsh, .sand, .party: //I don't think I need to build this out since it doesn't have a specific speed for any player 12/11/24.
            timePerFrameFallback = defaultTime
        }
        
        let animateAction = SKAction.animate(with: player.textures[type.rawValue],
                                             timePerFrame: (timePerFrame ?? timePerFrameFallback) * timePerFrameMultiplier)
        return repeatCount == -1 ? SKAction.repeatForever(animateAction) : SKAction.repeat(animateAction, count: repeatCount)
    }
    
    /**
     Class function that moves a Player, e.g. Magmoor, from a starting point to an ending point and animating "illusions" along the way.
     - parameters:
        - playerNode: the parent Player node, i.e. Magmoor
        - backgroundNode: the node to add the child illusions to
        - tag: an optional tag to differentiate the parent node, if there are multiple
        - color: the color of the illusions
        - playSound: if true, plays a snake-like rattling sound (used by Magmoor primarily)
        - startPoint: the Player's starting point
        - endPoint: the Player's ending point
        - startScale: the Player's starting scale
        - endScale: the Player's ending scale
     - returns: an SKAction of the illusions animation
     */
    static func moveWithIllusions(playerNode: SKSpriteNode, backgroundNode: SKNode, tag: String = "",
                                  color: UIColor, playSound: Bool, fierce: Bool = false,
                                  startPoint: CGPoint, endPoint: CGPoint,
                                  startScale: CGFloat, endScale: CGFloat? = nil) -> SKAction {
        
        let blinkDivision: Int = 20
        var illusionStep: Int = 1
        
        return SKAction.repeat(SKAction.sequence([
            SKAction.run {
                let scaleDiff: CGFloat = (endScale ?? startScale) - startScale
                let incrementScale: CGFloat = scaleDiff * CGFloat(illusionStep) / CGFloat(blinkDivision)
                
                let illusionSprite = SKSpriteNode(imageNamed: fierce ? "VillainJump (1)" : (playerNode.texture?.getFilename() ?? "VillainJump (1)"))
                illusionSprite.size = Player.size
                illusionSprite.xScale = playerNode.xScale + incrementScale * (playerNode.xScale < 0 ? -1 : 1)
                illusionSprite.yScale = playerNode.yScale + incrementScale
                illusionSprite.position = SpriteMath.Trigonometry.getMidpoint(startPoint: startPoint,
                                                                              endPoint: endPoint,
                                                                              step: illusionStep,
                                                                              totalSteps: blinkDivision)
                illusionSprite.color = color
                illusionSprite.colorBlendFactor = 1
                illusionSprite.zPosition = playerNode.zPosition + CGFloat(illusionStep)
                illusionSprite.name = "escapePlayer\(tag)\(illusionStep)"
                
                backgroundNode.addChild(illusionSprite)
                
                if illusionStep == 1 && playSound {
                    AudioManager.shared.playSound(for: "magicteleport")
                    AudioManager.shared.playSound(for: "magicteleport2")
                }
            },
            SKAction.wait(forDuration: 1 / TimeInterval(blinkDivision)),
            SKAction.run {
                if let illusionSprite = backgroundNode.childNode(withName: "escapePlayer\(tag)\(illusionStep)") {
                    illusionSprite.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                }
                
                illusionStep += 1
            }
        ]), count: blinkDivision)
    }
    
    /**
     NEW instance function that moves a player with illusions.
     > Warning: This is an object function, not a class function. This is a new type of animation that is not static, so call it from your Player object. Added 9/24/24.
     - parameters:
        - backgroundNode: the gameboard sprite to add the duplicate child to.
        - trailLength: number of repeats of duplicates to create before resetting the isAnimatingIllusions2 guard property.
        - trailTightness: "closeness" of the duplicates.
     */
    func moveWithIllusionsElder(backgroundNode: SKNode, trailColor: UIColor?, trailLength: Int, trailTightness: TimeInterval) {
        guard !isAnimatingIllusions2 else { return }
        
        var zPositionOffset: CGFloat = 1

        isAnimatingIllusions2 = true

        func leaveTrail(fadeDuration: TimeInterval) {
            let duplicate = Player(type: self.type)
            duplicate.sprite.xScale = self.sprite.xScale
            duplicate.sprite.yScale = self.sprite.yScale
            duplicate.sprite.position = self.sprite.position
            duplicate.sprite.zPosition = self.sprite.zPosition - CGFloat(trailLength + 1) + zPositionOffset
             
            if let color = trailColor {
                duplicate.sprite.color = color
                duplicate.sprite.colorBlendFactor = 1
            }
            
            backgroundNode.addChild(duplicate.sprite)
            
            duplicate.sprite.run(Player.animate(player: duplicate, type: .idle))
            duplicate.sprite.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: fadeDuration),
                SKAction.removeFromParent()
            ]))
            
            ParticleEngine.shared.animateParticles(type: .magicLight,
                                                   toNode: duplicate.sprite,
                                                   position: .zero,
                                                   scale: 4,
                                                   zPosition: -1,
                                                   duration: 0)
        }
        
        sprite.run(SKAction.repeat(SKAction.sequence([
            SKAction.run {
                leaveTrail(fadeDuration: 0.5)
                zPositionOffset += 1
            },
            SKAction.wait(forDuration: trailTightness)
        ]), count: trailLength)) { [weak self] in
            self?.isAnimatingIllusions2 = false
        }
    }
    
    /**
     Animates a levitating, idling state.
     - parameters:
        - player: the Player object
        - shouldReverse: determines start direction of levitation movement
        - randomizeDuration: if true, adds a potential 0...1 second delay
     - returns: the idle, levitating action
     */
    static func animateIdleLevitate(player: Player, shouldReverse: Bool = false, randomizeDuration: Bool = true) -> SKAction {
        let moveOffset: CGFloat = shouldReverse ? -20 : 20
        
        return SKAction.group([
            Player.animate(player: player, type: .idle),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: moveOffset, duration: 1 + (randomizeDuration ? TimeInterval.random(in: 0...1) : 0)),
                SKAction.moveBy(x: 0, y: -moveOffset, duration: 1 + (randomizeDuration ? TimeInterval.random(in: 0...1) : 0))
            ]))
        ])
    }
    
    
}
