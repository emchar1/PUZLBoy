//
//  Extension+Double.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/25/23.
//

import Foundation

extension Double {
    func truncate(placesAfterDecimal: Int) -> Double {
        return Double(floor(pow(10.0, Double(placesAfterDecimal)) * self) / pow(10.0, Double(placesAfterDecimal)))
    }
}
