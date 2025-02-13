//
//  DuplicateItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/12/25.
//

import Foundation

struct DuplicateItem {
    
    // MARK: - Properties
    
    static var spawnedItems: [LevelType] = []
    
    
    // MARK: - Initialization
    
    
    // MARK: - Functions
    
    /**
     Call this function once, once the chosenSword has been selected!
     */
    static func populateSpawnedItems(count: Int, luck: CGFloat) {
        spawnedItems = (
            Array(repeating: .sword, count: Int(0.25 * CGFloat(count)))
            + Array(repeating: .hammer, count: Int(0.2 * CGFloat(count)))
            + Array(repeating: .gem, count: Int(0.4 * CGFloat(count)))
            + Array(repeating: .partyFast, count: Int(0.1 * CGFloat(count)))
            + Array(repeating: .partySlow, count: Int(0.05 * CGFloat(count)))
        ).shuffled()
    }
    
}
