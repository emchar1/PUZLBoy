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
    
    static let radioNodeScale: CGFloat = 0.36
    static let radioNodeSizeOrig = CGSize(width: 512, height: 225)
    static let radioNodeSize = CGSize(width: radioNodeSizeOrig.width * radioNodeScale, height: radioNodeSizeOrig.height * radioNodeScale)
    static let radioStatus: (on: CGFloat, off: CGFloat) = (-radioNodeSizeOrig.width, -radioNodeSizeOrig.height)

    private var text: String
    private(set) var isOn: Bool
    private var nodeName: String { "radiobutton" + text }
    private var settingsSize: CGSize
    private var isAnimating = false
    
    private var labelNode: SKLabelNode
    private var radioButton: SKSpriteNode
    private var radioOn: SKSpriteNode
    private var radioOff: SKSpriteNode
    
    weak var delegate: SettingsRadioNodeDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, settingsSize: CGSize, isOn: Bool = true) {
        self.text = text
        self.isOn = isOn
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
        
        radioButton = SKSpriteNode(imageNamed: "radioButton")
        radioButton.position = CGPoint(x: settingsSize.width, y: settingsSize.height / 2)
        radioButton.anchorPoint = CGPoint(x: 1, y: 0.5)
        radioButton.scale(to: SettingsRadioNode.radioNodeSize)
        
        radioOn = SKSpriteNode(imageNamed: "radioOn")
        radioOn.position = CGPoint(x: SettingsRadioNode.radioStatus.on, y: 0)
        radioOn.anchorPoint = CGPoint(x: 0, y: 0.5)
        radioOn.zPosition = 1

        radioOff = SKSpriteNode(imageNamed: "radioOff")
        radioOff.position = CGPoint(x: SettingsRadioNode.radioStatus.off, y: 0)
        radioOff.anchorPoint = CGPoint(x: 0, y: 0.5)
        radioOff.zPosition = 1

        super.init()

//        //FIXME: - DELETE
//        let backgroundNode = SKSpriteNode(color: .systemPink, size: settingsSize)
//        backgroundNode.anchorPoint = .zero
//        addChild(backgroundNode)
        
        radioButton.name = nodeName

        radioButton.addChild(isOn ? radioOn : radioOff)
        addChild(labelNode)
        addChild(radioButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isAnimating else { return }
        guard scene?.nodes(at: location).filter({ $0.name == nodeName }).first != nil else { return }

        isAnimating = true
        isOn.toggle()
        
        if isOn {
            radioOff.run(SKAction.moveTo(x: SettingsRadioNode.radioStatus.on, duration: 0.2)) {
                self.radioOff.removeFromParent()
                self.radioOff.position.x = SettingsRadioNode.radioStatus.off
                self.radioButton.addChild(self.radioOn)
                
                self.isAnimating = false
            }
        }
        else {
            radioOn.run(SKAction.moveTo(x: SettingsRadioNode.radioStatus.off, duration: 0.2)) {
                self.radioOn.removeFromParent()
                self.radioOn.position.x = SettingsRadioNode.radioStatus.on
                self.radioButton.addChild(self.radioOff)
                
                self.isAnimating = false
            }
        }
        
        ButtonTap.shared.tap(type: .buttontap4)
        delegate?.didTapRadio(self)
    }
}
