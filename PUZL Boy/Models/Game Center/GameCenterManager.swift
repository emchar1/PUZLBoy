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
    
    typealias Score = (level: Int, username: String?, score: Int?, isLocalPlayer: Bool?)
    private let leaderboardLevelIDPrefix = "PUZLBoy.HiScoreLV"
    private var scores: [Score] = []
    private var isLoadingScores = false
    var shouldCancelLeaderboards = false
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
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [getLeaderboardLevelID(level)]) { error in
                print("Leaderboard: \(self.getLeaderboardLevelID(level)) updated!")
            }
        }
        else {
            let scoreReporter = GKScore(leaderboardIdentifier: getLeaderboardLevelID(level))
            scoreReporter.value = Int64(score)
                            
            GKScore.report([scoreReporter])
        }
    }
    
    ///Shows the built-in Game Center leaderboard
    func showLeaderboard(level: Int, completion: (() -> Void)?) {
        let gcvc: GKGameCenterViewController
        
        if #available(iOS 14.0, *) {
            gcvc = GKGameCenterViewController(leaderboardID: getLeaderboardLevelID(level), playerScope: .global, timeScope: .allTime)
        }
        else {
            gcvc = GKGameCenterViewController()
            gcvc.leaderboardIdentifier = getLeaderboardLevelID(level)
            gcvc.leaderboardTimeScope = .allTime
        }
        
        gcvc.gameCenterDelegate = self
 
        viewController?.present(gcvc, animated: true, completion: completion)
    }
        
    ///For use in custom Game Center Table Views. Warning: completion may not get called if something happens while loading the scores array and the full scores.count >= maxLevel is not realized. Is this a bug?
    func loadScores(leaderboardType: LeaderboardsPage.LeaderboardType, level: Int, completion: @escaping ([Score]) -> Void) {
        guard GKLocalPlayer.local.isAuthenticated else { return print("Unable to fetch leaderboard! Player is not authenticated!!!") }
        guard !isLoadingScores else { return print("Scores are currently loading. Returning from loadScores() function.") }
        
        scores = []
        isLoadingScores = true
        shouldCancelLeaderboards = false
        
        if #available(iOS 14.0, *) {
            GKLeaderboard.loadLeaderboards(IDs: leaderboardType == .all ? getAllLeaderboardIDs() : [getLeaderboardLevelID(level)]) { [unowned self] (leaderboards, error) in
                
                guard error == nil else { return print("Error fetching leaderboard: \(error!.localizedDescription)") }
                guard let leaderboards = leaderboards else { return print("Leaderboards are nil!") }
                
                for leaderboard in leaderboards {
                    leaderboard.loadEntries(for: .global, timeScope: .allTime, range: leaderboardType == .all ? NSRange(1...1) : NSRange(1...100)) { [unowned self] (localPlayer, allPlayers, playerCount, error) in
                        
                        guard error == nil else { return print("Error loading scores: \(error!.localizedDescription)") }
                        guard let currentLevel = getLevelFromLeaderboard(leaderboard.baseLeaderboardID) else { return }
                        guard let allPlayers = allPlayers else { return print("All Players array is nil!") }
                        
                        if leaderboardType == .all {
                            guard currentLevel <= level else { return }
                            
                            if populateScores(maxLevel: level,
                                              level: currentLevel,
                                              topPlayer: allPlayers.count > 0 ? allPlayers[0].player.displayName : nil,
                                              playerScore: allPlayers.count > 0 ? allPlayers[0].score : nil) {
                                isLoadingScores = false
                                completion(self.scores)
                            }
                        }
                        else { //leaderboardType == .level
                            guard currentLevel == level else { return }
                            
                            if allPlayers.count <= 0 {
                                isLoadingScores = false
                                completion(self.scores)
                                
                                return
                            }
                            
                            for (index, player) in allPlayers.enumerated() {
                                self.scores.append(Score(level: index + 1,
                                                         username: player.player.displayName,
                                                         score: player.score,
                                                         isLocalPlayer: false))
                                
                                if player == allPlayers.last {
                                    isLoadingScores = false
                                    completion(self.scores)
                                }
                            }
                        }//end if leaderboardType == .all
                        
                    }//end leaderboard.loadEntries()
                }//end for
            }//end GKLeaderboard.loadLeaderboards()
        }//end if #available(iOS 14.0)
        else {
            GKLeaderboard.loadLeaderboards { [unowned self] (leaderboards, error) in
                guard error == nil else { return print("Error fetching leaderboard: \(error!.localizedDescription)") }
                guard let leaderboards = leaderboards else { return print("Leaderboards are nil!") }
                
                for leaderboard in leaderboards {
                    leaderboard.playerScope = .global
                    
                    leaderboard.loadScores { [unowned self] (scores, error) in
                        guard error == nil else { return print("Error loading scores: \(error!.localizedDescription)") }
                        guard let currentLevel = getLevelFromLeaderboard(leaderboard.identifier ?? "-1") else { return }
                        
                        if leaderboardType == .all {
                            guard currentLevel <= level else { return }
                            
                            if populateScores(maxLevel: level,
                                              level: currentLevel,
                                              topPlayer: scores != nil ? scores![0].player.displayName : nil,
                                              playerScore: scores != nil ? Int(scores![0].value) : nil) {
                                isLoadingScores = false
                                completion(self.scores)
                            }
                        }
                        else {
                            guard currentLevel == level else { return }
                            guard let scores = scores, scores.count > 0 else {
                                isLoadingScores = false
                                completion(self.scores)
                                
                                return print("Scores array is nil!")
                            }
                            
                            for (index, score) in scores.enumerated() {
                                self.scores.append(Score(level: index + 1,
                                                         username: score.player.displayName,
                                                         score: Int(score.value),
                                                         isLocalPlayer: false))
                                
                                if score == scores.last {
                                    isLoadingScores = false
                                    completion(self.scores)
                                }
                            }
                        }//end if leaderboardType == .all
                        
                    }//end leaderboard.loadScores()
                }//end for
            }//end GKLeaderboard.loadLeaderboards()
        }//end else
    }//end func loadScoresByLevel()
    
    private func populateScores(maxLevel: Int, level: Int, topPlayer: String?, playerScore: Int?) -> Bool {
        scores.append(Score(level: level, username: topPlayer, score: playerScore, isLocalPlayer: topPlayer == GKLocalPlayer.local.displayName))
        
        if scores.count >= maxLevel {
            scores.sort(by: { $0.level < $1.level })
            
            return true
        }
        else {
            return false
        }
    }
    
    private func getLeaderboardLevelID(_ level: Int) -> String {
        let levelString = String(format: "%04d", level) //4 digit level, with leading zeroes
        
        return leaderboardLevelIDPrefix + levelString
    }
    
    private func getAllLeaderboardIDs() -> [String] {
        var ids: [String] = []

        for i in 0...Level.finalLevel {
            ids.append(getLeaderboardLevelID(i))
        }
        
        return ids
    }
    
    private func getLevelFromLeaderboard(_ id: String) -> Int? {
        return Int(id.suffix(4))
    }
    
    
    // MARK: - Achievement Functions
    
    /**
     Loads all the achievements and achievement descriptions and returns them for further processing.
     - parameter completion: completion handler that returns all the achievements and achievement descriptions for further processing.
     */
    func loadAchievements(completion: (([GKAchievement], [GKAchievementDescription]) -> Void)?) {
        GKAchievement.loadAchievements { achievements, error in
            guard error == nil else { return print("Error loading achievements: \(error!.localizedDescription)") }
            guard let achievements = achievements else { return }

            GKAchievementDescription.loadAchievementDescriptions { achievementDescriptions, error in
                guard error == nil else { return print("Error loading achievement descriptions: \(error!.localizedDescription)") }
                guard let achievementDescriptions = achievementDescriptions else { return }
                
                completion?(achievements, achievementDescriptions)
            }
        }
    }
    
    /**
     Loads the specified achievement and achievement description from the requested identifier and returns it for further processing.
     - parameters:
        - identifier: the achievement identifier in the format 'PUZL.BoyAchievementNAME' where NAME is the specific achievement.
        - completion: completion handler that returns the specific achievement and achievement description for further processing.
     */
    func loadAchievementForIdentifier(_ identifier: String, completion: ((GKAchievement, GKAchievementDescription) -> Void)?) {
        GKAchievement.loadAchievements { achievements, error in
            guard error == nil else { return print("Error loading achievements: \(error!.localizedDescription)") }
            guard let achievements = achievements else { return }
            guard let achievement = achievements.filter({ $0.identifier == identifier }).first else { return print("Achievement \"\(identifier)\" not found.") }
            
            GKAchievementDescription.loadAchievementDescriptions { achievementDescriptions, error in
                guard error == nil else { return print("Error loading achievement descriptions: \(error!.localizedDescription)") }
                guard let achievementDescriptions = achievementDescriptions else { return }
                guard let achievementDescription = achievementDescriptions.filter({ $0.identifier == identifier }).first else { return }
                
                completion?(achievement, achievementDescription)
            }
        }
    }
    
    ///Loads all the achievements (not achievement descriptions) and runs a percentage update from the Achievements custom class. This function does not return anything, nor does it get a handle on the achievements object, so it's mainly used for setup upon app initialization.
    func loadAchievements() {
        Achievement.initAchievements()
        
        GKAchievement.loadAchievements { achievements, error in
            guard error == nil else { return print("Error loading achievements: \(error!.localizedDescription)") }
            guard let achievements = achievements else { return }
            
            Achievement.updateAchievements(achievements)
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
        
        if Achievement.isPUZLMasterAchieved() {
            //This should only be run once. Achievement.isPUZLMasterAchieved() will not run again if PUZL Master Achievement is already obtained.
            print("Congrats!!! You beat the game! You are the PUZL Master!!")
            updateProgress(achievement: .puzlMaster, shouldReportImmediately: true)
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
            print("GameCenterManager.resetAchivements()...... DONE!")
        }
    }
}


// MARK: - GKLocalPlayerListener

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


// MARK: - GKGameCenterControllerDelegate

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
