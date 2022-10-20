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
    static var levels: [Level] = [
        Level(level: 0, moves: 4, gems: 0, gameboard: [[.start, .grass, .grass],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .grass, .end]]),

        Level(level: 1, moves: 4, gems: 1, gameboard: [[.start, .grass, .gemOn],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .grass, .end]]),

        Level(level: 2, moves: 6, gems: 2, gameboard: [[.start, .grass, .gemOn],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .gemOn, .end]]),
        
        Level(level: 3, moves: 6, gems: 2, gameboard: [[.start, .grass, .gemOn],
                                                       [.gemOn, .grass, .grass],
                                                       [.grass, .grass, .end]]),

        Level(level: 4, moves: 12, gems: 5, gameboard: [[.start, .end, .grass, .grass],
                                                       [.marsh, .ice, .hammer, .sword],
                                                       [.boulder, .enemy, .warp, .gemOn],
                                                       [.gemOn, .gemOn, .gemOn, .gemOn]])
    ]
}
