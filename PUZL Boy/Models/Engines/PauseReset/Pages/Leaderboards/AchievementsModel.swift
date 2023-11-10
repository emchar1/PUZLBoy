//
//  AchievementsModel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/8/23.
//

import Foundation

struct AchievementsModel {

    //Achievement Descriptions
    let identifier: String
    let title: String
    let descriptionCompleted: String
    let descriptionNotCompleted: String
    let isHidden: Bool

    //Achievements (reported)
    let percentComplete: Int
    let isCompleted: Bool
    let completionDate: Date?
    
    //Computed Properties
    var imageName: String {
        let idPrefix = "PUZLBoy.Achievement"

        return identifier.replacingOccurrences(of: idPrefix, with: "").lowercased()
    }
    
    var completionDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let dateAcquired: String = completionDate == nil ? "N/A" :  dateFormatter.string(from: completionDate!)
        
        return dateAcquired
    }
}
