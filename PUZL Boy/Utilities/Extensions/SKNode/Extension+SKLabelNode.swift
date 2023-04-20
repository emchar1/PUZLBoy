//
//  Extension+SKLabelNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/20/23.
//

import SpriteKit

extension SKLabelNode {
    
    func addTripleShadow(shadowOffset: CGFloat = -3, shadow1Color: UIColor = .black, shadow2Color: UIColor = .black, shadow3Color: UIColor = .black) {
        let shadow1 = SKLabelNode(text: self.text)
        shadow1.position = CGPoint(x: shadowOffset, y: shadowOffset)
        shadow1.fontColor = shadow1Color
        shadow1.zPosition = zPositionOffset
        shadow1.name = "shadow1"
        shadow1.alpha = 0.75

        let shadow2 = SKLabelNode(text: self.text)
        shadow2.position = CGPoint(x: 2 * shadowOffset, y: 2 * shadowOffset)
        shadow2.fontColor = shadow2Color
        shadow2.zPosition = 2 * zPositionOffset
        shadow2.name = "shadow2"
        shadow2.alpha = 0.5

        let shadow3 = SKLabelNode(text: self.text)
        shadow3.position = CGPoint(x: 3 * shadowOffset, y: 3 * shadowOffset)
        shadow3.fontColor = shadow3Color
        shadow3.zPosition = 3 * zPositionOffset
        shadow3.name = "shadow3"
        shadow3.alpha = 0.25

        addChild(shadow1)
        addChild(shadow2)
        addChild(shadow3)
        
        updateShadow()
    }
    
    func addDropShadow(shadowOffset: CGPoint = CGPoint(x: -3, y: -3)) {
        let shadow = SKLabelNode(text: self.text)
        shadow.position = shadowOffset
        shadow.fontColor = .black
        shadow.zPosition = zPositionOffset
        shadow.alpha = 0.25
        shadow.name = "dropShadow"
        
        addChild(shadow)
                
        updateShadow()
    }
    
    func addHeavyDropShadow() {
        addDropShadow(shadowOffset: CGPoint(x: -8, y: -8))
    }
    
    func updateShadow() {
        for node in children {
            guard node.name == "dropShadow" || node.name == "shadow1" || node.name == "shadow2" || node.name == "shadow3" else { continue }
            guard let shadow = node as? SKLabelNode else { continue }
                
                
            shadow.text = self.text
            shadow.fontName = self.fontName
            shadow.fontSize = self.fontSize
            shadow.verticalAlignmentMode = self.verticalAlignmentMode
            shadow.horizontalAlignmentMode = self.horizontalAlignmentMode
            shadow.numberOfLines = self.numberOfLines
            shadow.preferredMaxLayoutWidth = self.preferredMaxLayoutWidth
        }
    }
    
    @discardableResult func removeShadow() -> Bool {
        guard let shadow = children.filter({ $0.name == "dropShadow" }).first else { return false }

        shadow.removeFromParent()
        return true
    }
}
