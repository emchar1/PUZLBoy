//
//  SettingsTapButton.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/7/23.
//

import SpriteKit

protocol SettingsTapButtonDelegate: AnyObject {
    func didTapButton(_ buttonNode: SettingsTapButton)
}

class SettingsTapButton: SKNode {
    
    // MARK: - Properties
    
    static let buttonSize = UIDevice.isiPad ? CGSize(width: 400, height: 140) : CGSize(width: 250, height: 100)
    private var nodeName: String { "SettingsTapButton" + text }

    private let shadowOffset: CGFloat = 6
    private var colors: (background: UIColor?, shadow: UIColor?)
    private var backgroundColor: UIColor {
        return colors.background ?? DayTheme.skyColor.bottom.triadic.first.darkenColor(factor: 3)
    }
    private var backgroundShadowColor: UIColor {
        return colors.shadow ?? DayTheme.skyColor.bottom.splitComplementary.first.lightenColor(factor: 6)
    }
    private var positionOrig: CGPoint {
        CGPoint(x: -SettingsTapButton.buttonSize.width / 2 - shadowOffset, y: SettingsTapButton.buttonSize.height / 2 - shadowOffset)
    }

    private var text: String
    private var isAnimating = false
    private var isPressed = true
    private(set) var isDisabled = false
    
    private var tapButton: SKShapeNode!
    private var disabledOnlay: SKShapeNode!
    
    weak var delegate: SettingsTapButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, colors: (background: UIColor?, shadow: UIColor?) = (nil, nil)) {
        self.text = text
        self.colors = colors
        
        super.init()
        
        setupSprites()
        updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("deinit SettingsTapButton: \(nodeName)")
    }
    
    private func setupSprites() {
        let labelNode = SKLabelNode(text: text)
        labelNode.position = CGPoint(x: 0, y: 0)
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.fontName = UIFont.chatFont
        labelNode.fontSize = UIFont.chatFontSizeLarge
        labelNode.fontColor = UIFont.chatFontColor
        labelNode.zPosition = 5
        labelNode.addDropShadow()
                
        tapButton = SKShapeNode(rectOf: SettingsTapButton.buttonSize, cornerRadius: 20)
        tapButton.position = positionOrig
        tapButton.fillTexture = SKTexture(image: UIImage.gradientTextureMenu)
        tapButton.strokeColor = .white
        tapButton.lineWidth = 0
        tapButton.name = nodeName
        tapButton.addDropShadow(rectOf: SettingsTapButton.buttonSize, cornerRadius: 20, shadowOffset: shadowOffset)
        
        disabledOnlay = SKShapeNode(rectOf: SettingsTapButton.buttonSize, cornerRadius: 20)
        disabledOnlay.fillColor = .black
        disabledOnlay.lineWidth = 0
        disabledOnlay.alpha = 0
        disabledOnlay.zPosition = 10
        
        addChild(tapButton)
        tapButton.addChild(labelNode)
        tapButton.addChild(disabledOnlay)
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isAnimating else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }
        guard !isDisabled else {
            ButtonTap.shared.tap(type: .buttontap6)
            return
        }
        
        isPressed = true
        
        tapButton.run(SKAction.move(to: tapButton.position + CGPoint(x: -shadowOffset, y: -shadowOffset), duration: 0))
        tapButton.hideShadow(animationDuration: 0)
    }
    
    func touchUp() {
        guard isPressed else { return }
        
        isAnimating = true
        isPressed = false
        
        tapButton.run(SKAction.move(to: positionOrig, duration: 0.2)) { [weak self] in
            self?.isAnimating = false
        }
        
        tapButton.showShadow(shadowOffset: shadowOffset, animationDuration: 0.2)
    }
    
    func tapButton(in location: CGPoint, type: ButtonTap.ButtonType) {
        guard isPressed else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        ButtonTap.shared.tap(type: type)
        delegate?.didTapButton(self)
    }
    
    func updateColors() {
        tapButton.fillColor = backgroundColor
        tapButton.updateShadowColor(backgroundShadowColor)
    }
    
    func setDisabled(_ disabled: Bool) {
        isDisabled = disabled
        
        disabledOnlay.alpha = isDisabled ? 0.35 : 0
    }
    
    func animateAppear() {
        run(SKAction.fadeIn(withDuration: 0.25))
    }
}
