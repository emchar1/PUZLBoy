//
//  SettingsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/29/23.
//

import SpriteKit
import FirebaseAuth
import StoreKit

class SettingsPage: ParentPage {
    
    // MARK: - Properties
    
    private(set) var radioMusic: SettingsRadioNode!
    private var radioSoundFX: SettingsRadioNode!
    private var radioVibration: SettingsRadioNode!
    private(set) var radioPartyLights: SettingsRadioNode!
    
    private(set) var tapButtonNotifications: SettingsTapButton!
    private(set) var tapButtonRateReview: SettingsTapButton!
    private(set) var tapButtonReportBug: SettingsTapButton!
    
    private var user: User?

    
    // MARK: - Initialization
    
    init(user: User?, contentSize: CGSize) {
        super.init(contentSize: contentSize, titleText: "Settings")
        
        self.nodeName = "settingsPage"
        self.contentSize = contentSize
        self.user = user
        name = nodeName
        
        let radioSectionHeight: CGFloat = UIDevice.isiPad ? 150 : 100
        let radioSize = CGSize(width: contentSize.width - 2 * SettingsPage.padding, height: SettingsRadioNode.radioNodeSize.height)
        let radioStart: CGFloat = -SettingsPage.padding - 1.5 * radioSectionHeight
        
        let tapButtonSectionHeight: CGFloat = UIDevice.isiPad ? 180 : 120
        let tapButtonSize = CGSize(width: contentSize.width - 2 * SettingsPage.padding, height: SettingsTapButton.buttonSize.height)
        let tapButtonStart: CGFloat = -SettingsPage.padding - 1.5 * tapButtonSectionHeight
        
        radioMusic = SettingsRadioNode(
            text: "🎵 Music",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic))
        radioMusic.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height)
        radioMusic.zPosition = 10
        radioMusic.delegate = self
        
        radioSoundFX = SettingsRadioNode(
            text: "🔈 Sound FX",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteSoundFX))
        radioSoundFX.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - radioSectionHeight )
        radioSoundFX.zPosition = 10
        radioSoundFX.delegate = self
        
        radioVibration = SettingsRadioNode(
            text: "📳 Vibration",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disableVibration))
        radioVibration.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 2 * radioSectionHeight)
        radioVibration.zPosition = 10
        radioVibration.delegate = self
        
        radioPartyLights = SettingsRadioNode(
            text: "🪩 Bonus Level Lights",
            settingsSize: radioSize,
            isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disablePartyLights))
        radioPartyLights.position = CGPoint(x: SettingsPage.padding, y: radioStart - SettingsRadioNode.radioNodeSize.height - 3 * radioSectionHeight)
        radioPartyLights.zPosition = 10
        radioPartyLights.delegate = self
        
        tapButtonNotifications = SettingsTapButton(text: "🔔 Notifications", buttonText: "Enable", settingsSize: tapButtonSize)
        tapButtonNotifications.position = CGPoint(x: SettingsPage.padding, y: tapButtonStart - SettingsTapButton.buttonSize.height - 4 * tapButtonSectionHeight)
        tapButtonNotifications.zPosition = 10
        tapButtonNotifications.delegate = self

        tapButtonRateReview = SettingsTapButton(text: "❤️ Tell Your Friends", buttonText: "Share", settingsSize: tapButtonSize)
        tapButtonRateReview.position = CGPoint(x: SettingsPage.padding, y: tapButtonStart - SettingsTapButton.buttonSize.height - 5 * tapButtonSectionHeight)
        tapButtonRateReview.zPosition = 10
        tapButtonRateReview.delegate = self

        tapButtonReportBug = SettingsTapButton(text: "✉️ Report a Bug", buttonText: "Feedback", settingsSize: tapButtonSize)
        tapButtonReportBug.position = CGPoint(x: SettingsPage.padding, y: tapButtonStart - SettingsTapButton.buttonSize.height - 6 * tapButtonSectionHeight)
        tapButtonReportBug.zPosition = 10
        tapButtonReportBug.delegate = self
        
        addChild(contentNode)
        contentNode.addChild(titleLabel)
        contentNode.addChild(radioMusic)
        contentNode.addChild(radioSoundFX)
        contentNode.addChild(radioVibration)
        contentNode.addChild(radioPartyLights)
        
        contentNode.addChild(tapButtonNotifications)
        contentNode.addChild(tapButtonRateReview)
        contentNode.addChild(tapButtonReportBug)
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
    
    override func touchDown(for touches: Set<UITouch>) {
        super.touchDown(for: touches)
        
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }

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
        
        radioMusic.touchUp()
        radioSoundFX.touchUp()
        radioVibration.touchUp()
        radioPartyLights.touchUp()
        
        tapButtonNotifications.touchUp()
        tapButtonRateReview.touchUp()
        tapButtonReportBug.touchUp()
    }
    
    override func touchNode(for touches: Set<UITouch>) {
        super.touchNode(for: touches)
        
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        radioMusic.tapRadio(in: location)
        radioSoundFX.tapRadio(in: location)
        radioVibration.tapRadio(in: location)
        radioPartyLights.tapRadio(in: location)
        
        tapButtonNotifications.tapButton(in: location)
        tapButtonRateReview.tapButton(in: location)
        tapButtonReportBug.tapButton(in: location)
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
                PartyModeSprite.shared.addLights(duration: 0.5)
            }
            else {
                PartyModeSprite.shared.removeLights(duration: 0.5)
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
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        case let buttonNode where buttonNode == tapButtonRateReview:
            NotificationCenter.default.post(name: .shareURL, object: nil)
            
//            SKStoreReviewController.requestReview()
        case let buttonNode where buttonNode == tapButtonReportBug:
            NotificationCenter.default.post(name: .showMailCompose , object: nil)
        default:
            return
        }
    }
}
