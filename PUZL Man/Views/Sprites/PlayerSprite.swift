//
//  PlayerSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/6/22.
//

import SpriteKit

class PlayerSprite {
    
    // MARK: - Properties
    
    var inventory: Inventory {
        didSet {
            if hasHammers() && !hasSwords() {
                sprite.strokeColor = .systemPink
            }
            else if hasSwords() && !hasHammers() {
                sprite.strokeColor = .cyan
            }
            else if hasHammers() && hasSwords() {
                sprite.strokeColor = .purple
            }
            else {
                sprite.strokeColor = .clear
            }
        }
    }
    var sprite: SKShapeNode
    
    
    // MARK: - Initialization
    
    init(position: CGPoint) {
        inventory = Inventory(hammers: 0, swords: 0)
        
        sprite = SKShapeNode(circleOfRadius: 75)
        sprite.fillColor = .orange
        sprite.strokeColor = .clear
        sprite.lineWidth = 18
        sprite.position = position
        sprite.zPosition = K.ZPosition.player
    }
    
    
    // MARK: - Helper Functions
    
    func hasHammers() -> Bool {
        return inventory.hammers > 0
    }

    func hasSwords() -> Bool {
        return inventory.swords > 0
    }
}
