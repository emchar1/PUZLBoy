//
//  LevelBuilder.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

class LevelBuilder {
    static var levels: [Level] = [
        Level(level: 0, moves: 4, gems: 0, gameboard: [[.start, .grass, .grass],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .grass, .end]]),

        Level(level: 1, moves: 4, gems: 1, gameboard: [[.start, .grass, .gem],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .grass, .end]]),

        Level(level: 2, moves: 6, gems: 2, gameboard: [[.start, .grass, .gem],
                                                       [.grass, .grass, .grass],
                                                       [.grass, .gem, .end]]),
        
        Level(level: 3, moves: 6, gems: 2, gameboard: [[.start, .grass, .gem],
                                                       [.gem, .grass, .grass],
                                                       [.grass, .grass, .end]]),

        Level(level: 4, moves: 12, gems: 5, gameboard: [[.start, .end, .gem, .grass],
                                                       [.marsh, .ice, .hammer, .sword],
                                                       [.boulder, .enemy, .warp, .gem],
                                                       [.gem, .gem, .gem, .gem]])
    ]
}
