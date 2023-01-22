//
//  TimerManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/21/23.
//

import Foundation

class TimerManager {
    
    // MARK: - Properties
    
    private var timeInitial = Date()
    private var timeFinal = Date()
    private var initialElapsedTime: TimeInterval = 0
    
    var elapsedTime: TimeInterval {
        TimeInterval(timeFinal.timeIntervalSince1970 - timeInitial.timeIntervalSince1970)
    }
    
    
    // MARK: - Functions
    
    init(elapsedTime: TimeInterval = 0) {
        initialElapsedTime = elapsedTime
        timeFinal = timeInitial + elapsedTime
    }
    
    func resetTime() {
        initialElapsedTime = 0
        
        timeInitial = Date()
        timeFinal = Date()
    }
    
    func pollTime() {
        timeFinal = Date() + initialElapsedTime
    }
}
