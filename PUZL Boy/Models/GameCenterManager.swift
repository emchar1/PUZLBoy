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
    
    private let leaderboardLevelIDPrefix = "PUZLBoy.HiScoreLV"
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
    
    
    // MARK: - Functions
    
    func postScoreToLeaderboard(score: Int, level: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return print("Unable to save score! Player is not authenticated.") }
        
        let scoreReporter = GKScore(leaderboardIdentifier: getLeaderboardLevelID(level))
        scoreReporter.value = Int64(score)
                        
        GKScore.report([scoreReporter])
    }
    
    func showLeaderboard(level: Int) {
        let gcvc = GKGameCenterViewController()
        gcvc.leaderboardIdentifier = getLeaderboardLevelID(level)
        gcvc.gameCenterDelegate = self

        viewController?.present(gcvc, animated: true)
    }
    
    private func getLeaderboardLevelID(_ level: Int) -> String {
        let levelString = String(format: "%04d", level) //4 digit level, with leading zeroes
        
        return leaderboardLevelIDPrefix + levelString
    }
}


// MARK: GKLocalPlayerListener

extension GameCenterManager: GKLocalPlayerListener {
    //what goes here???
}


// MARK: GKGameCenterControllerDelegate

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
