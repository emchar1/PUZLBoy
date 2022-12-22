//
//  AchievementNuclear.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementNuclear: BaseAchievement {
    override func updatePercentage() {
        percentComplete = 100
        print("Percent complete for Nuclear: \(percentComplete)")
    }
}
