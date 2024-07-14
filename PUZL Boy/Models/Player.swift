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
        case hero = "hero", princess, princess2, villain, youngTrainer, youngVillain, elder0, elder1, elder2
    }

    enum Texture: Int {
        case idle = 0, run, walk, dead, glide, jump, idleHammer, idleSword, idleHammerSword, runHammer, runSword, runHammerSword, glideHammer, glideSword, glideHammerSword,

             //Elders only (for now 7/9/24)
             elderAttack,
             
             //IMPORTANT: marsh, sand, party MUST come last! They're not part of textures[[]] so their Int.rawValue will throw off the indexing
             marsh, sand, party
        
        var movementSpeed: TimeInterval {
            var speed: TimeInterval
            
            switch self {
            case .run:              speed = 0.5
            case .runHammer:        speed = 0.5
            case .runSword:         speed = 0.5
            case .runHammerSword:   speed = 0.5
            case .walk:             speed = 0.75
            case .glide:            speed = 0.5
            case .glideHammer:      speed = 0.5
            case .glideSword:       speed = 0.5
            case .glideHammerSword: speed = 0.5
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
        textures.append([]) //idleHammer
        textures.append([]) //idleSword
        textures.append([]) //idleHammerSword
        textures.append([]) //runHammer
        textures.append([]) //runSword
        textures.append([]) //runHammerSword
        textures.append([]) //glideHammer
        textures.append([]) //glideSword
        textures.append([]) //glideHammerSword
        textures.append([]) //elderAttack

        //This must come BEFORE setting up the sprite below!!
        switch type {
        case .hero:
            setupHero()
        case .princess:
            setupPrincess()
        case .princess2:
            setupPrincess2()
        case .villain:
            setupVillain()
        case .youngTrainer:
            setupYoungTrainer()
        case .youngVillain:
            setupYoungVillain()
        case .elder0:
            setupElder(rank: 0)
        case .elder1:
            setupElder(rank: 1)
        case .elder2:
            setupElder(rank: 2)
        }
        
        sprite = SKSpriteNode(texture: textures[Texture.idle.rawValue][0])
        sprite.size = Player.size
        sprite.setScale(scale * scaleMultiplier)
        sprite.zPosition = K.ZPosition.player
    }
    
    private mutating func setupHero() {
        scaleMultiplier = 1
        
        for i in 1...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("Idle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("Run (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("Walk (\(i))"))
            textures[Texture.dead.rawValue].append(atlas.textureNamed("Dead (\(i))"))
            textures[Texture.idleHammer.rawValue].append(atlas.textureNamed("IdleHammer (\(i))"))
            textures[Texture.idleSword.rawValue].append(atlas.textureNamed("IdleSword (\(i))"))
            textures[Texture.idleHammerSword.rawValue].append(atlas.textureNamed("IdleHammerSword (\(i))"))
            textures[Texture.runHammer.rawValue].append(atlas.textureNamed("RunHammer (\(i))"))
            textures[Texture.runSword.rawValue].append(atlas.textureNamed("RunSword (\(i))"))
            textures[Texture.runHammerSword.rawValue].append(atlas.textureNamed("RunHammerSword (\(i))"))

            if i <= 12 {
                textures[Texture.jump.rawValue].append(atlas.textureNamed("Jump (\(i))"))
            }

            if i == 5 {
                textures[Texture.glide.rawValue].append(atlas.textureNamed("Run (\(i))"))
                textures[Texture.glideHammer.rawValue].append(atlas.textureNamed("RunHammer (\(i))"))
                textures[Texture.glideSword.rawValue].append(atlas.textureNamed("RunSword (\(i))"))
                textures[Texture.glideHammerSword.rawValue].append(atlas.textureNamed("RunHammerSword (\(i))"))
            }
        }
    }
    
    private mutating func setupPrincess() {
        scaleMultiplier = 0.75
        
        for i in 1...16 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("PrincessIdle (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("PrincessWalk (\(i))"))
        }
        
        for i in 17...20 {
            textures[Texture.walk.rawValue].append(atlas.textureNamed("PrincessWalk (\(i))"))
        }
        
        for i in 26...33 {
            textures[Texture.jump.rawValue].append(atlas.textureNamed("PrincessJump (\(i))"))
        }
    }
    
    private mutating func setupPrincess2() {
        scaleMultiplier = 0.75
        
        for i in 1...16 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("Princess2Idle (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("Princess2Idle (\(i))")) // FIXME: - temporary
        }
    }
    
    private mutating func setupVillain() {
        scaleMultiplier = 1.5
        
        for i in 1...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("VillainIdle (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("VillainIdle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("VillainIdle (\(i))"))
        }
    }
    
    // TODO: - young trainer setup
    private mutating func setupYoungTrainer() {
        scaleMultiplier = 1.5 * 0.95
        
        //Stagger the starting animation frame
        for i in 3...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("YoungMarlinIdle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("YoungMarlinRun (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("YoungMarlinWalk (\(i))"))
        }
        
        for i in 1...2 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("YoungMarlinIdle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("YoungMarlinRun (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("YoungMarlinWalk (\(i))"))
        }
    }
    
    // TODO: - young villain setup
    private mutating func setupYoungVillain() {
        scaleMultiplier = 1.5
        
        //Stagger the starting animation frame
        for i in 8...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("YoungMagmoorIdle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("YoungMagmoorRun (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("YoungMagmoorWalk (\(i))"))
        }
        
        for i in 1...7 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("YoungMagmoorIdle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("YoungMagmoorRun (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("YoungMagmoorWalk (\(i))"))
        }
    }
    
    private mutating func setupElder(rank: Int) {
        func setupElderTextures(indexLast: Int, textureType: Texture.RawValue, elderRank: Int, filenameTextureType: String) {
            for i in 0...indexLast {
                let indexLeadingZeroes = String(format: "%03d", i)
                
                textures[textureType].append(atlas.textureNamed("Elder\(elderRank)\(filenameTextureType)_\(indexLeadingZeroes)"))
            }
        }

        scaleMultiplier = 1.5 * 0.9
        
        //Idle frames
        setupElderTextures(indexLast: 11, textureType: Texture.idle.rawValue, elderRank: rank, filenameTextureType: "Idle")
        
        //Attack frames
        setupElderTextures(indexLast: 7, textureType: Texture.elderAttack.rawValue, elderRank: rank, filenameTextureType: "Attack")
        
        //Run frames
        setupElderTextures(indexLast: 7, textureType: Texture.run.rawValue, elderRank: rank, filenameTextureType: "Run")
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
