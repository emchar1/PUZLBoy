//
//  PrincessCageSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/13/24.
//

import SpriteKit

class PrincessCageSprite: SKNode {
    
    // MARK: - Properties
    
    private let scaleSize: CGFloat = 8
    private var gameboard: GameboardSprite
    private var villainNode: SKSpriteNode
    private var princessNode: SKSpriteNode

    private var flingNode: SKSpriteNode!
    private var backNode: SKSpriteNode!
    private var frontNode: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, villainNode: SKSpriteNode, princessNode: SKSpriteNode) {
        self.gameboard = gameboard
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
        flingNode = SKSpriteNode(imageNamed: "magmoorShieldTop")
        flingNode.position = villainNode.position - CGPoint(x: 80, y: -80)
        flingNode.color = .red
        flingNode.colorBlendFactor = 1
        flingNode.setScale(0)
        flingNode.zPosition = villainNode.zPosition + 5
        
        backNode = SKSpriteNode(imageNamed: "magmoorShieldBottom")
        backNode.color = flingNode.color
        backNode.colorBlendFactor = flingNode.colorBlendFactor
        backNode.alpha = 0
        backNode.zPosition = -5
        
        frontNode = SKSpriteNode(imageNamed: "magmoorShieldTop")
        frontNode.color = flingNode.color
        frontNode.colorBlendFactor = flingNode.colorBlendFactor
        frontNode.alpha = 0
        frontNode.zPosition = 5
        
        gameboard.sprite.addChild(flingNode)
        princessNode.addChild(backNode)
        princessNode.addChild(frontNode)
    }
    
    
    // MARK: - Functions
    
    func encagePrincess() {
        let flingDuration: TimeInterval = 1
        let pulseDuration: TimeInterval = 1.8
        let fadeDuration: TimeInterval = 1.8
        
        let villain = Player(type: .villain)
        let attackAction = SKAction.animate(with: villain.textures[Player.Texture.attack.rawValue], timePerFrame: 0.12)
        
        let princess = Player(type: .princess)
        let writheAction = Player.animate(player: princess, type: .jump)
        
        let flingAction = SKAction.sequence([
            SKAction.group([
                SKAction.move(to: princessNode.position, duration: flingDuration),
                SKAction.rotate(byAngle: 2 * .pi, duration: flingDuration),
                SKAction.scale(to: 1 / UIDevice.spriteScale, duration: flingDuration)
            ]),
            SKAction.fadeOut(withDuration: fadeDuration / 6),
            SKAction.removeFromParent()
        ])
        
        let pulseAction = SKAction.repeatForever(SKAction.group([
            SKAction.rotate(byAngle: .pi / 2, duration: pulseDuration * 2),
            SKAction.sequence([
                SKAction.scale(to: scaleSize * 0.9, duration: pulseDuration),
                SKAction.scale(to: scaleSize * 1.1, duration: pulseDuration)
            ])
        ]))
        
        let encageAction = SKAction.group([
            SKAction.fadeIn(withDuration: fadeDuration / 3),
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
        
        princessNode.removeAllActions()
        princessNode.run(writheAction)
        
        flingNode.run(flingAction)
        backNode.run(SKAction.sequence([SKAction.wait(forDuration: flingDuration), encageAction, pulseAction]))
        frontNode.run(SKAction.sequence([SKAction.wait(forDuration: flingDuration), encageAction, pulseAction]))
        
        AudioManager.shared.playSound(for: "shieldcast", delay: flingDuration)
        AudioManager.shared.playSound(for: "shieldcast2", delay: flingDuration)
    }
    
    
}
