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
    private(set) var scale = 0.5
    private(set) var scaleMultiplier: CGFloat = 1

    private(set) var sprite: SKSpriteNode!
    private(set) var textures: [[SKTexture]]
    private var atlas: SKTextureAtlas
    
    enum PlayerType: String {
        case hero = "hero", princess, villain
    }

    enum Texture: Int {
        case idle = 0, run, walk, marsh, sand, party, dead, glide, jump, idleHammer, idleSword, idleHammerSword, runHammer, runSword, runHammerSword, marshHammer, marshSword, marshHammerSword, sandHammer, sandSword, sandHammerSword, glideHammer, glideSword, glideHammerSword
        
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
            case .marshHammer:      speed = 1.0
            case .marshSword:       speed = 1.0
            case .marshHammerSword: speed = 1.0
            case .sand:             speed = 0.5
            case .sandHammer:       speed = 0.5
            case .sandSword:        speed = 0.5
            case .sandHammerSword:  speed = 0.5
            case .party:            speed = 0.5
            case .jump:             speed = 0.02 //FIXME: - Where is this really used???
            default:                speed = 0.25
            }
            
            return speed * PartyModeSprite.shared.speedMultiplier
        }
    }
    
    
    // MARK: - Initialization
    
    init(type: PlayerType) {
        atlas = SKTextureAtlas(named: type.rawValue)
        
        textures = []
        textures.append([]) //idle
        textures.append([]) //run
        textures.append([]) //walk
        textures.append([]) //marsh
        textures.append([]) //sand
        textures.append([]) //party
        textures.append([]) //dead
        textures.append([]) //glide
        textures.append([]) //jump
        textures.append([]) //idleHammer
        textures.append([]) //idleSword
        textures.append([]) //idleHammerSword
        textures.append([]) //runHammer
        textures.append([]) //runSword
        textures.append([]) //runHammerSword
        textures.append([]) //marshHammer
        textures.append([]) //marshSword
        textures.append([]) //marshHammerSword
        textures.append([]) //sandHammer
        textures.append([]) //sandSword
        textures.append([]) //sandHammerSword
        textures.append([]) //glideHammer
        textures.append([]) //glideSword
        textures.append([]) //glideHammerSword

        //This must come BEFORE setting up the sprite below!!
        switch type {
        case .hero:
            setupHero()
        case .princess:
            setupPrincess()
        case .villain:
            setupVillain()
        }
        
        sprite = SKSpriteNode(texture: textures[Texture.idle.rawValue][0])
        sprite.size = Player.size
        sprite.setScale(scale * scaleMultiplier)
        sprite.position = .zero
        sprite.zPosition = K.ZPosition.player
    }
    
    private mutating func setupHero() {
        scaleMultiplier = 1
        
        for i in 1...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("Idle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("Run (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("Walk (\(i))"))
            textures[Texture.marsh.rawValue].append(atlas.textureNamed("Run (\(i))"))
            textures[Texture.sand.rawValue].append(atlas.textureNamed("Run (\(i))"))
            textures[Texture.party.rawValue].append(atlas.textureNamed("Run (\(i))"))
            textures[Texture.dead.rawValue].append(atlas.textureNamed("Dead (\(i))"))
            textures[Texture.idleHammer.rawValue].append(atlas.textureNamed("IdleHammer (\(i))"))
            textures[Texture.idleSword.rawValue].append(atlas.textureNamed("IdleSword (\(i))"))
            textures[Texture.idleHammerSword.rawValue].append(atlas.textureNamed("IdleHammerSword (\(i))"))
            textures[Texture.runHammer.rawValue].append(atlas.textureNamed("RunHammer (\(i))"))
            textures[Texture.runSword.rawValue].append(atlas.textureNamed("RunSword (\(i))"))
            textures[Texture.runHammerSword.rawValue].append(atlas.textureNamed("RunHammerSword (\(i))"))
            textures[Texture.marshHammer.rawValue].append(atlas.textureNamed("RunHammer (\(i))"))
            textures[Texture.marshSword.rawValue].append(atlas.textureNamed("RunSword (\(i))"))
            textures[Texture.marshHammerSword.rawValue].append(atlas.textureNamed("RunHammerSword (\(i))"))
            textures[Texture.sandHammer.rawValue].append(atlas.textureNamed("RunHammer (\(i))"))
            textures[Texture.sandSword.rawValue].append(atlas.textureNamed("RunSword (\(i))"))
            textures[Texture.sandHammerSword.rawValue].append(atlas.textureNamed("RunHammerSword (\(i))"))

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
        scaleMultiplier = 0.8
        
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
    
    private mutating func setupVillain() {
        scaleMultiplier = 1.5
        
        for i in 1...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("VillainIdle (\(i))"))
        }
    }
    
    
    // MARK: - Functions
    
    mutating func setScale(_ scale: CGFloat) {
        self.scale = scale * scaleMultiplier
    }
    
    static func getStandardScale(panelSize: CGFloat) -> CGFloat {
        //Changed scale from 0.5 to 1 to 1.5 due to new hero width size from 313 to original 614 to new 946
        let scale: CGFloat = 1.5

        return scale * panelSize / Player.size.width
    }
}
