//
//  AchievementSpeedDemon.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/2/23.
//

import Foundation

class AchievementSpeedDemon: BaseAchievement {
    static let levelRequirement: Int = 80
    static let timeRequirement: TimeInterval = 6
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Speed Demon: \(percentComplete)")
    }
}
