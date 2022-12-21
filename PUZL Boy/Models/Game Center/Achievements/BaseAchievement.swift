//
//  BaseAchievement.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/20/22.
//

import GameKit

class BaseAchievement: GKAchievement {

    // MARK: - Properties
     
    /// Determine if achievement has unreported progress
    var inProgress = false
    
    /// Determine if achievement is completed
    var isComplete = false
    
    override var percentComplete: Double {
        didSet {
            if percentComplete >= 100 {
                isComplete = true
            }
        }
    }
    
    
    // MARK: - Functions
    
    /// Updates the progress of the achievement
    func updateProgress() {
        guard !isComplete else { return }
        
        updatePercentage()
        
        inProgress = true
        
        reportIfCompleted()
    }
    
    /// Logic to update the percentage completed.
    func updatePercentage() {
        fatalError("updatePercentage() has not been implemented. Please override this method in the subclass.")
    }
    
    /// Report the achievement if it is completed
    func reportIfCompleted() {
        guard isComplete else { return }
        
        GameCenterManager.shared.report(soloAchievement: self)
    }
}
