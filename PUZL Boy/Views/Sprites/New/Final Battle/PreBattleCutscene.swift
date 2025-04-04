//
//  PreBattleCutscene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/3/25.
//

import SpriteKit

class PreBattleCutscene: SKScene {
    
    // MARK: - Properties
    
    var centerPoint: CGPoint {
        CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    private var fadeNode: SKShapeNode!
    
    private var hero: Player!
    private var elder0: Player!
    private var elder1: Player!
    private var elder2: Player!
    private var fakePrincess: Player!
    private var magmoor: Player!
    private var gate: SKSpriteNode!
    private var gateBackground: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("PreBattleCutscene deinit")
    }
    
    private func setupScene() {
        backgroundColor = .black
        
        fadeNode = SKShapeNode(rectOf: size)
        fadeNode.position = centerPoint
        fadeNode.fillColor = .black
        fadeNode.lineWidth = 0
        fadeNode.zPosition = 100
        
        hero = Player(type: .hero)
        hero.sprite.position = centerPoint
        hero.sprite.alpha = 0
        hero.sprite.zPosition = 20
        
        elder0 = Player(type: .elder0)
        elder0.sprite.position = centerPoint
        elder0.sprite.alpha = 0
        elder0.sprite.zPosition = 18
        
        elder1 = Player(type: .elder1)
        elder1.sprite.position = centerPoint
        elder1.sprite.alpha = 0
        elder1.sprite.zPosition = 22
        
        elder2 = Player(type: .elder2)
        elder2.sprite.position = centerPoint
        elder2.sprite.alpha = 0
        elder2.sprite.zPosition = 14
        
        fakePrincess = Player(type: .princess)
        fakePrincess.sprite.position = centerPoint
        fakePrincess.sprite.alpha = 0
        fakePrincess.sprite.zPosition = 25
        
        magmoor = Player(type: .villain)
        magmoor.sprite.position = centerPoint
        magmoor.sprite.alpha = 0
        magmoor.sprite.zPosition = 27
        
        gate = SKSpriteNode(texture: SKTexture(imageNamed: "endOpenMagic"))
        gate.position = centerPoint
        gate.setScale(2)
        gate.zPosition = 10
        
        print(gate.size)
        
        gateBackground = SKSpriteNode(color: .white, size: CGSize(width: 512 + 16, height: 512 + 16))
        gateBackground.position = centerPoint
        gateBackground.zPosition = 8
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(fadeNode)
        addChild(hero.sprite)
        addChild(elder0.sprite)
        addChild(elder1.sprite)
        addChild(elder2.sprite)
        addChild(fakePrincess.sprite)
        addChild(magmoor.sprite)
        addChild(gate)
        addChild(gateBackground)
    }
    
    func animateScene() {
        fadeNode.run(SKAction.fadeOut(withDuration: 4.5))
        
        playScene1()
    }
    
    private func playScene1() {
        let pauseDuration: TimeInterval = 3
        let runDuration: TimeInterval = 0.5
        
        func enterGate(player: Player, offset: CGPoint) {
            let keyRunningAction = "runningAction"
            
            player.sprite.run(Player.animate(player: player, type: .run), withKey: keyRunningAction)
            player.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: pauseDuration),
                offset.x < 0 ? SKAction.scaleX(to: -player.sprite.xScale, duration: 0) : SKAction.wait(forDuration: 0),
                SKAction.group([
                    SKAction.fadeIn(withDuration: runDuration),
                    SKAction.moveBy(x: offset.x, y: offset.y, duration: runDuration)
                ]),
                offset.x < 0 ? SKAction.scaleX(to: player.sprite.xScale, duration: 0) : SKAction.wait(forDuration: 0),
            ])) {
                player.sprite.removeAction(forKey: keyRunningAction)
                player.sprite.run(Player.animate(player: player, type: .idle))
            }
        }
        
        enterGate(player: hero, offset: CGPoint(x: 200, y: -50))
        enterGate(player: elder0, offset: CGPoint(x: 50, y: 50))
        enterGate(player: elder1, offset: CGPoint(x: -25, y: -100))
        enterGate(player: elder2, offset: CGPoint(x: -200, y: 0))
        
        gate.run(SKAction.repeatForever(SKAction.colorizeWithRainbowColorSequence(blendFactor: 1, duration: 0.5)))
        gate.run(SKAction.sequence([
            SKAction.wait(forDuration: pauseDuration + runDuration),
            SKAction.run {
                AudioManager.shared.playSound(for: "dooropen")
            },
            SKAction.setTexture(SKTexture(imageNamed: "endClosedMagic"))
        ]))
    }
    
    
}
