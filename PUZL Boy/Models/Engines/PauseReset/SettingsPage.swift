//
//  SettingsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/29/23.
//

import SpriteKit

class SettingsPage: SKNode {
    
    // MARK: - Properties
    
    static let nodeName = "settingsPage"
    static let padding: CGFloat = 40
    private var contentSize: CGSize
    private var contentNode: SKSpriteNode
    
    //Radio Buttons
    private var radioMusic: SettingsRadioNode
    private var radioSoundFX: SettingsRadioNode
    private var radioVibrations: SettingsRadioNode
    private var radioPartyLights: SettingsRadioNode

    
    // MARK: - Initialization
    
    init(contentSize: CGSize) {
        self.contentSize = contentSize

        let sectionHeight: CGFloat = 100
        let radioSize = CGSize(width: contentSize.width - 2 * SettingsPage.padding, height: SettingsRadioNode.radioNodeSize.height)
        let radioStart: CGFloat = -SettingsPage.padding - 1.5 * sectionHeight
        
        contentNode = SKSpriteNode(color: .clear, size: contentSize)
        contentNode.anchorPoint = CGPoint(x: 0, y: 1)
        contentNode.position = CGPoint(x: -contentSize.width / 2, y: contentSize.height / 2)
        
        let titleLabel = SKLabelNode(text: "SETTINGS")
        titleLabel.position = CGPoint(x: contentSize.width / 2, y: -SettingsPage.padding)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .top
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeMedium
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.addHeavyDropShadow()
        titleLabel.zPosition = 10
        
        radioMusic = SettingsRadioNode(text: "🎵 Music", settingsSize: radioSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic))
        radioMusic.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height)
        radioMusic.zPosition = 20

        radioSoundFX = SettingsRadioNode(text: "🔈 Sound FX", settingsSize: radioSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteSoundFX))
        radioSoundFX.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - sectionHeight )
        radioSoundFX.zPosition = 20
        
        radioVibrations = SettingsRadioNode(text: "📳 Vibrations", settingsSize: radioSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disableVibrations))
        radioVibrations.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 2 * sectionHeight)
        radioVibrations.zPosition = 20

        radioPartyLights = SettingsRadioNode(text: "🪩 Bonus Level Lights", settingsSize: radioSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disablePartyLights))
        radioPartyLights.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 3 * sectionHeight)
        radioPartyLights.zPosition = 20
        
        super.init()
        
        name = SettingsPage.nodeName
        
        radioMusic.delegate = self
        radioSoundFX.delegate = self
        radioVibrations.delegate = self
        radioPartyLights.delegate = self
        
        addChild(contentNode)
        contentNode.addChild(titleLabel)
        contentNode.addChild(radioMusic)
        contentNode.addChild(radioSoundFX)
        contentNode.addChild(radioVibrations)
        contentNode.addChild(radioPartyLights)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func touchDown(at location: CGPoint) {
        radioMusic.touchDown(in: location)
        radioSoundFX.touchDown(in: location)
        radioVibrations.touchDown(in: location)
        radioPartyLights.touchDown(in: location)
    }
}


// MARK: - SettingsRadioNodeDelegate

extension SettingsPage: SettingsRadioNodeDelegate {
    func didTapRadio(_ radioNode: SettingsRadioNode) {
        switch radioNode {
        case let radioNode where radioNode == radioMusic:
            UserDefaults.standard.set(!radioNode.isOn, forKey: K.UserDefaults.muteMusic)
            AudioManager.shared.updateVolumes()
        case let radioNode where radioNode == radioSoundFX:
            UserDefaults.standard.set(!radioNode.isOn, forKey: K.UserDefaults.muteSoundFX)
            AudioManager.shared.updateVolumes()
        case let radioNode where radioNode == radioVibrations:
            UserDefaults.standard.set(!radioNode.isOn, forKey: K.UserDefaults.disableVibrations)
            
            if radioNode.isOn {
                Haptics.shared.executeCustomPattern(pattern: .enableVibrations)
            }
        case let radioNode where radioNode == radioPartyLights:
            UserDefaults.standard.set(!radioNode.isOn, forKey: K.UserDefaults.disablePartyLights)
            
            if radioNode.isOn {
                PartyModeSprite.shared.addLights()
            }
            else {
                PartyModeSprite.shared.removeLights()
            }
        default:
            return
        }
    }
}
