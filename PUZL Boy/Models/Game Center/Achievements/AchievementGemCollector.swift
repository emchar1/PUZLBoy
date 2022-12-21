//
//  AchievementGemCollector.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import GameKit

class AchievementGemCollector: BaseAchievement {
    override func updatePercentage() {
        percentComplete += 50
        
        print("percent complete for gem collector: \(percentComplete)")
    }
}
