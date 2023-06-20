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
    case boundary = 0, start, endClosed, endOpen, gem //important panels
    case grass, marsh, ice, sand, lava, partytile //terrain panels
    case hammer, sword, heart //inventory panels
    case boulder, enemy, warp, warp2, warp3 //special panels
    case partyPill, partyGem, partyGemDouble, partyGemTriple //party time!!!
    
    var description: String {
        //Should boundary default to ""?
        return self == .boundary ? "" : String(describing: self)
    }
    
    static func getLevelType(from string: String) -> LevelType {
        switch string {
        case "boundary": return .boundary
        case "start": return .start
        case "endClosed": return .endClosed
        case "endOpen": return .endOpen
        case "gem": return .gem
        case "grass": return .grass
        case "marsh": return .marsh
        case "ice": return .ice
        case "sand": return .sand
        case "lava": return .lava
        case "partytile": return .partytile
        case "hammer": return .hammer
        case "sword": return .sword
        case "heart": return .heart
        case "boulder": return .boulder
        case "enemy": return .enemy
        case "warp": return .warp
        case "warp2": return .warp2
        case "warp3": return .warp3
        case "partyPill": return .partyPill
        case "partyGem": return .partyGem
        case "partyGemDouble": return .partyGemDouble
        case "partyGemTriple": return .partyGemTriple
        default: return .boundary //.boundary ensures all types are accounted for.
        }
    }
}
