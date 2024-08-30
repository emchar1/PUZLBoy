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
        case magicBlastLite = "MagicBlastLiteParticles"
        case magicElderExplosion = "MagicElderExplosionParticles"
        case magicElderExplosionStars = "MagicElderStarsParticles"
        case magicElderIce = "MagicElderIceParticles"
        case magicElderEarth = "MagicElderEarthParticles"
        case magicElderFire = "MagicElderFireParticles"
        case magicElderFire2 = "MagicElderFire2Particles"
        case magicElder = "MagicElderParticles"
        case magicExplosion = "MagicExplosionParticles"
        case magicLight = "MagicLightParticles" // FIXME: - Testing for Marlin Magic
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
        particles.name = ParticleEngine.nodeName + getPositionString(nameGameboardPosition)
        
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
        if type == .magicLight {
            animateCircle(particles: particles, duration: 2)
        }
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
    
    func removeParticles(fromNode node: SKNode, nameGameboardPosition: K.GameboardPosition? = nil) {
        for particleNode in node.children {
            guard particleNode.name == ParticleEngine.nodeName + getPositionString(nameGameboardPosition) else { continue }
                    
            particleNode.removeAllActions()
            particleNode.removeFromParent()
        }
    }
    
    func hideParticles(fromNode node: SKNode, fadeDuration: TimeInterval = 0.25) {
        for particleNode in node.children {
            guard let name = particleNode.name, name.contains(ParticleEngine.nodeName) else { continue }

            particleNode.run(SKAction.fadeOut(withDuration: fadeDuration))
        }
    }
    
    func showParticles(fromNode node: SKNode, fadeDuration: TimeInterval = 0.25) {
        for particleNode in node.children {
            guard let name = particleNode.name, name.contains(ParticleEngine.nodeName) else { continue }
                    
            particleNode.run(SKAction.fadeIn(withDuration: fadeDuration))
        }
    }
    
    private func getPositionString(_ position: K.GameboardPosition?) -> String {
        if let position = position {
            return "(\(position.row),\(position.col))"
        }
        else {
            return ""
        }
    }
    
    
    
}
