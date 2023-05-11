//
//  SettingsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/29/23.
//

import SpriteKit

class SettingsPage: ParentPage {
    
    // MARK: - Properties
    
    private var radioMusic: SettingsRadioNode!
    private var radioSoundFX: SettingsRadioNode!
    private var radioVibrations: SettingsRadioNode!
    private var radioPartyLights: SettingsRadioNode!

    
    // MARK: - Initialization
    
    init(contentSize: CGSize) {
        super.init(contentSize: contentSize, titleText: "Settings")
        
        self.nodeName = "settingsPage"
        self.contentSize = contentSize
        name = nodeName
        
        let sectionHeight: CGFloat = 100
        let radioSize = CGSize(width: contentSize.width - 2 * padding, height: SettingsRadioNode.radioNodeSize.height)
        let radioStart: CGFloat = -padding - 1.5 * sectionHeight
        
        radioMusic = SettingsRadioNode(
            text: "🎵 Music",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic)
        )
        radioMusic.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height)
        radioMusic.zPosition = 20
        radioMusic.delegate = self
        
        radioSoundFX = SettingsRadioNode(
            text: "🔈 Sound FX",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteSoundFX)
        )
        radioSoundFX.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - sectionHeight )
        radioSoundFX.zPosition = 20
        radioSoundFX.delegate = self
        
        radioVibrations = SettingsRadioNode(
            text: "📳 Vibrations",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disableVibrations)
        )
        radioVibrations.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 2 * sectionHeight)
        radioVibrations.zPosition = 20
        radioVibrations.delegate = self
        
        radioPartyLights = SettingsRadioNode(
            text: "🪩 Bonus Level Lights",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disablePartyLights)
        )
        radioPartyLights.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 3 * sectionHeight)
        radioPartyLights.zPosition = 20
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
    
    
    // MARK: - Touch Functions
    
    override func touchDown(at location: CGPoint) {
        super.touchDown(at: location)
        
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
