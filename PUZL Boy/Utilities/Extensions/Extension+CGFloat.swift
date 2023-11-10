//
//  Extension+CGFloat.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/22/23.
//

import Foundation

extension CGFloat {
    ///Converts the CGFloat number to radians (assuming it's in degrees, initially).
    func toRadians() -> CGFloat {
        return self * (.pi / 180)
    }
    
    ///Converts the CGFloat number to degrees (assuming it's in radians, initially).
    func toDegrees() -> CGFloat {
        return self * (180 / .pi)
    }
}
