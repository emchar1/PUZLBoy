//
//  AchievementRockNRoller.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementRockNRoller: BaseAchievement {
    let requirement: Double = 450
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Rock n Roller: \(percentComplete)")
    }
}
