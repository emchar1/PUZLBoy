//
//  PlayerSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/6/22.
//

import SpriteKit

class PlayerSprite {
    var sprite: SKShapeNode
    
    init(position: CGPoint) {
        sprite = SKShapeNode(circleOfRadius: 75)
        sprite.fillColor = .orange
        sprite.strokeColor = .cyan
        sprite.lineWidth = 10
        
        //FIXME: - Need CGPoint within the gameboard!!
        sprite.position = position//CGPoint(x:  K.iPhoneWidth / 3 - 85 * 2, y: K.iPhoneWidth / 3 - 85 * 2)
        
        sprite.zPosition = K.ZPosition.player
    }
}
