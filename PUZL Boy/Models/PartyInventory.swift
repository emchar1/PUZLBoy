//
//  PartyInventory.swift
//  PUZL Boy
//
//  Created by Eddie Char on 6/20/23.
//

import Foundation

struct PartyInventory {
    
    // MARK: - Properties
    
    let timeVal: TimeInterval = 5
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
        let multiplier = max(2 * gemsDouble + 3 * gemsTriple, 1)
        
        return gems * multiplier
    }
    
    func getTotalLives() -> Int {
        return lives + getTotalGems() / gemsPerLife
    }
    
    func getRandomItem() -> LevelType {
        let randomizeItem = Int.random(in: 0..<1000)
        var randomItem: LevelType
        
        switch randomizeItem {
        case 0..<20:    randomItem = .partyGemDouble
        case 120..<130: randomItem = .partyGemTriple
        case 230..<235: randomItem = .partyLife
        case 340..<360: randomItem = .partyTime
        default:        randomItem = .partyGem
        }

        return randomItem
    }
    
    func getStatus() {
        print("Gems: \(gems), 2x: \(gemsDouble), 3x: \(gemsTriple), Total Gems: \(getTotalGems()), Lives: \(lives), Total Lives: \(getTotalLives())")
    }
}
