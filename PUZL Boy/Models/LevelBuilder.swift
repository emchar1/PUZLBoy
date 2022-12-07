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
                    (terrain: LevelType.getLevelType(from: model.r0c0), overlay: LevelType.getLevelType(from: model.s0d0)),
                    (terrain: LevelType.getLevelType(from: model.r0c1), overlay: LevelType.getLevelType(from: model.s0d1)),
                    (terrain: LevelType.getLevelType(from: model.r0c2), overlay: LevelType.getLevelType(from: model.s0d2))
                ])
                gameboard.append([
                    (terrain: LevelType.getLevelType(from: model.r1c0), overlay: LevelType.getLevelType(from: model.s1d0)),
                    (terrain: LevelType.getLevelType(from: model.r1c1), overlay: LevelType.getLevelType(from: model.s1d1)),
                    (terrain: LevelType.getLevelType(from: model.r1c2), overlay: LevelType.getLevelType(from: model.s1d2))
                ])
                gameboard.append([
                    (terrain: LevelType.getLevelType(from: model.r2c0), overlay: LevelType.getLevelType(from: model.s2d0)),
                    (terrain: LevelType.getLevelType(from: model.r2c1), overlay: LevelType.getLevelType(from: model.s2d1)),
                    (terrain: LevelType.getLevelType(from: model.r2c2), overlay: LevelType.getLevelType(from: model.s2d2))
                ])


                if model.r3c0 != "" {
                    //Complete the previous rows first...
                    gameboard[0].append((terrain: LevelType.getLevelType(from: model.r0c3), overlay: LevelType.getLevelType(from: model.s0d3)))
                    gameboard[1].append((terrain: LevelType.getLevelType(from: model.r1c3), overlay: LevelType.getLevelType(from: model.s1d3)))
                    gameboard[2].append((terrain: LevelType.getLevelType(from: model.r2c3), overlay: LevelType.getLevelType(from: model.s2d3)))

                    //Then build the last row
                    gameboard.append([
                        (terrain: LevelType.getLevelType(from: model.r3c0), overlay: LevelType.getLevelType(from: model.s3d0)),
                        (terrain: LevelType.getLevelType(from: model.r3c1), overlay: LevelType.getLevelType(from: model.s3d1)),
                        (terrain: LevelType.getLevelType(from: model.r3c2), overlay: LevelType.getLevelType(from: model.s3d2)),
                        (terrain: LevelType.getLevelType(from: model.r3c3), overlay: LevelType.getLevelType(from: model.s3d3))
                    ])
                }

                if model.r4c0 != "" {
                    //Complete the previous rows first...
                    gameboard[0].append((terrain: LevelType.getLevelType(from: model.r0c4), overlay: LevelType.getLevelType(from: model.s0d4)))
                    gameboard[1].append((terrain: LevelType.getLevelType(from: model.r1c4), overlay: LevelType.getLevelType(from: model.s1d4)))
                    gameboard[2].append((terrain: LevelType.getLevelType(from: model.r2c4), overlay: LevelType.getLevelType(from: model.s2d4)))
                    gameboard[3].append((terrain: LevelType.getLevelType(from: model.r3c4), overlay: LevelType.getLevelType(from: model.s3d4)))

                    //Then build the last row
                    gameboard.append([
                        (terrain: LevelType.getLevelType(from: model.r4c0), overlay: LevelType.getLevelType(from: model.s4d0)),
                        (terrain: LevelType.getLevelType(from: model.r4c1), overlay: LevelType.getLevelType(from: model.s4d1)),
                        (terrain: LevelType.getLevelType(from: model.r4c2), overlay: LevelType.getLevelType(from: model.s4d2)),
                        (terrain: LevelType.getLevelType(from: model.r4c3), overlay: LevelType.getLevelType(from: model.s4d3)),
                        (terrain: LevelType.getLevelType(from: model.r4c4), overlay: LevelType.getLevelType(from: model.s4d4))
                    ])
                }

                if model.r5c0 != "" {
                    //Complete the previous rows first...
                    gameboard[0].append((terrain: LevelType.getLevelType(from: model.r0c5), overlay: LevelType.getLevelType(from: model.s0d5)))
                    gameboard[1].append((terrain: LevelType.getLevelType(from: model.r1c5), overlay: LevelType.getLevelType(from: model.s1d5)))
                    gameboard[2].append((terrain: LevelType.getLevelType(from: model.r2c5), overlay: LevelType.getLevelType(from: model.s2d5)))
                    gameboard[3].append((terrain: LevelType.getLevelType(from: model.r3c5), overlay: LevelType.getLevelType(from: model.s3d5)))
                    gameboard[4].append((terrain: LevelType.getLevelType(from: model.r4c5), overlay: LevelType.getLevelType(from: model.s4d5)))

                    //Then build the last row
                    gameboard.append([
                        (terrain: LevelType.getLevelType(from: model.r5c0), overlay: LevelType.getLevelType(from: model.s5d0)),
                        (terrain: LevelType.getLevelType(from: model.r5c1), overlay: LevelType.getLevelType(from: model.s5d1)),
                        (terrain: LevelType.getLevelType(from: model.r5c2), overlay: LevelType.getLevelType(from: model.s5d2)),
                        (terrain: LevelType.getLevelType(from: model.r5c3), overlay: LevelType.getLevelType(from: model.s5d3)),
                        (terrain: LevelType.getLevelType(from: model.r5c4), overlay: LevelType.getLevelType(from: model.s5d4)),
                        (terrain: LevelType.getLevelType(from: model.r5c5), overlay: LevelType.getLevelType(from: model.s5d5))
                    ])
                }

                levels.append(Level(level: model.level, moves: model.moves, gameboard: gameboard))
            } //end for model...
            
            LevelBuilder.levels = levels
            completion?()
        }//end FIRManager.initializeRecords()
    }//end getLevels()
}
