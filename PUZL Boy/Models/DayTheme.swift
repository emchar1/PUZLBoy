//
//  DayTheme.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/30/22.
//

import SpriteKit

struct DayTheme {
    static let skyImage: UIImage = UIImage.createGradientImage(withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height), startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 0.5), colors: [DayTheme.skyColor.top.cgColor, DayTheme.skyColor.bottom.cgColor])
    
    static var currentTheme: Theme {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        switch currentHour {
        case 6...12:
            return .morning
        case 13...18:
            return .afternoon
        default:
            return .night
        }
    }
    
    static var skyColor: (top: UIColor, bottom: UIColor) {
        switch currentTheme {
        case .morning:
            return (UIColor(red: 92 / 255, green: 149 / 255, blue: 207 / 255, alpha: 1.0),
                    UIColor(red: 254 / 255, green: 252 / 255, blue: 246 / 255, alpha: 1.0))
        case .afternoon:
            return (UIColor(red: 238 / 255, green: 175 / 255, blue: 97 / 255, alpha: 1.0),
                    UIColor(red: 206 / 255, green: 73 / 255, blue: 147 / 255, alpha: 1.0))
        case .night:
            return (UIColor(red: 6 / 255, green: 21 / 255, blue: 30 / 255, alpha: 1.0),
                    UIColor(red: 32 / 255, green: 40 / 255, blue: 89 / 255, alpha: 1.0))
        }
    }
    
    static var grassColor: (top: UIColor, bottom: UIColor) {
        return (UIColor(red: 94 / 255, green: 177 / 255, blue: 72 / 255, alpha: 1.0),
                UIColor(red: 44 / 255, green: 147 / 255, blue: 42 / 255, alpha: 1.0))
    }
    
    static var spriteColor: UIColor {
        switch currentTheme {
        case .morning:
            return .clear
        case .afternoon:
            return .red
        case .night:
            return .blue
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
