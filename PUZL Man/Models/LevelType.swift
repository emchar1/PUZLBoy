//
//  LevelType.swift
//  PUZL Man
//
//  Created by Eddie Char on 11/15/22.
//

import Foundation

/**
 Represents the gameboard textures.
 */
enum LevelType: Int, CaseIterable {
    case boundary = 0, start, endClosed, endOpen, gem, gemOnIce //important panels
    case grass, marsh, ice //terrain panels
    case hammer, sword //inventory panels
    case boulder, enemy, warp //special panels
    
    var description: String {
        return String(describing: self)
    }
}
