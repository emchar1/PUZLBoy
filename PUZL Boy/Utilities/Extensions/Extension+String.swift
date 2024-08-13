//
//  Extension+String.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/9/24.
//

import Foundation

extension String? {
    /**
     Searches for if the optional string contains "left" and returns true if so. NO LONGER USED 8/13/24.
     - returns: true if "left" is found.
     */
    func isLeftButton() -> Bool {
        guard let self = self else { return false }
        
        return self.contains("left")
    }
}
