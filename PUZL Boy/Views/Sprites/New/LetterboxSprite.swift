//
//  LetterboxSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/9/24.
//

import SpriteKit

class LetterboxSprite: SKNode {
    
    // MARK: - Properties
    
    private var topNode: SKShapeNode!
    private var bottomNode: SKShapeNode!
    private var color: UIColor
    private(set) var height: CGFloat

    
    // MARK: - Initialization
    
    init(color: UIColor, height: CGFloat) {
        self.color = color
        self.height = height

        super.init()

        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        zPosition = K.ZPosition.letterboxOverlay
        
        topNode = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.size.width, height: 1))
        topNode.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height)
        topNode.fillColor = color
        topNode.lineWidth = 0
        
        bottomNode = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.size.width, height: 1))
        bottomNode.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: 0)
        bottomNode.fillColor = color
        bottomNode.lineWidth = 0

        addChild(topNode)
        addChild(bottomNode)
    }
    
    
    // MARK: - Functions
    
    func setColor(_ color: UIColor) {
        self.color = color
    }
    
    func setHeight(_ height: CGFloat) {
        self.height = height
    }
    
    func show(duration: TimeInterval = 3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        topNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.scaleY(to: height, duration: duration)
        ])) {
            completion?()
        }
        
        bottomNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.scaleY(to: height, duration: duration)
        ]))
    }
    
    func hide(duration: TimeInterval = 3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        topNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.scaleY(to: 1, duration: duration)
        ])) {
            completion?()
        }
        
        bottomNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.scaleY(to: 1, duration: duration)
        ]))
    }
}
