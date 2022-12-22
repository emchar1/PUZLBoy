//
//  AchievementMyPreciouses.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementMyPreciouses: BaseAchievement {
    let requirement: Double = 1000
    
    override func updatePercentage() {
        percentComplete += 1 / requirement * 100
        print("Percent complete for My Preciouses: \(percentComplete)")
    }
}
