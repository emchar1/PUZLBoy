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
        
        //--SCREEN SIZE--
        
        ///Default width of the device in Portrait mode, per RayWenderlich tutorial. Should not be used AT ALL. Use K.ScreenDimensions.screenSize.width!!!
        private static let width: CGFloat = 1536
        
        ///Default height of the device in Portrait mode, per RayWenderlich tutorial. Should not be used directly. Use K.ScreenDimensions.screenSize.height instead!!!
        private static let height: CGFloat = 2048
        
        ///The device's screen size.
        static var size: CGSize { CGSize(width: height / UIDevice.modelInfo.ratio, height: height) }
        
        ///The device's screen size in UI terms, which is different than [SpriteKit] screenSize.
        static var sizeUI: CGSize { UIScreen.main.bounds.size }
        
        ///The ratio of SpriteKit screenSize to UIKit screenSize
        static var ratioSKtoUI: CGFloat { size.width / sizeUI.width }
        
        
        //--MARGINS--
        
        ///Top margin of the device.
        static let topMargin: CGFloat = UIDevice.modelInfo.topSafeArea
        
        ///Bottom margin of the device.
        static let bottomMargin: CGFloat = UIDevice.modelInfo.bottomSafeArea
        
        ///Adds an additional margin size to the left and right sides of the screen, if it's an iPad (due to the 4/3 aspect ratio).
        static var lrMargin: CGFloat { UIDevice.isiPad ? 80 : 0 }
        
        ///Top border of the gameboard sprite. Needs to be set in gameboardSprite, otherwise it defaults to topMargin.
        static var topOfGameboard: CGFloat = topMargin
    }
    
    
    ///Various zPosition values used throughout the app.
    struct ZPosition {
        
        //--LAUNCH SCENE--
        static let skyNode: CGFloat = 25
        static let backgroundObjectMoon: CGFloat = 30
        static let loadingNode: CGFloat = 610
        static let parallaxLayer0: CGFloat = 70
        
        
        //--TITLE SCENE--
        static let puzlTitle: CGFloat = 655
        static let boyTitle: CGFloat = 660
        static let menuBackground: CGFloat = 665
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
        static let chatDialogue: CGFloat = 800 //510 <-- original zPosition but changed to 800 to be on top of bloodOverlay 3/21/24

        //Player
        static let player: CGFloat = 600
        static let itemsAndEffects: CGFloat = 620
        static let itemsPoints: CGFloat = 630
        
        //SpeechBubbles
        static let bloodOverlay: CGFloat = 640
        static let letterboxOverlay: CGFloat = 650
        static let speechBubble: CGFloat = 660
        static let hintArrow: CGFloat = 760

        //Party Foreground
        static let partyForegroundOverlay: CGFloat = 777
        
        //Pause Menu - at least 200 over partyForegroundOverlay!!
        static let pauseScreen: CGFloat = 900
        static let pauseButton: CGFloat = 950

        //Important messaging
        static let messagePrompt: CGFloat = 1000
        static let activityIndicator: CGFloat = 1020
    }
    
    
    struct UserDefaults {
        //UserDefault Keys
        static let firebaseUID = "FirebaseUID"
        static let muteMusic = "MuteMusic"
        static let muteSoundFX = "MuteSoundFX"
        static let disableVibration = "DisableVibration"
        static let shouldSkipIntro = "ShouldSkipIntro"
        static let reviewStoreCount = "ReviewStoreCount"
        static let savedTime = "SavedTimeForReplenishLives"
        static let feedbackSubmitDate = "FeedbackSubmitDate"
    }
}
