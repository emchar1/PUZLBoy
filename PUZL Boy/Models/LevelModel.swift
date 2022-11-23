//
//  LevelModel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/22/22.
//

import Foundation

struct LevelModel: CustomStringConvertible {
    let level: Int
    let moves: Int
    
    //Row 0
    let r0c0: String
    let r0c1: String
    let r0c2: String
    let r0c3: String
    let r0c4: String
    let r0c5: String
    
    //Row 1
    let r1c0: String
    let r1c1: String
    let r1c2: String
    let r1c3: String
    let r1c4: String
    let r1c5: String
    
    //Row 2
    let r2c0: String
    let r2c1: String
    let r2c2: String
    let r2c3: String
    let r2c4: String
    let r2c5: String
    
    //Row 3
    let r3c0: String
    let r3c1: String
    let r3c2: String
    let r3c3: String
    let r3c4: String
    let r3c5: String
    
    //Row 4
    let r4c0: String
    let r4c1: String
    let r4c2: String
    let r4c3: String
    let r4c4: String
    let r4c5: String
    
    //Row 5
    let r5c0: String
    let r5c1: String
    let r5c2: String
    let r5c3: String
    let r5c4: String
    let r5c5: String
    
    var description: String {
        return "\nlevel: \(level), moves: \(moves), gameboard: \n\t[[\(r0c0), \(r0c1), \(r0c2), \(r0c3), \(r0c4), \(r0c5)], \n\t [\(r1c0), \(r1c1), \(r1c2), \(r1c3), \(r1c4), \(r1c5)], \n\t [\(r2c0), \(r2c1), \(r2c2), \(r2c3), \(r2c4), \(r2c5)], \n\t [\(r3c0), \(r3c1), \(r3c2), \(r3c3), \(r3c4), \(r3c5)], \n\t [\(r4c0), \(r4c1), \(r4c2), \(r4c3), \(r4c4), \(r4c5)], \n\t [\(r5c0), \(r5c1), \(r5c2), \(r5c3), \(r5c4), \(r5c5)]]"
    }
}
