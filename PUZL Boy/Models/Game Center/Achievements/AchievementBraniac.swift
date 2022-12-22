//
//  AchievementBraniac.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/22/22.
//

import Foundation

class AchievementBraniac: BaseAchievement {
    override func updatePercentage() {
        percentComplete = 100
        print("Percent complete for Braniac: \(percentComplete)")
    }
}
