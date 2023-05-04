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
    private var radioStrobeLights: SettingsRadioNode
    private var radioFunGame: SettingsRadioNode
    
    
    // MARK: - Initialization
    
    init(maskSize: CGSize) {
        self.maskSize = maskSize
        self.contentSize = CGSize(width: maskSize.width, height: K.ScreenDimensions.iPhoneWidth * 2)
        
        maskNode = SKSpriteNode(color: .magenta, size: maskSize)
        maskNode.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                
        cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: maskSize.height / 2)
        cropNode.maskNode = maskNode
        
        contentNode = SKSpriteNode(color: .orange, size: contentSize)
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
        
        radioMusic = SettingsRadioNode(text: "Music", settingsSize: settingsSize)
        radioMusic.position = CGPoint(x: 0, y: -200)
        radioMusic.zPosition = 20

        radioSoundFX = SettingsRadioNode(text: "SoundFX", settingsSize: settingsSize)
        radioSoundFX.position = CGPoint(x: 0, y: -300)
        radioSoundFX.zPosition = 20

        radioStrobeLights = SettingsRadioNode(text: "StrobeLights", settingsSize: settingsSize)
        radioStrobeLights.position = CGPoint(x: 0, y: -400)
        radioStrobeLights.zPosition = 20

        radioFunGame = SettingsRadioNode(text: "FunGame", settingsSize: settingsSize)
        radioFunGame.position = CGPoint(x: 0, y: -600)
        radioFunGame.zPosition = 20

        super.init()
        
        name = SettingsPage.nodeName
        
        contentNode.addChild(titleLabel)
        contentNode.addChild(radioMusic)
        contentNode.addChild(radioSoundFX)
        contentNode.addChild(radioStrobeLights)
        contentNode.addChild(radioFunGame)
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
        radioStrobeLights.touchDown(in: location)
        radioFunGame.touchDown(in: location)
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
