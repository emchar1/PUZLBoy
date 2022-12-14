//
//  Haptics.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/13/22.
//

import UIKit
import CoreHaptics

struct Haptics {
    static var engine: CHHapticEngine?
    
    /**
     Adds a haptic feedback vibration.
     - parameter style: style of feedback to produce
     */
    static func addHapticFeedback(withStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
//        guard !K.muteOn else { return }
            
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func startHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    static func executeHapticPattern() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        guard !K.muteOn else { return }
        
        var events = [CHHapticEvent]()
        
        for index in stride(from: 0.1, to: 0.3, by: 0.05) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: index)
            
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)

            try player?.start(atTime: 0)
        } catch {
            print(error)
        }
        
        // The engine stopped; print out why
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = {
            print("The engine reset")

            do {
                try engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
}

