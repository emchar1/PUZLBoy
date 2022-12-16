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
    
    private(set) var level: Int
    private(set) var moves: Int
    private(set) var gems: Int
    private(set) var gameboard: K.Gameboard

    private(set) var player: K.GameboardPosition!
    private(set) var start: K.GameboardPosition!
    private(set) var end: K.GameboardPosition!

    var description: String {
        var returnValue = "\nlevel: \(level), moves: \(moves), gems: \(gems), gameboard:\n"
        
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
    
    init(level: Int, moves: Int, gameboard: K.Gameboard) {
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
        self.gems = gemsCount
        self.gameboard = gameboard

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
}
