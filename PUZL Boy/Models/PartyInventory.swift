//
//  PartyInventory.swift
//  PUZL Boy
//
//  Created by Eddie Char on 6/20/23.
//

import Foundation

struct PartyInventory {
    
    // MARK: - Properties
    
    let gemsPerLife = 100
    var gems: Int
    var gemsDouble: Int
    var gemsTriple: Int
    var lives: Int

    
    // MARK: - Initialization
    
    init() {
        gems = 0
        gemsDouble = 0
        gemsTriple = 0
        lives = 0
    }
    
    
    // MARK: - Functions
    
    func getTotalGems() -> Int {
        return gems * (2 * gemsDouble + 3 * gemsTriple)
    }
    
    func getTotalLives() -> Int {
        return getTotalGems() / gemsPerLife
    }
    
    func getRandomItem() -> LevelType {
        let randomizeItem = Int.random(in: 0..<1000)
        var randomItem: LevelType
        
        switch randomizeItem {
        case 0..<20:    randomItem = .partyGemDouble
        case 20..<30:   randomItem = .partyGemTriple
        default:        randomItem = .partyGem
        }

        return randomItem
    }
    
    func getStatus() {
        print("Gems: \(gems), 2x: \(gemsDouble), 3x: \(gemsTriple), Total Gems: \(getTotalGems()), Total Lives: \(getTotalLives())")
    }
}
