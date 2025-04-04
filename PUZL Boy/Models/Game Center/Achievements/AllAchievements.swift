//
//  AllAchievements.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/3/25.
//

import Foundation

class AchievementAvidReader: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Avid Reader: \(percentComplete)")
    }
}

class AchievementExterminator: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 100

    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Exterminator: \(percentComplete)")
    }
}

class AchievementDragonSlayer: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 200

    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Dragon Slayer: \(percentComplete)")
    }
}

class AchievementBeastMaster: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 550
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Beast Master: \(percentComplete)")
    }
}

class AchievementStoneCutter: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 25
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Stone Cutter: \(percentComplete)")
    }
}

class AchievementBoulderBreaker: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 125
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Boulder Breaker: \(percentComplete)")
    }
}

class AchievementRockNRoller: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 450
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Rock n Roller: \(percentComplete)")
    }
}

class AchievementGemCollector: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 150
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Gem Collector: \(percentComplete)")
    }
}

class AchievementJewelConnoisseur: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 1200
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Jewel Connoisseur: \(percentComplete)")
    }
}

class AchievementMyPreciouses: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 3000
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for My Preciouses: \(percentComplete)")
    }
}

class AchievementHotToTrot: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Hot To Trot: \(percentComplete)")
    }
}

class AchievementOnFire: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for On Fire: \(percentComplete)")
    }
}

class AchievementNuclear: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Nuclear: \(percentComplete)")
    }
}

class AchievementBraniac: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Braniac: \(percentComplete)")
    }
}

class AchievementEnigmatologist: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Enigmatologist: \(percentComplete)")
    }
}

class AchievementPUZLGuru: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for PUZL Guru: \(percentComplete)")
    }
}

class AchievementScavenger: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 20

    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Scavenger: \(percentComplete)")
    }
}

class AchievementItemWielder: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 80

    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Item Wielder: \(percentComplete)")
    }
}

class AchievementHoarder: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Hoarder: \(percentComplete)")
    }
}

class AchievementKlutz: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 100
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Klutz: \(percentComplete)")
    }
}

class AchievementReckless: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 50
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for Reckless: \(percentComplete)")
    }
}

class AchievementSuperEfficient: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 35
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for SuperEfficient: \(percentComplete)")
    }
}

class AchievementSpeedDemon: BaseAchievement, @unchecked Sendable {
    static let levelRequirement: Int = 80
    static let timeRequirement: TimeInterval = 6
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Speed Demon: \(percentComplete)")
    }
}

class AchievementSlowPoke: BaseAchievement, @unchecked Sendable {
    static let levelRequirement: Int = 80
    static let timeRequirement: TimeInterval = 15 * 60
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for Slow Poke: \(percentComplete)")
    }
}

class AchievementAdMobster: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 50
    
    override func updatePercentage(increment: Double = 1) {
        percentComplete += increment / requirement * 100
        print("Percent complete for AdMobster: \(percentComplete)")
    }
}

class AchievementBigSpender: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 5
    
    override func updatePercentage(increment: Double = 0.99) {
        percentComplete += increment / requirement * 100
        print("Percent complete for BigSpender: \(percentComplete)")
    }
}

class AchievementEndlessWallet: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 10
    
    override func updatePercentage(increment: Double = 0.99) {
        percentComplete += increment / requirement * 100
        print("Percent complete for EndlessWallet: \(percentComplete)")
    }
}

class AchievementFatCat: BaseAchievement, @unchecked Sendable {
    let requirement: Double = 20
    
    override func updatePercentage(increment: Double = 0.99) {
        percentComplete += increment / requirement * 100
        print("Percent complete for FatCat: \(percentComplete)")
    }
}

class AchievementPUZLMaster: BaseAchievement, @unchecked Sendable {
    override func updatePercentage(increment: Double = 1) {
        percentComplete = 100
        print("Percent complete for PUZL Master: \(percentComplete)")
    }
}
