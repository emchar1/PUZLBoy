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
    let elapsedTime: TimeInterval
    let hintAvailable: Bool
    let hintCountRemaining: Int
    let levelModel: LevelModel
    let levelStatsArray: [LevelStats]
    let livesRemaining: Int
    let newLevel: Int
    let saveDate: Date
    let score: Int
    let totalScore: Int
    let uid: String
    let usedContinue: Bool
    let winStreak: Int
    let gameCompleted: Bool
}
