//
//  Achievement.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/20/22.
//

import GameKit

enum Achievement: String, CaseIterable {
    
    // MARK: - Cases
    
    //Add achievements as we go, here.
    case dragonSlayer = "DragonSlayer"
    case boulderBreaker = "BoulderBreaker"
    case gemCollector = "GemCollector"
    
    
    // MARK: - Properties
    
    private static let achievementIDPrefix = "PUZLBoy.Achievement"
    static var achievements: [Achievement: BaseAchievement] = [:]
    
    
    // MARK: - Functions
    
    static func initAchievements() {
        achievements = [:]
        
        for achievement in allCases {
            achievements[achievement] = factory(achievement: achievement)
        }
        
        print("Initialized Achievement.achievements dictionary.")
    }
    
    static func updateAchievements(_ achievements: [GKAchievement]) {
        for gkAchievement in achievements {
            guard let achievement = Achievement(rawValue: getAchievementRawValue(from: gkAchievement.identifier)) else {
                print("Unknown achievement identifier: \(gkAchievement.identifier)")
                continue
            }
            
            self.achievements[achievement]?.percentComplete = gkAchievement.percentComplete
        }
    }
    
    
    // MARK: - Helper Functions
    
    private static func factory(achievement: Achievement) -> BaseAchievement {
        let gkAchievement: BaseAchievement
        let id = achievementIDPrefix + achievement.rawValue
        
        //Add achievements as we go, here.
        switch achievement {
        case .dragonSlayer:         gkAchievement = AchievementDragonSlayer(identifier: id)
        case .boulderBreaker:       gkAchievement = AchievementBoulderBreaker(identifier: id)
        case .gemCollector:         gkAchievement = AchievementGemCollector(identifier: id)
        }
        
        gkAchievement.showsCompletionBanner = true
        
        return gkAchievement
    }
    
    private static func getAchievementRawValue(from identifier: String) -> String {
        guard identifier.contains(achievementIDPrefix) else { return "" }
        
        return String(identifier.dropFirst(achievementIDPrefix.count))
    }
}
