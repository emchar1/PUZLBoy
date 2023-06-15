//
//  TimerManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/21/23.
//

import Foundation

class TimerManager {
    
    // MARK: - Properties
    
    private let partyLevelTime: TimeInterval = 60
    private var isParty = false
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
        
        // FIXME: - partyLevelTime - NOPE! there's a quick blip of the 75 seconds. blink and you miss it.
        //It's fine that this is offset by partyLevelTime because pollTime() resets it to Date() for non-party level. This assumes pollTime will always be called; it doesn't have to, but this game calls it every second.
        timeFinal = Date(timeIntervalSinceNow: partyLevelTime)
        
        //Ideally, but isParty is set AFTER resetTime() causing it to be off sync.
//        timeFinal = isParty ? Date(timeIntervalSinceNow: partyLevelTime) : Date()
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
    
    func setIsParty(_ isParty: Bool) {
        self.isParty = isParty
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
