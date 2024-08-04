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
    case grass, marsh, ice, sand, lava, snow, water, partytile //terrain panels
    case hammer, sword, heart //inventory panels
    case boulder, enemy, enemyIce, warp, warp2, warp3, warp4 //special panels
    case partyPill, partyGem, partyGemDouble, partyGemTriple, partyHint, partyLife, partyTime, partyFast, partySlow, partyBomb, partyBoom //party items
    case statue0, statue1, statue2, statue3 //tiki statues
    
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
        case "snow": return .snow
        case "water": return .water
        case "partytile": return .partytile
        case "hammer": return .hammer
        case "sword": return .sword
        case "heart": return .heart
        case "boulder": return .boulder
        case "enemy": return .enemy
        case "enemyIce": return .enemyIce
        case "warp": return .warp
        case "warp2": return .warp2
        case "warp3": return .warp3
        case "warp4": return .warp4
        case "partyPill": return .partyPill
        case "partyGem": return .partyGem
        case "partyGemDouble": return .partyGemDouble
        case "partyGemTriple": return .partyGemTriple
        case "partyHint": return .partyHint
        case "partyLife": return .partyLife
        case "partyTime": return .partyTime
        case "partyFast": return .partyFast
        case "partySlow": return .partySlow
        case "partyBomb": return .partyBomb
        case "partyBoom": return .partyBoom
        case "statue0": return .statue0
        case "statue1": return .statue1
        case "statue2": return .statue2
        case "statue3": return .statue3
        default: return .boundary //.boundary ensures all types are accounted for.
        }
    }
}
