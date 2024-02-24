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
        case hero = "hero", princess, princess2, villain, youngTrainer, youngVillain
    }

    enum Texture: Int {
        case idle = 0, run, walk, dead, glide, jump, idleHammer, idleSword, idleHammerSword, runHammer, runSword, runHammerSword, glideHammer, glideSword, glideHammerSword,

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
        }        
    }
    
    private mutating func setupVillain() {
        scaleMultiplier = 1.5
        
        for i in 1...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("VillainIdle (\(i))"))
        }
    }
    
    // TODO: - young trainer setup
    private mutating func setupYoungTrainer() {
        scaleMultiplier = 1.5 * 0.8
        
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
    
    
    // MARK: - Functions
    
    mutating func setPlayerScale(_ scale: CGFloat) {
        self.scale = scale * scaleMultiplier
    }
    
    static func getGameboardScale(panelSize: CGFloat) -> CGFloat {
        //Changed scale from 0.5 to 1 to 1.5 due to new hero width size from 313 to original 614 to new 946
        let scale: CGFloat = 1.5

        //GameboardSprite.panelSize = K.ScreenDimensions.size / panelCount. For example, on iPhone 15 Pro, K.ScreenDimensions.size = Player.size.width = 945, therefore function returns 1.5 / panelCount
        return scale * panelSize / Player.size.width
    }
}
