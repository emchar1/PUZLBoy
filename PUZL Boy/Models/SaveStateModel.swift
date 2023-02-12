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
    let gemsRemaining: Int
    let gemsCollected: Int
    let winStreak: Int
    let inventory: Inventory
    let playerPosition: PlayerPosition
    let levelModel: LevelModel
    let newLevel: Int
    let uid: String
}

//K.GameboardPosition can't be codable due to it being a tuple, so I need a separate struct here.
struct PlayerPosition: Codable {
    let row: Int
    let col: Int
}
