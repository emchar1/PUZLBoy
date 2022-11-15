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
        Level(level: 0, moves: 4, gameboard: [[.start, .grass, .grass],
                                              [.grass, .grass, .grass],
                                              [.grass, .grass, .endOpen]]),
        
        Level(level: 1, moves: 4, gameboard: [[.start, .grass, .gem],
                                              [.grass, .grass, .grass],
                                              [.grass, .grass, .endClosed]]),
        
        Level(level: 2, moves: 6, gameboard: [[.start, .grass, .gem],
                                              [.grass, .grass, .grass],
                                              [.grass, .gem, .endClosed]]),
        
        Level(level: 3, moves: 6, gameboard: [[.start, .grass, .gem],
                                              [.gem, .grass, .grass],
                                              [.grass, .grass, .endClosed]]),
        
        Level(level: 4, moves: 8, gameboard: [[.start, .grass, .gem],
                                              [.grass, .grass, .gem],
                                              [.gem, .grass, .endClosed]]),
        
        Level(level: 5, moves: 8, gameboard: [[.start, .boulder, .gem],
                                              [.grass, .boulder, .grass],
                                              [.grass, .grass, .endClosed]]),
        
        Level(level: 6, moves: 6, gameboard: [[.start, .marsh, .grass],
                                              [.grass, .grass, .gem],
                                              [.gem, .marsh, .endClosed]]),
        
        Level(level: 7, moves: 9, gameboard: [[.start, .grass, .grass, .gem],
                                              [.ice, .ice, .gem, .grass],
                                              [.ice, .ice, .boulder, .grass],
                                              [.boulder, .gem, .endClosed, .boulder]]),
        
        Level(level: 8, moves: 99, gameboard: [[.start, .ice, .marsh, .gemOnIce, .ice, .ice, .ice, .gemOnIce],
                                               [.ice, .ice, .gemOnIce, .grass, .ice, .ice, .ice, .gemOnIce],
                                               [.ice, .ice, .gemOnIce, .grass, .ice, .ice, .ice, .gemOnIce],
                                               [.ice, .ice, .gemOnIce, .grass, .ice, .ice, .ice, .gemOnIce],
                                               [.ice, .ice, .gemOnIce, .grass, .ice, .ice, .ice, .gemOnIce],
                                               [.ice, .ice, .gemOnIce, .grass, .ice, .ice, .ice, .gemOnIce],
                                               [.ice, .ice, .boulder, .grass, .ice, .ice, .ice, .gemOnIce],
                                               [.boulder, .gem, .endClosed, .boulder, .ice, .ice, .ice, .gemOnIce]]),
        
        Level(level: 9, moves: 12, gameboard: [[.start, .endClosed, .grass, .grass],
                                               [.marsh, .ice, .hammer, .sword],
                                               [.boulder, .enemy, .warp, .gem],
                                               [.gem, .gem, .gem, .gem]])
    ]
}
