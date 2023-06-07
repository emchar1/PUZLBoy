//
//  ButtonTap.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/13/23.
//

import UIKit

struct ButtonTap {
    
    // MARK: - Properties
    
    static let shared: ButtonTap = {
        let buttonTap = ButtonTap()
        
        //Add'l setup
        
        return buttonTap
    }()
    
    enum ButtonType: String {
        case noSound, buttontap1, buttontap2, buttontap3, buttontap4, buttontap5, buttontap6, buttontap7
    }
    
    // MARK: - Functions
    
    func tap(type: ButtonTap.ButtonType, hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .soft) {
        if type != .noSound {
            AudioManager.shared.playSound(for: type.rawValue)
        }
        
        Haptics.shared.addHapticFeedback(withStyle: hapticStyle)
    }
}
