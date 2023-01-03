//
//  GameCenterManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/18/22.
//

import FirebaseAuth
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
    var firebaseUser: User?

    
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
                
                self.getFirebaseCredentials { user in
                    self.firebaseUser = user
                    print("Firebase user: \(self.firebaseUser?.displayName ?? "<Game Center user not signed in!>") signed in.")
                }
                
                //And load the achievements!
                self.loadAchievements()
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
    
    
    // MARK: - Leaderboard Functions
    
    func postScoreToLeaderboard(score: Int, level: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return print("Unable to save score! Player is not authenticated.") }
                
        if #available(iOS 14.0, *) {
            //Just giving this a whirl. I believe it's the same as non-iOS 14.0 version...
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [getLeaderboardLevelID(level)]) { error in
                print("Leaderboard: \(self.getLeaderboardLevelID(level)) updated!")
            }
        } else {
            let scoreReporter = GKScore(leaderboardIdentifier: getLeaderboardLevelID(level))
            scoreReporter.value = Int64(score)
                            
            GKScore.report([scoreReporter])
        }
    }
    
    func showLeaderboard(level: Int) {
        let gcvc = GKGameCenterViewController()
//        gcvc.leaderboardIdentifier = "PUZLBoy.AllLevelsHiScore"
        gcvc.leaderboardIdentifier = getLeaderboardLevelID(level)
        gcvc.leaderboardTimeScope = .allTime
        gcvc.gameCenterDelegate = self

//        // FIXME: - TEST ONLY
//        GKLeaderboard.loadLeaderboards { leaderboards, error in
//            if #available(iOS 14.0, *) {
//                leaderboards?[level].loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime) { localPlayer, leaderboardEntry, error in
//                    print("Level \(level) High Score: \(localPlayer?.score ?? -99)")
//                }
//            }
//        }
 
        viewController?.present(gcvc, animated: true)
    }
    
    private func getLeaderboardLevelID(_ level: Int) -> String {
        let levelString = String(format: "%04d", level) //4 digit level, with leading zeroes
        
        return leaderboardLevelIDPrefix + levelString
    }
    
    
    // MARK: - Achievement Functions
    
    func loadAchievements() {
        Achievement.initAchievements()
        
        GKAchievement.loadAchievements { achievements, error in
            guard error == nil else { return print("Error loading achievements: \(error!.localizedDescription)") }
            guard let achievements = achievements else { return }
            
            Achievement.updateAchievements(achievements)

            print("Achievements loaded!")
        }
    }
    
    /**
     Updates the progress of the achievement.
     - parameters:
        - achievement: The achievement to update
        - increment: The value (rate) at which to update the achievement
        - shouldReportImmediately: If this is set to `true` then post it to App Store Connect using GKAchievement.report() and immediately update the percentage shown on the achievement page. Initially set to `false`.
     */
    func updateProgress(achievement: Achievement, increment: Double = 1, shouldReportImmediately: Bool = false) {
        guard let achievmentToUpdate = Achievement.achievements[achievement] else { return }
        
        achievmentToUpdate.updateProgress(increment: increment)
        
        if shouldReportImmediately {
            report(soloAchievement: achievmentToUpdate)
        }
    }
    
    func report(soloAchievement: BaseAchievement) {
        report(achievements: [soloAchievement])
    }
    
    func report(achievements: [BaseAchievement]) {
        guard GKLocalPlayer.local.isAuthenticated else { return print("Unable to attempt to report Achievements! Player is not authenticated.") }
        
        var achievementsFiltered = achievements
        
        achievementsFiltered = achievements.filter({ achievement -> Bool in
            return achievement.inProgress
        })
        
        achievementsFiltered.forEach { achievement in
            achievement.inProgress = false
        }
        
        GKAchievement.report(achievementsFiltered) { error in
            guard error == nil else { return print("Error reporting achievements to Game Center: \(error!.localizedDescription)") }
            
            //handle stuff here
            print("Achievements reported!")
        }
    }
    
    func resetAchievements() {
        GKAchievement.resetAchievements { error in
            guard error == nil else { return print("Error resetting achievements") }
            
            self.loadAchievements()
            print("Achievements reset!")
        }
    }
}


// MARK: GKLocalPlayerListener

extension GameCenterManager: GKLocalPlayerListener {
    /**
     Gets the currently signed in Game Center user and creates/signs into a Firebase Auth user from it. The results of the Firebase Auth user is in the completion handler.
     - parameter completion: completion handler with the User returned
     */
    func getFirebaseCredentials(completion: @escaping (User) -> Void) {
        GameCenterAuthProvider.getCredential { credential, error in
            guard let credential = credential else { return print(error?.localizedDescription ?? "No error") }
            
            Auth.auth().signIn(with: credential) { user, error in
                guard let user = user else { return print(error?.localizedDescription ?? "No error") }
                
                completion(user.user)
                
                print("Player signed into Game Center via Firebase Auth!")
            }
        }
    }
    
    
}


// MARK: GKGameCenterControllerDelegate

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
