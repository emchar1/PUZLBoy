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
    func updateProgress(increment: Double = 1) {
        guard !isComplete else { return }
        
        updatePercentage(increment: increment)
        
        inProgress = true
        
        // FIXME: - Will this ever get called??
        reportIfCompleted()
    }
    
    /// Logic to update the percentage completed.
    func updatePercentage(increment: Double = 1) {
        fatalError("updatePercentage() has not been implemented. Please override this method in the subclass.")
    }
    
    /// Report the achievement if it is completed
    func reportIfCompleted() {
        guard isComplete else { return }
        
        print("BaseAchievement.reportIfCompleted() got called... I'll be damned!")
        
        GameCenterManager.shared.report(soloAchievement: self)
    }
}
