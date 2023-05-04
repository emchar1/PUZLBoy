//
//  SettingsRadioNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/1/23.
//

import SpriteKit

protocol SettingsRadioNodeDelegate: AnyObject {
    func didTapRadio()
}

class SettingsRadioNode: SKNode {
    
    // MARK: - Properties
    
    static let radioNodeSize = CGSize(width: 160, height: 80)
    private var text: String
    private var isOn: Bool
    private var nodeName: String { "radiobutton" + text }
    private var settingsSize: CGSize
    private var isAnimating = false
    
    private var radiobuttonOnAtlas: SKTextureAtlas
    private var radiobuttonOffAtlas: SKTextureAtlas
    private var radiobuttonOnTextures: [SKTexture] = []
    private var radiobuttonOffTextures: [SKTexture] = []
    
    private var labelNode: SKLabelNode
    private(set) var radioNode: SKSpriteNode
    
    weak var delegate: SettingsRadioNodeDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, settingsSize: CGSize, isOn: Bool = true) {
        self.text = text
        self.isOn = isOn
        self.settingsSize = settingsSize
        
        radiobuttonOnAtlas = SKTextureAtlas(named: "radiobuttonOn")
        radiobuttonOffAtlas = SKTextureAtlas(named: "radiobuttonOff")
        
        for i in 0...11 {
            radiobuttonOnTextures.append(radiobuttonOnAtlas.textureNamed("radiobuttonOn\(i)"))
            radiobuttonOffTextures.append(radiobuttonOffAtlas.textureNamed("radiobuttonOff\(i)"))
        }
        
        labelNode = SKLabelNode(text: text)
        labelNode.position = CGPoint(x: SettingsPage.padding, y: settingsSize.height / 2)
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .left
        labelNode.fontName = UIFont.gameFont
        labelNode.fontSize = UIFont.gameFontSizeMedium
        labelNode.fontColor = UIFont.gameFontColor
        labelNode.zPosition = 10
        labelNode.addDropShadow()
        
        radioNode = SKSpriteNode(imageNamed: isOn ? "radiobuttonOn0" : "radiobuttonOff0")
        radioNode.position = CGPoint(x: settingsSize.width - SettingsPage.padding, y: settingsSize.height / 2)
        radioNode.anchorPoint = CGPoint(x: 1, y: 0.5)
        radioNode.scale(to: SettingsRadioNode.radioNodeSize)
        
        super.init()
        
        radioNode.name = nodeName
        
        addChild(labelNode)
        addChild(radioNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isAnimating else { return }
        guard let radioNodePositionInScene = radioNode.positionInScene else { return }
        
        let adjustedLocation = CGPoint(x: location.x, y: location.y - radioNodePositionInScene.y + SettingsRadioNode.radioNodeSize.height / 2)
        
        guard let radioNode = nodes(at: adjustedLocation).filter({ $0.name == nodeName }).first else { return }

        isAnimating = true

        let textures = isOn ? radiobuttonOnTextures : radiobuttonOffTextures
        
        radioNode.run(SKAction.animate(with: textures, timePerFrame: 0.01)) {
            self.radioNode.run(SKAction.setTexture(SKTexture(imageNamed: self.isOn ? "radiobuttonOff0" : "radiobuttonOn0")))
            self.isOn.toggle()
            self.isAnimating = false
        }
        
        K.ButtonTaps.tap2()

        delegate?.didTapRadio()
    }
}
