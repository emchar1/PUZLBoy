//
//  PlayerSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/6/22.
//

import SpriteKit

class PlayerSprite {
    
    // MARK: - Properties
    
    var inventory: Inventory
    var sprite: SKShapeNode
    
    
    // MARK: - Initialization
    
    init(position: CGPoint) {
        inventory = Inventory(hammers: 0, swords: 0)
        
        sprite = SKShapeNode(circleOfRadius: 75)
        sprite.fillColor = .orange
        sprite.strokeColor = .cyan
        sprite.lineWidth = 10
        
        //FIXME: - Need CGPoint within the gameboard!!
        sprite.position = position//CGPoint(x:  K.iPhoneWidth / 3 - 85 * 2, y: K.iPhoneWidth / 3 - 85 * 2)
        
        sprite.zPosition = K.ZPosition.player
    }
}
