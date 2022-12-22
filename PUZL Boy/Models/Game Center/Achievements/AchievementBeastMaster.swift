//
//  AchievementBeastMaster.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementBeastMaster: BaseAchievement {
    let requirement: Double = 50
    
    override func updatePercentage() {
        percentComplete += 1 / requirement * 100
        print("Percent complete for Beast Master: \(percentComplete)")
    }
}
