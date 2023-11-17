//
//  AchievementSuperEfficient.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/1/23.
//

import Foundation

class AchievementSuperEfficient: BaseAchievement {
    let requirement: Double = 30
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for SuperEfficient: \(percentComplete)")
    }
}
