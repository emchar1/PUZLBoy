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
    
    ///Returns the total lives earned during the party level round, with a minimum of 1 life possible earned.
    func getTotalLives() -> Int {
        return max(1, lives + getTotalGems() / gemsPerLife)
    }
    
    func getRandomItem() -> LevelType {
        let randomizeItem = Int.random(in: 0..<1000)
        var randomItem: LevelType
        
        switch randomizeItem {
        case 100..<120: randomItem = .partyGemDouble
        case 220..<230: randomItem = .partyGemTriple
        case 330..<335: randomItem = .partyLife
        case 440..<475: randomItem = .partyTime
        case 520..<580: randomItem = .partyFast
        case 630..<690: randomItem = .partySlow
        default:        randomItem = .partyGem
        }

        return randomItem
    }
    
    func getStatus() {
        print("Gems: \(gems), 2x: \(gemsDouble), 3x: \(gemsTriple), Total Gems: \(getTotalGems()), Lives: \(lives), Total Lives: \(getTotalLives())")
    }
}
