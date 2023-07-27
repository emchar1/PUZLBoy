//
//  PartyInventory.swift
//  PUZL Boy
//
//  Created by Eddie Char on 6/20/23.
//

import Foundation

struct PartyInventory {
    
    // MARK: - Properties
    
    //Shared properties
    static let timeIncrement: TimeInterval = 5
    static let gemsPerLife = 100
    
    //Items
    var gems: Int
    var gemsDouble: Int
    var gemsTriple: Int
    var time: Int
    var speedUp: Int
    var speedDown: Int
    var lives: Int
    
    //Misc properties
    private var panelCount: Int
    private(set) var spawnDelayDuration: TimeInterval
    private(set) var itemWaitDuration: TimeInterval
    
    var randomizePosition: K.GameboardPosition {
        (row: Int.random(in: 0..<panelCount), col: Int.random(in: 0..<panelCount))
    }

    
    // MARK: - Initialization
    
    init(panelCount: Int = 3) {
        gems = 0
        gemsDouble = 0
        gemsTriple = 0
        time = 0
        speedUp = 0
        speedDown = 0
        lives = 0
        
        self.panelCount = panelCount
        
        switch panelCount {
        case 6:
            spawnDelayDuration = 0.2
            itemWaitDuration = 3
        case 5:
            spawnDelayDuration = 0.3
            itemWaitDuration = 3
        case 4:
            spawnDelayDuration = 0.4
            itemWaitDuration = 2.5
        default: //gameboardSize = 3
            spawnDelayDuration = 0.6
            itemWaitDuration = 2
        }
    }
    
    
    // MARK: - Functions
    
    func getTotalGems() -> Int {
        let multiplier = max(2 * gemsDouble + 3 * gemsTriple, 1)
        
        return gems * multiplier
    }
    
    ///Returns the total lives earned during the party level round, with a minimum of 1 life possible earned.
    func getTotalLives() -> Int {
        return max(1, lives + getTotalGems() / PartyInventory.gemsPerLife)
    }
    
    func getRandomItem() -> LevelType {
        let randomizeItem = Int.random(in: 0..<1000)
        var randomItem: LevelType
        var bombRange: Range<Int>
        
        switch panelCount {
        case 4:     bombRange = 800..<825
        case 5:     bombRange = 800..<900
        case 6:     bombRange = 800..<1000
        default:    bombRange = 800..<825
        }
        
        switch randomizeItem {
        case 100..<120:
            randomItem = .partyGemDouble
        case 220..<230:
            randomItem = .partyGemTriple
        case 330..<335:
            randomItem = .partyLife
        case 440..<460:
            randomItem = .partyTime
        case (panelCount <= 4 ? 520..<580 : 520..<560):
            randomItem = .partyFast
        case (panelCount <= 4 ? 630..<700 : 600..<700):
            randomItem = .partySlow
        case bombRange:
            randomItem = .partyBomb
        default:
            randomItem = .partyGem
        }

        return randomItem
    }
    
    func getStatus() {
        print("Gems: \(gems), 2x: \(gemsDouble), 3x: \(gemsTriple), Total Gems: \(getTotalGems()) | Time: \(time), Speed+: \(speedUp), Speed-: \(speedDown) | 1-UP: \(lives), Total Lives: \(getTotalLives())")
    }
}
