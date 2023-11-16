//
//  AchievementBoulderBreaker.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/20/22.
//

import Foundation

class AchievementBoulderBreaker: BaseAchievement {
    let requirement: Double = 125
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Boulder Breaker: \(percentComplete)")
    }
}
