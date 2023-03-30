//
//  StoreReviewManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/7/23.
//

import StoreKit

class StoreReviewManager {
    
    // MARK: - Properties
    
    private var reviewCount: Int
    private let reviewMax = 4
    private var levelRestartCount = 0
    private let levelRestartMax = 10
    
    static var shared: StoreReviewManager = {
        let manager = StoreReviewManager()
        
        //Custom initialization
        
        return manager
    }()
    
    
    // MARK: - Initialization
    
    init() {
        reviewCount = UserDefaults.standard.integer(forKey: K.UserDefaults.reviewStoreCount)
    }
    
    
    // MARK: - Functions
        
    ///Run this function in the game loop, i.e. when starting/restarting a (new) level?
    func incrementCount() {
        guard levelRestartCount < levelRestartMax else { return }
        
        levelRestartCount += 1
        print("Incrementing levelRestartCount: \(levelRestartCount)")

        //This should only run once, i.e. when the max is reached, then the guard statement prevents it from running again...
        if levelRestartCount >= levelRestartMax {
            incrementCountAndAskForReview()
        }
    }
    
    private func incrementCountAndAskForReview() {
        reviewCount += 1
        print("App Store Review count has been incremented to \(reviewCount)")
        
        if reviewCount >= reviewMax {
            reviewCount = 0
            SKStoreReviewController.requestReview()
            print("App Store Review requested. Count reset to 0.")
        }

        UserDefaults.standard.set(reviewCount, forKey: K.UserDefaults.reviewStoreCount)
    }
}
