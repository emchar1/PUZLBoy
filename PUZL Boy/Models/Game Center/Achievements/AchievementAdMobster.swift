//
//  AchievementAdMobster.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/16/23.
//

import Foundation

class AchievementAdMobster: BaseAchievement {
    let requirement: Double = 50
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for AdMobster: \(percentComplete)")
    }
}
