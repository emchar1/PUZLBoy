//
//  AchievementsModel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/8/23.
//

import Foundation

struct AchievementsModel {
    let identifier: String
    let title: String
    let descriptionCompleted: String
    let descriptionNotCompleted: String
    let percentComplete: Int
    let isCompleted: Bool
    let completionDate: Date?
    
    var imageName: String {
        let idPrefix = "PUZLBoy.Achievement"

        return identifier.replacingOccurrences(of: idPrefix, with: "").lowercased()
    }
}
