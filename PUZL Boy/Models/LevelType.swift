//
//  LevelType.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/15/22.
//

import Foundation

/**
 Represents the gameboard textures.
 */
enum LevelType: Int, CaseIterable {
    case boundary = 0, start, endClosed, endOpen, gem, gemOnIce //important panels
    case grass, marsh, ice //terrain panels
    case hammer, sword //inventory panels
    case boulder, enemy, warp //special panels
    
    var description: String {
        return String(describing: self)
    }
    
    static func getLevelType(from string: String) -> LevelType {
        switch string {
        case "boundary": return .boundary
        case "start": return .start
        case "endClosed": return .endClosed
        case "endOpen": return .endOpen
        case "gem": return .gem
        case "gemOnIce": return .gemOnIce
        case "grass": return .grass
        case "marsh": return .marsh
        case "ice": return .ice
        case "hammer": return .hammer
        case "sword": return .sword
        case "boulder": return .boulder
        case "enemy": return .enemy
        case "warp": return .warp
        default: return .boundary //.boundary is a good way to ensure all types are accounted for here.
        }
    }
}
