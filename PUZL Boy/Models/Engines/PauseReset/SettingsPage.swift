//
//  SettingsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/29/23.
//

import SpriteKit

class SettingsPage: SKNode {
    
    // MARK: - Properties
    
    static let padding: CGFloat = 20
    private let maxPositionChange: CGFloat = 50
    private var initialYPosition: CGFloat?
    private var finalYPosition: CGFloat?
    private var positionChange: CGFloat {
        guard let finalYPosition = finalYPosition, let initialYPosition = initialYPosition else { return 0 }
        
        return min(max(-maxPositionChange, finalYPosition - initialYPosition), maxPositionChange)
    }
    
    static let nodeName = "settingsPage"
    private var maskSize: CGSize
    private var contentSize: CGSize
    private var isPressed = false

    private var cropNode: SKCropNode
    private var maskNode: SKSpriteNode
    private var contentNode: SKSpriteNode
    
    //Radio Buttons
    private var radioMusic: SettingsRadioNode
    private var radioSoundFX: SettingsRadioNode
    private var radioVibrations: SettingsRadioNode
    private var radioPartyLights: SettingsRadioNode

    
    // MARK: - Initialization
    
    init(maskSize: CGSize) {
        self.maskSize = maskSize
        self.contentSize = CGSize(width: maskSize.width, height: K.ScreenDimensions.iPhoneWidth * 2)
        
        maskNode = SKSpriteNode(color: .magenta, size: maskSize)
        maskNode.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                
        cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: maskSize.height / 2)
        cropNode.maskNode = maskNode
        
        contentNode = SKSpriteNode(color: .clear, size: contentSize)
        contentNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        contentNode.position = CGPoint(x: -contentSize.width / 2, y: 0)
        
        // TODO: Add Settings fields
        let titleLabel = SKLabelNode(text: "SETTINGS")
        titleLabel.position = CGPoint(x: contentSize.width / 2, y: -SettingsPage.padding)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .top
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeMedium
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.addHeavyDropShadow()
        titleLabel.zPosition = 10
        
        let settingsSize = CGSize(width: contentSize.width, height: SettingsRadioNode.radioNodeSize.height)
        
        radioMusic = SettingsRadioNode(text: "Music", settingsSize: settingsSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic))
        radioMusic.position = CGPoint(x: 0, y: -200)
        radioMusic.zPosition = 20

        radioSoundFX = SettingsRadioNode(text: "Sound FX", settingsSize: settingsSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.muteSoundFX))
        radioSoundFX.position = CGPoint(x: 0, y: -300)
        radioSoundFX.zPosition = 20
        
        radioVibrations = SettingsRadioNode(text: "Vibrations", settingsSize: settingsSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disableVibrations))
        radioVibrations.position = CGPoint(x: 0, y: -400)
        radioVibrations.zPosition = 20

        radioPartyLights = SettingsRadioNode(text: "Bonus Level Lights", settingsSize: settingsSize, isOn: !UserDefaults.standard.bool(forKey: K.UserDefaults.disablePartyLights))
        radioPartyLights.position = CGPoint(x: 0, y: -500)
        radioPartyLights.zPosition = 20
        
        super.init()
        
        name = SettingsPage.nodeName
        
        radioMusic.delegate = self
        radioSoundFX.delegate = self
        radioVibrations.delegate = self
        radioPartyLights.delegate = self
        
        contentNode.addChild(titleLabel)
        contentNode.addChild(radioMusic)
        contentNode.addChild(radioSoundFX)
        contentNode.addChild(radioVibrations)
        contentNode.addChild(radioPartyLights)
        cropNode.addChild(contentNode)
        addChild(cropNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Move Functions
    
    func touchDown(at location: CGPoint) {
        isPressed = true
        
        initialYPosition = location.y

        radioMusic.touchDown(in: location)
        radioSoundFX.touchDown(in: location)
        radioVibrations.touchDown(in: location)
        radioPartyLights.touchDown(in: location)
    }
    
    func touchUp() {
        isPressed = false
        
        if contentNode.position.y <= 0 {
            contentNode.run(SKAction.sequence([
                SKAction.moveTo(y: 0, duration: 0.25)
            ]))
        }
        else if contentNode.position.y >= contentSize.height - maskSize.height {
            contentNode.run(SKAction.sequence([
                SKAction.moveTo(y: contentSize.height - maskSize.height, duration: 0.25)
            ]))
        }
        
        initialYPosition = nil
        finalYPosition = nil
    }
    
    func scrollNode(to location: CGPoint) {
        guard isPressed else { return }
        guard initialYPosition != nil else { return }
        
        let scrollThreshold: CGFloat = 40

        finalYPosition = location.y
        
        if contentNode.position.y <= -scrollThreshold && positionChange <= -maxPositionChange {
            contentNode.position.y += -1
        }
        else if contentNode.position.y >= contentSize.height - maskSize.height + scrollThreshold && positionChange >= maxPositionChange {
            contentNode.position.y += 1
        }
        else {
            contentNode.position.y += positionChange
        }
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
            
            // FIXME: - Requires Implementation
        default:
            return
        }
    }
}
