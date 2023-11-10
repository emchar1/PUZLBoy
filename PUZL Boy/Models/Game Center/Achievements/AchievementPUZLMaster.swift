//
//  AchievementPUZLMaster.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/4/23.
//

import Foundation

class AchievementPUZLMaster: BaseAchievement {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for PUZL Master: \(percentComplete)")
    }
}
