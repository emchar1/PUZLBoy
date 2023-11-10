//
//  Controls.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/1/22.
//

import Foundation

enum Controls {
    case up, down, left, right
    
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
        }
    }
}
