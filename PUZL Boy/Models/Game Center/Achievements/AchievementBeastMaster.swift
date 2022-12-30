//
//  AchievementBeastMaster.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementBeastMaster: BaseAchievement {
    let requirement: Double = 100
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Beast Master: \(percentComplete)")
    }
}
