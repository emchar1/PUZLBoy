//
//  SettingsTapArea.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/11/23.
//

import SpriteKit

protocol SettingsTapAreaDelegate: AnyObject {
    func didTapArea(_ tapArea: SettingsTapArea)
}

class SettingsTapArea: SKNode {
    
    // MARK: - Properties
    
    private var labelText: String
    private var buttonText: String
    private var settingsSize: CGSize
    
    private var tapButton: SettingsTapButton!
    
    weak var delegate: SettingsTapAreaDelegate?
    
    
    // MARK: - Initialization
    
    init(labelText: String, buttonText: String, settingsSize: CGSize) {
        self.labelText = labelText
        self.buttonText = buttonText
        self.settingsSize = settingsSize
        
        super.init()
        
        setupSprites()
        updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("SettingsTapArea deinit")
    }
    
    private func setupSprites() {
        let labelNode = SKLabelNode(text: labelText.uppercased())
        labelNode.position = CGPoint(x: 0, y: settingsSize.height / 2)
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .left
        labelNode.fontName = UIFont.gameFont
        labelNode.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeLarge : UIFont.gameFontSizeMedium
        labelNode.fontColor = UIFont.gameFontColor
        labelNode.zPosition = 10
        labelNode.addDropShadow()
        
        tapButton = SettingsTapButton(text: buttonText)
        tapButton.position.x = settingsSize.width
        tapButton.delegate = self
        
        addChild(labelNode)
        addChild(tapButton)
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        tapButton.touchDown(in: location)
    }
    
    func touchUp() {
        tapButton.touchUp()
    }
    
    func tapButton(in location: CGPoint) {
        tapButton.tapButton(in: location, type: .buttontap5)
    }
    
    func updateColors() {
        tapButton.updateColors()
    }
}


// MARK: - SettingsTapButtonDelegate

extension SettingsTapArea: SettingsTapButtonDelegate {
    func didTapButton(_ buttonNode: SettingsTapButton) {
        delegate?.didTapArea(self)
    }
}
