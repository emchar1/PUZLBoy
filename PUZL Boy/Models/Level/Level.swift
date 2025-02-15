//
//  Level.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

/**
 Represents a Level object, with level #, total number of moves, total number of gems needed to finish the level, and the gameboard.
 */
struct Level: CustomStringConvertible {
    
    // MARK: - Properties

    //Party time
    static let partyMinLevelRequired: Int = 100
    static let partyFrequency: Int = 50
    static let partyLevel: Int = -1
    static let finalLevel: Int = 500

    private(set) var level: Int
    private(set) var moves: Int
    private(set) var health: Int
    private(set) var gems: Int
    private(set) var hintsAttempt: String
    private(set) var hintsBought: String
    private(set) var hintsSolution: String
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
    
    init(level: Int, moves: Int, health: Int, hintsAttempt: String, hintsBought: String, hintsSolution: String, gameboard: K.Gameboard) {
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
        
        if startFound && endFound {
            //If it's a normal level...
            self.level = level
            self.moves = moves
            self.health = health
            self.gems = gemsCount
            self.hintsAttempt = hintsAttempt
            self.hintsBought = hintsBought
            self.hintsSolution = hintsSolution
            self.gameboard = gameboard
            self.inventory = Inventory(hammers: 0, swords: 0)
            
            //Opens the door initially, if 0 gems are found on the gameboard
            if self.gems == 0 {
                self.gameboard[self.end.row][self.end.col].terrain = .endOpen
            }
        }
        else {
            //Else, it's a party level...
            start = (0, 0)
            player = start
            end = (gameboard.count - 1, gameboard.count - 1)

            self.level = Level.partyLevel
            self.moves = 999
            self.health = 999
            self.gems = 1 //MUST NOT BE 0!!
            self.hintsAttempt = ""
            self.hintsBought = ""
            self.hintsSolution = ""
            self.gameboard = gameboard
            self.inventory = Inventory(hammers: 0, swords: 0)
        }
    }
    
    
    // MARK: - Party Functions
    
    /**
     Checks if a level is a party level or not.
     - parameter level: The level (Int) to check
     - returns: True if it is a party level.
     */
    static func isPartyLevel(_ level: Int) -> Bool {
        return level == partyLevel
    }
    
    /**
     Checks if a level should provide a pill.
     - parameter level: The level (Int) to check
     - returns: True if it is a level that should provide a pill.
     */
    static func shouldProvidePill(_ level: Int) -> Bool {
        return level % partyFrequency == 0 && level < finalLevel && level >= partyMinLevelRequired
    }
    
    
    // MARK: - Functions
    
    mutating func updatePlayer(position: K.GameboardPosition) {
        player = position
    }
    
    mutating func removeOverlayObject(at position: K.GameboardPosition) {
        //.boundary represents non-existent overlay object
        gameboard[position.row][position.col].overlay = .boundary
    }
    
    mutating func setLevelType(at position: K.GameboardPosition, with gameboardPanel: K.GameboardPanel) {
        guard (position.row >= 0 && position.row < gameboard.count) && (position.col >= 0 && position.col < gameboard[0].count) else { return }
        
        gameboard[position.row][position.col] = gameboardPanel
    }
    
    ///Returns the level type for the terrain, or, if it has it, the overlay panel.
    func getLevelType(at position: K.GameboardPosition) -> LevelType {
        guard (position.row >= 0 && position.row < gameboard.count) && (position.col >= 0 && position.col < gameboard[0].count) else { return .boundary }
        
        let check = gameboard[position.row][position.col]
        
        //Only return overlay if there's an item
        return check.overlay == .boundary ? getTerrainType(at: position) : getOverlayType(at: position)
    }
    
    ///Similar to getLevelType(at:), but returns the terrain, always.
    func getTerrainType(at position: K.GameboardPosition) -> LevelType {
        guard (position.row >= 0 && position.row < gameboard.count) && (position.col >= 0 && position.col < gameboard[0].count) else { return .boundary }
        
        return gameboard[position.row][position.col].terrain
    }
    
    ///Similar to getLevelType(at:), but returns the overlay, always.
    func getOverlayType(at position: K.GameboardPosition) -> LevelType {
        guard (position.row >= 0 && position.row < gameboard.count) && (position.col >= 0 && position.col < gameboard[0].count) else { return .boundary }
        
        return gameboard[position.row][position.col].overlay
    }
    
    func getLevelModel(level: Int, movesRemaining: Int, heathRemaining: Int, hintsAttempt: String, hintsBought: String, hintsSolution: String, gemsCollected: Int, gemsRemaining: Int, playerPosition: PlayerPosition, inventory: Inventory) -> LevelModel {
        let gameboardSize = gameboard[0].count

        return LevelModel(
            level: level, moves: movesRemaining, health: heathRemaining, hintsAttempt: hintsAttempt, hintsBought: hintsBought, hintsSolution: hintsSolution, gemsCollected: gemsCollected, gemsRemaining: gemsRemaining,
            playerPosition: playerPosition, inventory: inventory,

            //terrain
            r0c0: gameboard[0][0].terrain.description,
            r0c1: gameboard[0][1].terrain.description,
            r0c2: gameboard[0][2].terrain.description,
            r0c3: gameboardSize <= 3 ? "" : gameboard[0][3].terrain.description,
            r0c4: gameboardSize <= 4 ? "" : gameboard[0][4].terrain.description,
            r0c5: gameboardSize <= 5 ? "" : gameboard[0][5].terrain.description,
            r0c6: gameboardSize <= 6 ? "" : gameboard[0][6].terrain.description,

            r1c0: gameboard[1][0].terrain.description,
            r1c1: gameboard[1][1].terrain.description,
            r1c2: gameboard[1][2].terrain.description,
            r1c3: gameboardSize <= 3 ? "" : gameboard[1][3].terrain.description,
            r1c4: gameboardSize <= 4 ? "" : gameboard[1][4].terrain.description,
            r1c5: gameboardSize <= 5 ? "" : gameboard[1][5].terrain.description,
            r1c6: gameboardSize <= 6 ? "" : gameboard[1][6].terrain.description,

            r2c0: gameboard[2][0].terrain.description,
            r2c1: gameboard[2][1].terrain.description,
            r2c2: gameboard[2][2].terrain.description,
            r2c3: gameboardSize <= 3 ? "" : gameboard[2][3].terrain.description,
            r2c4: gameboardSize <= 4 ? "" : gameboard[2][4].terrain.description,
            r2c5: gameboardSize <= 5 ? "" : gameboard[2][5].terrain.description,
            r2c6: gameboardSize <= 6 ? "" : gameboard[2][6].terrain.description,

            r3c0: gameboardSize <= 3 ? "" : gameboard[3][0].terrain.description,
            r3c1: gameboardSize <= 3 ? "" : gameboard[3][1].terrain.description,
            r3c2: gameboardSize <= 3 ? "" : gameboard[3][2].terrain.description,
            r3c3: gameboardSize <= 3 ? "" : gameboard[3][3].terrain.description,
            r3c4: gameboardSize <= 4 ? "" : gameboard[3][4].terrain.description,
            r3c5: gameboardSize <= 5 ? "" : gameboard[3][5].terrain.description,
            r3c6: gameboardSize <= 6 ? "" : gameboard[3][6].terrain.description,

            r4c0: gameboardSize <= 4 ? "" : gameboard[4][0].terrain.description,
            r4c1: gameboardSize <= 4 ? "" : gameboard[4][1].terrain.description,
            r4c2: gameboardSize <= 4 ? "" : gameboard[4][2].terrain.description,
            r4c3: gameboardSize <= 4 ? "" : gameboard[4][3].terrain.description,
            r4c4: gameboardSize <= 4 ? "" : gameboard[4][4].terrain.description,
            r4c5: gameboardSize <= 5 ? "" : gameboard[4][5].terrain.description,
            r4c6: gameboardSize <= 6 ? "" : gameboard[4][6].terrain.description,

            r5c0: gameboardSize <= 5 ? "" : gameboard[5][0].terrain.description,
            r5c1: gameboardSize <= 5 ? "" : gameboard[5][1].terrain.description,
            r5c2: gameboardSize <= 5 ? "" : gameboard[5][2].terrain.description,
            r5c3: gameboardSize <= 5 ? "" : gameboard[5][3].terrain.description,
            r5c4: gameboardSize <= 5 ? "" : gameboard[5][4].terrain.description,
            r5c5: gameboardSize <= 5 ? "" : gameboard[5][5].terrain.description,
            r5c6: gameboardSize <= 6 ? "" : gameboard[5][6].terrain.description,

            r6c0: gameboardSize <= 6 ? "" : gameboard[6][0].terrain.description,
            r6c1: gameboardSize <= 6 ? "" : gameboard[6][1].terrain.description,
            r6c2: gameboardSize <= 6 ? "" : gameboard[6][2].terrain.description,
            r6c3: gameboardSize <= 6 ? "" : gameboard[6][3].terrain.description,
            r6c4: gameboardSize <= 6 ? "" : gameboard[6][4].terrain.description,
            r6c5: gameboardSize <= 6 ? "" : gameboard[6][5].terrain.description,
            r6c6: gameboardSize <= 6 ? "" : gameboard[6][6].terrain.description,

            //overlay
            s0d0: gameboard[0][0].overlay.description,
            s0d1: gameboard[0][1].overlay.description,
            s0d2: gameboard[0][2].overlay.description,
            s0d3: gameboardSize <= 3 ? "" : gameboard[0][3].overlay.description,
            s0d4: gameboardSize <= 4 ? "" : gameboard[0][4].overlay.description,
            s0d5: gameboardSize <= 5 ? "" : gameboard[0][5].overlay.description,
            s0d6: gameboardSize <= 6 ? "" : gameboard[0][6].overlay.description,

            s1d0: gameboard[1][0].overlay.description,
            s1d1: gameboard[1][1].overlay.description,
            s1d2: gameboard[1][2].overlay.description,
            s1d3: gameboardSize <= 3 ? "" : gameboard[1][3].overlay.description,
            s1d4: gameboardSize <= 4 ? "" : gameboard[1][4].overlay.description,
            s1d5: gameboardSize <= 5 ? "" : gameboard[1][5].overlay.description,
            s1d6: gameboardSize <= 6 ? "" : gameboard[1][6].overlay.description,

            s2d0: gameboard[2][0].overlay.description,
            s2d1: gameboard[2][1].overlay.description,
            s2d2: gameboard[2][2].overlay.description,
            s2d3: gameboardSize <= 3 ? "" : gameboard[2][3].overlay.description,
            s2d4: gameboardSize <= 4 ? "" : gameboard[2][4].overlay.description,
            s2d5: gameboardSize <= 5 ? "" : gameboard[2][5].overlay.description,
            s2d6: gameboardSize <= 6 ? "" : gameboard[2][6].overlay.description,

            s3d0: gameboardSize <= 3 ? "" : gameboard[3][0].overlay.description,
            s3d1: gameboardSize <= 3 ? "" : gameboard[3][1].overlay.description,
            s3d2: gameboardSize <= 3 ? "" : gameboard[3][2].overlay.description,
            s3d3: gameboardSize <= 3 ? "" : gameboard[3][3].overlay.description,
            s3d4: gameboardSize <= 4 ? "" : gameboard[3][4].overlay.description,
            s3d5: gameboardSize <= 5 ? "" : gameboard[3][5].overlay.description,
            s3d6: gameboardSize <= 6 ? "" : gameboard[3][6].overlay.description,

            s4d0: gameboardSize <= 4 ? "" : gameboard[4][0].overlay.description,
            s4d1: gameboardSize <= 4 ? "" : gameboard[4][1].overlay.description,
            s4d2: gameboardSize <= 4 ? "" : gameboard[4][2].overlay.description,
            s4d3: gameboardSize <= 4 ? "" : gameboard[4][3].overlay.description,
            s4d4: gameboardSize <= 4 ? "" : gameboard[4][4].overlay.description,
            s4d5: gameboardSize <= 5 ? "" : gameboard[4][5].overlay.description,
            s4d6: gameboardSize <= 6 ? "" : gameboard[4][6].overlay.description,

            s5d0: gameboardSize <= 5 ? "" : gameboard[5][0].overlay.description,
            s5d1: gameboardSize <= 5 ? "" : gameboard[5][1].overlay.description,
            s5d2: gameboardSize <= 5 ? "" : gameboard[5][2].overlay.description,
            s5d3: gameboardSize <= 5 ? "" : gameboard[5][3].overlay.description,
            s5d4: gameboardSize <= 5 ? "" : gameboard[5][4].overlay.description,
            s5d5: gameboardSize <= 5 ? "" : gameboard[5][5].overlay.description,
            s5d6: gameboardSize <= 6 ? "" : gameboard[5][6].overlay.description,

            s6d0: gameboardSize <= 6 ? "" : gameboard[6][0].overlay.description,
            s6d1: gameboardSize <= 6 ? "" : gameboard[6][1].overlay.description,
            s6d2: gameboardSize <= 6 ? "" : gameboard[6][2].overlay.description,
            s6d3: gameboardSize <= 6 ? "" : gameboard[6][3].overlay.description,
            s6d4: gameboardSize <= 6 ? "" : gameboard[6][4].overlay.description,
            s6d5: gameboardSize <= 6 ? "" : gameboard[6][5].overlay.description,
            s6d6: gameboardSize <= 6 ? "" : gameboard[6][6].overlay.description
        )
    }
}
