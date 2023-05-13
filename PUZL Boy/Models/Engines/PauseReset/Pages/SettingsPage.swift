//
//  SettingsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/29/23.
//

import SpriteKit
import FirebaseAuth

class SettingsPage: ParentPage {
    
    // MARK: - Properties
    
    private var radioMusic: SettingsRadioNode!
    private var radioSoundFX: SettingsRadioNode!
    private var radioVibration: SettingsRadioNode!
    private var radioPartyLights: SettingsRadioNode!
    
    private var tapButtonNotifications: SettingsTapButton!
    private var tapButtonRateReview: SettingsTapButton!
    private var tapButtonReportBug: SettingsTapButton!
    
    private var user: User?

    
    // MARK: - Initialization
    
    init(user: User?, contentSize: CGSize) {
        super.init(contentSize: contentSize, titleText: "Settings")
        
        self.nodeName = "settingsPage"
        self.contentSize = contentSize
        self.user = user
        name = nodeName
        
        let radioSectionHeight: CGFloat = 100
        let radioSize = CGSize(width: contentSize.width - 2 * padding, height: SettingsRadioNode.radioNodeSize.height)
        let radioStart: CGFloat = -padding - 1.0 * radioSectionHeight
        
        let tapButtonSectionHeight: CGFloat = 120
        let tapButtonSize = CGSize(width: contentSize.width - 2 * padding, height: SettingsTapButton.buttonSize.height)
        let tapButtonStart: CGFloat = -padding - 1.0 * tapButtonSectionHeight
        
        radioMusic = SettingsRadioNode(
            text: "🎵 Music",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic))
        radioMusic.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height)
        radioMusic.zPosition = 10
        radioMusic.delegate = self
        
        radioSoundFX = SettingsRadioNode(
            text: "🔈 Sound FX",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteSoundFX))
        radioSoundFX.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - radioSectionHeight )
        radioSoundFX.zPosition = 10
        radioSoundFX.delegate = self
        
        radioVibration = SettingsRadioNode(
            text: "📳 Vibration",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disableVibration))
        radioVibration.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 2 * radioSectionHeight)
        radioVibration.zPosition = 10
        radioVibration.delegate = self
        
        radioPartyLights = SettingsRadioNode(
            text: "🪩 Bonus Level Lights",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disablePartyLights))
        radioPartyLights.position = CGPoint(x: padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 3 * radioSectionHeight)
        radioPartyLights.zPosition = 10
        radioPartyLights.delegate = self
        
        tapButtonNotifications = SettingsTapButton(text: "🔔 Notifications", buttonText: "Enable", settingsSize: tapButtonSize)
        tapButtonNotifications.position = CGPoint(x: padding, y: tapButtonStart - SettingsTapButton.buttonSize.height - 4 * tapButtonSectionHeight)
        tapButtonNotifications.zPosition = 10
        tapButtonNotifications.delegate = self

        tapButtonRateReview = SettingsTapButton(text: "❤️ Rate & Review", buttonText: "Review", settingsSize: tapButtonSize)
        tapButtonRateReview.position = CGPoint(x: padding, y: tapButtonStart - SettingsTapButton.buttonSize.height - 5 * tapButtonSectionHeight)
        tapButtonRateReview.zPosition = 10
        tapButtonRateReview.delegate = self

        tapButtonReportBug = SettingsTapButton(text: "✉️ Report a Bug", buttonText: "Feedback", settingsSize: tapButtonSize)
        tapButtonReportBug.position = CGPoint(x: padding, y: tapButtonStart - SettingsTapButton.buttonSize.height - 6 * tapButtonSectionHeight)
        tapButtonReportBug.zPosition = 10
        tapButtonReportBug.delegate = self
        
        let idLabel = SKLabelNode(text: "ID: \(user?.uid ?? "0000")")
        idLabel.position = CGPoint(x: padding, y: -contentSize.height + 10)
        idLabel.fontName = UIFont.chatFont
        idLabel.fontSize = UIFont.chatFontSize
        idLabel.fontColor = UIFont.chatFontColor
        idLabel.horizontalAlignmentMode = .left
        idLabel.verticalAlignmentMode = .bottom
        idLabel.alpha = 0.75
        idLabel.zPosition = 10
        idLabel.addDropShadow()

        
        addChild(contentNode)
        contentNode.addChild(titleLabel)
        contentNode.addChild(radioMusic)
        contentNode.addChild(radioSoundFX)
        contentNode.addChild(radioVibration)
        contentNode.addChild(radioPartyLights)
        
        contentNode.addChild(tapButtonNotifications)
        contentNode.addChild(tapButtonRateReview)
        contentNode.addChild(tapButtonReportBug)
        contentNode.addChild(idLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func updateColors() {
        tapButtonNotifications.updateColors()
        tapButtonRateReview.updateColors()
        tapButtonReportBug.updateColors()
    }
    
    override func touchDown(at location: CGPoint) {
        super.touchDown(at: location)
        
        radioMusic.touchDown(in: location)
        radioSoundFX.touchDown(in: location)
        radioVibration.touchDown(in: location)
        radioPartyLights.touchDown(in: location)
        
        tapButtonNotifications.touchDown(in: location)
        tapButtonRateReview.touchDown(in: location)
        tapButtonReportBug.touchDown(in: location)
    }
    
    override func touchUp() {
        super.touchUp()
        
        tapButtonNotifications.touchUp()
        tapButtonRateReview.touchUp()
        tapButtonReportBug.touchUp()
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
        case let radioNode where radioNode == radioVibration:
            UserDefaults.standard.set(!radioNode.isOn, forKey: K.UserDefaults.disableVibration)
            
            if radioNode.isOn {
                Haptics.shared.executeCustomPattern(pattern: .enableVibration)
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


// MARK: - SettingsTapButtonDelegate

extension SettingsPage: SettingsTapButtonDelegate {
    func didTapButton(_ buttonNode: SettingsTapButton) {
        switch buttonNode {
        case let buttonNode where buttonNode == tapButtonNotifications:
            print("Implement Notifications button")
        case let buttonNode where buttonNode == tapButtonRateReview:
            print("Implement Rate/Review button")
        case let buttonNode where buttonNode == tapButtonReportBug:
            print("Implement Report Bug button")
        default:
            return
        }
    }
}
