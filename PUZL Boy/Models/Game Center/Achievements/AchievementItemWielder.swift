//
//  AchievementItemWielder.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/30/22.
//

import Foundation

class AchievementItemWielder: BaseAchievement {
    let requirement: Double = 80

    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Item Wielder: \(percentComplete)")
    }
}
