//
//  Constants.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/2/22.
//

import Foundation

struct K {
    /**
     Default width of the iPhone device in Portrait mode, per RayWenderlich tutorial.
     */
    static let width: CGFloat = 1536

    /**
     Default height of the iPhone device in Portrait mode, per RayWenderlich tutorial.
     */
    static let height: CGFloat = 2048

    /**
     Default aspect ratio of the iPhone device in Portrait mode, per  RayWenderlich tutorial, i.e. 1.3333
     */
    static let ratio: CGFloat = width / height

    /**
     Aspect ratio of the most recent iPhone, i.e. iPhone 14. Ratio is 2.16667
     */
    static let iPhoneRatio: CGFloat = 19.5 / 9
    
    /**
     Width of the most recent iPhone, i.e. iPhone 14. Width is 945
     */
    static let iPhoneWidth: CGFloat = height / iPhoneRatio
    
    /**
     Margin of the most recent iPhone, i.e. iPhone 14. Set to half of the difference between the default width and the width of the most recent iPhone, i.e. 296
     */
    static let iPhoneMargin: CGFloat = (width - iPhoneWidth) / 2 //296

    /**
     Top margin of the device.
     */
    static let topMargin: CGFloat = 280
    
    /**
     Bottom margin of the device.
     */
    static let bottomMargin: CGFloat = 80
    
    /**
     Position, row, col, on the gameboard.
     */
    typealias GameboardPosition = (row: Int, col: Int)
    
    /**
     Various zPosition values used throughout the app.
     */
    struct ZPosition {
        static let gameboard: CGFloat = 100
        static let panel: CGFloat = 200
        static let player: CGFloat = 300
    }
}
