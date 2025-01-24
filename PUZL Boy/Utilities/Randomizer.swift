//
//  Randomizer.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/23/25.
//

import Foundation

struct Randomizer {
    
    // MARK: - Properties
    
    private var randomValue: Int!
    
    
    // MARK: - Initialization
    
    init() {
        randomize()
    }
    
    
    // MARK: - Functions
    
    mutating func randomize(upperBound: Int = 100) {
        randomValue = Int.random(in: 0..<upperBound)
    }
    
    func isMultiple(of mod: Int) -> Bool {
        return randomValue % mod == 0
    }
    
    func isMultiple(of mods: [Int]) -> Bool {
        for mod in mods {
            if isMultiple(of: mod) {
                return true
            }
        }
        
        return false
    }
    
    func getValue() -> Int {
        return randomValue
    }
    
    
}
