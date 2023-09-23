//
//  ParticleEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/23/23.
//

import SpriteKit

class ParticleEngine: SKNode {
    
    // MARK: - Properties
    
    static let nodeName = "ParticleEmitter"
    
    static let shared: ParticleEngine = {
        let engine = ParticleEngine()
        
        //Add'l setup if needed
        
        return engine
    }()
    
    enum ParticleType: String {
        case boulderCrush = "BoulderCrushParticles"
        case dragonFire = "DragonFire"
        case gemCollect = "GemCollectParticles"
        case gemSparkle = "GemSparkleParticles"
        case hearts = "HeartsParticles"
        case heroRainbow = "HeroRainbowParticles"
        case itemPickup = "ItemPickupParticles"
        case lavaAppear = "LavaAppearParticles"
        case lavaSizzle = "LavaSizzleParticles"
        case magicBlast = "MagicParticles"
        case partyGem = "PartyGemParticles"
        case poisonBubbles = "PoisonBubblesParticles"
        case warp = "WarpParticles"
        case warp4 = "Warp4Particles"
    }
    
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit ParticleEngine")
    }
    
    
    // MARK: - Functions
    
    func animateParticles(type: ParticleType, toNode node: SKNode, position: CGPoint, scale: CGFloat = 1, angle: CGFloat = 0, duration: TimeInterval) {
        guard let particles = SKEmitterNode(fileNamed: type.rawValue) else { return print("Particle file not found: \(type.rawValue).sks")}
        
        particles.position = position
        particles.setScale(scale * (UIDevice.isiPad ? 1.7 : 1))
        particles.zPosition = K.ZPosition.itemsAndEffects + 10
        particles.name = ParticleEngine.nodeName
        
        if angle != 0 {
            particles.run(SKAction.rotate(toAngle: angle, duration: 0))
        }
        
        node.addChild(particles)
        
        
        guard duration > 0 else { return }
        
        let fadeDuration: TimeInterval = 0.25
        
        particles.run(SKAction.sequence([
            SKAction.wait(forDuration: duration - fadeDuration),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ]))
    }
    
    func removeParticles(fromNode node: SKNode) {
        for particleNode in node.children {
            guard particleNode.name == ParticleEngine.nodeName else { continue }
                    
            particleNode.removeAllActions()
            particleNode.removeFromParent()
        }
    }
    
    func hideParticles(fromNode node: SKNode) {
        for particleNode in node.children {
            guard particleNode.name == ParticleEngine.nodeName else { continue }
                    
            particleNode.run(SKAction.fadeOut(withDuration: 0.25))
        }
    }
    
    func showParticles(fromNode node: SKNode) {
        for particleNode in node.children {
            guard particleNode.name == ParticleEngine.nodeName else { continue }
                    
            particleNode.run(SKAction.fadeIn(withDuration: 0.25))
        }
    }
}
