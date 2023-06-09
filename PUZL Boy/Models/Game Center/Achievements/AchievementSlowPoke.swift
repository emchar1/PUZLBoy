//
//  AchievementSlowPoke.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/2/23.
//

import Foundation

class AchievementSlowPoke: BaseAchievement {
    static let levelRequirement: Int = 80
    static let timeRequirement: TimeInterval = 15 * 60
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Slow Poke: \(percentComplete)")
    }
}
