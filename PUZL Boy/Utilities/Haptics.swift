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
        case enemy, killEnemy, boulder, breakBoulder, marsh, sand, snow, lava, water, warp, thunder, enableVibration, statue, heartbeat
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
            }
            
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func stopHapticEngine() {
        engine?.stop()
    }
    
    /**
     Adds a haptic feedback vibration.
     - parameter style: style of feedback to produce
     */
    func addHapticFeedback(withStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard !UserDefaults.standard.bool(forKey: K.UserDefaults.disableVibration) else { return }
            
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func executeCustomPattern(pattern: Pattern) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        guard !UserDefaults.standard.bool(forKey: K.UserDefaults.disableVibration) else { return }

        var events = [CHHapticEvent]()
        
        switch pattern {
        case .enemy:
            for index in stride(from: 0.1, to: 0.4, by: 0.05) {
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
            //Hammer blow
            events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ], relativeTime: 0.2))
            
            //Boulder crumble
            for index in stride(from: 1.0, to: 1.7, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
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
        case .sand, .snow:
            for index in stride(from: 0.0, to: 1.25, by: 0.15) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .lava, .water:
            for index in stride(from: 0.0, to: 1.5, by: 0.05) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .warp:
            for index in stride(from: 0.0, to: 2.0, by: 0.02) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .thunder:
            for index in stride(from: 0.0, to: 24, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .enableVibration:
            for index in stride(from: 0.0, to: 0.3, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .statue:
            for index in stride(from: 0.0, to: 0.6, by: 0.2) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
            
            for index in stride(from: 0.6, to: 0.8, by: 0.01) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
                
                events.append(event)
            }
        case .heartbeat:
            let beat1 = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                                                   CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)],
                                      relativeTime: 0)
            let beat2 = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                                                   CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)],
                                      relativeTime: 0.4)
            
            events.append(beat1)
            events.append(beat2)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)

            try player?.start(atTime: 0)
        } catch {
            print("There was an error executing a custom pattern: \(error.localizedDescription)")
            
            //BUGFIX# 230913E01 because stoppedHandler and resetHandler below weren't calling when the engine was stopped and needed to be reset!
            startHapticEngine(shouldInitialize: false)
        }
        
//        // The engine stopped; print out why
//        engine?.stoppedHandler = { [weak self] reason in
//            self?.startHapticEngine(shouldInitialize: false)
//        }
//
//        // If something goes wrong, attempt to restart the engine immediately
//        engine?.resetHandler = { [weak self] in
//            self?.startHapticEngine(shouldInitialize: false)
//        }
    }
}

