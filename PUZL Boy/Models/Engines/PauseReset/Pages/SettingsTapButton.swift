//
//  SettingsTapButton.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/11/23.
//

import SpriteKit

protocol SettingsTapButtonDelegate: AnyObject {
    func didTapButton(_ buttonNode: SettingsTapButton)
}

class SettingsTapButton: SKNode {
    
    // MARK: - Properties
    
    static let buttonSize = CGSize(width: 250, height: 100)
    let shadowOffset: CGFloat = 6

    private var text: String
    private var nodeName: String { "tapbutton" + text }
    private var settingsSize: CGSize
    private var isAnimating = false
    private var isPressed = true
    
    private var backgroundColor: UIColor { DayTheme.skyColor.bottom.triadic.first.darkenColor(factor: 3) }
    private var backgroundShadowColor: UIColor { DayTheme.skyColor.bottom.splitComplementary.first.lightenColor(factor: 6) }
    
    private var labelNode: SKLabelNode
    private var tapButton: SKShapeNode
    
    weak var delegate: SettingsTapButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, buttonText: String, settingsSize: CGSize) {
        self.text = text
        self.settingsSize = settingsSize
        
        labelNode = SKLabelNode(text: text.uppercased())
        labelNode.position = CGPoint(x: 0, y: settingsSize.height / 2)
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .left
        labelNode.fontName = UIFont.gameFont
        labelNode.fontSize = UIFont.gameFontSizeMedium
        labelNode.fontColor = UIFont.gameFontColor
        labelNode.zPosition = 10
        labelNode.addDropShadow()
                
        tapButton = SKShapeNode(rectOf: SettingsTapButton.buttonSize, cornerRadius: 20)
        tapButton.position = CGPoint(x: settingsSize.width - SettingsTapButton.buttonSize.width/2 - shadowOffset,
                                     y: SettingsTapButton.buttonSize.height/2 - shadowOffset)
        tapButton.fillTexture = SKTexture(image: UIImage.menuGradientTexture)
        tapButton.strokeColor = .white
        tapButton.lineWidth = 0
        tapButton.addDropShadow(rectOf: SettingsTapButton.buttonSize, cornerRadius: 20, shadowOffset: shadowOffset)
        
        let buttonLabelNode = SKLabelNode(text: buttonText)
        buttonLabelNode.position = CGPoint(x: 0, y: 0)
        buttonLabelNode.verticalAlignmentMode = .center
        buttonLabelNode.horizontalAlignmentMode = .center
        buttonLabelNode.fontName = UIFont.chatFont
        buttonLabelNode.fontSize = UIFont.chatFontSize
        buttonLabelNode.fontColor = UIFont.chatFontColor
        buttonLabelNode.zPosition = 5
        buttonLabelNode.addDropShadow()

        super.init()

        
        tapButton.name = nodeName
        
        updateColors()

        addChild(labelNode)
        addChild(tapButton)
        tapButton.addChild(buttonLabelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isAnimating else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        isPressed = true
        
        tapButton.run(SKAction.group([
            SKAction.move(to: tapButton.position + CGPoint(x: -shadowOffset, y: -shadowOffset), duration: 0),
            SKAction.run {
                self.tapButton.hideShadow(animationDuration: 0, completion: nil)
            }
        ])) {
            //Delegate here???
            
        }
        
        ButtonTap.shared.tap(type: .buttontap5)

        delegate?.didTapButton(self)
    }
    
    func touchUp() {
        guard isPressed else { return }
        
        isAnimating = true
        isPressed = false
        
        tapButton.run(SKAction.group([
            SKAction.move(to: tapButton.position + CGPoint(x: shadowOffset, y: shadowOffset), duration: 0.2),
            SKAction.run {
                self.tapButton.showShadow(shadowOffset: self.shadowOffset, animationDuration: 0.2, completion: nil)
            }
        ])) {
            self.isAnimating = false
        }
    }
    
    func updateColors() {
        tapButton.fillColor = backgroundColor
        tapButton.updateShadowColor(backgroundShadowColor)
    }
}
