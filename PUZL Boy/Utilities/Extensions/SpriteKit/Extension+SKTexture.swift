//
//  Extension+SKTexture.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/20/23.
//

import SpriteKit

extension SKTexture {
    func getFilename() -> String? {
        let delimiter = "'"
        var filename = self.description
        
        guard let firstHalf = filename.range(of: delimiter) else { return nil }
        filename.removeSubrange(filename.startIndex...firstHalf.lowerBound)
        
        guard let secondHalf = filename.range(of: delimiter) else { return nil }
        filename.removeSubrange(secondHalf.lowerBound..<filename.endIndex)
        
        return "\(filename)"
    }
}
