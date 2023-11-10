//
//  Extension+SKLabelNode.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/20/23.
//

import SpriteKit

extension SKLabelNode {
    
    func addTripleShadow(shadowOffset: CGFloat = -3, shadow1Color: UIColor = .black, shadow2Color: UIColor = .black, shadow3Color: UIColor = .black) {
        let shadow1 = SKLabelNode(text: text)
        shadow1.position = CGPoint(x: shadowOffset, y: shadowOffset)
        shadow1.fontColor = shadow1Color
        shadow1.zPosition = -zPositionOffset
        shadow1.name = "shadow1"
        shadow1.alpha = 0

        let shadow2 = SKLabelNode(text: text)
        shadow2.position = 2 * CGPoint(x: shadowOffset, y: shadowOffset)
        shadow2.fontColor = shadow2Color
        shadow2.zPosition = 2 * -zPositionOffset
        shadow2.name = "shadow2"
        shadow2.alpha = 0

        let shadow3 = SKLabelNode(text: text)
        shadow3.position = 3 * CGPoint(x: shadowOffset, y: shadowOffset)
        shadow3.fontColor = shadow3Color
        shadow3.zPosition = 3 * -zPositionOffset
        shadow3.name = "shadow3"
        shadow3.alpha = 0

        addChild(shadow1)
        addChild(shadow2)
        addChild(shadow3)
        
        updateShadow()
    }
    
    func addDropShadow(shadowOffset: CGPoint = CGPoint(x: -3, y: -3), alpha: CGFloat = 0.25) {
        let shadow = SKLabelNode(text: text)
        shadow.position = shadowOffset
        shadow.fontColor = .black
        shadow.zPosition = -zPositionOffset
        shadow.alpha = alpha
        shadow.name = "dropShadow"
        
        addChild(shadow)
                
        updateShadow()
    }
    
    func addHeavyDropShadow(alpha: CGFloat = 0.25) {
        addDropShadow(shadowOffset: CGPoint(x: -8, y: -8), alpha: alpha)
    }
    
    func updateShadow() {
        for node in children {
            guard node.name == "dropShadow" || node.name == "shadow1" || node.name == "shadow2" || node.name == "shadow3" else { continue }
            guard let shadow = node as? SKLabelNode else { continue }
                
                
            shadow.text = text
            shadow.fontName = fontName
            shadow.fontSize = fontSize
            shadow.verticalAlignmentMode = verticalAlignmentMode
            shadow.horizontalAlignmentMode = horizontalAlignmentMode
            shadow.numberOfLines = numberOfLines
            shadow.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        }
    }
    
    @discardableResult func removeShadow() -> Bool {
        guard let shadow = children.filter({ $0.name == "dropShadow" }).first else { return false }

        shadow.removeFromParent()
        return true
    }
    
    func updateShadowColor(_ color: UIColor = .gray) {
        for node in children {
            guard node.name == "shadow1" || node.name == "shadow2" || node.name == "shadow3" || node.name == "dropShadow" else { continue }
            guard let shadowNode = node as? SKLabelNode else { continue }
            
            shadowNode.fontColor = color
        }
    }
    
    
    // MARK: - Animation
    
    func showShadow(shadowOffset: CGFloat = -3, animationDuration: TimeInterval = 0.1, completion: (() -> Void)?) {
        for node in children {
            switch node.name {
            case "shadow1":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 3 * animationDuration),
                    SKAction.fadeAlpha(to: 0.75, duration: animationDuration)
                ]))
            case "shadow2":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 3 * animationDuration),
                    SKAction.fadeAlpha(to: 0.5, duration: 2 * animationDuration)
                ]))
            case "shadow3":
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 3 * animationDuration),
                    SKAction.fadeAlpha(to: 0.25, duration: 3 * animationDuration)
                ])) {
                    completion?()
                }
            case "dropShadow":
                node.run(SKAction.move(to: CGPoint(x: shadowOffset, y: shadowOffset), duration: animationDuration))
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


extension SKLabelNode {
    // TODO: - Alternative to ChatEngine text animation dialgoue, that doesn't use timers. Better for pause screens, apparently.
    func startTyping(_ duration: TimeInterval, completion: (() -> Void)?) {
        guard let text = self.text else { return }

        self.text = ""
        
        var index = 0
        var block: (() -> Void)!
        
        block = {
            index += 1
            
            if index > text.count {
                completion?()
                return
            }
            else {
                let action = SKAction.sequence([
                    SKAction.wait(forDuration: duration),
                    SKAction.run {
                        self.text = String(text.prefix(index))
                    }
                ])
                
                self.run(action, completion: block)
            }
        }
        
        block()
    }
}
