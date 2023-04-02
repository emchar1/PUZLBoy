//
//  MenuItemLabel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/1/23.
//

import SpriteKit

class MenuItemLabel: SKLabelNode {
    
    // MARK: - Properties
    
    private var shadowNode: SKLabelNode = SKLabelNode()
    private(set) var type: MenuType
    
    private(set) var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                alpha = 1
                shadowNode.alpha = 0.25
            }
            else {
                alpha = 0.25
                shadowNode.alpha = 0
            }
        }
    }
    
    enum MenuType: String {
        case menuStart, menuLevelSelect, menuOptions, menuCredits
    }
    
    
    // MARK: - Initialization
    
    init(text: String, ofType type: MenuType, at position: CGPoint = .zero) {
        self.type = type
        
        super.init()

        self.text = text
        self.position = position
        fontName = UIFont.chatFont
        fontSize = 75
        fontColor = .white
        horizontalAlignmentMode = .center
        verticalAlignmentMode = .center
        zPosition = 10
        name = type.rawValue

        shadowNode.text = text
        shadowNode.position = CGPoint(x: -10, y: -10)
        shadowNode.fontName = UIFont.chatFont
        shadowNode.fontSize = 75
        shadowNode.fontColor = .black
        shadowNode.horizontalAlignmentMode = .center
        shadowNode.verticalAlignmentMode = .center
        shadowNode.zPosition = -5
        shadowNode.alpha = 0.25
        
        self.addChild(shadowNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func setIsEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    func tapButton(toColor tappedColor: UIColor) {
        if isEnabled {
            self.run(SKAction.group([
                SKAction.sequence([
                    SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0),
                    SKAction.colorize(with: tappedColor, colorBlendFactor: 1.0, duration: 0.25),
                    SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.25)
                ]),
                SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 0.1),
                    SKAction.scale(to: 0.95, duration: 0.1),
                    SKAction.scale(to: 1, duration: 0.2)
                ])
            ]))
            
            K.ButtonTaps.tap1()
            
            if type == .menuStart {
                AudioManager.shared.playSound(for: "revive")
            }
        }
        else {
            Haptics.shared.addHapticFeedback(withStyle: .rigid)
        }
    }
    
    
}
