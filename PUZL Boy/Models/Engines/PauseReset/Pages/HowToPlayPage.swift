//
//  HowToPlayPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/10/23.
//

import SpriteKit

class HowToPlayPage: ParentPage {
    
    // MARK: - Properties
    
    private let maxPositionChange: CGFloat = 50
    private var isPressed = false
    private var initialYPosition: CGFloat?
    private var finalYPosition: CGFloat?
    private var positionChange: CGFloat {
        guard let finalYPosition = finalYPosition, let initialYPosition = initialYPosition else { return 0 }

        return min(max(-maxPositionChange, finalYPosition - initialYPosition), maxPositionChange)
    }
    
    private var maskSize: CGSize!
    private var cropNode: SKCropNode!
    private var maskNode: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    init(maskSize: CGSize) {
        let content = CGSize(width: maskSize.width, height: maskSize.height * 2)

        super.init(contentSize: content, titleText: "How To Play")

        self.maskSize = maskSize
        self.contentSize = content
        
        maskNode = SKSpriteNode(color: .magenta, size: maskSize)
        maskNode.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        maskNode.name = "maskNode"

        cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: maskSize.height / 2)
        cropNode.maskNode = maskNode
        
        contentNode.color = .brown
                
        name = nodeName
        
        addChild(cropNode)
        cropNode.addChild(contentNode)
        contentNode.addChild(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Touch Functions
    
    override func touchDown(at location: CGPoint) {
        super.touchDown(at: location)
        
        isPressed = true
        
        initialYPosition = location.y
    }
    
    override func touchUp() {
        super.touchUp()
        
        isPressed = false

        if contentNode.position.y <= 0 {
            moveContentNode(to: 0, duration: 0.25)
        }
        else if contentNode.position.y >= contentSize.height - maskSize.height {
            moveContentNode(to: contentSize.height - maskSize.height, duration: 0.25)
        }

        initialYPosition = nil
        finalYPosition = nil
    }
    
    func moveContentNode(to y: CGFloat, duration: TimeInterval) {
        contentNode.run(SKAction.moveTo(y: y, duration: duration))
    }
    
    func scrollNode(to location: CGPoint) {
        guard isPressed else { return }
        guard initialYPosition != nil else { return }

        let scrollThreshold: CGFloat = 40

        finalYPosition = location.y

        if contentNode.position.y <= -scrollThreshold && positionChange <= -maxPositionChange {
            contentNode.position.y += -1
        }
        else if contentNode.position.y >= contentSize.height - maskSize.height + scrollThreshold && positionChange >= maxPositionChange {
            contentNode.position.y += 1
        }
        else {
            contentNode.position.y += positionChange
        }
    }
}
