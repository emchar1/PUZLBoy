//
//  Inventory.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/28/22.
//

import Foundation

struct Inventory: CustomStringConvertible, Codable {
    var hammers: Int
    var swords: Int
    
    var description: String {
        return "Hammers: \(hammers), Swords: \(swords)"
    }
    
    init(hammers: Int, swords: Int) {
        self.hammers = hammers
        self.swords = swords
    }
    
    func getItemCount() -> Int {
        return hammers + swords
    }
}
