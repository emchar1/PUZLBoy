//
//  CloseButtonSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/1/23.
//

import SpriteKit

protocol CloseButtonSpriteDelegate: AnyObject {
    func didTapButton()
}

class CloseButtonSprite: SKNode {
    // MARK: - Properties
    
    private let buttonSize = CGSize(width: 80, height: 80)
    private let inset: CGFloat = 20
    private var isPressed = false
    private var sprite: SKSpriteNode!
    
    weak var delegate: CloseButtonSpriteDelegate?
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    private func setupNodes() {
        sprite = SKSpriteNode(imageNamed: "closeButton")
        sprite.scale(to: buttonSize)
        sprite.color = .black
        sprite.colorBlendFactor = 0
        
        zPosition = 2 * zPositionOffset
        name = "closeButton"
        
        addChild(sprite)
    }
    
    
    // MARK: - Functions
    
    func setPosition(to position: CGPoint, withInset: Bool = true) {
        self.position = position - buttonSize.width / 2 - (withInset ? inset : 0)
    }
    
    
    // MARK: - UI Touch Functions
    
    func touchDown() {
        isPressed = true
        
        sprite.colorBlendFactor = 0.25
    }
    
    func touchUp() {
        guard isPressed else { return }
        
        isPressed = false
        
        sprite.colorBlendFactor = 0
    }
        
    func buttonTapped() {
        guard isPressed else { return }
        
        delegate?.didTapButton()

        ButtonTap.shared.tap(type: .buttontap6)
    }
}
