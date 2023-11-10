//
//  AchievementScavenger.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/30/22.
//

import Foundation

class AchievementScavenger: BaseAchievement {
    let requirement: Double = 20

    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Scavenger: \(percentComplete)")
    }
}
