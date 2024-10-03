//
//  InstructionalSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/2/24.
//

import SpriteKit

class InstructionalSprite: SKNode {
    
    // MARK: - Properties
    
    private let iconFileName: String?
    private let text: String
    private let spawnPosition: CGPoint
    
    private var iconNode: SKSpriteNode?
    private var textNode: SKLabelNode!
    
    enum AnimationType {
        case taptap, summon, text
    }
    
    
    // MARK: - Initialization
    
    init(iconFileName: String?, text: String, position: CGPoint) {
        self.iconFileName = iconFileName
        self.text = text
        self.spawnPosition = position
        
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit InstructionalSprite - \(textNode.text ?? "No label")")
    }
    
    private func setupNodes() {
        let mainColor = UIColor.white
        
        if let iconFileName = iconFileName {
            iconNode = SKSpriteNode(texture: SKTexture(imageNamed: iconFileName))
            iconNode!.position = spawnPosition + CGPoint(x: 0, y: 150)
            iconNode!.size = CGSize(width: 200, height: 200)
            iconNode!.color = mainColor
            iconNode!.colorBlendFactor = 1
            iconNode!.alpha = 0
            iconNode!.zPosition = K.ZPosition.messagePrompt
        }
        
        textNode = SKLabelNode(text: text)
        textNode.position = spawnPosition
        textNode.fontName = UIFont.chatFont
        textNode.fontSize = UIFont.chatFontSizeLarge
        textNode.fontColor = mainColor
        textNode.alpha = 0
        textNode.zPosition = K.ZPosition.messagePrompt
        textNode.addDropShadow()
        
        name = text
    }
    
    
    // MARK: - Main Functions
    
    func addToParent(_ parentNode: SKNode) {
        if let iconNode = iconNode {
            addChild(iconNode)
        }
        
        addChild(textNode)
        
        parentNode.addChild(self)
    }
    
    func animateNodes(duration: TimeInterval, completion: @escaping () -> Void) {
        let tapAction = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.wait(forDuration: duration),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ])
        
        iconNode?.run(animateNodeType(.taptap), withKey: "iconKey")
        iconNode?.run(tapAction)
        
        textNode.run(animateNodeType(.text), withKey: "textKey")
        textNode.run(tapAction) { [unowned self] in
            removeAction(forKey: "iconKey")
            removeAction(forKey: "textKey")
            completion()
        }
    }
    
    private func animateNodeType(_ animationType: AnimationType) -> SKAction {
        let action: SKAction

        switch animationType {
        case .taptap:
            action = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 0.8, duration: 0),
                SKAction.scale(to: 1, duration: 0.1)
            ]))
        case .summon:
            action = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 0.8, duration: 0),
                SKAction.scale(to: 1, duration: 0.1)
            ]))
        case .text:
            action = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.25),
                SKAction.fadeIn(withDuration: 0.25)
            ]))
        }
        
        return action
    }
    
    
    
}
