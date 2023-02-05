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
    
    private let leaderboardLevelIDPrefix = "PUZLBoy.HiScoreLV"
    var viewController: UIViewController?
    
    static let shared: GameCenterManager = {
        let instance = GameCenterManager(completion: nil)

        //additional setup, if needed

        return instance
    }()

    
    // MARK: - Initialization
    
    private init(completion: ((User?) -> Void)?) {
        super.init()
        
        //Checks for authentication upon initialization
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                print("Authenticated to Game Center!")
                
                //Uses GKLocalPlayerListener protocol implementation, defined at the bottom
                GKLocalPlayer.local.register(self)
                
                //Get Firebase user credentials
                self.getFirebaseCredentials { user in
                    completion?(user)
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
    
    func getUser(completion: ((User?) -> Void)?) {
        let _ = GameCenterManager { user in
            completion?(user)
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
        guard let achievementToUpdate = Achievement.achievements[achievement] else { return }
        
        achievementToUpdate.updateProgress(increment: increment)
        
        if shouldReportImmediately {
            report(soloAchievement: achievementToUpdate)
        }
        
        if achievementToUpdate.isComplete, Achievement.isPUZLMasterAchieved() {
            print("Congrats!!! You beat the game! You are the PUZL Master!!")
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
        }
    }
    
    func resetAchievements() {
        GKAchievement.resetAchievements { error in
            guard error == nil else { return print("Error resetting achievements: \(error!.localizedDescription)") }
            
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
    private func getFirebaseCredentials(completion: @escaping (User?) -> Void) {
        GameCenterAuthProvider.getCredential { credential, error in
            guard let credential = credential else {
                completion(nil)
                print("Can't get GameCenter credentials: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            Auth.auth().signIn(with: credential) { user, error in
                guard let user = user else {
                    completion(nil)
                    print("Error signing into Firebase Auth: \(error?.localizedDescription ?? "No error")")
                    return
                }
                
                completion(user.user)
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
