//
//  Extension+SKNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/20/23.
//

import SpriteKit

extension SKNode {
    
    // MARK: - Properties

    ///A unit of 1, which can be added or subtracted from a zPosition
    var zPositionOffset: CGFloat { 1 }
    
    var positionInScene: CGPoint? {
        if let scene = scene, let parent = parent {
            return parent.convert(position, to: scene)
        }
        else {
            return nil
        }
    }
    
    
    // MARK: - Functions
    
    
}
