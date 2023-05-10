//
//  SettingsManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/28/23.
//

import SpriteKit

protocol SettingsManagerDelegate: AnyObject {
    func didTapButton(_ node: SettingsButton)
}

class SettingsManager: SKNode {
    
    // MARK: - Properties
    
    private let settingsScale: CGFloat = 0.95
    private var settingsWidth: CGFloat
    private var buttonHeight: CGFloat
    private var buttonSize: CGSize
    private var currentButtonPressed: SettingsButton?
    
    private(set) var button1: SettingsButton
    private(set) var button2: SettingsButton
    private(set) var button3: SettingsButton
    private(set) var button4: SettingsButton
    private(set) var button5: SettingsButton
    
    weak var delegate: SettingsManagerDelegate?
    
    
    // MARK: - Initialization
    
    init(settingsWidth: CGFloat, buttonHeight: CGFloat) {
        self.settingsWidth = settingsWidth
        self.buttonHeight = buttonHeight
        buttonSize = CGSize(width: settingsWidth / 5 * settingsScale, height: buttonHeight)
        
        button1 = SettingsButton(type: .button1, position: .zero, size: buttonSize)
        button2 = SettingsButton(type: .button2, position: .zero, size: buttonSize)
        button3 = SettingsButton(type: .button3, position: .zero, size: buttonSize)
        button4 = SettingsButton(type: .button4, position: .zero, size: buttonSize)
        button5 = SettingsButton(type: .button5, position: .zero, size: buttonSize)
        
        super.init()
        
        button1.delegate = self
        button2.delegate = self
        button3.delegate = self
        button4.delegate = self
        button5.delegate = self
        
        addButtonNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addButtonNodes() {
        addChild(button1)
        addChild(button2)
        addChild(button3)
        addChild(button4)
        addChild(button5)
    }
    
    
    
    // MARK: - Functions
    
    func setInitialPosition(_ initialPosition: CGPoint) {
        let adjustedX = initialPosition.x + buttonSize.width / settingsScale / 2 + abs(button1.shadowSize.x)
        let adjustedY = initialPosition.y - 0.5 * buttonSize.height - 3 * 10 //30 for the triple shadow size
        let adjustedPosition = CGPoint(x: adjustedX, y: adjustedY)
        
        button1.position = (adjustedPosition)
        button2.position = button1.position + CGPoint(x: buttonSize.width / settingsScale, y: 0)
        button3.position = button2.position + CGPoint(x: buttonSize.width / settingsScale, y: 0)
        button4.position = button3.position + CGPoint(x: buttonSize.width / settingsScale, y: 0)
        button5.position = button4.position + CGPoint(x: buttonSize.width / settingsScale, y: 0)
    }
    
    func updateColors() {
        button1.updateColors()
        button2.updateColors()
        button3.updateColors()
        button4.updateColors()
        button5.updateColors()
    }
    
    func tap(_ button: SettingsButton, tapQuietly: Bool = false) {
        guard currentButtonPressed?.type != button.type else { return }

        button.touchDown()
        button.tapButton(tapQuietly: tapQuietly)
                
        if !(button.type == .button1 || button.type == .button3) {
            if button2.type != button.type { button2.touchUp() }
            if button4.type != button.type { button4.touchUp() }
            if button5.type != button.type { button5.touchUp() }
            
            currentButtonPressed = button
        }
    }
}


// MARK: - SettingsButtonDelegate

extension SettingsManager: SettingsButtonDelegate {
    func didTapButton(_ node: SettingsButton) {
        delegate?.didTapButton(node)
    }
    
}
