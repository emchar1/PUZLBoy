//
//  Extension+SKSpriteNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/15/23.
//

import SpriteKit

extension SKSpriteNode {
    func addGlow(textureName: String, radiusPercentage: Float = 0.1) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius" : Float(size.width) * radiusPercentage])

        let effect = SKSpriteNode(texture: SKTexture(imageNamed: textureName))
        effect.anchorPoint = .zero
        effect.color = .white
        effect.colorBlendFactor = 1
        
        effectNode.addChild(effect)
        addChild(effectNode)
    }
    
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

        let warpGeometryGridSkewLeft = SKWarpGeometryGrid(columns: 2, rows: 2,
                                                          sourcePositions: noWarp, destinationPositions: skewLeft)
        
        let warpGeometryGridSkewRight = SKWarpGeometryGrid(columns: 2, rows: 2,
                                                           sourcePositions: noWarp, destinationPositions: skewRight)
        
        let warpGeometryGridSquash = SKWarpGeometryGrid(columns: 2, rows: 2,
                                                        sourcePositions: noWarp, destinationPositions: squash)

        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 2, rows: 2,
                                                        sourcePositions: noWarp, destinationPositions: noWarp)

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
        
        self.run(warpAction)
    }
}
