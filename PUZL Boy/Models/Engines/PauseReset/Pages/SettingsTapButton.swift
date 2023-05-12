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

    private var text: String
    private var nodeName: String { "tapbutton" + text }
    private var settingsSize: CGSize
    private var isAnimating = false
    
    private var labelNode: SKLabelNode
    private var tapButton: SKShapeNode
    
    weak var delegate: SettingsTapButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, settingsSize: CGSize) {
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
        
        tapButton = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 300, height: 100), cornerRadius: 20)
        tapButton.fillColor = .purple
        tapButton.strokeColor = .white
        tapButton.lineWidth = 0
        tapButton.addDropShadow(rectOf: CGSize(width: 300, height: 100), cornerRadius: 20)
        
        super.init()

//        //FIXME: - DELETE
//        let backgroundNode = SKSpriteNode(color: .systemPink, size: settingsSize)
//        backgroundNode.anchorPoint = .zero
//        addChild(backgroundNode)
        
        tapButton.name = nodeName

        addChild(labelNode)
        addChild(tapButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func touchDown(in location: CGPoint) {
        guard !isAnimating else { return }
        guard let tapButtonPositionInScene = tapButton.positionInScene else { return }
        
        let adjustedLocation = CGPoint(
            // FIXME: - Closer, but still not correct. The x value is off!
            x: location.x + (UIDevice.isiPad ? 300 : 0),
            y: location.y - tapButtonPositionInScene.y + 100 / 2
        )
        
        guard nodes(at: adjustedLocation).filter({ $0.name == nodeName }).first != nil else { return }

        isAnimating = true
        
        tapButton.run(SKAction.move(to: CGPoint(x: -6, y: -6), duration: 0.2)) {
            //Delegate here???
            
            self.isAnimating = false
        }
        
        K.ButtonTaps.tap4()

        delegate?.didTapButton(self)
    }
}
