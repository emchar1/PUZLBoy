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
    static var levels: [Level] = []
    
    // FIXME: - Need to call this to initialize levels!!! Maybe move this to FIRManager?
    static func getLevels(completion: (() -> ())?) {
        var levels: [Level] = []

        FIRManager.initializeRecords { levelModels in
            for model in levelModels {
                var gameboard: K.Gameboard = []

                //Guaranteed 3x3
                gameboard.append([
                    LevelType.getLevelType(from: model.r0c0),
                    LevelType.getLevelType(from: model.r0c1),
                    LevelType.getLevelType(from: model.r0c2)
                ])
                gameboard.append([
                    LevelType.getLevelType(from: model.r1c0),
                    LevelType.getLevelType(from: model.r1c1),
                    LevelType.getLevelType(from: model.r1c2)
                ])
                gameboard.append([
                    LevelType.getLevelType(from: model.r2c0),
                    LevelType.getLevelType(from: model.r2c1),
                    LevelType.getLevelType(from: model.r2c2)
                ])


                if model.r3c0 != "" {
                    //Complete the previous rows first...
                    gameboard[0].append(LevelType.getLevelType(from: model.r0c3))
                    gameboard[1].append(LevelType.getLevelType(from: model.r1c3))
                    gameboard[2].append(LevelType.getLevelType(from: model.r2c3))

                    //Then build the last row
                    gameboard.append([
                        LevelType.getLevelType(from: model.r3c0),
                        LevelType.getLevelType(from: model.r3c1),
                        LevelType.getLevelType(from: model.r3c2),
                        LevelType.getLevelType(from: model.r3c3)
                    ])
                }

                if model.r4c0 != "" {
                    //Complete the previous rows first...
                    gameboard[0].append(LevelType.getLevelType(from: model.r0c4))
                    gameboard[1].append(LevelType.getLevelType(from: model.r1c4))
                    gameboard[2].append(LevelType.getLevelType(from: model.r2c4))
                    gameboard[3].append(LevelType.getLevelType(from: model.r3c4))

                    //Then build the last row
                    gameboard.append([
                        LevelType.getLevelType(from: model.r4c0),
                        LevelType.getLevelType(from: model.r4c1),
                        LevelType.getLevelType(from: model.r4c2),
                        LevelType.getLevelType(from: model.r4c3),
                        LevelType.getLevelType(from: model.r4c4)
                    ])
                }

                if model.r5c0 != "" {
                    //Complete the previous rows first...
                    gameboard[0].append(LevelType.getLevelType(from: model.r0c5))
                    gameboard[1].append(LevelType.getLevelType(from: model.r1c5))
                    gameboard[2].append(LevelType.getLevelType(from: model.r2c5))
                    gameboard[3].append(LevelType.getLevelType(from: model.r3c5))
                    gameboard[4].append(LevelType.getLevelType(from: model.r4c5))

                    //Then build the last row
                    gameboard.append([
                        LevelType.getLevelType(from: model.r5c0),
                        LevelType.getLevelType(from: model.r5c1),
                        LevelType.getLevelType(from: model.r5c2),
                        LevelType.getLevelType(from: model.r5c3),
                        LevelType.getLevelType(from: model.r5c4),
                        LevelType.getLevelType(from: model.r5c5)
                    ])
                }

                levels.append(Level(level: model.level, moves: model.moves, gameboard: gameboard))
            } //end for model...
            
            LevelBuilder.levels = levels
            completion?()
        }//end FIRManager.initializeRecords()
    }//end getLevels()
}
