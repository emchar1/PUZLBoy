//
//  LevelSelectEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/29/23.
//

import SpriteKit

//protocol LevelSelectEngineDelegate: AnyObject {
//    func didTapLevelSelect()
//}


class LevelSelectEngine {
    
    // MARK: - Properties
    
    private var levelPicker: UIPickerView!
    private var node: SKShapeNode!
    var dismissButton: DecisionButtonSprite!
    
    var isShowing: Bool {
        return node.parent != nil
    }
    
    
    // MARK: - Initialization
    
    init() {
        levelPicker = UIPickerView(frame: .zero)

        node = SKShapeNode(rectOf: CGSize(width: 300, height: 300), cornerRadius: 20)
        node.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        node.lineWidth = 8
        node.strokeColor = .white
        node.fillColor = .gray
        node.setScale(0)
        node.position = CGPoint(x: 300, y: 60)
        node.zPosition = 2 * node.zPositionOffset
        
//        let okLabel = SKLabelNode(text: "OK")
//        okLabel.fontColor = UIFont.chatFontColor
//        okLabel.fontName = UIFont.chatFont
//        okLabel.fontSize = UIFont.chatFontSizeMedium
//        okLabel.horizontalAlignmentMode = .center
//        okLabel.verticalAlignmentMode = .center
        
        dismissButton = DecisionButtonSprite(text: "OK", color: .blue, iconImageName: nil)
//        dismissButton.delegate = self
//        dismissNode.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
//        dismissNode.lineWidth = 4
//        dismissNode.strokeColor = .white
//        dismissNode.fillColor = .blue
//        dismissNode.position = CGPoint(x: 0, y: -80)
//        dismissNode.zPosition = dismissNode.zPositionOffset
//        dismissNode.name = "dismissNode"
        
//        dismissButton.addChild(okLabel)
        node.addChild(dismissButton)
    }
    
    
    // MARK: - Show/Hide Functions
    
    func toggleLevelSelector(to parentNode: SKNode) {
        if isShowing {
            hideLevelSelector()
        }
        else {
            showLevelSelector(to: parentNode)
        }
    }
    
    func showLevelSelector(to parentNode: SKNode) {
        guard !isShowing else { return print("LevelSelectEngine already has a parent.") }
        
        parentNode.addChild(node)
        
        node.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2)
        ]))
    }
    
    func hideLevelSelector() {
        node.run(SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    
    // MARK: - Touch Functions
    
    
}
