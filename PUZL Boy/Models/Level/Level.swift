//
//  Level.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

// FIXME: - Don't scroll down to the bottom (getLevelModel()) it lags...

/**
 Represents a Level object, with level #, total number of moves, total number of gems needed to finish the level, and the gameboard.
 */
struct Level: CustomStringConvertible {
    
    // MARK: - Properties
    
    private(set) var level: Int
    private(set) var moves: Int
    private(set) var health: Int
    private(set) var gems: Int
    private(set) var gameboard: K.Gameboard
    var inventory: Inventory

    private(set) var player: K.GameboardPosition!
    private(set) var start: K.GameboardPosition!
    private(set) var end: K.GameboardPosition!

    var description: String {
        var returnValue = "\nlevel: \(level), health: \(health), moves: \(moves), gems: \(gems), inventory: \(inventory), gameboard:\n"
        
        for row in gameboard {
            returnValue += "\t["
            
            for col in row {
                returnValue += "\(col.terrain.rawValue), "
            }
            
            returnValue += "]\n"
        }
        
        return returnValue
    }
    
    
    // MARK: - Initialization
    
    init(level: Int, moves: Int, health: Int, gameboard: K.Gameboard) {
        guard gameboard.count == gameboard[0].count else { fatalError("Gameboard must be of equal rows and columns.") }
        
        var startFound = false
        var endFound = false
        var gemsCount = 0
        
        for (rowIndex, row) in gameboard.enumerated() {
            for (colIndex, col) in row.enumerated() {
                if col.terrain == .start {
                    start = (rowIndex, colIndex)
                    player = start
                    startFound = true
                }
                
                if col.terrain == .endClosed || col.terrain == .endOpen {
                    end = (rowIndex, colIndex)
                    endFound = true
                }
                
                if col.overlay == .gem {
                    gemsCount += 1
                }
            }
        }
        
        guard startFound && endFound else { fatalError("Gameboard must have a start panel and an end panel.") }
        
        self.level = level
        self.moves = moves
        self.health = health
        self.gems = gemsCount
        self.gameboard = gameboard
        self.inventory = Inventory(hammers: 0, swords: 0)

        //Opens the door initially, if 0 gems are found on the gameboard
        if self.gems == 0 {
            self.gameboard[self.end.row][self.end.col].terrain = .endOpen
        }
    }
    
    
    // MARK: - Functions
    
    mutating func updatePlayer(position: K.GameboardPosition) {
        player = position
    }
    
    mutating func removeOverlayObject(at position: K.GameboardPosition) {
        // FIXME: - Is .boundary the right way to represent non-existent overlay object?
        gameboard[position.row][position.col].overlay = .boundary
    }
    
    mutating func setLevelType(at position: K.GameboardPosition, with gameboardPanel: K.GameboardPanel) {
        guard (position.row >= 0 && position.row < gameboard.count) && (position.col >= 0 && position.col < gameboard[0].count) else { return }
        
        gameboard[position.row][position.col] = gameboardPanel
    }
    
    func getLevelType(at position: K.GameboardPosition) -> LevelType {
        guard (position.row >= 0 && position.row < gameboard.count) && (position.col >= 0 && position.col < gameboard[0].count) else { return .boundary }
        
        let check = gameboard[position.row][position.col]
        
        //Only return overlay if there's an item
        return check.overlay == .boundary ? check.terrain : check.overlay
    }
    
    
    // FIXME: - I REALLY HATE HOW SLOW AND INEFFICIENT THIS IS!!!
    func getLevelModel(level: Int, movesRemaining: Int, heathRemaining: Int, gemsCollected: Int, gemsRemaining: Int, playerPosition: PlayerPosition, inventory: Inventory) -> LevelModel {
        let gameboardSize = gameboard[0].count

        return LevelModel(
            level: level, moves: movesRemaining, health: heathRemaining, gemsCollected: gemsCollected, gemsRemaining: gemsRemaining,
            playerPosition: playerPosition, inventory: inventory,

            //terrain
            r0c0: gameboard[0][0].terrain.description,
            r0c1: gameboard[0][1].terrain.description,
            r0c2: gameboard[0][2].terrain.description,
            r0c3: gameboardSize <= 3 ? "" : gameboard[0][3].terrain.description,
            r0c4: gameboardSize <= 4 ? "" : gameboard[0][4].terrain.description,
            r0c5: gameboardSize <= 5 ? "" : gameboard[0][5].terrain.description,

            r1c0: gameboard[1][0].terrain.description,
            r1c1: gameboard[1][1].terrain.description,
            r1c2: gameboard[1][2].terrain.description,
            r1c3: gameboardSize <= 3 ? "" : gameboard[1][3].terrain.description,
            r1c4: gameboardSize <= 4 ? "" : gameboard[1][4].terrain.description,
            r1c5: gameboardSize <= 5 ? "" : gameboard[1][5].terrain.description,

            r2c0: gameboard[2][0].terrain.description,
            r2c1: gameboard[2][1].terrain.description,
            r2c2: gameboard[2][2].terrain.description,
            r2c3: gameboardSize <= 3 ? "" : gameboard[2][3].terrain.description,
            r2c4: gameboardSize <= 4 ? "" : gameboard[2][4].terrain.description,
            r2c5: gameboardSize <= 5 ? "" : gameboard[2][5].terrain.description,

            r3c0: gameboardSize <= 3 ? "" : gameboard[3][0].terrain.description,
            r3c1: gameboardSize <= 3 ? "" : gameboard[3][1].terrain.description,
            r3c2: gameboardSize <= 3 ? "" : gameboard[3][2].terrain.description,
            r3c3: gameboardSize <= 3 ? "" : gameboard[3][3].terrain.description,
            r3c4: gameboardSize <= 4 ? "" : gameboard[3][4].terrain.description,
            r3c5: gameboardSize <= 5 ? "" : gameboard[3][5].terrain.description,

            r4c0: gameboardSize <= 4 ? "" : gameboard[4][0].terrain.description,
            r4c1: gameboardSize <= 4 ? "" : gameboard[4][1].terrain.description,
            r4c2: gameboardSize <= 4 ? "" : gameboard[4][2].terrain.description,
            r4c3: gameboardSize <= 4 ? "" : gameboard[4][3].terrain.description,
            r4c4: gameboardSize <= 4 ? "" : gameboard[4][4].terrain.description,
            r4c5: gameboardSize <= 5 ? "" : gameboard[4][5].terrain.description,

            r5c0: gameboardSize <= 5 ? "" : gameboard[5][0].terrain.description,
            r5c1: gameboardSize <= 5 ? "" : gameboard[5][1].terrain.description,
            r5c2: gameboardSize <= 5 ? "" : gameboard[5][2].terrain.description,
            r5c3: gameboardSize <= 5 ? "" : gameboard[5][3].terrain.description,
            r5c4: gameboardSize <= 5 ? "" : gameboard[5][4].terrain.description,
            r5c5: gameboardSize <= 5 ? "" : gameboard[5][5].terrain.description,

            //overlay
            s0d0: gameboard[0][0].overlay.description,
            s0d1: gameboard[0][1].overlay.description,
            s0d2: gameboard[0][2].overlay.description,
            s0d3: gameboardSize <= 3 ? "" : gameboard[0][3].overlay.description,
            s0d4: gameboardSize <= 4 ? "" : gameboard[0][4].overlay.description,
            s0d5: gameboardSize <= 5 ? "" : gameboard[0][5].overlay.description,

            s1d0: gameboard[1][0].overlay.description,
            s1d1: gameboard[1][1].overlay.description,
            s1d2: gameboard[1][2].overlay.description,
            s1d3: gameboardSize <= 3 ? "" : gameboard[1][3].overlay.description,
            s1d4: gameboardSize <= 4 ? "" : gameboard[1][4].overlay.description,
            s1d5: gameboardSize <= 5 ? "" : gameboard[1][5].overlay.description,

            s2d0: gameboard[2][0].overlay.description,
            s2d1: gameboard[2][1].overlay.description,
            s2d2: gameboard[2][2].overlay.description,
            s2d3: gameboardSize <= 3 ? "" : gameboard[2][3].overlay.description,
            s2d4: gameboardSize <= 4 ? "" : gameboard[2][4].overlay.description,
            s2d5: gameboardSize <= 5 ? "" : gameboard[2][5].overlay.description,

            s3d0: gameboardSize <= 3 ? "" : gameboard[3][0].overlay.description,
            s3d1: gameboardSize <= 3 ? "" : gameboard[3][1].overlay.description,
            s3d2: gameboardSize <= 3 ? "" : gameboard[3][2].overlay.description,
            s3d3: gameboardSize <= 3 ? "" : gameboard[3][3].overlay.description,
            s3d4: gameboardSize <= 4 ? "" : gameboard[3][4].overlay.description,
            s3d5: gameboardSize <= 5 ? "" : gameboard[3][5].overlay.description,

            s4d0: gameboardSize <= 4 ? "" : gameboard[4][0].overlay.description,
            s4d1: gameboardSize <= 4 ? "" : gameboard[4][1].overlay.description,
            s4d2: gameboardSize <= 4 ? "" : gameboard[4][2].overlay.description,
            s4d3: gameboardSize <= 4 ? "" : gameboard[4][3].overlay.description,
            s4d4: gameboardSize <= 4 ? "" : gameboard[4][4].overlay.description,
            s4d5: gameboardSize <= 5 ? "" : gameboard[4][5].overlay.description,

            s5d0: gameboardSize <= 5 ? "" : gameboard[5][0].overlay.description,
            s5d1: gameboardSize <= 5 ? "" : gameboard[5][1].overlay.description,
            s5d2: gameboardSize <= 5 ? "" : gameboard[5][2].overlay.description,
            s5d3: gameboardSize <= 5 ? "" : gameboard[5][3].overlay.description,
            s5d4: gameboardSize <= 5 ? "" : gameboard[5][4].overlay.description,
            s5d5: gameboardSize <= 5 ? "" : gameboard[5][5].overlay.description
        )
    }
}
