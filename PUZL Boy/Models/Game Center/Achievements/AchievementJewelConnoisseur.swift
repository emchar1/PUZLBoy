//
//  AchievementJewelConnoisseur.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementJewelConnoisseur: BaseAchievement {
    let requirement: Double = 250
    
    override func updatePercentage() {
        percentComplete += 1 / requirement * 100
        print("Percent complete for Jewel Connoisseur: \(percentComplete)")
    }
}
