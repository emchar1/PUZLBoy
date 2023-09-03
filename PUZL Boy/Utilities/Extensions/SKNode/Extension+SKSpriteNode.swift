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
        shadow.zPosition = -1
        shadow.name = "shadowNode"
        
        addChild(shadow)
    }
}
