//
//  ScoringManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/21/23.
//

import Foundation

class ScoringManager {
    
    // MARK: - Properties
    
    private(set) var score = 0
    private(set) var totalScore = 0

    
    // MARK: - Functions
    
    init(score: Int = 0, totalScore: Int = 0) {
        self.score = score
        self.totalScore = totalScore
    }
    
    func addToScore(_ score: Int) {
        self.score += score
    }
    
    func setScore(_ score: Int) {
        self.score = score
    }

    func resetScore() {
        score = 0
    }
    
    func balanceScores() {
        score -= 1
        totalScore += 1
    }
}
