//
//  AchievementPUZLMaster.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/22/22.
//

import Foundation

class AchievementPUZLMaster: BaseAchievement {
    override func updatePercentage() {
        percentComplete = 100
        print("Percent complete for PUZL Master: \(percentComplete)")
    }
}
