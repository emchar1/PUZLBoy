//
//  AchievementBoulderBreaker.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/20/22.
//

import Foundation

class AchievementBoulderBreaker: BaseAchievement {
    let requirement: Double = 20
    
    override func updatePercentage() {
        percentComplete += 1 / requirement * 100
        print("Percent complete for Boulder Breaker: \(percentComplete)")
    }
}
