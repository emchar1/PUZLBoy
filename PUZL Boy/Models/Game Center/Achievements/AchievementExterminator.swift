//
//  AchievementExterminator.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementExterminator: BaseAchievement {
    let requirement: Double = 10

    override func updatePercentage() {
        percentComplete += 1 / requirement * 100
        print("Percent complete for Exterminator: \(percentComplete)")
    }
}
