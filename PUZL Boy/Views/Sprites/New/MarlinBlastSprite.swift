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
    
    deinit {
        print("deinit MarlinBlastSprite")
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
    
    func animateBlast(playSound: Bool, color: UIColor = .cyan, delay: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let blastDuration: TimeInterval = 0.25
        let blastContactPoint = CGPoint(x: 0, y: K.ScreenDimensions.size.height / 2)
        
        let blastAction = SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0),
            SKAction.moveTo(y: blastContactPoint.y, duration: blastDuration)
        ])
        
        let flashOverlayNode = SKShapeNode(rectOf: K.ScreenDimensions.size)
        flashOverlayNode.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
        flashOverlayNode.fillColor = .white
        flashOverlayNode.zPosition = 5
        flashOverlayNode.alpha = 0
        
        addChild(flashOverlayNode)
        
        if playSound {
            AudioManager.shared.playSound(for: "marlinblast", delay: delay ?? 0)
        }
        
        flashOverlayNode.run(SKAction.sequence([
            SKAction.wait(forDuration: (delay ?? 0) + blastDuration),
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
        
        blastTop.run(blastAction)
        blastBottom.run(blastAction)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: (delay ?? 0) + blastDuration),
            SKAction.fadeOut(withDuration: blastDuration * 2)
        ])) { [weak self] in
            self?.resetBlast()
            completion?()
        }
    }
    
    
}
