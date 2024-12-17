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
        FIRManager.saveStateModel?.aorAgeOfRuin ?? false
    }
    
    /* DISABLED 12/16/24 as AOR toggles back and forth now.
    ///Checks to see if conditions are met for Age of Ruin to be activated.
    static var conditionsMet: Bool {
        //Age of Balance if player makes these choices:
        // FIXME: - 10/8/24 Still working on conditions to sustain AOB.
        let ageOfBalance: Bool =
        !(FIRManager.decisionsLeftButton[0] ?? true) && //1. Prepare First
        (FIRManager.decisionsLeftButton[2] ?? false) && //2. Give (feather) Away
//        !(FIRManager.decisionsLeftButton[3] ?? true) && //3. Let (Magmoor) Go
        (FIRManager.bravery ?? 0) >= MagmoorCreepyMinion.maxBravery //4. Must defeat Magmoor's minion without letting Bravery hit 0.
        
        return !ageOfBalance                              //i.e. return Age of Ruin
    }
     */
    
    static var ruinSuffix: String {
        isActive ? "Ruin" : ""
    }

}
