//
//  Level.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/1/22.
//

import Foundation

enum LevelType: Int {
    case start = -2, end, gem //required panels
    case grass, marsh, ice //terrain panels
    case hammer, sword //tool panels
    case boulder, enemy, warp //special panels
}


class Level: CustomStringConvertible {
    
    // MARK: - Properties
    
    typealias Position = (row: Int, col: Int)
    
    var level: Int
    var moves: Int
    var gems: Int
    var gameboard: [[LevelType]]

    var player: Position!
    var start: Position!
    var end: Position!

    var isSolved: Bool {
        return gems <= 0
    }
    
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
    
    init(level: Int, moves: Int, gems: Int, gameboard: [[LevelType]]) {
        guard gameboard.count == gameboard[0].count else { fatalError("Gameboard must be of equal rows and columns.") }
        
        var startFound = false
        var endFound = false
        
        for (rowIndex, row) in gameboard.enumerated() {
            for (colIndex, col) in row.enumerated() {
                if col == .start {
                    start = (rowIndex, colIndex)
                    player = start
                    startFound = true
                }
                
                if col == .end {
                    end = (rowIndex, colIndex)
                    endFound = true
                }
            }
        }
        
        guard startFound && endFound else { fatalError("Gameboard must have a start panel and an end panel.") }
        
        self.level = level
        self.moves = moves
        self.gems = gems
        self.gameboard = gameboard
    }
    
    
    // MARK: - Functions
    
//    func setPanel(with type: LevelType, at cell: Position) {
//        guard cell.row < gameboard.count && cell.col < gameboard[0].count else { return print("Array out of bounds") }
//
//        gameboard[cell.row][cell.col] = type
//    }
}
