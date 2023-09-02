//
//  MenuItemLabel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/1/23.
//

import SpriteKit

protocol MenuItemLabelDelegate: AnyObject {
    func buttonWasTapped(_ node: MenuItemLabel)
}

class MenuItemLabel: SKLabelNode {
    
    // MARK: - Properties
    
    private var shadowNode: SKLabelNode = SKLabelNode()
    private var isPressed: Bool = false
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
    
    weak var delegate: MenuItemLabelDelegate?
    
    
    // MARK: - Initialization
    
    init(text: String, ofType type: MenuType, at position: CGPoint = .zero) {
        self.type = type
        
        super.init()

        self.text = text
        self.position = position
        fontName = UIFont.chatFont
        fontSize = UIFont.titleMenuFontSize
        fontColor = .white
        horizontalAlignmentMode = .center
        verticalAlignmentMode = .center
        zPosition = 10
        name = type.rawValue
        addHeavyDropShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func setIsEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    func touchDown() {
        guard isEnabled else { return }
        
        isPressed = true
        
        run(SKAction.scale(to: 0.95, duration: 0.1))
    }
    
    func touchUp() {
        guard isEnabled else { return }
        
        isPressed = false
        
        run(SKAction.scale(to: 1.0, duration: 0))
    }
    
    func tapButton(toColor tappedColor: UIColor) {
        guard isEnabled else { return }
        guard isPressed else { return }
        
        delegate?.buttonWasTapped(self)
        
        run(SKAction.group([
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
        
        if type == .menuStart {
            ButtonTap.shared.tap(type: .buttontap3)
        }
        else {
            ButtonTap.shared.tap(type: .buttontap1)
        }
    }
    
    
}
