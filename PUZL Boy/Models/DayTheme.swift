//
//  DayTheme.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/30/22.
//

import SpriteKit

struct DayTheme {
    
    // MARK: - Properties

    typealias SkyColors = (top: UIColor, bottom: UIColor)
    
    static let morningSky: SkyColors = (UIColor(red: 32 / 255, green: 99 / 255, blue: 207 / 255, alpha: 1.0),
                                        UIColor(red: 174 / 255, green: 232 / 255, blue: 246 / 255, alpha: 1.0))
    
    static let bloodSky: SkyColors = (UIColor(red: 69 / 255, green: 22 / 255, blue: 22 / 255, alpha: 1.0),
                                      UIColor(red: 122 / 255, green: 69 / 255, blue: 69 / 255, alpha: 1.0))
    
    static var currentTheme: Theme {
        guard !AgeOfRuin.isActive else { return .blood }
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        switch currentHour {
        case 4...7:
            return .dawn
        case 8...15:
            return .morning
        case 16...19:
            return .afternoon
        default:
            return .night
        }
    }
    
    static var skyColor: SkyColors {
        switch currentTheme {
        case .dawn:
            return (UIColor(red: 12 / 255, green: 30 / 255, blue: 99 / 255, alpha: 1.0),
                    UIColor(red: 176 / 255, green: 83 / 255, blue: 117 / 255, alpha: 1.0))
        case .morning:
            return morningSky
        case .afternoon:
            return (UIColor(red: 226 / 255, green: 93 / 255, blue: 127 / 255, alpha: 1.0),
                    UIColor(red: 238 / 255, green: 175 / 255, blue: 47 / 255, alpha: 1.0))
        case .night:
            return (UIColor(red: 1 / 255, green: 5 / 255, blue: 20 / 255, alpha: 1.0),
                    UIColor(red: 22 / 255, green: 50 / 255, blue: 129 / 255, alpha: 1.0))
        case .blood:
            return bloodSky
        }
    }
    
    static var spriteColor: UIColor {
        switch currentTheme {
        case .dawn:
            return .purple
        case .morning:
            return .clear
        case .afternoon:
            return .orange
        case .night:
            return .blue
        case .blood:
            return .red
        }
    }

    static var spriteShade: CGFloat {
        switch currentTheme {
        case .dawn:
            return 0.5
        case .morning:
            return 0
        case .afternoon:
            return 0.25
        case .night:
            return 0.5
        case .blood:
            return 0.5
        }
    }
        
    enum Theme {
        case dawn, morning, afternoon, night, blood
    }
    
    
    // MARK: - Functions
    
    static func getSkyImage(useMorningSky: Bool = false) -> UIImage {
        guard !useMorningSky else { return UIImage.gradientTextureSkyMorning }
        
        let skyImage: UIImage
        
        switch currentTheme {
        case .dawn:
            skyImage = UIImage.gradientTextureSkyDawn
        case .morning:
            skyImage = UIImage.gradientTextureSkyMorning
        case .afternoon:
            skyImage = UIImage.gradientTextureSkyAfternoon
        case .night:
            skyImage = UIImage.gradientTextureSkyNight
        case .blood:
            skyImage = UIImage.gradientTextureSkyBlood
        }
        
        return skyImage
    }
    
    
}
