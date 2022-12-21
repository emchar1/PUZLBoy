//
//  AchievementDragonSlayer.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/20/22.
//

import GameKit

class AchievementDragonSlayer: BaseAchievement {
    override func updatePercentage() {
        percentComplete += 50
        
        print("percent complete for dragon slayer: \(percentComplete)")
    }
}
