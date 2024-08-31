//
//  PlayerTextures.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/3/23.
//

import SpriteKit

struct Player {
    
    // MARK: - Properties
    
    static let size = CGSize(width: 946, height: 564)
    static let cutsceneScale: CGFloat = 0.75 //to be used in cutscenes
    private(set) var scale = 0.5
    private(set) var scaleMultiplier: CGFloat = 1
    private(set) var type: PlayerType

    private(set) var sprite: SKSpriteNode!
    private(set) var textures: [[SKTexture]]
    private var atlas: SKTextureAtlas
    
    enum PlayerType: String, CaseIterable {
        case hero = "hero", trainer, princess, princess2, villain, youngTrainer, youngVillain, elder0, elder1, elder2
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
            setupPlayer(framesRange: [1...6, 1...6, nil, nil, nil, nil, 1...6])
        case .princess:
            setupPlayer(framesRange: [1...16, nil, 1...20, nil, nil, 26...33, nil])
        case .princess2:
            setupPlayer(framesRange: [1...12, 1...8, 1...8, nil, nil, 1...4, 1...8],
                        framesCommand: [nil, nil, "Run", nil, nil, nil, nil])
        case .villain:
            setupPlayer(framesRange: [1...12, 1...12, 1...12, 1...12, nil, 1...4, 1...7],
                        framesCommand: [nil, "Idle", "Idle", nil, nil, nil, nil])
        case .youngTrainer:
            setupPlayer(framesRange: [1...15, 1...15, 1...15, 1...15, 5...5, nil, nil])
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
    
    private mutating func setupPlayer(framesRange: [ClosedRange<Int>?], framesCommand: [String?]? = nil) {
        guard framesRange.count == Texture.allCases.count - 3 else { return print("Player.setupPlayer() out of range for: \(self.type)") }
        
        let prefix: String
        let multiplier: CGFloat
        
        switch self.type {
        case .hero:
            prefix = ""
            multiplier = 1
        case .trainer:
            prefix = "Trainer"
            multiplier = 1.5
        case .princess:
            prefix = "Princess"
            multiplier = 0.75
        case .princess2:
            prefix = "Princess2"
            multiplier = 0.75
        case .villain:
            prefix = "Villain"
            multiplier = 1.5
        case .youngTrainer:
            prefix = "YoungMarlin"
            multiplier = 1
        case .youngVillain:
            prefix = "YoungMagmoor"
            multiplier = 1
        case .elder0:
            prefix = "Elder0"
            multiplier = 1.5 * 0.9
        case .elder1:
            prefix = "Elder1"
            multiplier = 1.5 * 0.9
        case .elder2:
            prefix = "Elder2"
            multiplier = 1.5 * 0.9
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
    
    mutating func setPlayerScale(_ scale: CGFloat) {
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
     Class function that moves a Player, i.e. Magmoor, from a starting point to an ending point and animating "illusions" along the way.
     - parameters:
        - magmoorNode: the parent Player node, i.e. Magmoor
        - backgroundNode: the node to add the child illusions to
        - startPoint: the Player's starting point
        - endPoint: the Player's ending point
        - startScale: the Player's starting scale
        - endScale: the Player's ending scale
     - returns: an SKAction of the illusions animation
     */
    static func moveWithIllusions(magmoorNode: SKSpriteNode, backgroundNode: SKNode,
                                  startPoint: CGPoint, endPoint: CGPoint,
                                  startScale: CGFloat, endScale: CGFloat? = nil) -> SKAction {

        let blinkDivision: Int = 20
        var illusionStep: Int = 1
        
        return SKAction.repeat(SKAction.sequence([
            SKAction.run {
                let scaleDiff: CGFloat = (endScale ?? startScale) - startScale
                let incrementScale: CGFloat = scaleDiff * CGFloat(illusionStep) / CGFloat(blinkDivision)

                let illusionSprite = SKSpriteNode(imageNamed: magmoorNode.texture?.getFilename() ?? "VillainIdle (1)")
                illusionSprite.size = Player.size
                illusionSprite.xScale = magmoorNode.xScale + incrementScale * (magmoorNode.xScale < 0 ? -1 : 1)
                illusionSprite.yScale = magmoorNode.yScale + incrementScale
                illusionSprite.position = SpriteMath.Trigonometry.getMidpoint(startPoint: startPoint,
                                                                              endPoint: endPoint,
                                                                              step: illusionStep,
                                                                              totalSteps: blinkDivision)
                illusionSprite.color = .black
                illusionSprite.colorBlendFactor = 1
                illusionSprite.zPosition = magmoorNode.zPosition + CGFloat(illusionStep)
                illusionSprite.name = "escapeVillain\(illusionStep)"
                
                backgroundNode.addChild(illusionSprite)
                
                if illusionStep == 1 {
                    AudioManager.shared.playSound(for: "magicteleport")
                    AudioManager.shared.playSound(for: "magicteleport2")
                }
            },
            SKAction.wait(forDuration: 1 / TimeInterval(blinkDivision)),
            SKAction.run {
                if let illusionSprite = backgroundNode.childNode(withName: "escapeVillain\(illusionStep)") {
                    illusionSprite.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                }
                
                illusionStep += 1
            }
        ]), count: blinkDivision)
    }
    
    
}
