//
//  Extension+SKSpriteNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/15/23.
//

import SpriteKit

extension SKSpriteNode {
    static let keyAnimateStatue = "animateStatue"
    static let keyDanceStatue = "danceStatue"
    
    /**
     Adds a glow surrounding the parent sprite node.
     - parameters:
        - textureName: the image of which to create the glow.
        - radiusPercentage: the size of the glow.
        - startingAlpha: starting alpha of the glowEffectNode.
     */
    func addGlow(spriteNode: SKSpriteNode, radiusPercentage: Float = 0.1, startingAlpha: CGFloat = 1) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius" : Float(size.width) * radiusPercentage])
        effectNode.alpha = startingAlpha
        effectNode.name = "glowEffectNode"

        let effect = spriteNode
        effect.anchorPoint = .zero
        effect.color = .white
        effect.colorBlendFactor = 1
        
        effectNode.addChild(effect)
        addChild(effectNode)
    }
    
    /**
     Animates a glow fading in, wating, then fading out
     - parameters:
        - fadeDuration: length of fadeIn, and fadeOut
        - waitDuration: length of wait before fading out
     */
    func animateAppearGlow(fadeDuration: TimeInterval, waitDuration: TimeInterval) {
        guard let glowEffectNode = childNode(withName: "glowEffectNode") as? SKEffectNode else { return print("No glow effect node found.") }
        
        glowEffectNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeDuration)
        ]))
    }
    
    /**
     Adds a black shadow (alpha = 0.25) to the parent sprite node
     - parameter offset: the offset point of the shadow.
     */
    func addShadow(offset: CGPoint = CGPoint(x: -3, y: -3)) {
        let shadow = SKSpriteNode(texture: self.texture)
        shadow.position = self.position + offset
        shadow.anchorPoint = self.anchorPoint
        shadow.size = self.size
        shadow.color = .black
        shadow.colorBlendFactor = 1
        shadow.alpha = 0.25
        shadow.zPosition = -zPositionOffset
        shadow.name = "shadowNode"
        
        addChild(shadow)
    }
    
    
    // MARK: - Party Tiles Animation
    
    func animatePartyTileShimmer(gameboardColor: UIColor) {
        let randomHue = UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        let randomDuration = TimeInterval.random(in: 0.75...1.0)

        self.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.colorize(with: gameboardColor, colorBlendFactor: 0.0, duration: randomDuration),
            SKAction.colorize(with: randomHue, colorBlendFactor: 1.0, duration: randomDuration)
        ])))
    }
    
    
    // MARK: - Tiki Statue Animations
    
    func animateStatue() {
        let noWarp: [SIMD2<Float>] = [
            SIMD2(0, 1),        SIMD2(0.5, 1),      SIMD2(1, 1),
            SIMD2(0, 0.5),      SIMD2(0.5, 0.5),    SIMD2(1, 0.5),
            SIMD2(0, 0),        SIMD2(0.5, 0),      SIMD2(1, 0)
        ]
        
        let skewLeft: [SIMD2<Float>] = [
            SIMD2(0, 1.25),     SIMD2(0.5, 1),      SIMD2(1, 0.75),
            SIMD2(0, 0.75),     SIMD2(0.5, 0.5),    SIMD2(1, 0.25),
            SIMD2(0, 0.25),     SIMD2(0.5, 0),      SIMD2(1, -0.25)
        ]
        
        let skewRight: [SIMD2<Float>] = [
            SIMD2(0, 0.75),     SIMD2(0.5, 1),      SIMD2(1, 1.25),
            SIMD2(0, 0.25),     SIMD2(0.5, 0.5),    SIMD2(1, 0.75),
            SIMD2(0, -0.25),    SIMD2(0.5, 0),      SIMD2(1, 0.25)
        ]
        
        let squash: [SIMD2<Float>] = [
            SIMD2(-0.25, 0.75), SIMD2(0.5, 0.75),   SIMD2(1.25, 0.75),
            SIMD2(-0.25, 0.5),  SIMD2(0.5, 0.5),    SIMD2(1.25, 0.5),
            SIMD2(-0.25, 0.25), SIMD2(0.5, 0.25),   SIMD2(1.25, 0.25)
        ]

        let warpGeometryGridSkewLeft = SKWarpGeometryGrid(columns: 2, rows: 2, sourcePositions: noWarp, destinationPositions: skewLeft)
        let warpGeometryGridSkewRight = SKWarpGeometryGrid(columns: 2, rows: 2, sourcePositions: noWarp, destinationPositions: skewRight)
        let warpGeometryGridSquash = SKWarpGeometryGrid(columns: 2, rows: 2, sourcePositions: noWarp, destinationPositions: squash)
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 2, rows: 2, sourcePositions: noWarp, destinationPositions: noWarp)

        let warpAction = SKAction.sequence([
            SKAction.warp(to: warpGeometryGridSkewLeft, duration: 0)!,
            SKAction.wait(forDuration: 0.2),
            SKAction.warp(to: warpGeometryGridSkewRight, duration: 0)!,
            SKAction.wait(forDuration: 0.2),
            SKAction.warp(to: warpGeometryGridSquash, duration: 0)!,
            SKAction.wait(forDuration: 0.2),
            SKAction.warp(to: warpGeometryGridNoWarp, duration: 0)!,
            SKAction.rotate(byAngle: 2 * .pi, duration: 0.2)
        ])
        
        self.run(warpAction, withKey: SKSpriteNode.keyAnimateStatue)
    }
    
    func animateDaemon(newTexture: SKTexture, delay: TimeInterval? = nil) {
        let scaryStatue = SKSpriteNode(texture: newTexture)
        scaryStatue.zPosition = 1
        scaryStatue.alpha = 0
        scaryStatue.name = "scaryStatue"
        
        for node in children {
            if node.name == "scaryStatue" {
                node.removeFromParent()
            }
        }
        
        addChild(scaryStatue)
        
        let shakeDuration: TimeInterval = 0.06
        let shakeCount = 48

        let tikiAction = SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.repeat(SKAction.sequence([
                SKAction.rotate(toAngle: .pi / 12, duration: shakeDuration),
                SKAction.rotate(toAngle: -.pi / 12, duration: shakeDuration),
            ]), count: shakeCount),
            SKAction.rotate(toAngle: 0, duration: shakeDuration)
        ])
        
        let scaryTikiAction = SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.wait(forDuration: shakeDuration * 2 * TimeInterval(shakeCount / 2)),
            SKAction.fadeIn(withDuration: shakeDuration * 2 * TimeInterval(shakeCount / 2))
        ])
        
        self.run(tikiAction)
        scaryStatue.run(scaryTikiAction)
    }
    
    func danceStatue() {
        let tempo: TimeInterval = 0.25
        let bounceDuration: TimeInterval = 0.1
        let shimmyDuration: TimeInterval = 0.1
        let xIncBounce: CGFloat = 6
        let xIncShimmy: CGFloat = 8
        
        let bounceLeftAction = SKAction.sequence([    
            SKAction.moveBy(x: -xIncBounce, y: 10, duration: bounceDuration),
            SKAction.moveBy(x: -xIncBounce, y: 4, duration: bounceDuration),
            SKAction.moveBy(x: -xIncBounce, y: -4, duration: bounceDuration),
            SKAction.moveBy(x: -xIncBounce, y: -10, duration: bounceDuration)
        ])

        let bounceRightAction = SKAction.sequence([
            SKAction.moveBy(x: xIncBounce, y: 10, duration: bounceDuration),
            SKAction.moveBy(x: xIncBounce, y: 4, duration: bounceDuration),
            SKAction.moveBy(x: xIncBounce, y: -4, duration: bounceDuration),
            SKAction.moveBy(x: xIncBounce, y: -10, duration: bounceDuration)
        ])
                
        let shimmyAction = SKAction.sequence([
            SKAction.moveBy(x: xIncShimmy, y: 0, duration: shimmyDuration),
            SKAction.moveBy(x: -xIncShimmy, y: 0, duration: shimmyDuration),
            SKAction.moveBy(x: xIncShimmy, y: 0, duration: shimmyDuration),
            SKAction.moveBy(x: -xIncShimmy, y: 0, duration: shimmyDuration)
        ])
        
        let danceLeftSequence = SKAction.sequence([
            bounceLeftAction,
            SKAction.wait(forDuration: tempo),
            bounceRightAction,
            SKAction.wait(forDuration: tempo),
            bounceLeftAction,
            SKAction.wait(forDuration: tempo),
            shimmyAction,
            SKAction.wait(forDuration: tempo)
        ])
        
        let danceLeftAltSequence = SKAction.sequence([
            bounceLeftAction,
            SKAction.wait(forDuration: tempo),
            bounceRightAction,
            SKAction.wait(forDuration: tempo),
            shimmyAction,
            SKAction.wait(forDuration: tempo),
            bounceLeftAction,
            SKAction.wait(forDuration: tempo)
        ])
        
        let danceRightSequence = SKAction.sequence([
            bounceRightAction,
            SKAction.wait(forDuration: tempo),
            bounceLeftAction,
            SKAction.wait(forDuration: tempo),
            bounceRightAction,
            SKAction.wait(forDuration: tempo),
            shimmyAction,
            SKAction.wait(forDuration: tempo)
        ])

        let danceRightAltSequence = SKAction.sequence([
            bounceRightAction,
            SKAction.wait(forDuration: tempo),
            shimmyAction,
            SKAction.wait(forDuration: tempo),
            bounceLeftAction,
            SKAction.wait(forDuration: tempo),
            bounceRightAction,
            SKAction.wait(forDuration: tempo)
        ])
        
        let sequence0Action = SKAction.sequence([danceLeftSequence, danceRightSequence, danceRightAltSequence, danceLeftSequence])
        let sequence1Action = SKAction.sequence([danceLeftAltSequence, danceRightAltSequence, danceRightSequence, danceLeftSequence])
        let sequence2Action = SKAction.sequence([danceRightSequence, danceLeftAltSequence, danceLeftAltSequence, danceRightSequence])
        let sequence3Action = SKAction.sequence([danceRightAltSequence, danceLeftSequence, danceLeftSequence, danceRightSequence])
        let selectedSequence: SKAction
        
        let sequenceSelector = Int.random(in: 0...3)

        switch sequenceSelector {
        case 0:     selectedSequence = sequence0Action
        case 1:     selectedSequence = sequence1Action
        case 2:     selectedSequence = sequence2Action
        case 3:     selectedSequence = sequence3Action
        default:    selectedSequence = sequence0Action
        }
        
        self.run(SKAction.repeatForever(selectedSequence), withKey: SKSpriteNode.keyDanceStatue)
    }
    
    
}
