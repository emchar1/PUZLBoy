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
        case dragonFireIdle = "DragonFireIdle"
        case dragonFireLite = "DragonFireLite"
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
        case pointer = "PointerParticles"
        case pointerRainbow = "PointerRainbowParticles"
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
        print("ParticleEngine deinit")
    }
    
    
    // MARK: - Functions
    
    func animateParticles(type: ParticleType, toNode node: SKNode, position: CGPoint, scale: CGFloat = 1, angle: CGFloat = 0, shouldFlipHorizontally: Bool = false, zPosition: CGFloat = K.ZPosition.itemsAndEffects + 10, duration: TimeInterval) {
        
        guard let particles = SKEmitterNode(fileNamed: type.rawValue) else { return print("Particle file not found: \(type.rawValue).sks")}
        
        particles.position = position
        particles.setScale(2 * scale / UIDevice.modelInfo.ratio)
        particles.xScale *= shouldFlipHorizontally ? -1 : 1
        particles.zPosition = zPosition
        particles.name = ParticleEngine.nodeName
        
        if angle != 0 {
            particles.zRotation = angle
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
