//
//  LevelBuilder.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

/**
 Class with all the possible levels. These will need to be done thoughtfully.
 */
class LevelBuilder {
    static var maxLevel: Int { return levels.count - 1 }
    
    static var levels: [Level] = [
        Level(level: 0, moves: 4, gems: 0, gameboard: [[.start, .grass, .grass],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .grass, .endOpen]]),

        Level(level: 1, moves: 4, gems: 1, gameboard: [[.start, .grass, .gemOn],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .grass, .endClosed]]),

        Level(level: 2, moves: 6, gems: 2, gameboard: [[.start, .grass, .gemOn],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .gemOn, .endClosed]]),
        
        Level(level: 3, moves: 6, gems: 2, gameboard: [[.start, .grass, .gemOn],
                                                       [.gemOn, .grass, .grass],
                                                       [.grass, .grass, .endClosed]]),

        Level(level: 4, moves: 8, gems: 3, gameboard: [[.start, .grass, .gemOn],
                                                       [.grass, .grass, .gemOn],
                                                       [.gemOn, .grass, .endClosed]]),
        
        Level(level: 5, moves: 6, gems: 2, gameboard: [[.start, .marsh, .grass],
                                                       [.grass, .grass, .gemOn],
                                                       [.gemOn, .marsh, .endClosed]]),
        
        Level(level: 6, moves: 9, gems: 3, gameboard: [[.start, .grass, .grass, .gemOn],
                                                       [.ice, .ice, .gemOn, .grass],
                                                       [.ice, .ice, .boulder, .grass],
                                                       [.boulder, .gemOn, .endClosed, .boulder]]),

        Level(level: 7, moves: 11, gems: 5, gameboard: [[.start, .endClosed, .grass, .grass],
                                                       [.marsh, .ice, .hammer, .sword],
                                                       [.boulder, .enemy, .warp, .gemOn],
                                                       [.gemOn, .gemOn, .gemOn, .gemOn]])
    ]
}
