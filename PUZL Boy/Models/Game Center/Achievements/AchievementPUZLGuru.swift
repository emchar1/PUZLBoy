//
//  AchievementPUZLGuru.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/22/22.
//

import Foundation

class AchievementPUZLGuru: BaseAchievement {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for PUZL Guru: \(percentComplete)")
    }
}
