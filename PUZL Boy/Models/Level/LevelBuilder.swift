//
//  LevelBuilder.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

/**
 Class with all the possible levels. Also creates the levels, like when first launching the app, in GameViewController.
 */
struct LevelBuilder {
    
    // MARK: - Properties
    
    static var levels: [Level] = []
    static var levelsSize: Int { return levels.count - 1 }
    static let minLevels = 3
    static let maxLevels = 7
    
    
    // MARK: - Functions
    
    static func getLevels(completion: (() -> ())?) {
        var levels: [Level] = []

        FIRManager.initializeLevelRealtimeRecords { levelModels in
            for model in levelModels {
                let gameboard = buildGameboard(levelModel: model)

                levels.append(Level(level: model.level, moves: model.moves, health: model.health, hintsAttempt: model.hintsAttempt, hintsBought: model.hintsBought, hintsSolution: model.hintsSolution, gameboard: gameboard))
            } //end for model...
            
            LevelBuilder.levels = levels
            completion?()
            levels.removeAll()
        }//end FIRManager.initializeLevelRealtimeRecords()
    }//end getLevels()
    
    static func buildGameboard(levelModel model: LevelModel) -> K.Gameboard {
        var gameboard: K.Gameboard = []
        
        //Guaranteed 3x3
        gameboard.append([
            (terrain: getTerrain(model.r0c0), overlay: getOverlay(model.s0d0)),
            (terrain: getTerrain(model.r0c1), overlay: getOverlay(model.s0d1)),
            (terrain: getTerrain(model.r0c2), overlay: getOverlay(model.s0d2))
        ])
        gameboard.append([
            (terrain: getTerrain(model.r1c0), overlay: getOverlay(model.s1d0)),
            (terrain: getTerrain(model.r1c1), overlay: getOverlay(model.s1d1)),
            (terrain: getTerrain(model.r1c2), overlay: getOverlay(model.s1d2))
        ])
        gameboard.append([
            (terrain: getTerrain(model.r2c0), overlay: getOverlay(model.s2d0)),
            (terrain: getTerrain(model.r2c1), overlay: getOverlay(model.s2d1)),
            (terrain: getTerrain(model.r2c2), overlay: getOverlay(model.s2d2))
        ])

        if model.r3c0 != "" {
            //Complete the previous rows first...
            gameboard[0].append((terrain: getTerrain(model.r0c3), overlay: getOverlay(model.s0d3)))
            gameboard[1].append((terrain: getTerrain(model.r1c3), overlay: getOverlay(model.s1d3)))
            gameboard[2].append((terrain: getTerrain(model.r2c3), overlay: getOverlay(model.s2d3)))

            //Then build the last row
            gameboard.append([
                (terrain: getTerrain(model.r3c0), overlay: getOverlay(model.s3d0)),
                (terrain: getTerrain(model.r3c1), overlay: getOverlay(model.s3d1)),
                (terrain: getTerrain(model.r3c2), overlay: getOverlay(model.s3d2)),
                (terrain: getTerrain(model.r3c3), overlay: getOverlay(model.s3d3))
            ])
        }

        if model.r4c0 != "" {
            //Complete the previous rows first...
            gameboard[0].append((terrain: getTerrain(model.r0c4), overlay: getOverlay(model.s0d4)))
            gameboard[1].append((terrain: getTerrain(model.r1c4), overlay: getOverlay(model.s1d4)))
            gameboard[2].append((terrain: getTerrain(model.r2c4), overlay: getOverlay(model.s2d4)))
            gameboard[3].append((terrain: getTerrain(model.r3c4), overlay: getOverlay(model.s3d4)))

            //Then build the last row
            gameboard.append([
                (terrain: getTerrain(model.r4c0), overlay: getOverlay(model.s4d0)),
                (terrain: getTerrain(model.r4c1), overlay: getOverlay(model.s4d1)),
                (terrain: getTerrain(model.r4c2), overlay: getOverlay(model.s4d2)),
                (terrain: getTerrain(model.r4c3), overlay: getOverlay(model.s4d3)),
                (terrain: getTerrain(model.r4c4), overlay: getOverlay(model.s4d4))
            ])
        }

        if model.r5c0 != "" {
            //Complete the previous rows first...
            gameboard[0].append((terrain: getTerrain(model.r0c5), overlay: getOverlay(model.s0d5)))
            gameboard[1].append((terrain: getTerrain(model.r1c5), overlay: getOverlay(model.s1d5)))
            gameboard[2].append((terrain: getTerrain(model.r2c5), overlay: getOverlay(model.s2d5)))
            gameboard[3].append((terrain: getTerrain(model.r3c5), overlay: getOverlay(model.s3d5)))
            gameboard[4].append((terrain: getTerrain(model.r4c5), overlay: getOverlay(model.s4d5)))

            //Then build the last row
            gameboard.append([
                (terrain: getTerrain(model.r5c0), overlay: getOverlay(model.s5d0)),
                (terrain: getTerrain(model.r5c1), overlay: getOverlay(model.s5d1)),
                (terrain: getTerrain(model.r5c2), overlay: getOverlay(model.s5d2)),
                (terrain: getTerrain(model.r5c3), overlay: getOverlay(model.s5d3)),
                (terrain: getTerrain(model.r5c4), overlay: getOverlay(model.s5d4)),
                (terrain: getTerrain(model.r5c5), overlay: getOverlay(model.s5d5))
            ])
        }
        
        if model.r6c0 != "" {
            //Complete the previous rows first...
            gameboard[0].append((terrain: getTerrain(model.r0c6), overlay: getOverlay(model.s0d6)))
            gameboard[1].append((terrain: getTerrain(model.r1c6), overlay: getOverlay(model.s1d6)))
            gameboard[2].append((terrain: getTerrain(model.r2c6), overlay: getOverlay(model.s2d6)))
            gameboard[3].append((terrain: getTerrain(model.r3c6), overlay: getOverlay(model.s3d6)))
            gameboard[4].append((terrain: getTerrain(model.r4c6), overlay: getOverlay(model.s4d6)))
            gameboard[5].append((terrain: getTerrain(model.r5c6), overlay: getOverlay(model.s5d6)))

            //Then build the last row
            gameboard.append([
                (terrain: getTerrain(model.r6c0), overlay: getOverlay(model.s6d0)),
                (terrain: getTerrain(model.r6c1), overlay: getOverlay(model.s6d1)),
                (terrain: getTerrain(model.r6c2), overlay: getOverlay(model.s6d2)),
                (terrain: getTerrain(model.r6c3), overlay: getOverlay(model.s6d3)),
                (terrain: getTerrain(model.r6c4), overlay: getOverlay(model.s6d4)),
                (terrain: getTerrain(model.r6c5), overlay: getOverlay(model.s6d5)),
                (terrain: getTerrain(model.r6c6), overlay: getOverlay(model.s6d6))
            ])
        }
        
        return gameboard
    } //end buildGameboard()
    
    /**
     Helper function that adds the terrain panel.
     - parameter levelTypeString: the terrain panel read in from the Excel Import file
     - returns: the LevelType terrain panel
     */
    private static func getTerrain(_ levelTypeString: String) -> LevelType {
        return getPanel(levelTypeString)
    }
    
    /**
     Helper function that adds the overlay panel.
     - parameter levelTypeString: the overlay panel read in from the Excel Import file
     - returns: the LevelType overlay panel
     */
    private static func getOverlay(_ levelTypeString: String) -> LevelType {
        return getPanel(levelTypeString)
    }
    
    /**
     Helper function that adds the terrain or overlay panel. This function does not differentiate, and will return whatever panel (terrain or overlay) is read in.
     - parameter levelType: the terrain (or overlay) panel read in from the Excel Import file
     - returns: the LevelType terrain (or overlay) panel
     */
    private static func getPanel(_ levelType: String) -> LevelType {
        return LevelType.getLevelType(from: levelType)
    }
    
    ///Builds a party gameboard with all party tiles.
    static func buildPartyGameboard(ofSize size: Int = minLevels) -> K.Gameboard {
        let sizeAdjusted = size.clamp(min: minLevels, max: maxLevels)
        let partyPanel: K.GameboardPanel = (terrain: .partytile, overlay: .boundary)
        var gameboard: K.Gameboard = []
        
        //Guaranteed 3x3
        for _ in 0..<3 {
            gameboard.append([partyPanel, partyPanel, partyPanel])
        }

        //size == 4
        if sizeAdjusted > 3 {
            for i in 0..<3 {
                gameboard[i].append(partyPanel)
            }

            gameboard.append([partyPanel, partyPanel, partyPanel, partyPanel])
        }

        //size == 5
        if sizeAdjusted > 4 {
            for i in 0..<4 {
                gameboard[i].append(partyPanel)
            }

            gameboard.append([partyPanel, partyPanel, partyPanel, partyPanel, partyPanel])
        }

        //size == 6
        if sizeAdjusted > 5 {
            for i in 0..<5 {
                gameboard[i].append(partyPanel)
            }

            gameboard.append([partyPanel, partyPanel, partyPanel, partyPanel, partyPanel, partyPanel])
        }

        //size == 7
        if sizeAdjusted > 6 {
            for i in 0..<6 {
                gameboard[i].append(partyPanel)
            }

            gameboard.append([partyPanel, partyPanel, partyPanel, partyPanel, partyPanel, partyPanel, partyPanel])
        }

        return gameboard
    }
    
    
}
