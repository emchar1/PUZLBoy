//
//  AchievementOnFire.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementOnFire: BaseAchievement {
    override func updatePercentage() {
        percentComplete = 100
        print("Percent complete for On Fire: \(percentComplete)")
    }
}
