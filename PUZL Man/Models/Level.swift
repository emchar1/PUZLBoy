//
//  Level.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

/**
 Represents a Level object, with level #, total number of moves, total number of gems needed to finish the level, and the gameboard.
 */
struct Level: CustomStringConvertible {
    
    // MARK: - Properties
    
    private(set) var level: Int
    private(set) var moves: Int
    private(set) var gems: Int
    private(set) var gameboard: [[LevelType]]

    private(set) var player: K.GameboardPosition!
    private(set) var start: K.GameboardPosition!
    private(set) var end: K.GameboardPosition!

    var description: String {
        var returnValue = ""
        
        for row in gameboard {
            for col in row {
                returnValue += "\(col.rawValue), "
            }
            
            returnValue += "\n"
        }
        
        return returnValue
    }
    
    
    // MARK: - Initialization
    
    init(level: Int, moves: Int, gameboard: [[LevelType]]) {
        guard gameboard.count == gameboard[0].count else { fatalError("Gameboard must be of equal rows and columns.") }
        
        var startFound = false
        var endFound = false
        var gemsCount = 0
        
        for (rowIndex, row) in gameboard.enumerated() {
            for (colIndex, col) in row.enumerated() {
                if col == .start {
                    start = (rowIndex, colIndex)
                    player = start
                    startFound = true
                }
                
                if col == .endClosed || col == .endOpen {
                    end = (rowIndex, colIndex)
                    endFound = true
                }
                
                if col == .gem || col == .gemOnIce {
                    gemsCount += 1
                }
            }
        }
        
        guard startFound && endFound else { fatalError("Gameboard must have a start panel and an end panel.") }
        
        self.level = level
        self.moves = moves
        self.gems = gemsCount
        self.gameboard = gameboard
    }
    
    
    // MARK: - Functions
    
    mutating func updatePlayer(position: K.GameboardPosition) {
        player = position
    }
    
    mutating func setLevelType(at position: K.GameboardPosition, levelType: LevelType) {
        gameboard[position.row][position.col] = levelType
    }
    
    func getLevelType(at position: K.GameboardPosition) -> LevelType {
        guard (position.row >= 0 && position.row < gameboard.count) && (position.col >= 0 && position.col < gameboard[0].count) else {
            print("Hit a wall...")
            return .boundary
        }
        
        return gameboard[position.row][position.col]
    }
}
