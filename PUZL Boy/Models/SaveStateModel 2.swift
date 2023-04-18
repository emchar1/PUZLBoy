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
    let saveDate: Date
    let level: Int
    let livesRemaining: Int
    let totalScore: Int
    let uid: String
}
