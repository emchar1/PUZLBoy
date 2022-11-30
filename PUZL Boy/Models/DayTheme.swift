//
//  DayTheme.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/30/22.
//

import SpriteKit

struct DayTheme {
    static var currentTheme: Theme {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        switch currentHour {
        case 5...12:
            return .morning
        case 13...19:
            return .afternoon
        default:
            return .night
        }
    }
    
    static var skyColor: UIColor {
        switch currentTheme {
        case .morning:
            return UIColor(red: 192 / 255, green: 229 / 255, blue: 255 / 255, alpha: 1.0)
        case .afternoon:
            return UIColor(red: 215 / 255, green: 174 / 255, blue: 122 / 255, alpha: 1.0)
        case .night:
            return UIColor(red: 25 / 255, green: 25 / 255, blue: 40 / 255, alpha: 1.0)
        }
    }
    
    static var grassColor: UIColor {
        switch currentTheme {
        case .morning:
            return UIColor(red: 94 / 255, green: 177 / 255, blue: 72 / 255, alpha: 1.0)
        case .afternoon:
            return UIColor(red: 84 / 255, green: 127 / 255, blue: 42 / 255, alpha: 1.0)
        case .night:
            return UIColor(red: 35 / 255, green: 54 / 255, blue: 62 / 255, alpha: 1.0)
        }
    }
    
    static var spriteShade: CGFloat {
        switch currentTheme {
        case .morning:
            return 0
        case .afternoon:
            return 0.25
        case .night:
            return 0.5
        }
    }
    
    enum Theme {
        case morning, afternoon, night
    }
}
