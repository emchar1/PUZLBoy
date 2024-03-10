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
    let decision0: String?
    let decision1: String?
    let decision2: String?
    let decision3: String?
    let elapsedTime: TimeInterval
    let gameCompleted: Bool
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
}
