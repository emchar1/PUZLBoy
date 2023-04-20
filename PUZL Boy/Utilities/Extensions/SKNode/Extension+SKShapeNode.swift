//
//  Extension+SKShapeNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/19/23.
//

import SpriteKit

extension SKShapeNode {
    func addShadow(rectOf: CGSize, cornerRadius: CGFloat, shadowOffset: CGFloat = 10, shadowColor: UIColor = .gray) {
        let shadow1 = SKShapeNode(rectOf: rectOf, cornerRadius: cornerRadius)
        shadow1.position = CGPoint(x: -shadowOffset, y: -shadowOffset)
        shadow1.fillColor = shadowColor
        shadow1.strokeColor = .white
        shadow1.lineWidth = 0
        shadow1.zPosition = zPositionOffset
        shadow1.name = "shadow1"
        shadow1.alpha = 0

        let shadow2 = SKShapeNode(rectOf: rectOf, cornerRadius: cornerRadius)
        shadow2.position = CGPoint(x: -2 * shadowOffset, y: -2 * shadowOffset)
        shadow2.fillColor = shadowColor
        shadow2.strokeColor = .white
        shadow2.lineWidth = 0
        shadow2.zPosition = 2 * zPositionOffset
        shadow2.name = "shadow2"
        shadow2.alpha = 0

        let shadow3 = SKShapeNode(rectOf: rectOf, cornerRadius: cornerRadius)
        shadow3.position = CGPoint(x: -3 * shadowOffset, y: -3 * shadowOffset)
        shadow3.fillColor = shadowColor
        shadow3.strokeColor = .white
        shadow3.lineWidth = 0
        shadow3.zPosition = 3 * zPositionOffset
        shadow3.name = "shadow3"
        shadow3.alpha = 0
        
        addChild(shadow1)
        addChild(shadow2)
        addChild(shadow3)
    }
    
    func updateShadowColor(_ color: UIColor = .gray) {
        for node in children {
            guard node.name == "shadow1" || node.name == "shadow2" || node.name == "shadow3" else { continue }
            guard let shadow = node as? SKShapeNode else { continue }
                                
            shadow.fillColor = color
        }
    }
    
    func showShadow(animationDuration: TimeInterval = 0.1, completion: (() -> Void)?) {
        guard childNode(withName: "shadow1") != nil else { return print("No shadow to show, so shoo!") }
        
        for node in children {
            switch node.name {
            case "shadow1":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0 * animationDuration),
                    SKAction.fadeAlpha(to: 0.5, duration: animationDuration)
                ]))
            case "shadow2":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 1 * animationDuration),
                    SKAction.fadeAlpha(to: 0.5, duration: animationDuration)
                ]))
            case "shadow3":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 2 * animationDuration),
                    SKAction.fadeAlpha(to: 0.25, duration: animationDuration)
                ])) {
                    completion?()
                }
            default:
                break
            }
        }
    }
    
    func hideShadow(animationDuration: TimeInterval = 0.05, completion: (() -> Void)?) {
        guard childNode(withName: "shadow1") != nil else { return print("No shadow to hide.") }
        
        for node in children {
            switch node.name {
            case "shadow1":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 2 * animationDuration),
                    SKAction.fadeAlpha(to: 0, duration: animationDuration)
                ])) {
                    completion?()
                }
            case "shadow2":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 1 * animationDuration),
                    SKAction.fadeAlpha(to: 0, duration: animationDuration)
                ]))
            case "shadow3":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0 * animationDuration),
                    SKAction.fadeAlpha(to: 0, duration: animationDuration)
                ]))
            default:
                break
            }
        }
    }
    
    
}
