//
//  Extension+UIFont.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/10/22.
//

import UIKit

extension UIFont {
    //Game Font
    static let gameFont: String = "LuckiestGuy-Regular"
    static let gameFontColor: UIColor = .white
    static let gameFontColorOutOfTime: UIColor = UIColor(red: 255 / 255, green: 50 / 255, blue: 75 / 255, alpha: 1)
    static let gameFontSizeExtraLarge: CGFloat = UIDevice.isiPad ? 100 : 75
    static let gameFontSizeLarge: CGFloat = UIDevice.isiPad ? 75 : gameFontSizeMedium
    static let gameFontSizeMedium: CGFloat = 50
    static let gameFontSizeSmall: CGFloat = 40
    
    //Chat Font
    static let chatFont: String = "Boogaloo-Regular"
    static let chatFontColor: UIColor = .white
    static let chatFontSizeExtraLarge: CGFloat = 99
    static let chatFontSizeLarge: CGFloat = UIDevice.isiPad ? 72 : chatFontSizeMedium
    static let chatFontSizeMedium: CGFloat = 48
    static let chatFontSizeSmall: CGFloat = 40
    
    //Misc
    static let titleMenuFontSize: CGFloat = 72
    static let pauseTabsFontSize: CGFloat = UIDevice.isiPad ? 34 : 28
}
