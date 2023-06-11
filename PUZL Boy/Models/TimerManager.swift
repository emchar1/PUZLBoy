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
    
    var elapsedTime: TimeInterval {
        TimeInterval(timeFinal.timeIntervalSinceNow - timeInitial.timeIntervalSinceNow)
    }
    
    var formattedText: String {
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int(elapsedTime * 10) % 10
        var returnString: String
        
        if isParty && minutes <= 0 {
            returnString = String(format: "%02i.%i%i", seconds, milliseconds, Int.random(in: 0...9))
        }
        else {
            returnString = String(format: "%02i:%02i", minutes, seconds)
        }
        
        return returnString
    }
    
    
    // MARK: - Functions
    
    init(elapsedTime: TimeInterval = 0) {
        timeInitial = Date(timeIntervalSinceNow: -elapsedTime)
    }
    
    func resetTime() {
        timeInitial = Date()
        timeFinal = Date()
    }
    
    func pollTime() {
        timeFinal = Date()
    }
    
    func pauseTime() {
        pollTime()
    }
    
    func resumeTime() {
        timeInitial = Date(timeIntervalSinceNow: -elapsedTime)
        pollTime()
    }
    
    private func debugProperties(label: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        print(" === \(label.uppercased()) === ")
        print("timeInitial: \(numberFormatter.string(from: NSNumber(value: timeInitial.timeIntervalSinceNow)) ?? "-9999")")
        print("timeFinal: \(numberFormatter.string(from: NSNumber(value: timeFinal.timeIntervalSinceNow)) ?? "-9999")")
        print("elapsedTime: \(numberFormatter.string(from: NSNumber(value: elapsedTime)) ?? "-9999")")
        print()
    }
}
