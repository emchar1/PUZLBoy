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
        case normal, blackout, princess, rainbow
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
        
        AudioManager.shared.stopSound(for: overworldMusic)
    }
    
    // MARK: - Functions
    
    func animate(pattern: BackgroundPattern, fadeDuration: TimeInterval) {
        func cycleColors(colors: [UIColor], blendFactor: CGFloat, duration: TimeInterval, shouldBlink: Bool) -> [SKAction] {
            var actions: [SKAction] = []
            
            for color in colors {
                actions.append(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: shouldBlink ? 0 : duration))

                if shouldBlink {
                    actions.append(SKAction.colorize(with: .clear, colorBlendFactor: blendFactor, duration: duration))
                }
            }
            
            return actions
        }
        
        previousOverworldMusic = overworldMusic
        
        backgroundSprite.removeAllActions()
        bloodOverlay.removeAllActions()
        flashGameboard.removeAllActions()
        
        switch pattern {
        case .normal:
            overworldMusic = "bossbattle3"
            
            backgroundSprite.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
            backgroundSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration))
            
            bloodOverlay.run(SKAction.fadeAlpha(to: FinalBattle2Background.defaultBloodOverlayAlpha, duration: fadeDuration))
            bloodOverlay.run(SKAction.colorize(with: FireIceTheme.overlayColor, colorBlendFactor: 1, duration: fadeDuration))
            
            flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
        case .blackout:
            backgroundSprite.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
            backgroundSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration))

            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
            
            flashGameboard.run(SKAction.sequence([
                SKAction.colorize(with: .black, colorBlendFactor: 1, duration: 0),
                SKAction.fadeAlpha(to: 0.8, duration: fadeDuration)
            ]))
        case .princess:
            let princessColors: (first: UIColor, second: UIColor) = (UIColor.magenta, UIColor.white)
            let pulseDuration: TimeInterval = 0.08
            
            overworldMusic = AudioManager.ageOfBalanceThemes.overworld
            
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
        
        if previousOverworldMusic != overworldMusic {
            if let previousOverworldMusic = previousOverworldMusic {
                AudioManager.shared.stopSound(for: previousOverworldMusic)
            }
            
            AudioManager.shared.playSound(for: overworldMusic)
        }
    } //end animate()
    
    
}
