//
//  Extension+SKShapeNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/19/23.
//

import SpriteKit

extension SKShapeNode {
    ///Adds a simple drop shadow effect.
    func addDropShadow(rectOf: CGSize, cornerRadius: CGFloat, shadowOffset: CGFloat = 10, shadowColor: UIColor = .gray) {
        let shadow = SKShapeNode(rectOf: rectOf, cornerRadius: cornerRadius)
        shadow.position = CGPoint(x: -shadowOffset, y: -shadowOffset)
        shadow.fillColor = shadowColor
        shadow.strokeColor = .white
        shadow.lineWidth = 0
        shadow.zPosition = -zPositionOffset
        shadow.name = "dropShadow"
        shadow.alpha = 0.75

        addChild(shadow)
    }
    
    ///Adds a triple shadow effect.
    func addShadow(rectOf: CGSize, cornerRadius: CGFloat, shadowOffset: CGFloat = 10, shadowColor: UIColor = .gray) {
        let shadow1 = SKShapeNode(rectOf: rectOf, cornerRadius: cornerRadius)
        shadow1.position = CGPoint(x: -shadowOffset, y: -shadowOffset)
        shadow1.fillColor = shadowColor
        shadow1.strokeColor = .white
        shadow1.lineWidth = 0
        shadow1.zPosition = -zPositionOffset
        shadow1.name = "shadow1"
        shadow1.alpha = 0

        let shadow2 = SKShapeNode(rectOf: rectOf, cornerRadius: cornerRadius)
        shadow2.position = -2 * CGPoint(x: shadowOffset, y: shadowOffset)
        shadow2.fillColor = shadowColor
        shadow2.strokeColor = .white
        shadow2.lineWidth = 0
        shadow2.zPosition = 2 * -zPositionOffset
        shadow2.name = "shadow2"
        shadow2.alpha = 0

        let shadow3 = SKShapeNode(rectOf: rectOf, cornerRadius: cornerRadius)
        shadow3.position = -3 * CGPoint(x: shadowOffset, y: shadowOffset)
        shadow3.fillColor = shadowColor
        shadow3.strokeColor = .white
        shadow3.lineWidth = 0
        shadow3.zPosition = 3 * -zPositionOffset
        shadow3.name = "shadow3"
        shadow3.alpha = 0
        
        addChild(shadow1)
        addChild(shadow2)
        addChild(shadow3)
    }
    
    func updateShadowColor(_ color: UIColor = .gray) {
        for node in getShadowNodes() {
            node.fillColor = color
        }
    }
    
    ///Returns an array of all shadow related SKShapeNodes.
    func getShadowNodes() -> [SKShapeNode] {
        var shadowNodes: [SKShapeNode] = []
        
        for node in children {
            guard node.name == "shadow1" || node.name == "shadow2" || node.name == "shadow3" || node.name == "dropShadow" else { continue }
            guard let shadowNode = node as? SKShapeNode else { continue }
            
            shadowNodes.append(shadowNode)
        }
        
        return shadowNodes
    }
    
    func showShadow(shadowOffset: CGFloat = 10, animationDuration: TimeInterval = 0.1, completion: (() -> Void)?) {
        for node in children {
            switch node.name {
            case "shadow1":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0 * animationDuration),
                    SKAction.fadeAlpha(to: 0.75, duration: animationDuration)
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
            case "dropShadow":
                node.run(SKAction.move(to: CGPoint(x: -shadowOffset, y: -shadowOffset), duration: animationDuration))
            default:
                break
            }
        }
    }
    
    func hideShadow(animationDuration: TimeInterval = 0.05, completion: (() -> Void)?) {
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
            case "dropShadow":
                node.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: animationDuration))
            default:
                break
            }
        }
    }
    
    
}
