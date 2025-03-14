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
    static let gameFontSizeExtraLarge: CGFloat = 75 / UIDevice.spriteScale
    static let gameFontSizeLarge: CGFloat = 50 / UIDevice.spriteScale
    static let gameFontSizeMedium: CGFloat = 50
    static let gameFontSizeSmall: CGFloat = 40
    
    //Chat Font
    static let chatFont: String = "Boogaloo-Regular"
    static let chatFontColor: UIColor = .white
    static let chatFontSizeExtraLarge: CGFloat = 72 / UIDevice.spriteScale
    static let chatFontSizeLarge: CGFloat = 48 / UIDevice.spriteScale
    static let chatFontSizeMedium: CGFloat = 48
    static let chatFontSizeSmall: CGFloat = 40
    
    //Misc
    static let infiniteFont: String = "HelveticaNeue-CondensedBold"
    static let infiniteSizeExtraLarge: CGFloat = 125 / UIDevice.spriteScale
    static let titleMenuFontSize: CGFloat = 72
    static let pauseTabsFontSize: CGFloat = 28 / UIDevice.spriteScale
}
