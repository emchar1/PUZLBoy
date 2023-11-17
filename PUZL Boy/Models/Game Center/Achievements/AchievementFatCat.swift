//
//  AchievementFatCat.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/4/23.
//

import Foundation

class AchievementFatCat: BaseAchievement {
    let requirement: Double = 20
    
    override func updatePercentage(increment: Double = 0.99) {
        percentComplete += increment / requirement * 100
        print("Percent complete for FatCat: \(percentComplete)")
    }
}
