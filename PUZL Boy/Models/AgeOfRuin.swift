//
//  AgeOfRuin.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/15/24.
//

import Foundation

struct AgeOfRuin {
    
    // MARK: - Properties
    
    ///Shows what's in the FIRManager's SaveStateModel's ageOfRuin property.
    static var isActive: Bool {
        FIRManager.saveStateModel?.ageOfRuin ?? false
    }
    
    ///Checks to see if conditions are met for Age of Ruin to be activated.
    static var conditionsMet: Bool {
        //Age of Peace if player makes these choices:
        let ageOfPeace: Bool =
        !(FIRManager.decisionsLeftButton[0] ?? true) && //1. Prepare First
        (FIRManager.decisionsLeftButton[2] ?? false) && //2. Give (feather) Away
        !(FIRManager.decisionsLeftButton[3] ?? true)    //3. Let (Magmoor) Go
        
        return !ageOfPeace
    }
    
    static var ruinSuffix: String {
        isActive ? "Ruin" : ""
    }

}
