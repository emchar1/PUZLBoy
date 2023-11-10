//
//  LevelStats.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/13/23.
//

import Foundation

struct LevelStats: Codable, Equatable, Comparable {
    
    // MARK: - Properties
    
    let level: Int
    let elapsedTime: TimeInterval
    let livesUsed: Int
    let movesRemaining: Int
    let enemiesKilled: Int
    let bouldersBroken: Int
    let score: Int
    let didWin: Bool
    let inventory: Inventory
    
    
    // MARK: - Equatable, Comparable Functions
    
    static func == (lhs: LevelStats, rhs: LevelStats) -> Bool {
        return lhs.level == rhs.level
    }
    
    static func < (lhs: LevelStats, rhs: LevelStats) -> Bool {
        return lhs.level < rhs.level
    }
}
