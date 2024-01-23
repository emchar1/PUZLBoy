//
//  MarlinBlastSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/22/24.
//

import SpriteKit

class MarlinBlastSprite: SKNode {
    
    // MARK: - Properties
    
    private var blastTop: SKSpriteNode!
    private var blastBottom: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        blastTop = SKSpriteNode(imageNamed: "marlinBlast")
        blastTop.anchorPoint = .zero
        blastTop.position = CGPoint(x: 0, y: K.ScreenDimensions.size.height)
        blastTop.size = CGSize(width: K.ScreenDimensions.size.width, height: K.ScreenDimensions.size.width)
        
        blastBottom = blastTop.copy() as? SKSpriteNode
        blastBottom.position.y = 0
        blastBottom.yScale = -1

        addChild(blastTop)
        addChild(blastBottom)
    }
    
    
    // MARK: - Functions
    
    private func resetBlast() {
        blastTop.position.y = K.ScreenDimensions.size.height
        blastBottom.position.y = 0
        
        self.alpha = 1
    }
    
    func animateBlast() {
        let blastDuration: TimeInterval = 0.25
        let blastContactPoint = CGPoint(x: 0, y: K.ScreenDimensions.size.height / 2)
        let blastTopAction = SKAction.moveTo(y: blastContactPoint.y, duration: blastDuration)
        let blastBottomAction = SKAction.moveTo(y: blastContactPoint.y, duration: blastDuration)
        
        let flashOverlayNode = SKShapeNode(rectOf: K.ScreenDimensions.size)
        flashOverlayNode.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
        flashOverlayNode.fillColor = .white
        flashOverlayNode.zPosition = 5
        flashOverlayNode.alpha = 0
        
        addChild(flashOverlayNode)
        
        AudioManager.shared.playSound(for: "marlinblast")
                
        flashOverlayNode.run(SKAction.sequence([
            SKAction.wait(forDuration: blastDuration),
            SKAction.fadeIn(withDuration: 0),
            SKAction.fadeOut(withDuration: blastDuration * 0.25),
            SKAction.fadeIn(withDuration: 0),
            SKAction.fadeOut(withDuration: blastDuration * 0.25),
            SKAction.fadeIn(withDuration: 0),
            SKAction.fadeOut(withDuration: blastDuration * 0.25),
            SKAction.fadeIn(withDuration: 0),
            SKAction.fadeOut(withDuration: blastDuration * 0.75),
            SKAction.removeFromParent()
        ]))

        blastTop.run(blastTopAction)
        blastBottom.run(blastBottomAction)

        run(SKAction.sequence([
            SKAction.wait(forDuration: blastDuration),
            SKAction.fadeOut(withDuration: blastDuration * 2)
        ])) { [unowned self] in
            resetBlast()
        }
        
    }
}
