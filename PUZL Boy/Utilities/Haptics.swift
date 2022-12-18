//
//  Haptics.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/13/22.
//

import UIKit
import CoreHaptics

class Haptics {
    
    // MARK: - Properties
    
    //Transformed this into a singleton class, just to see the difference... 12/18/22
    static let shared: Haptics = {
        let instance = Haptics()
        //additional setup, if needed
        return instance
    }()
    
    var engine: CHHapticEngine?
    
    enum Pattern {
        case enemy, killEnemy, boulder, breakBoulder, marsh
    }
    
    
    // MARK: - Initialization
    
    /**
     Private init ensures only one instance of Haptics exists in the entire app.
     */
    private init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        startHapticEngine(shouldInitialize: true)
    }
    
    
    // MARK: - Functions
    
    func startHapticEngine(shouldInitialize: Bool) {
        do {
            if shouldInitialize {
                engine = try CHHapticEngine()
                print("Initialized the Haptics engine.")
            }
            
            try engine?.start()
            print("Started haptic engine.")
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    /**
     Adds a haptic feedback vibration.
     - parameter style: style of feedback to produce
     */
    func addHapticFeedback(withStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
//        guard !K.muteOn else { return }
            
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func executeCustomPattern(pattern: Pattern) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        guard !K.muteOn else { return }
        
        var events = [CHHapticEvent]()
        
        switch pattern {
        case .enemy:
            for index in stride(from: 0.1, to: 0.3, by: 0.05) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .killEnemy:
            for index in stride(from: 0.3, to: 0.6, by: 0.01) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .boulder:
            addHapticFeedback(withStyle: .rigid)
        case .breakBoulder:
            for index in stride(from: 0.2, to: 0.4, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .marsh:
            for index in stride(from: 0.0, to: 0.7, by: 0.03) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)

            try player?.start(atTime: 0)
        } catch {
            print(error)
        }
        
        // The engine stopped; print out why
        engine?.stoppedHandler = { [unowned self] reason in
            print("The engine stopped: \(reason)")

            // FIXME: - This should work in resetHandler, but it's not starting the engine, so I put it here too. Is this correct???
            startHapticEngine(shouldInitialize: false)
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = { [unowned self] in
            print("The engine reset")

            startHapticEngine(shouldInitialize: false)
        }
    }
}

