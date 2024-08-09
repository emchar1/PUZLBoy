//
//  AchievementHoarder.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/30/22.
//

import Foundation

class AchievementHoarder: BaseAchievement {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Hoarder: \(percentComplete)")
    }
}
