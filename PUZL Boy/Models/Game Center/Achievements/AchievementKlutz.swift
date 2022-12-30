//
//  AchievementKlutz.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/22/22.
//

import Foundation

class AchievementKlutz: BaseAchievement {
    let requirement: Double = 100
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Klutz: \(percentComplete)")
    }
}
