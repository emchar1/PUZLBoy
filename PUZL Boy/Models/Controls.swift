//
//  Controls.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/1/22.
//

import Foundation

enum Controls: String {
    case up = "U", down = "D", left = "L", right = "R", unknown = "X"
    
    var getOpposite: Controls {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .left:
            return .right
        case .right:
            return .left
        case .unknown:
            return .unknown
        }
    }
}
