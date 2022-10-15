//
//  GameEngine.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/9/22.
//

import UIKit

class GameEngine {
    var movesUsed: Int = 0
    var movesTotal: Int
    var level: Int
    var isGameOver: Bool { movesUsed >= movesTotal }
    

    init(movesTotal: Int, level: Int) {
        self.movesTotal = movesTotal
        self.level = level
    }
    
    func incrementMovesUsed(by amount: Int = 1) {
        guard !isGameOver else { return print("Game Over buddy") }
        
        movesUsed += amount
    }
}
