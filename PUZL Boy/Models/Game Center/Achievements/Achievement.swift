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
    case avidReader = "AvidReader"
    case exterminator = "Exterminator"
    case dragonSlayer = "DragonSlayer"
    case beastMaster = "BeastMaster"
    case stoneCutter = "StoneCutter"
    case boulderBreaker = "BoulderBreaker"
    case rockNRoller = "RockNRoller"
    case gemCollector = "GemCollector"
    case jewelConnoisseur = "JewelConnoisseur"
    case myPreciouses = "MyPreciouses"
    case hotToTrot = "HotToTrot"
    case onFire = "OnFire"
    case nuclear = "Nuclear"
    case braniac = "Braniac"
    case enigmatologist = "Enigmatologist"
    case puzlGuru = "PUZLGuru"
    case scavenger = "Scavenger"
    case itemWielder = "ItemWielder"
    case hoarder = "Hoarder"
    case klutz = "Klutz"
    case reckless = "Reckless"
    case superEfficient = "SuperEfficient"
    case speedDemon = "SpeedDemon"
    case slowPoke = "SlowPoke"
    case adMobster = "AdMobster"
    case bigSpender = "BigSpender"
    case endlessWallet = "EndlessWallet"
    case fatCat = "FatCat"
    case puzlMaster = "PUZLMaster"
    
    
    // MARK: - Properties
    
    private static let achievementIDPrefix = "PUZLBoy.Achievement"
    static var achievements: [Achievement: BaseAchievement] = [:]
    static var allAchievements: [BaseAchievement] = []
    
    
    // MARK: - Functions
    
    static func initAchievements() {
        achievements = [:]
        
        for achievement in allCases {
            achievements[achievement] = factory(achievement: achievement)
            allAchievements.append(achievements[achievement]!)
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
    
    static func isPUZLMasterAchieved() -> Bool {
        //First check if PUZL Master has already been obtained...
        if let puzlMasterAchievement = achievements[.puzlMaster], puzlMasterAchievement.isComplete {
            return false
        }

        //...if not, check if all other achievements are complete
        for achievement in allAchievements {
            if !(achievement is AchievementPUZLMaster) && !achievement.isComplete {
                return false
            }
        }
        
        //PUZL Master is achieved!
        print("PUZL Master Achieved!")
        return true
    }
    
    
    // MARK: - Helper Functions
    
    private static func factory(achievement: Achievement) -> BaseAchievement {
        let gkAchievement: BaseAchievement
        let id = achievementIDPrefix + achievement.rawValue
        
        //Add achievements as we go, here.
        switch achievement {
        case .avidReader:           gkAchievement = AchievementAvidReader(identifier: id)
        case .exterminator:         gkAchievement = AchievementExterminator(identifier: id)
        case .dragonSlayer:         gkAchievement = AchievementDragonSlayer(identifier: id)
        case .beastMaster:          gkAchievement = AchievementBeastMaster(identifier: id)
        case .stoneCutter:          gkAchievement = AchievementStoneCutter(identifier: id)
        case .boulderBreaker:       gkAchievement = AchievementBoulderBreaker(identifier: id)
        case .rockNRoller:          gkAchievement = AchievementRockNRoller(identifier: id)
        case .gemCollector:         gkAchievement = AchievementGemCollector(identifier: id)
        case .jewelConnoisseur:     gkAchievement = AchievementJewelConnoisseur(identifier: id)
        case .myPreciouses:         gkAchievement = AchievementMyPreciouses(identifier: id)
        case .hotToTrot:            gkAchievement = AchievementHotToTrot(identifier: id)
        case .onFire:               gkAchievement = AchievementOnFire(identifier: id)
        case .nuclear:              gkAchievement = AchievementNuclear(identifier: id)
        case .braniac:              gkAchievement = AchievementBraniac(identifier: id)
        case .enigmatologist:       gkAchievement = AchievementEnigmatologist(identifier: id)
        case .puzlGuru:             gkAchievement = AchievementPUZLGuru(identifier: id)
        case .scavenger:            gkAchievement = AchievementScavenger(identifier: id)
        case .itemWielder:          gkAchievement = AchievementItemWielder(identifier: id)
        case .hoarder:              gkAchievement = AchievementHoarder(identifier: id)
        case .klutz:                gkAchievement = AchievementKlutz(identifier: id)
        case .reckless:             gkAchievement = AchievementReckless(identifier: id)
        case .superEfficient:       gkAchievement = AchievementSuperEfficient(identifier: id)
        case .speedDemon:           gkAchievement = AchievementSpeedDemon(identifier: id)
        case .slowPoke:             gkAchievement = AchievementSlowPoke(identifier: id)
        case .adMobster:            gkAchievement = AchievementAdMobster(identifier: id)
        case .bigSpender:           gkAchievement = AchievementBigSpender(identifier: id)
        case .endlessWallet:        gkAchievement = AchievementEndlessWallet(identifier: id)
        case .fatCat:               gkAchievement = AchievementFatCat(identifier: id)
        case .puzlMaster:           gkAchievement = AchievementPUZLMaster(identifier: id)
        }
        
        gkAchievement.showsCompletionBanner = true
        
        return gkAchievement
    }
    
    private static func getAchievementRawValue(from identifier: String) -> String {
        guard identifier.contains(achievementIDPrefix) else { return "" }
        
        return String(identifier.dropFirst(achievementIDPrefix.count))
    }
}
