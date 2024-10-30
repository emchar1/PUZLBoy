//
//  SettingsRadioNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/1/23.
//

import SpriteKit

protocol SettingsRadioNodeDelegate: AnyObject {
    func didTapRadio(_ radioNode: SettingsRadioNode)
}

class SettingsRadioNode: SKNode {
    
    // MARK: - Properties
    
    static let radioNodeScale: CGFloat = UIDevice.isiPad ? 0.52 : 0.36
    static let radioNodeSizeOrig = CGSize(width: 512, height: 225)
    static let radioNodeSize = CGSize(width: radioNodeSizeOrig.width * radioNodeScale, height: radioNodeSizeOrig.height * radioNodeScale)
    static let radioStatus: (on: CGFloat, off: CGFloat) = (-radioNodeSizeOrig.width / 3, -radioNodeSizeOrig.height / 3)

    private var text: String
    private(set) var isOn: Bool
    private var nodeName: String { "radiobutton" + text }
    private var settingsSize: CGSize
    private var isAnimating = false
    private var isPressed = false
    
    private var labelNode: SKLabelNode!
    private var radioButton: SKSpriteNode!
    private var radioOn: SKSpriteNode!
    private var radioOff: SKSpriteNode!
    
    weak var delegate: SettingsRadioNodeDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, settingsSize: CGSize, isOn: Bool = true) {
        self.text = text
        self.isOn = isOn
        self.settingsSize = settingsSize
        
        super.init()

        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("SettingsRadioNode \(text) deinit")
    }
    
    private func setupSprites() {
        labelNode = SKLabelNode(text: text.uppercased())
        labelNode.position = CGPoint(x: 0, y: settingsSize.height / 2)
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .left
        labelNode.fontName = UIFont.gameFont
        labelNode.fontSize = UIFont.gameFontSizeLarge
        labelNode.fontColor = UIFont.gameFontColor
        labelNode.zPosition = 10
        labelNode.addDropShadow()
        
        radioButton = SKSpriteNode(imageNamed: "radioButton")
        radioButton.position = CGPoint(x: settingsSize.width, y: settingsSize.height / 2)
        radioButton.anchorPoint = CGPoint(x: 1, y: 0.5)
        radioButton.scale(to: SettingsRadioNode.radioNodeSize)
        radioButton.name = nodeName

        radioOn = SKSpriteNode(imageNamed: "radioOn")
        radioOn.position = CGPoint(x: SettingsRadioNode.radioStatus.on, y: 0)
        radioOn.anchorPoint = CGPoint(x: 0, y: 0.5)
        radioOn.zPosition = 1

        radioOff = SKSpriteNode(imageNamed: "radioOff")
        radioOff.position = CGPoint(x: SettingsRadioNode.radioStatus.off, y: 0)
        radioOff.anchorPoint = CGPoint(x: 0, y: 0.5)
        radioOff.zPosition = 1

        radioButton.addChild(isOn ? radioOn : radioOff)
        addChild(labelNode)
        addChild(radioButton)
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isAnimating else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        isPressed = true
    }
    
    func touchUp() {
        guard isPressed else { return }
        
        isPressed = false
    }
    
    func tapRadio(in location: CGPoint) {
        guard isPressed else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        isAnimating = true
        isOn.toggle()
        
        if isOn {
            radioOff.run(SKAction.sequence([
                SKAction.moveTo(x: SettingsRadioNode.radioStatus.on, duration: 0.2),
                SKAction.removeFromParent(),
                SKAction.moveTo(x: SettingsRadioNode.radioStatus.off, duration: 0)
            ])) { [weak self] in
                guard let self = self else { return }
                
                radioButton.addChild(radioOn)
                isAnimating = false
            }
        }
        else {
            radioOn.run(SKAction.sequence([
                SKAction.moveTo(x: SettingsRadioNode.radioStatus.off, duration: 0.2),
                SKAction.removeFromParent(),
                SKAction.moveTo(x: SettingsRadioNode.radioStatus.on, duration: 0)
            ])) { [weak self] in
                guard let self = self else { return }
                
                radioButton.addChild(radioOff)
                isAnimating = false
            }
        }
        
        ButtonTap.shared.tap(type: .buttontap4, hapticStyle: .rigid)
        delegate?.didTapRadio(self)
    }
    
    func setIsOn(_ isOn: Bool) {
        self.isOn = isOn
        
        radioOff.removeFromParent()
        radioOn.removeFromParent()

        if isOn {
            radioButton.addChild(radioOn)
        }
        else {
            radioButton.addChild(radioOff)
        }
    }
}
