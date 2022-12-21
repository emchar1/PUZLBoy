//
//  AchievementBoulderBreaker.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/20/22.
//

import GameKit

class AchievementBoulderBreaker: BaseAchievement {
    override func updatePercentage() {
        percentComplete += 50
        
        print("percent complete for boulder breaker: \(percentComplete)")
    }
}
