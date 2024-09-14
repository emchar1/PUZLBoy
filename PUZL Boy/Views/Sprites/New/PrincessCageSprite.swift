//
//  PrincessCageSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/13/24.
//

import SpriteKit

class PrincessCageSprite: SKNode {
    
    // MARK: - Properties
    
    private let scaleSize: CGFloat = 15
    
    private var backNode: SKSpriteNode!
    private var frontNode: SKSpriteNode!
    private var princessNode: SKSpriteNode
    
    
    // MARK: - Initialization
    
    init(princessNode: SKSpriteNode) {
        self.princessNode = princessNode
        
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        backNode = SKSpriteNode(imageNamed: "princessCageBack")
        backNode.setScale(scaleSize * 3)
        backNode.alpha = 0
        backNode.zPosition = -5
        
        frontNode = SKSpriteNode(imageNamed: "princessCageFront")
        frontNode.setScale(scaleSize * 3)
        frontNode.alpha = 0
        frontNode.zPosition = +5
        
        princessNode.addChild(backNode)
        princessNode.addChild(frontNode)
    }
    
    
    // MARK: - Functions
    
    func encagePrincess() {
        let pulseDuration: TimeInterval = 1.8
        let fadeDuration: TimeInterval = 1.8
        
        let princess = Player(type: .princess)
        let writheAction = SKAction.repeatForever(SKAction.animate(with: princess.textures[Player.Texture.jump.rawValue], timePerFrame: 0.02))
        
        let pulseAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: scaleSize * 0.9, duration: pulseDuration),
            SKAction.scale(to: scaleSize * 1.1, duration: pulseDuration)
        ]))
        
        let encageAction = SKAction.group([
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.sequence([
                SKAction.scale(to: scaleSize * 0.5, duration: fadeDuration / 6),
                SKAction.scale(to: scaleSize * 2, duration: fadeDuration / 6),
                SKAction.scale(to: scaleSize * 0.75, duration: fadeDuration / 6),
                SKAction.scale(to: scaleSize * 1.25, duration: fadeDuration / 6),
                SKAction.scale(to: scaleSize * 0.9, duration: fadeDuration / 6),
                SKAction.scale(to: scaleSize * 1.1, duration: fadeDuration / 6)
            ])
        ])

        princessNode.removeAllActions()
        princessNode.run(writheAction)
        frontNode.run(SKAction.sequence([encageAction, pulseAction]))
        backNode.run(SKAction.sequence([encageAction, pulseAction]))
    }
    
    
}
