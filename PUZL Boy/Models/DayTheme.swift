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
    
    private static var currentHour: Int = Calendar.current.component(.hour, from: Date())
    
    static var currentTheme: Theme {
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
        }
    }
    
    static var spriteColor: UIColor {
        switch currentTheme {
        case .dawn:
            return .blue
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
        case .dawn:
            return 0.5
        case .morning:
            return 0
        case .afternoon:
            return 0.25
        case .night:
            return 0.5
        }
    }
        
    enum Theme {
        case dawn, morning, afternoon, night
    }
    
    
    // MARK: - Functions
    
    static func setCurrentHour(automatic: Bool, timeIfManual: Int = 8) {
        currentHour = automatic ? Calendar.current.component(.hour, from: Date()) : timeIfManual
    }
    
    static func getSkyImage(endPointY: CGFloat = 0.5, useMorningSky: Bool = false) -> UIImage {
        let skyColor: SkyColors = useMorningSky ? morningSky : self.skyColor
        
        return UIImage.createGradientImage(
            withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height),
            startPoint: CGPoint(x: 0.5, y: 0),
            endPoint: CGPoint(x: 0.5, y: endPointY),
            colors: [skyColor.top.cgColor, skyColor.bottom.cgColor]
        )
    }
}
