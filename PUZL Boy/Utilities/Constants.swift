//
//  Constants.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/2/22.
//

import UIKit

struct K {
    ///Position, row, col, on the gameboard.
    typealias GameboardPosition = (row: Int, col: Int)
    
    ///Gameboard piece, i.e. one panel
    typealias GameboardPanel = (terrain: LevelType, overlay: LevelType)
    
    ///Gameboard i.e. 2D array of LevelType
    typealias Gameboard = [[GameboardPanel]]
    
    
    struct ScreenDimensions {
        ///Default width of the iPhone device in Portrait mode, per RayWenderlich tutorial.
        static let width: CGFloat = 1536
        
        ///Default height of the iPhone device in Portrait mode, per RayWenderlich tutorial.
        static let height: CGFloat = 2048
        
        ///Default aspect ratio of the iPhone device in Portrait mode, per  RayWenderlich tutorial, i.e. 1.3333
        static let ratio: CGFloat = width / height
        
        ///Aspect ratio of the most recent iPhone, i.e. iPhone 14. Ratio is 2.16667
        static let iPhoneRatio: CGFloat = UIDevice.modelInfo.ratio//19.5 / 9
        
        ///Width of the most recent iPhone, i.e. iPhone 14. Width is 945
        static let iPhoneWidth: CGFloat = height / iPhoneRatio
        
        ///Margin of the most recent iPhone, i.e. iPhone 14. Set to half of the difference between the default width and the width of the most recent iPhone, i.e. 296
        static let iPhoneMargin: CGFloat = (width - iPhoneWidth) / 2
        
        ///Top margin of the device.
        static let topMargin: CGFloat = UIDevice.modelInfo.topSafeArea
        
        ///Bottom margin of the device.
        static let bottomMargin: CGFloat = UIDevice.modelInfo.bottomSafeArea
        
        ///Adds an additional margin size to the left and right sides of the screen, if it's an iPad (due to the 4/3 aspect ratio).
        static var lrMargin: CGFloat {
            UIDevice.isiPad ? 80 : 0
        }
        
        ///Top border of the gameboard sprite. Needs to be set in gameboardSprite, otherwise it defaults to topMargin.
        static var topOfGameboard: CGFloat = topMargin
        
        ///The device's screen size.
        static var screenSize: CGSize {
            CGSize(width: iPhoneWidth, height: height)
        }
    }
    
    
    ///Various zPosition values used throughout the app.
    struct ZPosition {
        
        //--LAUNCH SCENE--
        static let skyNode: CGFloat = 25
        static let grassNode: CGFloat = 30
        static let backgroundObjectMoon: CGFloat = 40
        static let backgroundObjectCloud: CGFloat = 45
        static let backgroundObjectMountain: CGFloat = 50
        static let backgroundObjectTier2: CGFloat = 55
        static let backgroundObjectTier1: CGFloat = 60
        static let backgroundObjectTier0: CGFloat = 65
        static let loadingNode: CGFloat = 75
        
        
        //--TITLE SCENE--
        static let puzlTitleShadow: CGFloat = 650
        static let puzlTitle: CGFloat = 655
        static let boyTitle: CGFloat = 660
        static let menuBackground: CGFloat = 665
        static let menuItem: CGFloat = 670
        static let fadeTransitionNode: CGFloat = 700

        
        //--GAME SCENE--
        //Party Background
        static let partyBackgroundOverlay: CGFloat = 90

        //Gameboard
        static let gameboard: CGFloat = 100
        static let terrain: CGFloat = 120 //stacks with gameboard
        static let overlay: CGFloat = 130 //stacks with gameboard
        
        //AdScene - at least 300 over gameboard!!
        static let adSceneBlackout: CGFloat = 400

        //DisplaySprite
        static let display: CGFloat = 450

        //ChatEngine
        static let chatDimOverlay: CGFloat = 500
        static let chatDialogue: CGFloat = 510

        //Player
        static let player: CGFloat = 600
        static let itemsAndEffects: CGFloat = 620
        static let itemsPoints: CGFloat = 630

        //Party Foreground
        static let partyForegroundOverlay: CGFloat = 777
        
        //Pause Menu - at least 200 over partyForegroundOverlay!!
        static let pauseScreen: CGFloat = 900
        static let pauseButton: CGFloat = 910

        //Important messaging
        static let messagePrompt: CGFloat = 1000
        static let activityIndicator: CGFloat = 1020
    }
    
    
    struct UserDefaults {
        //UserDefault Keys
        static let soundIsMuted = "SoundIsMuted"
        static let reviewStoreCount = "ReviewStoreCount"
        static let savedTime = "SavedTimeForReplenishLives"
    }
    
    
    struct ButtonTaps {
        static func tap1() {
            tapCustom(soundFile: "buttontap")
        }
        
        static func tap2() {
            tapCustom(soundFile: "buttontap2")
        }

        static func tapCustom(soundFile: String, style: UIImpactFeedbackGenerator.FeedbackStyle = .soft) {
            AudioManager.shared.playSound(for: soundFile)
            Haptics.shared.addHapticFeedback(withStyle: style)
        }
    }
}
