//
//  Extension+Comparable.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/16/22.
//

import Foundation

extension Comparable {
    /**
     Imposes a lower and upper limit to a value.
     - parameters:
        - min: lower limit
        - max: upper limit
     */
    func clamp(min minValue: Self, max maxValue: Self) -> Self {
        return max(min(self, maxValue), minValue)
    }
}
