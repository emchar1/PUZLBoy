//
//  LifeSpawnerModel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/12/23.
//

import Foundation

// TODO: - Spawns more lives after time elapsed.
class LifeSpawnerModel {

    // MARK: - Properties
    
    static var shared: LifeSpawnerModel {
        let model = LifeSpawnerModel()
        
        //add'l setup, if needed
        
        return model
    }
    
    private let duration: TimeInterval = 5
    private(set) var spawnTimer: Timer
    
    
    // MARK: - Initialization
    
    init() {
        spawnTimer = Timer()
    }
    
    @objc private func spawnMoreLives(_ sender: Any) {
        print("5 lives granted!!!")
    }
    
    
    // MARK: - Functions
    
    func startTimer() {
        spawnTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(spawnMoreLives), userInfo: nil, repeats: true)
    }
}
