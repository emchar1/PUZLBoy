//
//  SaveStateModel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/3/23.
//

import Foundation
import FirebaseFirestoreSwift

struct SaveStateModel: Identifiable, Codable {
    @DocumentID public var id: String?
    let saveDate: Date
    let elapsedTime: TimeInterval
    let livesRemaining: Int
    let usedContinue: Bool
    let score: Int
    let totalScore: Int
    let winStreak: Int
    let levelStatsArray: [LevelStats]
    let levelModel: LevelModel
    let newLevel: Int
    let uid: String
}
