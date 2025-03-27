//
//  FinalBattle2Background.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/29/24.
//

import SpriteKit

class FinalBattle2Background {
    
    // MARK: - Properties
    
    static let keyInfinityFadeOut = "keyInfinityFadeOut"
    static let keyInfinityRainbow = "keyInfinityRainbow"
    static let keyEndGateMagicFadeOut = "keyEndGateMagicFadeOut"
    static let keyEndGateMagicRainbow = "keyEndGateMagicRainbow"
    
    static var defaultBloodOverlayAlpha: CGFloat = 0.25
    private var shieldColor: UIColor = .red
    
    private var backgroundSprite: SKSpriteNode
    private var bloodOverlay: SKSpriteNode
    private var infinityOverlay: SKSpriteNode
    private var flashGameboard: SKSpriteNode
    private var gameboard: GameboardSprite
    
    private var overworldMusicVolume: Float = 1
    private var overworldMusic: String
    private var rainbowMusic: String
    
    var isRunningSword8: Bool = false {
        didSet {
            if isRunningSword8 {
                guard oldValue != isRunningSword8 else { return }
                initializeSword8()
            }
            else {
                expireSword8()
            }
        }
    }
    
    enum BackgroundPattern {
        case normal, blackout, wave, convulse, princess, rainbow
    }
    
    
    // MARK: - Initialization
    
    init(backgroundSprite: SKSpriteNode, bloodOverlay: SKSpriteNode, infinityOverlay: SKSpriteNode, flashGameboard: SKSpriteNode, gameboard: GameboardSprite) {
        self.backgroundSprite = backgroundSprite
        self.bloodOverlay = bloodOverlay
        self.infinityOverlay = infinityOverlay
        self.flashGameboard = flashGameboard
        self.gameboard = gameboard
        
        overworldMusic = "bossbattle3"
        rainbowMusic = "overworldrainbow"
    }
    
    deinit {
        print("deinit FinalBattle2Background")
        
        stopAllMusic(fadeDuration: 2)
    }
    
    
    // MARK: - Functions
    
    /**
     Adjusts the overworld music to the set volume and fadeDuration
     - parameters:
        - volume: the new volume to set
        - shouldAdjust: if true, also adjust the overworldMusic volume, otherwise, don't.
        - fadeDuration: a fading time interval
     */
    func setOverworldMusicVolume(to volume: Float, shouldAdjust: Bool = true, fadeDuration: TimeInterval = 0) {
        overworldMusicVolume = volume
        
        if shouldAdjust {
            AudioManager.shared.adjustVolume(to: overworldMusicVolume, for: overworldMusic, fadeDuration: fadeDuration)
        }
    }
    
    /**
     Updates the shieldColor, i.e. if Magmoor's shield is damaged.
     */
    func updateShieldColor(_ newColor: UIColor) {
        self.shieldColor = newColor
    }
    
    /**
     Plays the overworld music. Call this at the battle start.
     */
    func playOverworldMusic() {
        setOverworldMusicVolume(to: 1)
        AudioManager.shared.playSound(for: overworldMusic)
        AudioManager.shared.stopSound(for: rainbowMusic)
    }
    
    /**
     Stops the overworld and rainbow music.
     */
    func stopAllMusic(fadeDuration: TimeInterval) {
        AudioManager.shared.stopSound(for: overworldMusic, fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: rainbowMusic, fadeDuration: fadeDuration)
    }
    
    /**
     Switch between overworld and rainbow music.
     - parameter toOverworld: switches to overworld, if true
     */
    func switchMusic(toOverworld: Bool) {
        let fadeDuration: TimeInterval = 2
        
        if toOverworld {
            AudioManager.shared.adjustVolume(to: overworldMusicVolume, for: overworldMusic, fadeDuration: fadeDuration)
            AudioManager.shared.stopSound(for: rainbowMusic, fadeDuration: fadeDuration)
        }
        else {
            AudioManager.shared.adjustVolume(to: 0, for: overworldMusic)
            AudioManager.shared.playSound(for: rainbowMusic)
        }
    }
    
    /**
     Animates the background with the requested pattern.
     - parameters:
        - pattern: the background pattern of animations
        - fadeDuration: the duration of the fade into the pattern
        - delay: add a delay, esp. when adjusting overworld music
        - shouldFlashGameboard: true if gameboard should flash a white color
     */
    func animate(pattern: BackgroundPattern, fadeDuration: TimeInterval, delay: TimeInterval?, shouldFlashGameboard: Bool = false) {
        backgroundSprite.removeAllActions()
        bloodOverlay.removeAllActions()
        flashGameboard.removeAllActions()
        
        switch pattern {
        case .normal:
            let flashDuration: TimeInterval = min(0.25, fadeDuration)
            
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (delay ?? 0)) {
                    self.setOverworldMusicVolume(to: 1, shouldAdjust: !self.isRunningSword8, fadeDuration: fadeDuration)
                }
            }
            else {
                flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
            }
        case .blackout:
            let flashGameboardAlpha: CGFloat = 0.75
            
            backgroundSprite.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
            backgroundSprite.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration))

            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
            
            flashGameboard.run(SKAction.sequence([
                SKAction.colorize(with: .black, colorBlendFactor: 1, duration: 0),
                SKAction.fadeAlpha(to: flashGameboardAlpha, duration: fadeDuration)
            ]))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (delay ?? 0)) {
                self.setOverworldMusicVolume(to: 0.1, shouldAdjust: !self.isRunningSword8, fadeDuration: fadeDuration)
            }
        case .wave:
            let magmoorColors: (first: UIColor, second: UIColor) = (shieldColor, UIColor.black)
            let pulseDuration: TimeInterval = 2
            let flashGameboardAlpha: CGFloat = 0.5
            
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
            let magmoorColors: (first: UIColor, second: UIColor) = (shieldColor, UIColor.black)
            let pulseDuration: TimeInterval = 0.04
            let flashGameboardAlpha: CGFloat = 0.5
            
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
        default:
            break
//        case .princess:
//            let princessColors: (first: UIColor, second: UIColor) = (UIColor.magenta, UIColor.white)
//            let pulseDuration: TimeInterval = 0.08
//            
//            overworldMusic = "bossbattle2"
//            
//            backgroundSprite.run(SKAction.fadeAlpha(to: 0.8, duration: fadeDuration))
//            backgroundSprite.run(SKAction.sequence([
//                SKAction.colorize(with: princessColors.first, colorBlendFactor: 1, duration: fadeDuration),
//                SKAction.repeatForever(SKAction.sequence(
//                    cycleColors(colors: [princessColors.second, princessColors.first],
//                                blendFactor: 1,
//                                duration: pulseDuration,
//                                shouldBlink: false)
//                ))
//            ]))
//            
//            bloodOverlay.run(SKAction.fadeAlpha(to: FinalBattle2Background.defaultBloodOverlayAlpha, duration: fadeDuration))
//            bloodOverlay.run(SKAction.sequence([
//                SKAction.colorize(with: princessColors.second, colorBlendFactor: 1, duration: fadeDuration),
//                SKAction.repeatForever(SKAction.sequence(
//                    cycleColors(colors: [princessColors.first, princessColors.second],
//                                blendFactor: 1,
//                                duration: pulseDuration,
//                                shouldBlink: false)
//                ))
//            ]))
//
//            flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
//        case .rainbow:
//            let shiftDuration: TimeInterval = PartyModeSprite.shared.quarterNote
//            
//            overworldMusic = ThemeManager.getAudio(theme: .party, sound: .overworld)
//            
//            backgroundSprite.run(SKAction.fadeAlpha(to: 0.5, duration: fadeDuration))
//            backgroundSprite.run(SKAction.sequence([
//                SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
//                SKAction.colorize(with: .clear, colorBlendFactor: 1, duration: shiftDuration),
//                SKAction.repeatForever(SKAction.sequence(
//                    cycleColors(colors: [.yellow, .green, .blue, .red],
//                                blendFactor: 1,
//                                duration: shiftDuration,
//                                shouldBlink: true)
//                ))
//            ]))
//            
//            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
//
//            flashGameboard.run(SKAction.fadeAlpha(to: 0.35, duration: fadeDuration))
//            flashGameboard.run(SKAction.sequence([
//                SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
//                SKAction.colorize(with: .clear, colorBlendFactor: 1, duration: shiftDuration / 2),
//                SKAction.repeatForever(SKAction.sequence(
//                    cycleColors(colors: UIColor.rainbowColors,
//                                blendFactor: 1,
//                                duration: shiftDuration / 2,
//                                shouldBlink: false)
//                ))
//            ]))
        } //end switch pattern
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
    
    ///Helper function for isRunningSword8 didSet
    private func initializeSword8() {
        switchMusic(toOverworld: false)
        
        infinityOverlay.removeAction(forKey: FinalBattle2Background.keyInfinityFadeOut)
        infinityOverlay.run(SKAction.fadeAlpha(to: 0.5, duration: 0))
        infinityOverlay.run(SKAction.repeatForever(SKAction.colorizeWithRainbowColorSequence(blendFactor: 1, duration: 0.25)), withKey: FinalBattle2Background.keyInfinityRainbow)
        
        if let endGateMagic = gameboard.sprite.childNode(withName: "endGateMagic") as? SKSpriteNode {
            endGateMagic.removeAction(forKey: FinalBattle2Background.keyEndGateMagicFadeOut)
            endGateMagic.run(SKAction.fadeIn(withDuration: 1))
            endGateMagic.run(SKAction.repeatForever(SKAction.colorizeWithRainbowColorSequence(duration: 0.25)), withKey: FinalBattle2Background.keyEndGateMagicRainbow)
        }
    }
    
    ///Helper function for isRunningSword8 didSet
    private func expireSword8() {
        switchMusic(toOverworld: true)
        
        infinityOverlay.removeAction(forKey: FinalBattle2Background.keyInfinityRainbow)
        infinityOverlay.run(SKAction.fadeOut(withDuration: 2), withKey: FinalBattle2Background.keyInfinityFadeOut)
        
        if let endGateMagic = gameboard.sprite.childNode(withName: "endGateMagic") as? SKSpriteNode {
            endGateMagic.removeAction(forKey: FinalBattle2Background.keyEndGateMagicRainbow)
            endGateMagic.run(SKAction.fadeOut(withDuration: 2), withKey: FinalBattle2Background.keyEndGateMagicFadeOut)
        }
    }
    
    
}
