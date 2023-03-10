//
//  AchievementExterminator.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementExterminator: BaseAchievement {
    let requirement: Double = 50

    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Exterminator: \(percentComplete)")
    }
}
