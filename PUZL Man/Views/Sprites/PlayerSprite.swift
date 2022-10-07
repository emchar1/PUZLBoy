//
//  PlayerSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/6/22.
//

import SpriteKit

class PlayerSprite {
    var sprite: SKShapeNode
    
    init() {
        sprite = SKShapeNode(circleOfRadius: 75)
        sprite.fillColor = .orange
        sprite.strokeColor = .cyan
        sprite.lineWidth = 10
        sprite.position = CGPoint(x: 85, y: 85)
        sprite.zPosition = 300
    }
}
