//
//  SkipIntroSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/5/23.
//

import SpriteKit

protocol SkipIntroSpriteDelegate: AnyObject {
    func buttonWasTapped()
}


class SkipIntroSprite: SKNode {

    // MARK: - Properties
    
    private let nodeName = "SkipIntroSprite"
    private var isPressed = false
    private var shouldDisable: Bool!
    
    private var backgroundNode: SKShapeNode!
    private var labelNode: SKLabelNode!
    private var ffButtonNode: SKSpriteNode!
    
    weak var delegate: SkipIntroSpriteDelegate?

    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit SkipIntroSprite")
    }
    
    private func setupNodes() {
        shouldDisable = false
        
        labelNode = SKLabelNode(text: "SKIP INTRO")
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        labelNode.fontName = UIFont.gameFont
        labelNode.fontSize = UIFont.gameFontSizeSmall
        labelNode.fontColor = UIFont.gameFontColor
        labelNode.zPosition = K.ZPosition.display
        labelNode.addDropShadow()
        
        ffButtonNode = SKSpriteNode(imageNamed: "forwardButtonBare")

        
        let padding: CGFloat = 8
        let backgroundSize = CGSize(width: labelNode.frame.width + ffButtonNode.size.width + padding * 4, height: ffButtonNode.size.height + padding * 2)
        let cornerRadius: CGFloat = (ffButtonNode.size.height + padding * 2) / 2
        
        backgroundNode = SKShapeNode(rectOf: backgroundSize, cornerRadius: cornerRadius)
        backgroundNode.fillColor = .clear
        backgroundNode.strokeColor = .white
        backgroundNode.lineWidth = 4
        backgroundNode.name = nodeName

        labelNode.position = CGPoint(x: -(ffButtonNode.size.width + padding) / 2, y: 0)
        ffButtonNode.position = CGPoint(x: (labelNode.frame.width + padding) / 2, y: 0)
        
        addChild(backgroundNode)
        backgroundNode.addChild(labelNode)
        backgroundNode.addChild(ffButtonNode)
    }
    
    
    // MARK: - Functions
    
    func animateSprite() {
        let duration: TimeInterval = 0.8
        
        self.alpha = 0

        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeIn(withDuration: duration),
            SKAction.wait(forDuration: duration * 2),
            SKAction.fadeOut(withDuration: duration),
            SKAction.wait(forDuration: duration)
        ])))
    }
    
    func deanimateSprite() {
        removeAllActions()
        removeFromParent()
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !shouldDisable else { return }
        guard let location = touches.first?.location(in: self) else { return }
        
        for node in nodes(at: location) {
            guard node.name == nodeName else { continue }

            isPressed = true
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPressed else { return }
        guard let location = touches.first?.location(in: self) else { return }
        
        for node in nodes(at: location) {
            guard node.name == nodeName else { continue }
            
            shouldDisable = true
            isPressed = false

            removeAllActions()
            run(SKAction.fadeOut(withDuration: 0.5))

            delegate?.buttonWasTapped()
            
            return
        }
    }
    
    
}
