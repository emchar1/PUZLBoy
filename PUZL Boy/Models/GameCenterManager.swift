//
//  GameCenterManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/18/22.
//

import GameKit

final class GameCenterManager: NSObject {
    
    // MARK: - Properties
    
    static let shared: GameCenterManager = {
        let instance = GameCenterManager()
        //additional setup, if needed
        return instance
    }()
    
    var viewController: UIViewController?

    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        
        //Checks for authentication upon initialization
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                print("Authenticated to Game Center!")
                
                //Uses GKLocalPlayerListener protocol implementation, defined at the bottom
                GKLocalPlayer.local.register(self)
            }
            else if let vc = gcAuthVC {
                //Request authentication
                self.viewController?.present(vc, animated: true)
            }
            else {
                print("Error authenticating to Game Center: \(error?.localizedDescription ?? "No error, actually.")")
            }
            
        }
    }
    
    
}


// MARK: GKLocalPlayerListener

extension GameCenterManager: GKLocalPlayerListener {
    //what goes here???
}
