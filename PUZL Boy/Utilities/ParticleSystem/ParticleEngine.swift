//
//  ParticleEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/23/23.
//

import SpriteKit

class ParticleEngine: SKNode {
    
    // MARK: - Properties
    
    static let shared: ParticleEngine = {
        let engine = ParticleEngine()
        
        //Add'l setup if needed
        
        return engine
    }()
    
    enum ParticleType: String {
        case boulderCrush = "BoulderCrushParticles"
        case gemCollect = "GemCollectParticles"
        case hearts = "HeartsParticles"
        case heroRainbow = "HeroRainbowParticles"
        case itemPickup = "ItemPickupParticles"
        case lavaAppear = "LavaAppearParticles"
        case partyGem = "PartyGemParticles"
        case warp = "WarpParticles"
    }
    
    
    // MARK: - Initialization
    private override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func animateParticles(type: ParticleType, toNode node: SKNode, position: CGPoint, scale: CGFloat = 1, duration: TimeInterval) {
        guard let particles = SKEmitterNode(fileNamed: type.rawValue) else { return print("Particle file not found: \(type.rawValue).sks")}
        
        particles.position = position
        particles.setScale(scale)
        particles.zPosition = K.ZPosition.itemsAndEffects + 10
        
        node.addChild(particles)
        
        particles.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent()
        ]))
    }
    
    
}
