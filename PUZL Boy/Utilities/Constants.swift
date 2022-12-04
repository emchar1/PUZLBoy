//
//  Constants.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/2/22.
//

import Foundation

struct K {
    /**
     Position, row, col, on the gameboard.
     */
    typealias GameboardPosition = (row: Int, col: Int)
    
    /**
     Gameboard i.e. 2D array of LevelType
     */
    typealias Gameboard = [[LevelType]]
    
    
    struct Audio {
        /**
         Current theme song for the overworld.
         */
        static let overworldTheme = "overworldoff"
        
        /**
         Shared AudioManager property throughout the project.
         */
        static let audioManager = AudioManager()
    }
    
    
    struct ScreenDimensions {
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
        static let iPhoneMargin: CGFloat = (width - iPhoneWidth) / 2
        
        /**
         Top margin of the device.
         */
        static let topMargin: CGFloat = 200
        
        /**
         Bottom margin of the device.
         */
        static let bottomMargin: CGFloat = 80
        
        /**
         The device's screen size.
         */
        static var screenSize: CGSize {
            CGSize(width: iPhoneWidth, height: height)
        }
    }
    
    
    /**
     Various zPosition values used throughout the app.
     */
    struct ZPosition {
        static let skyNode: CGFloat = 80
        static let gameboard: CGFloat = 100
        static let panel: CGFloat = 200
        static let backgroundObjectTier2: CGFloat = 250
        static let backgroundObjectTier1: CGFloat = 255
        static let backgroundObjectTier0: CGFloat = 260
        static let player: CGFloat = 300
        static let items: CGFloat = 350
        static let display: CGFloat = 400
    }
    
    
    struct UserDefaults {
        //UserDefault Keys
        static let soundIsMuted = "SoundIsMuted"
        static let hintsAreOff = "HintsAreOff"
        static let launchedBefore = "LaunchedBefore"
    }
}
