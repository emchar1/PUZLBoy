//
//  FinalBattle2Background.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/29/24.
//

import SpriteKit

class FinalBattle2Background {
    
    // MARK: - Properties
    
    static let defaultBloodOverlayAlpha: CGFloat = 0.25
    
    private var backgroundSprite: SKSpriteNode
    private var bloodOverlay: SKSpriteNode
    private var flashGameboard: SKSpriteNode

    private var overworldMusic: String
    private var previousOverworldMusic: String?
    
    enum BackgroundPattern {
        case normal, blackout, wave, convulse, princess, rainbow
    }
    
    
    // MARK: - Initialization
    
    init(backgroundSprite: SKSpriteNode, bloodOverlay: SKSpriteNode, flashGameboard: SKSpriteNode) {
        self.backgroundSprite = backgroundSprite
        self.bloodOverlay = bloodOverlay
        self.flashGameboard = flashGameboard
        
        overworldMusic = "bossbattle1"
        previousOverworldMusic = nil
    }
    
    deinit {
        print("deinit FinalBattle2Background")
        
        AudioManager.shared.stopSound(for: overworldMusic, fadeDuration: 2)
    }
    
    // MARK: - Functions
    
    /**
     Adjusts the overworld music to the set volume and fadeDuration
     - parameters:
        - volume: volume to set the overworld music
        - fadeDuration: a fading time interval
     **/
    func adjustOverworldMusic(volume: Float = 1, fadeDuration: TimeInterval = 0) {
        AudioManager.shared.adjustVolume(to: volume, for: overworldMusic, fadeDuration: fadeDuration)
    }
    
    /**
     Animates the background with the requested pattern.
     - parameters:
        - pattern: the background pattern of animations
        - fadeDuration: the duration of the fade into the pattern
        - shouldFlashGameboard: true if gameboard should flash a white color
     */
    func animate(pattern: BackgroundPattern, fadeDuration: TimeInterval, shouldFlashGameboard: Bool = false) {
        previousOverworldMusic = overworldMusic
        
        backgroundSprite.removeAllActions()
        bloodOverlay.removeAllActions()
        flashGameboard.removeAllActions()
        
        switch pattern {
        case .normal:
            let flashDuration: TimeInterval = min(0.25, fadeDuration)
            
            overworldMusic = "bossbattle3"
            
            backgroundSprite.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
            backgroundSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration))
            
            bloodOverlay.run(SKAction.fadeAlpha(to: FinalBattle2Background.defaultBloodOverlayAlpha, duration: fadeDuration))
            bloodOverlay.run(SKAction.sequence([
                SKAction.colorize(with: .black, colorBlendFactor: 1, duration: 0),
                SKAction.colorize(with: FireIceTheme.overlayColor, colorBlendFactor: 1, duration: fadeDuration)
            ]))
            
            if shouldFlashGameboard {
                flashGameboard.run(SKAction.sequence([
                    flashGameboardAction(color: .white, fadeAlpha: 1, duration: flashDuration),
                    SKAction.fadeOut(withDuration: fadeDuration - flashDuration)
                ]))
                
                adjustOverworldMusic(volume: 1, fadeDuration: fadeDuration)
            }
            else {
                flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
            }
        case .blackout:
            backgroundSprite.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
            backgroundSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration))

            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
            
            flashGameboard.run(SKAction.sequence([
                SKAction.colorize(with: .black, colorBlendFactor: 1, duration: 0),
                SKAction.fadeAlpha(to: 0.8, duration: fadeDuration)
            ]))
            
            adjustOverworldMusic(volume: 0.1, fadeDuration: fadeDuration)
        case .wave:
            let magmoorColors: (first: UIColor, second: UIColor) = (UIColor.red, UIColor.black)
            let pulseDuration: TimeInterval = 2
            let flashGameboardAlpha: CGFloat = 0.8
            
            backgroundSprite.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
            backgroundSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration))
            
            bloodOverlay.run(SKAction.fadeAlpha(to: FinalBattle2Background.defaultBloodOverlayAlpha, duration: fadeDuration))
            bloodOverlay.run(SKAction.repeatForever(SKAction.sequence(
                cycleColors(colors: [magmoorColors.first, magmoorColors.second],
                            blendFactor: 1,
                            duration: pulseDuration,
                            shouldBlink: false)
            )))
            
            if shouldFlashGameboard {
                flashGameboard.run(flashGameboardAction(color: .white, fadeAlpha: flashGameboardAlpha, duration: 0.25))
            }
            else {
                flashGameboard.run(SKAction.group([
                    SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration),
                    SKAction.fadeAlpha(to: flashGameboardAlpha, duration: fadeDuration)
                ]))
            }
        case .convulse:
            let magmoorColors: (first: UIColor, second: UIColor) = (UIColor.red, UIColor.black)
            let pulseDuration: TimeInterval = 0.04
            let flashGameboardAlpha: CGFloat = 0.8
            
            backgroundSprite.run(SKAction.fadeAlpha(to: 1, duration: pulseDuration))
            backgroundSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: pulseDuration))
            
            bloodOverlay.run(SKAction.fadeAlpha(to: 0.5, duration: fadeDuration))
            bloodOverlay.run(SKAction.repeatForever(SKAction.sequence(
                cycleColors(colors: [magmoorColors.first, magmoorColors.second],
                            blendFactor: 1,
                            duration: pulseDuration,
                            shouldBlink: true)
            )))
            
            if shouldFlashGameboard {
                flashGameboard.run(flashGameboardAction(color: .white, fadeAlpha:flashGameboardAlpha, duration: 0.25))
            }
            else {
                flashGameboard.run(SKAction.group([
                    SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration),
                    SKAction.fadeAlpha(to: flashGameboardAlpha, duration: fadeDuration)
                ]))
            }
        case .princess:
            let princessColors: (first: UIColor, second: UIColor) = (UIColor.magenta, UIColor.white)
            let pulseDuration: TimeInterval = 0.08
            
            overworldMusic = "bossbattle2"
            
            backgroundSprite.run(SKAction.fadeAlpha(to: 0.8, duration: fadeDuration))
            backgroundSprite.run(SKAction.sequence([
                SKAction.colorize(with: princessColors.first, colorBlendFactor: 1, duration: fadeDuration),
                SKAction.repeatForever(SKAction.sequence(
                    cycleColors(colors: [princessColors.second, princessColors.first],
                                blendFactor: 1,
                                duration: pulseDuration,
                                shouldBlink: false)
                ))
            ]))
            
            bloodOverlay.run(SKAction.fadeAlpha(to: FinalBattle2Background.defaultBloodOverlayAlpha, duration: fadeDuration))
            bloodOverlay.run(SKAction.sequence([
                SKAction.colorize(with: princessColors.second, colorBlendFactor: 1, duration: fadeDuration),
                SKAction.repeatForever(SKAction.sequence(
                    cycleColors(colors: [princessColors.first, princessColors.second],
                                blendFactor: 1,
                                duration: pulseDuration,
                                shouldBlink: false)
                ))
            ]))

            flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
        case .rainbow:
            let shiftDuration: TimeInterval = PartyModeSprite.shared.quarterNote
            
            overworldMusic = AudioManager.partyThemes.overworld
            
            backgroundSprite.run(SKAction.fadeAlpha(to: 0.5, duration: fadeDuration))
            backgroundSprite.run(SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
                SKAction.colorize(with: .clear, colorBlendFactor: 1, duration: shiftDuration),
                SKAction.repeatForever(SKAction.sequence(
                    cycleColors(colors: [.yellow, .green, .blue, .red],
                                blendFactor: 1,
                                duration: shiftDuration,
                                shouldBlink: true)
                ))
            ]))
            
            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))

            flashGameboard.run(SKAction.fadeAlpha(to: 0.35, duration: fadeDuration))
            flashGameboard.run(SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
                SKAction.colorize(with: .clear, colorBlendFactor: 1, duration: shiftDuration / 2),
                SKAction.repeatForever(SKAction.sequence(
                    cycleColors(colors: [.orange, .yellow, .green, .cyan, .blue, .purple, .systemPink, .red],
                                blendFactor: 1,
                                duration: shiftDuration / 2,
                                shouldBlink: false)
                ))
            ]))
        } //end switch pattern
        
        //Sets the overworld music, if previous overworld music was something different.
        if previousOverworldMusic != overworldMusic {
            if let previousOverworldMusic = previousOverworldMusic {
                AudioManager.shared.stopSound(for: previousOverworldMusic)
            }
            
            AudioManager.shared.playSound(for: overworldMusic)
        }
    } //end animate()
        
    
    // MARK: - Helper Animate Functions
    
    private func cycleColors(colors: [UIColor], blendFactor: CGFloat, duration: TimeInterval, shouldBlink: Bool) -> [SKAction] {
        var actions: [SKAction] = []
        
        for color in colors {
            actions.append(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: shouldBlink ? 0 : duration))

            if shouldBlink {
                actions.append(SKAction.colorize(with: .clear, colorBlendFactor: blendFactor, duration: duration))
            }
        }
        
        return actions
    }
    
    private func flashGameboardAction(color: UIColor, fadeAlpha: CGFloat, duration: TimeInterval) -> SKAction {
        return SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0),
            SKAction.fadeIn(withDuration: 0),
            SKAction.group([
                SKAction.colorize(with: .black, colorBlendFactor: 1, duration: duration),
                SKAction.fadeAlpha(to: fadeAlpha, duration: duration)
            ])
        ])
    }
    
    
}
