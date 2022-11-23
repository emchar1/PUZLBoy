//
//  LevelBuilder.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

/**
 Class with all the possible levels. These will need to be done thoughtfully.
 */
struct LevelBuilder {
    static var maxLevel: Int { return levels.count - 1 }
    
//    static var levels: [Level] = {
//        var levels: [Level] = []
//
//        FIRManager.initializeRecords { levelModels in
//            for model in levelModels {
//                var gameboardSize = 3
//                var gameboard: [[LevelType]] = []
//
//                //Guaranteed 3x3
//                gameboard.append([
//                    LevelType.getLevelType(from: model.r0c0),
//                    LevelType.getLevelType(from: model.r0c1),
//                    LevelType.getLevelType(from: model.r0c2)
//                ])
//                gameboard.append([
//                    LevelType.getLevelType(from: model.r1c0),
//                    LevelType.getLevelType(from: model.r1c1),
//                    LevelType.getLevelType(from: model.r1c2)
//                ])
//                gameboard.append([
//                    LevelType.getLevelType(from: model.r2c0),
//                    LevelType.getLevelType(from: model.r2c1),
//                    LevelType.getLevelType(from: model.r2c2)
//                ])
//
//
//                if model.r3c0 != "" {
//                    gameboardSize = 4
//
//                    //Complete the previous rows first...
//                    gameboard[0].append(LevelType.getLevelType(from: model.r0c3))
//                    gameboard[1].append(LevelType.getLevelType(from: model.r1c3))
//                    gameboard[2].append(LevelType.getLevelType(from: model.r2c3))
//
//                    //Then build the last row
//                    gameboard.append([
//                        LevelType.getLevelType(from: model.r3c0),
//                        LevelType.getLevelType(from: model.r3c1),
//                        LevelType.getLevelType(from: model.r3c2),
//                        LevelType.getLevelType(from: model.r3c3)
//                    ])
//                }
//
//                if model.r4c0 != "" {
//                    gameboardSize = 5
//
//                    //Complete the previous rows first...
//                    gameboard[0].append(LevelType.getLevelType(from: model.r0c4))
//                    gameboard[1].append(LevelType.getLevelType(from: model.r1c4))
//                    gameboard[2].append(LevelType.getLevelType(from: model.r2c4))
//                    gameboard[3].append(LevelType.getLevelType(from: model.r3c4))
//
//                    //Then build the last row
//                    gameboard.append([
//                        LevelType.getLevelType(from: model.r4c0),
//                        LevelType.getLevelType(from: model.r4c1),
//                        LevelType.getLevelType(from: model.r4c2),
//                        LevelType.getLevelType(from: model.r4c3),
//                        LevelType.getLevelType(from: model.r4c4)
//                    ])
//                }
//
//                if model.r5c0 != "" {
//                    gameboardSize = 6
//
//                    //Complete the previous rows first...
//                    gameboard[0].append(LevelType.getLevelType(from: model.r0c5))
//                    gameboard[1].append(LevelType.getLevelType(from: model.r1c5))
//                    gameboard[2].append(LevelType.getLevelType(from: model.r2c5))
//                    gameboard[3].append(LevelType.getLevelType(from: model.r3c5))
//                    gameboard[4].append(LevelType.getLevelType(from: model.r4c5))
//
//                    //Then build the last row
//                    gameboard.append([
//                        LevelType.getLevelType(from: model.r5c0),
//                        LevelType.getLevelType(from: model.r5c1),
//                        LevelType.getLevelType(from: model.r5c2),
//                        LevelType.getLevelType(from: model.r5c3),
//                        LevelType.getLevelType(from: model.r5c4),
//                        LevelType.getLevelType(from: model.r5c5)
//                    ])
//                }
//
//                levels.append(Level(level: model.level, moves: model.moves, gameboard: gameboard))
//            }
//        }
//
//        return levels
//    }()
    
    
    
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
                                               [.gem, .gem, .gem, .gem]]),
        
        Level(level: 10, moves: 9, gameboard: [[.start, .endClosed, .gem],
                                                [.marsh, .marsh, .ice],
                                                [.marsh, .marsh, .ice]]),
        
        Level(level: 11, moves: 3, gameboard: [[.start, .gemOnIce, .gemOnIce, .gemOnIce, .gemOnIce, .gemOnIce],
                                               [.grass, .grass, .grass, .grass, .grass, .gemOnIce],
                                               [.grass, .grass, .grass, .grass, .grass, .gemOnIce],
                                               [.grass, .grass, .grass, .grass, .grass, .gemOnIce],
                                               [.grass, .grass, .grass, .grass, .grass, .gem],
                                               [.grass, .grass, .grass, .grass, .grass, .endClosed]])

    ]
}
