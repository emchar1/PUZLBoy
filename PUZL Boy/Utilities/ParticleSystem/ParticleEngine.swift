//
//  ParticleEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/23/23.
//

import SpriteKit

class ParticleEngine: SKNode {
    
    // MARK: - Properties
    
    static let nodeNamePrefix = "ParticleEmitter"
    
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
        case dragonIce = "DragonIce"
        case dragonIceIdle = "DragonIceIdle"
        case dragonIceLite = "DragonIceLite"
        case gemCollect = "GemCollectParticles"
        case gemSparkle = "GemSparkleParticles"
        case groundExplode = "GroundExplodeParticles"
        case groundSplit = "GroundSplitParticles"
        case groundWarp = "GroundWarpParticles"
        case hearts = "HeartsParticles"
        case heroRainbow = "HeroRainbowParticles" // FIXME: - Just for test and giggles
        case inbetween = "InBetweenParticles"
        case itemPickup = "ItemPickupParticles"
        case lavaAppear = "LavaAppearParticles"
        case lavaSizzle = "LavaSizzleParticles"
        case magicBlast = "MagicBlastParticles"
        case magicBlastCastInvincible = "MagicBlastCastInvincibleParticles"
        case magicBlastCastDetonate = "MagicBlastCastDetonateParticles"
        case magicBlastLite = "MagicBlastLiteParticles"
        case magicBlastPoof = "MagicBlastPoofParticles"
        case magicElderExplosion = "MagicElderExplosionParticles"
        case magicElderExplosionStars = "MagicElderStarsParticles"
        case magicElderIce = "MagicElderIceParticles"
        case magicElderIce2 = "MagicElderIce2Particles"
        case magicElderEarth = "MagicElderEarthParticles"
        case magicElderEarth2 = "MagicElderEarth2Particles"
        case magicElderEarth3 = "MagicElderEarth3Particles"
        case magicElderFire = "MagicElderFireParticles"
        case magicElderFire2 = "MagicElderFire2Particles"
        case magicElderFire3 = "MagicElderFire3Particles"
        case magicElderFire4 = "MagicElderFire4Particles"
        case magicElder = "MagicElderParticles"
        case magicExplosion0 = "MagicExplosion0Particles"
        case magicExplosion1 = "MagicExplosion1Particles"
        case magicExplosion1_5 = "MagicExplosion1_5Particles"
        case magicExplosion2 = "MagicExplosion2Particles"
        case magicLight = "MagicLightParticles"
        case magicMerge = "MagicMergeParticles"
        case magicPrincessExplode = "MagicPrincessExplodeParticles"
        case magicPrincessExplode0 = "MagicPrincessExplode0Particles"
        case magicPrincessExplode1 = "MagicPrincessExplode1Particles"
        case magicPrincessExplode2 = "MagicPrincessExplode2Particles"
        case magicPrincessExplode3 = "MagicPrincessExplode3Particles"
        case magicPrincess = "MagicPrincessParticles"
        case magmoorBamf = "MagmoorBamfParticles" // FIXME: - Is this in use??? 12/2/24
        case magmoorSmoke = "MagmoorSmokeParticles"
        case partyGem = "PartyGemParticles"
        case pointer = "PointerParticles"
        case pointerRainbow = "PointerRainbowParticles"
        case poisonBubbles = "PoisonBubblesParticles"
        case snowfall = "SnowfallParticles"
        case warp = "WarpParticles"
        case warp4 = "Warp4Particles"
        case warp4Slow = "Warp4SlowParticles"
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
    
    func animateParticles(type: ParticleType,
                          toNode node: SKNode,
                          position: CGPoint,
                          scale: CGFloat = 1,
                          angle: CGFloat = 0,
                          shouldFlipHorizontally: Bool = false,
                          alpha: CGFloat = 1,
                          colorSequence: SKKeyframeSequence? = nil,
                          alphaSequence: SKKeyframeSequence? = nil,
                          emissionAngleRangeDegrees: CGFloat? = nil,
                          zPosition: CGFloat = K.ZPosition.itemsAndEffects + 10,
                          nameGameboardPosition: K.GameboardPosition? = nil,
                          duration: TimeInterval)
    {
        guard let particles = SKEmitterNode(fileNamed: type.rawValue) else { return print("Particle file not found: \(type.rawValue).sks")}
        
        particles.position = position
        particles.setScale(2 * scale / UIDevice.modelInfo.ratio)
        particles.xScale *= shouldFlipHorizontally ? -1 : 1
        particles.alpha = alpha
        particles.zPosition = zPosition
        particles.name = ParticleEngine.getNodeName(at: nameGameboardPosition)
        
        if angle != 0 {
            particles.zRotation = angle
        }
        
        if let colorSequence = colorSequence {
            particles.particleColorSequence = colorSequence
        }
        
        if let alphaSequence = alphaSequence {
            particles.particleAlphaSequence = alphaSequence
        }
        
        if let emissionAngleRangeDegrees = emissionAngleRangeDegrees {
            particles.emissionAngleRange = emissionAngleRangeDegrees.toRadians()
        }
        
        node.addChild(particles)
        
        
        guard duration > 0 else { return }
        
        let fadeDuration: TimeInterval = 0.25
        
        particles.run(SKAction.sequence([
            SKAction.wait(forDuration: duration - fadeDuration),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ]))
        
        // FIXME: - Testing for Marlin Magic
//        if type == .magicLight {
//            animateCircle(particles: particles, duration: 2)
//        }
    }
        
    // FIXME: - Testing for Marlin Magic
    private func animateCircle(particles: SKEmitterNode, duration: TimeInterval) {
        let origin = particles.position
        let radius: CGFloat = 100
        let divisions: CGFloat = 8

        particles.position = CGPoint(x: origin.x + radius * cos(0), y: origin.y + radius * sin(0))
        
        func animateArc(angle: CGFloat) -> SKAction {
            let endPoint = CGPoint(x: origin.x + radius * cos(angle), y: origin.y + radius * sin(angle))
            
            return SKAction.move(to: endPoint, duration: duration / (2 * divisions))
        }
        
        particles.run(SKAction.repeatForever(SKAction.sequence([
            animateArc(angle: 0),
            animateArc(angle: .pi / divisions),
            animateArc(angle: 2 * .pi / divisions),
            animateArc(angle: 3 * .pi / divisions),
            animateArc(angle: 4 * .pi / divisions),
            animateArc(angle: 5 * .pi / divisions),
            animateArc(angle: 6 * .pi / divisions),
            animateArc(angle: 7 * .pi / divisions),
            animateArc(angle: 8 * .pi / divisions),
            animateArc(angle: 9 * .pi / divisions),
            animateArc(angle: 10 * .pi / divisions),
            animateArc(angle: 11 * .pi / divisions),
            animateArc(angle: 12 * .pi / divisions),
            animateArc(angle: 13 * .pi / divisions),
            animateArc(angle: 14 * .pi / divisions),
            animateArc(angle: 15 * .pi / divisions),
        ])))
    }
    
    func removeParticles(fromNode node: SKNode, nameGameboardPosition: K.GameboardPosition? = nil, fadeDuration: TimeInterval = 0) {
        for particleNode in node.children {
            guard particleNode.name == ParticleEngine.getNodeName(at: nameGameboardPosition) else { continue }
            
            particleNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: fadeDuration),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    func hideParticles(fromNode node: SKNode, fadeDuration: TimeInterval = 0.25) {
        for particleNode in node.children {
            guard let name = particleNode.name, name.contains(ParticleEngine.nodeNamePrefix) else { continue }

            particleNode.run(SKAction.fadeOut(withDuration: fadeDuration))
        }
    }
    
    func showParticles(fromNode node: SKNode, fadeDuration: TimeInterval = 0.25) {
        for particleNode in node.children {
            guard let name = particleNode.name, name.contains(ParticleEngine.nodeNamePrefix) else { continue }
                    
            particleNode.run(SKAction.fadeIn(withDuration: fadeDuration))
        }
    }
    
    func animateExistingParticles(fromNode node: SKNode, action: SKAction, nameGameboardPosition: K.GameboardPosition? = nil) {
        for particleNode in node.children {
            guard particleNode.name == ParticleEngine.getNodeName(at: nameGameboardPosition) else { continue }
            
            particleNode.run(action)
        }
    }
    
    /**
     Used during Princess Olivia's final transformation power display.
     */
    func animatePrincessExplosion(toNode node: SKNode, position: CGPoint = .zero, scale: CGFloat = 1, zPosition: CGFloat = 0) {
        ParticleEngine.shared.animateParticles(type: .magicPrincessExplode0,
                                               toNode: node,
                                               position: position,
                                               scale: scale,
                                               zPosition: zPosition - 4,
                                               duration: 0)
        
        ParticleEngine.shared.animateParticles(type: .magicPrincessExplode1,
                                               toNode: node,
                                               position: position,
                                               scale: scale,
                                               zPosition: zPosition - 3,
                                               duration: 0)
        
        ParticleEngine.shared.animateParticles(type: .magicPrincessExplode2,
                                               toNode: node,
                                               position: position,
                                               scale: scale,
                                               zPosition: zPosition - 2,
                                               duration: 0)
        
        ParticleEngine.shared.animateParticles(type: .magicPrincessExplode3,
                                               toNode: node,
                                               position: position,
                                               scale: scale,
                                               zPosition: zPosition - 1,
                                               duration: 0)
    }
    
    static func getNodeName(at position: K.GameboardPosition?) -> String {
        guard let position = position else { return ParticleEngine.nodeNamePrefix }

        return "\(ParticleEngine.nodeNamePrefix)(\(position.row),\(position.col))"
    }
    
    
    
}
