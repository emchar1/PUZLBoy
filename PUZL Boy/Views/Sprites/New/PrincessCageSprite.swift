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
    private var villainNode: SKSpriteNode
    private var princessNode: SKSpriteNode

    private var flingNode: SKSpriteNode!
    private var backNode: SKSpriteNode!
    private var frontNode: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    init(villainNode: SKSpriteNode, princessNode: SKSpriteNode) {
        self.villainNode = villainNode
        self.princessNode = princessNode
        
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit PrincessCageSprite")
    }
    
    private func setupNodes() {
        flingNode = SKSpriteNode(imageNamed: "princessCageBack")
        
        backNode = SKSpriteNode(imageNamed: "princessCageBack")
        backNode.setScale(scaleSize * 3)
        backNode.alpha = 0
        backNode.zPosition = -5
        
        frontNode = SKSpriteNode(imageNamed: "princessCageFront")
        frontNode.setScale(scaleSize * 3)
        frontNode.alpha = 0
        frontNode.zPosition = +5
        
//        villainNode.addChild(flingNode)
        princessNode.addChild(backNode)
        princessNode.addChild(frontNode)
    }
    
    
    // MARK: - Functions
    
    func encagePrincess() {
        // FIXME; - Fling cage not working!!
        print("princessPosition: \(princessNode.positionInScene), villainNode: \(villainNode.positionInScene), cageNode: \(flingNode.positionInScene), villain - princess: \(villainNode.position - princessNode.position), v - p inScene: \((villainNode.positionInScene ?? .zero) - (princessNode.positionInScene ?? .zero))")
        
        let flingDuration: TimeInterval = 2
        let pulseDuration: TimeInterval = 1.8
        let fadeDuration: TimeInterval = 1.8
        
        let villain = Player(type: .villain)
        let attackAction = SKAction.animate(with: villain.textures[Player.Texture.attack.rawValue], timePerFrame: 0.12)
        
        let princess = Player(type: .princess)
        let writheAction = SKAction.repeatForever(SKAction.animate(with: princess.textures[Player.Texture.jump.rawValue], timePerFrame: 0.02))
        
        let flingAction = SKAction.sequence([
            SKAction.group([
                SKAction.move(to: CGPoint(x: 2, y: -3) * princessNode.position, duration: flingDuration),
                SKAction.rotate(byAngle: 3 * 2 * .pi, duration: flingDuration),
                SKAction.scale(to: scaleSize * 0.5, duration: flingDuration)
            ]),
            SKAction.fadeOut(withDuration: 0),
            SKAction.removeFromParent()
        ])
        
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
        
        villainNode.run(attackAction)
        flingNode.run(flingAction)
        
        princessNode.removeAllActions()
        princessNode.run(writheAction)
        frontNode.run(SKAction.sequence([encageAction, pulseAction]))
        backNode.run(SKAction.sequence([encageAction, pulseAction]))
    }
    
    
}
