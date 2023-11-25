//
//  LevelModel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/22/22.
//

import Foundation

//K.GameboardPosition can't be codable due to it being a tuple, so I need a separate struct here.
struct PlayerPosition: Codable {
    let row: Int
    let col: Int
}

///To be used for Firestore to store last saved state of a gameboard, level, moves and health.
struct LevelModel: CustomStringConvertible, Codable {
    let level: Int
    let moves: Int
    let health: Int
    let solution: String
    let attempt: String
    let gemsCollected: Int
    let gemsRemaining: Int
    let playerPosition: PlayerPosition
    let inventory: Inventory

    //TERRAIN
    //Row 0
    let r0c0: String
    let r0c1: String
    let r0c2: String
    let r0c3: String
    let r0c4: String
    let r0c5: String
    let r0c6: String
    
    //Row 1
    let r1c0: String
    let r1c1: String
    let r1c2: String
    let r1c3: String
    let r1c4: String
    let r1c5: String
    let r1c6: String
    
    //Row 2
    let r2c0: String
    let r2c1: String
    let r2c2: String
    let r2c3: String
    let r2c4: String
    let r2c5: String
    let r2c6: String

    //Row 3
    let r3c0: String
    let r3c1: String
    let r3c2: String
    let r3c3: String
    let r3c4: String
    let r3c5: String
    let r3c6: String

    //Row 4
    let r4c0: String
    let r4c1: String
    let r4c2: String
    let r4c3: String
    let r4c4: String
    let r4c5: String
    let r4c6: String

    //Row 5
    let r5c0: String
    let r5c1: String
    let r5c2: String
    let r5c3: String
    let r5c4: String
    let r5c5: String
    let r5c6: String

    //Row 6
    let r6c0: String
    let r6c1: String
    let r6c2: String
    let r6c3: String
    let r6c4: String
    let r6c5: String
    let r6c6: String

    
    //OVERLAYS
    //Row 0
    let s0d0: String
    let s0d1: String
    let s0d2: String
    let s0d3: String
    let s0d4: String
    let s0d5: String
    let s0d6: String

    //Row 1
    let s1d0: String
    let s1d1: String
    let s1d2: String
    let s1d3: String
    let s1d4: String
    let s1d5: String
    let s1d6: String

    //Row 2
    let s2d0: String
    let s2d1: String
    let s2d2: String
    let s2d3: String
    let s2d4: String
    let s2d5: String
    let s2d6: String

    //Row 3
    let s3d0: String
    let s3d1: String
    let s3d2: String
    let s3d3: String
    let s3d4: String
    let s3d5: String
    let s3d6: String

    //Row 4
    let s4d0: String
    let s4d1: String
    let s4d2: String
    let s4d3: String
    let s4d4: String
    let s4d5: String
    let s4d6: String

    //Row 5
    let s5d0: String
    let s5d1: String
    let s5d2: String
    let s5d3: String
    let s5d4: String
    let s5d5: String
    let s5d6: String

    //Row 6
    let s6d0: String
    let s6d1: String
    let s6d2: String
    let s6d3: String
    let s6d4: String
    let s6d5: String
    let s6d6: String

    var description: String {
        let s = "\nLV: \(level), moves: \(moves), health: \(health), gemsCollected: \(gemsCollected), gemsRemaining: \(gemsRemaining), gameboard: " +
        "\n\t[[\(r0c0), \(r0c1), \(r0c2), \(r0c3), \(r0c4), \(r0c5), \(r0c6)], " +
        "\n\t [\(r1c0), \(r1c1), \(r1c2), \(r1c3), \(r1c4), \(r1c5), \(r1c6)], " +
        "\n\t [\(r2c0), \(r2c1), \(r2c2), \(r2c3), \(r2c4), \(r2c5), \(r2c6)], " +
        "\n\t [\(r3c0), \(r3c1), \(r3c2), \(r3c3), \(r3c4), \(r3c5), \(r3c6)], " +
        "\n\t [\(r4c0), \(r4c1), \(r4c2), \(r4c3), \(r4c4), \(r4c5), \(r4c6)], " +
        "\n\t [\(r5c0), \(r5c1), \(r5c2), \(r5c3), \(r5c4), \(r5c5), \(r5c6)], " +
        "\n\t [\(r6c0), \(r6c1), \(r6c2), \(r6c3), \(r6c4), \(r6c5), \(r6c6)]]"
        
        return s
    }
}
