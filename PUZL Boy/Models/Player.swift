//
//  PlayerTextures.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/3/23.
//

import SpriteKit

struct Player {
    
    // MARK: - Properties
    
    let size = CGSize(width: 946, height: 564)
    private(set) var scale = 0.5

    private(set) var sprite: SKSpriteNode
    private(set) var textures: [[SKTexture]]
    private var atlas: SKTextureAtlas

    enum Texture: Int {
        case idle = 0, run, walk, dead, glide, marsh
        
        var animationSpeed: TimeInterval {
            switch self {
            case .run:
                return 0.5
            case .walk:
                return 0.75
            case .glide:
                return 0.5
            case .marsh:
                return 1.0
            default:
                return 0.25
            }
        }
    }
    
    
    // MARK: - Initialization
    
    init() {
        atlas = SKTextureAtlas(named: "player")
        textures = []
        textures.append([]) //idle
        textures.append([]) //run
        textures.append([]) //walk
        textures.append([]) //marsh
        textures.append([]) //dead
        textures.append([]) //glide

        for i in 1...15 {
            textures[Texture.idle.rawValue].append(atlas.textureNamed("Idle (\(i))"))
            textures[Texture.run.rawValue].append(atlas.textureNamed("Run (\(i))"))
            textures[Texture.walk.rawValue].append(atlas.textureNamed("Walk (\(i))"))
            textures[Texture.marsh.rawValue].append(atlas.textureNamed("Run (\(i))"))
            textures[Texture.dead.rawValue].append(atlas.textureNamed("Dead (\(i))"))
            
            if i == 5 {
                textures[Texture.glide.rawValue].append(atlas.textureNamed("Run (\(i))"))
            }
        }
        
        sprite = SKSpriteNode(texture: textures[Texture.idle.rawValue][0])
        sprite.size = size
        sprite.setScale(scale)
        sprite.position = .zero
        sprite.zPosition = K.ZPosition.player
    }
    
    
    // MARK: - Functions
    
    mutating func setScale(_ scale: CGFloat) {
        self.scale = scale
    }
}
