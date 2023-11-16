//
//  AchievementMyPreciouses.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/22.
//

import Foundation

class AchievementMyPreciouses: BaseAchievement {
    let requirement: Double = 3000
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for My Preciouses: \(percentComplete)")
    }
}
