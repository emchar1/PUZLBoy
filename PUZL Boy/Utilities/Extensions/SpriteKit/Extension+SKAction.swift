//
//  Extension+SKAction.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/13/25.
//

import SpriteKit

extension SKAction {
    static func colorizeWithRainbowColorSequence(blendFactor: CGFloat = 1, duration: TimeInterval = 1) -> SKAction {
        return SKAction.sequence([
            SKAction.colorize(with: UIColor.rainbowColors[0], colorBlendFactor: blendFactor, duration: duration),
            SKAction.colorize(with: UIColor.rainbowColors[1], colorBlendFactor: blendFactor, duration: duration),
            SKAction.colorize(with: UIColor.rainbowColors[2], colorBlendFactor: blendFactor, duration: duration),
            SKAction.colorize(with: UIColor.rainbowColors[3], colorBlendFactor: blendFactor, duration: duration),
            SKAction.colorize(with: UIColor.rainbowColors[4], colorBlendFactor: blendFactor, duration: duration),
            SKAction.colorize(with: UIColor.rainbowColors[5], colorBlendFactor: blendFactor, duration: duration),
            SKAction.colorize(with: UIColor.rainbowColors[6], colorBlendFactor: blendFactor, duration: duration),
            SKAction.colorize(with: UIColor.rainbowColors[7], colorBlendFactor: blendFactor, duration: duration)
        ])
    }
    
    
}
