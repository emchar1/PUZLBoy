//
//  TimerManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/21/23.
//

import Foundation

class TimerManager {
    
    // MARK: - Properties
    
    private let partyLevelTime: TimeInterval = 60.9
    private var isParty = false
    private var timeInitial = Date()
    private var timeFinal = Date()
    var milliseconds: Int { Int(elapsedTime * 10) % 10 }

    var elapsedTime: TimeInterval {
        TimeInterval(timeFinal.timeIntervalSinceNow - timeInitial.timeIntervalSinceNow)
    }
    
    var formattedText: String {
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        var returnString: String
        
        if isParty && minutes <= 0 {
            let randomHundredth = elapsedTime <= 0 ? 0 : Int.random(in: 0...9)
            
            returnString = String(format: "%02i.%i%i", seconds, milliseconds, randomHundredth)
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
        timeFinal = isParty ? Date(timeIntervalSinceNow: partyLevelTime) : Date()
    }
    
    func pollTime() {
        if isParty {
            timeInitial = Date()
        }
        else {
            timeFinal = Date()
        }
    }
    
    func pauseTime() {
        pollTime()
    }
    
    func resumeTime() {
        if isParty {
            timeFinal = Date(timeIntervalSinceNow: elapsedTime)
        }
        else {
            timeInitial = Date(timeIntervalSinceNow: -elapsedTime)
        }
        
        pollTime()
    }
    
    func addTime(_ seconds: TimeInterval) {
        guard isParty else { return print("Can only add time in a bonus level") }

        timeFinal += seconds
    }
    
    func killTime() {
        guard isParty else { return print("Can only kill time in a bonus level") }
        
        timeInitial = Date()
        timeFinal = Date()
    }
    
    func setIsParty(_ isParty: Bool) {
        self.isParty = isParty

        if isParty {
            resetTime()
        }
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
