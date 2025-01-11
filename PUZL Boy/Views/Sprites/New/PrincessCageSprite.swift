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
        flingNode.position = villainNode.position + Player.mysticWandOrigin
        flingNode.color = .yellow
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
        //Properties
        let villain = Player(type: .villain)
        let princess = Player(type: .princess)
        let attackDuration: TimeInterval = 0.12 * 3
        let flingDuration: TimeInterval = 0.5
        let fadeDuration: TimeInterval = 1.8
        
        //Actions
        let waitAction = SKAction.wait(forDuration: flingDuration + attackDuration)
        let attackAction = SKAction.animate(with: villain.textures[Player.Texture.attack.rawValue], timePerFrame: 0.12)
        let writheAction = Player.animate(player: princess, type: .jump)
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: .pi / 4, duration: fadeDuration))
        
        let pulseAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: scaleSize * 0.9, duration: fadeDuration),
            SKAction.scale(to: scaleSize * 1.1, duration: fadeDuration)
        ]))
        
        let flingAction = SKAction.sequence([
            SKAction.wait(forDuration: attackDuration),
            SKAction.group([
                SKAction.move(to: princessNode.position, duration: flingDuration),
                SKAction.rotate(byAngle: .pi, duration: flingDuration),
                SKAction.scale(to: 1 / UIDevice.spriteScale, duration: flingDuration)
            ]),
            SKAction.group([
                SKAction.scale(to: 0.5 / UIDevice.spriteScale, duration: fadeDuration / 6),
                SKAction.fadeOut(withDuration: fadeDuration / 6)
            ]),
            SKAction.removeFromParent()
        ])
        
        let encageAction = SKAction.group([
            SKAction.fadeIn(withDuration: fadeDuration / 3),
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: fadeDuration),
            SKAction.sequence([
                SKAction.scale(to: scaleSize * 0.50, duration: fadeDuration / 6),
                SKAction.scale(to: scaleSize * 2.00, duration: fadeDuration / 5),
                SKAction.scale(to: scaleSize * 0.75, duration: fadeDuration / 4),
                SKAction.scale(to: scaleSize * 1.25, duration: fadeDuration / 3),
                SKAction.scale(to: scaleSize * 0.90, duration: fadeDuration / 2),
                SKAction.scale(to: scaleSize * 1.10, duration: fadeDuration / 1)
            ])
        ])
        
        
        //Animations & Sound
        villainNode.run(attackAction)
        
        princessNode.removeAllActions()
        princessNode.run(SKAction.sequence([waitAction, writheAction]))
        
        flingNode.run(flingAction)
        
        backNode.run(rotateAction)
        backNode.run(SKAction.sequence([waitAction, encageAction, pulseAction]))
        
        frontNode.run(rotateAction)
        frontNode.run(SKAction.sequence([waitAction, encageAction, pulseAction]))
        
        AudioManager.shared.playSound(for: "shieldcast", delay: flingDuration + attackDuration)
        AudioManager.shared.playSound(for: "shieldcast2", delay: flingDuration + attackDuration)
        AudioManager.shared.playSound(for: "shieldpulse", delay: flingDuration + attackDuration)
    }
    
    
}
