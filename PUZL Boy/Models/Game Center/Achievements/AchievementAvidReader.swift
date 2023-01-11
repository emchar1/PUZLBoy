//
//  AchievementAvidReader.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/11/23.
//

import Foundation

class AchievementAvidReader: BaseAchievement {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Avid Reader: \(percentComplete)")
    }
}
