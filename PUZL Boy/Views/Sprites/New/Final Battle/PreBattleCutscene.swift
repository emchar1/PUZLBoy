//
//  PreBattleCutscene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/3/25.
//

import SpriteKit

class PreBattleCutscene: SKScene {
    
    // MARK: - Properties
    
    //offset positions of hero and elders with respect to gate position
    private let offsetPlayers: [CGPoint] = [
        CGPoint(x: 200, y: -50),    //hero
        CGPoint(x: 25, y: 50),      //elder0
        CGPoint(x: -50, y: -150),   //elder1
        CGPoint(x: -150, y: 40)     //elder2
    ]
    
    private var playerScale: CGFloat { Player.getGameboardScale(panelSize: size.width / 7) }
    private var centerPoint: CGPoint { CGPoint(x: size.width / 2, y: size.height / 2) }
    private var risePoint: CGPoint { CGPoint(x: size.width / 2, y: size.height * 3/4) }
    
    private var fadeNode: SKShapeNode!
    private var gate: SKSpriteNode!
    private var gateBackground: SKSpriteNode!
    
    private var tapPointerEngine: TapPointerEngine!
    private var chatEngine: ChatEngine!
    private var hero: Player!
    private var elder0: Player!
    private var elder1: Player!
    private var elder2: Player!
    private var cursedPrincess: Player!
    private var magmoor: Player!
    private var magmoorUnleashed: Player!
    
    
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
    
    func cleanupScene() {
        tapPointerEngine = nil
        chatEngine = nil
    }
    
    private func setupScene() {
        func setupPlayer(player: inout Player!, type: Player.PlayerType, zPosition: CGFloat) {
            player = Player(type: type)
            player.sprite.position = centerPoint
            player.sprite.alpha = 0
            player.sprite.zPosition = zPosition
        }
        
        backgroundColor = .black
        
        fadeNode = SKShapeNode(rectOf: size)
        fadeNode.position = centerPoint
        fadeNode.fillColor = .black
        fadeNode.lineWidth = 0
        fadeNode.zPosition = 100
        
        gate = SKSpriteNode(texture: SKTexture(imageNamed: "endOpenMagic"))
        gate.setScale(2)
        gate.zPosition = 2
        
        gateBackground = SKSpriteNode(color: .white, size: gate.size + CGSize(width: 16, height: 16))
        gateBackground.position = centerPoint
        gateBackground.zPosition = 8
        
        tapPointerEngine = TapPointerEngine(using: ChosenSword(type: FIRManager.chosenSword))
        
        chatEngine = ChatEngine()
        chatEngine.delegatePreBattle = self
        
        setupPlayer(player: &hero, type: .hero, zPosition: 20)
        setupPlayer(player: &elder0, type: .elder0, zPosition: 16)
        setupPlayer(player: &elder1, type: .elder1, zPosition: 22)
        setupPlayer(player: &elder2, type: .elder2, zPosition: 18)
        setupPlayer(player: &cursedPrincess, type: .cursedPrincess, zPosition: 25)
        setupPlayer(player: &magmoor, type: .villain, zPosition: 27)
        setupPlayer(player: &magmoorUnleashed, type: .villain2, zPosition: 29)
    }
    
    
    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        chatEngine.moveSprites(to: self)
        
        addChild(fadeNode)
        addChild(hero.sprite)
        addChild(elder0.sprite)
        addChild(elder1.sprite)
        addChild(elder2.sprite)
        addChild(cursedPrincess.sprite)
        addChild(magmoor.sprite)
        addChild(magmoorUnleashed.sprite)
        addChild(gateBackground)
        gateBackground.addChild(gate)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
        chatEngine.touchDown(in: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        chatEngine.didTapButton(in: location)
        chatEngine.touchUp()
    }
    
    
    // MARK: - Functions
    
    func animateScene() {
        fadeNode.run(SKAction.fadeOut(withDuration: 4.5)) { [weak self] in
            self?.playScene1()
        }
        
        gate.run(SKAction.repeatForever(SKAction.colorizeWithRainbowColorSequence(blendFactor: 1, duration: 0.5)))
    }
    
    private func playScene1() {
        let runDuration: TimeInterval = 0.5
        
        func enterGate(player: Player, offset: CGPoint) {
            let keyRunningAction = "runningAction"
            let spriteScale: CGFloat = player.sprite.xScale
            
            player.sprite.run(Player.animate(player: player, type: .run), withKey: keyRunningAction)
            player.sprite.run(SKAction.sequence([
                SKAction.scaleX(to: (offset.x < 0 ? -1 : 1) * spriteScale / 4, duration: 0),
                SKAction.scaleY(to: spriteScale / 4, duration: 0),
                SKAction.group([
                    SKAction.fadeIn(withDuration: runDuration / 2),
                    SKAction.move(to: centerPoint + offset, duration: runDuration),
                    SKAction.scaleX(to: (offset.x < 0 ? -1 : 1) * spriteScale, duration: runDuration),
                    SKAction.scaleY(to: player.sprite.yScale, duration: runDuration)
                ]),
                SKAction.scaleX(to: spriteScale, duration: 0)
            ])) {
                player.sprite.removeAction(forKey: keyRunningAction)
                player.sprite.run(Player.animate(player: player, type: .idle))
            }
        }
        
        enterGate(player: hero, offset: offsetPlayers[0])
        enterGate(player: elder0, offset: offsetPlayers[1])
        enterGate(player: elder1, offset: offsetPlayers[2])
        enterGate(player: elder2, offset: offsetPlayers[3])
        
        cursedPrincess.sprite.run(Player.animate(player: cursedPrincess, type: .idle))
        magmoor.sprite.run(Player.animate(player: magmoor, type: .idle))
        
        gate.run(SKAction.sequence([
            SKAction.wait(forDuration: runDuration),
            SKAction.setTexture(SKTexture(imageNamed: "endClosedMagic")),
            SKAction.run {
                AudioManager.shared.playSound(for: "dooropen")
            }
        ])) { [weak self] in
            self?.chatEngine.playDialogue(level: -2000, completion: nil)
        }
        
        AudioManager.shared.playSoundThenStop(for: "movetile\(Int.random(in: 1...3))", playForDuration: runDuration, fadeOut: runDuration)
    }
    
    private func playScene2() {
        let offsetToMatchMagmoorsEyes = CGPoint(x: -15, y: -35)
        
        func transitionAction(off: Bool) -> SKAction {
            return SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.fadeAlpha(to: off ? 0 : 1, duration: 3)
            ])
        }

        hero.sprite.run(SKAction.fadeOut(withDuration: 0))
        elder0.sprite.run(SKAction.fadeOut(withDuration: 0))
        elder1.sprite.run(SKAction.fadeOut(withDuration: 0))
        elder2.sprite.run(SKAction.fadeOut(withDuration: 0))
        
        magmoor.sprite.position.x = risePoint.x
        magmoor.sprite.xScale = -magmoor.scaleMultiplier
        magmoor.sprite.yScale = magmoor.scaleMultiplier
        magmoor.sprite.alpha = 1
        
        magmoorUnleashed.sprite.position = risePoint + offsetToMatchMagmoorsEyes
        magmoorUnleashed.sprite.xScale = -magmoorUnleashed.scaleMultiplier
        magmoorUnleashed.sprite.yScale = magmoorUnleashed.scaleMultiplier
        
        magmoor.sprite.run(Player.animateIdleLevitate(player: magmoor, randomizeDuration: false))
        magmoor.sprite.run(transitionAction(off: true))
        
        magmoorUnleashed.sprite.run(Player.animateIdleLevitate(player: magmoorUnleashed, randomizeDuration: false))
        magmoorUnleashed.sprite.run(transitionAction(off: false))
        
        AudioManager.shared.playSound(for: "bossbattle0")
    }
    
    
}


// MARK: - ChatEngine PreBattle

extension PreBattleCutscene: ChatEnginePreBattleDelegate {
    func zoomWideShot(zoomDuration: TimeInterval) {
        let scaleSize: CGFloat = 0.375
        let lrMargin: CGFloat = 200
        let leftEndPoint = CGPoint(x: lrMargin, y: centerPoint.y)
        let rightEndPoint = CGPoint(x: size.width - lrMargin, y: centerPoint.y)
        
        func moveLeft(player: Player, offset: CGPoint) {
            player.sprite.run(SKAction.group([
                SKAction.move(to: leftEndPoint + 2 * scaleSize * offset, duration: zoomDuration),
                SKAction.scale(to: scaleSize * player.scaleMultiplier, duration: zoomDuration)
            ]))
        }
        
        gateBackground.run(SKAction.sequence([
            SKAction.group([
                SKAction.move(to: leftEndPoint, duration: zoomDuration),
                SKAction.scale(to: 2 * scaleSize, duration: zoomDuration)
            ]),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        moveLeft(player: hero, offset: offsetPlayers[0])
        moveLeft(player: elder0, offset: offsetPlayers[1])
        moveLeft(player: elder1, offset: offsetPlayers[2])
        moveLeft(player: elder2, offset: offsetPlayers[3])
        
        magmoor.sprite.position = rightEndPoint
        magmoor.sprite.xScale = -scaleSize * magmoor.scaleMultiplier
        magmoor.sprite.yScale = scaleSize * magmoor.scaleMultiplier
        
        cursedPrincess.sprite.run(SKAction.sequence([
            SKAction.moveTo(x: size.width + cursedPrincess.sprite.size.width / 2, duration: 0),
            SKAction.fadeIn(withDuration: 0),
            SKAction.scaleX(to: -cursedPrincess.sprite.xScale, duration: 0),
            SKAction.group([
                SKAction.move(to: rightEndPoint, duration: zoomDuration),
                SKAction.scaleX(to: -scaleSize * cursedPrincess.scaleMultiplier, duration: zoomDuration),
                SKAction.scaleY(to: scaleSize * cursedPrincess.scaleMultiplier, duration: zoomDuration)
            ])
        ]))
    }
    
    func zoomInPrincess() {
        func moveOffScreen(player: Player) {
            player.sprite.run(SKAction.moveTo(x: -player.sprite.size.width / 2, duration: 0))
        }
        
        moveOffScreen(player: hero)
        moveOffScreen(player: elder0)
        moveOffScreen(player: elder1)
        moveOffScreen(player: elder2)
        
        gateBackground.run(SKAction.moveTo(x: -gateBackground.size.width / 2, duration: 0))
        
        cursedPrincess.sprite.run(SKAction.group([
            SKAction.move(to: centerPoint, duration: 0),
            SKAction.scaleX(to: -cursedPrincess.scaleMultiplier, duration: 0),
            SKAction.scaleY(to: cursedPrincess.scaleMultiplier, duration: 0)
        ]))
    }
    
    func zoomInElders() {
        let offsetMultiplier: CGFloat = 1.25
        
        func moveCenter(player: Player, offset: CGPoint) {
            player.sprite.run(SKAction.group([
                SKAction.move(to: centerPoint + offset, duration: 0),
                SKAction.scale(to: player.scale * player.scaleMultiplier, duration: 0)
            ]))
        }
        
        moveCenter(player: hero, offset: offsetPlayers[0] * offsetMultiplier)
        moveCenter(player: elder0, offset: offsetPlayers[1] * offsetMultiplier)
        moveCenter(player: elder1, offset: offsetPlayers[2] * offsetMultiplier)
        moveCenter(player: elder2, offset: offsetPlayers[3] * offsetMultiplier)
        
        gateBackground.run(SKAction.group([
            SKAction.move(to: centerPoint, duration: 0),
            SKAction.scale(to: 1, duration: 0)
        ]))
        
        cursedPrincess.sprite.run(SKAction.moveTo(x: size.width + cursedPrincess.sprite.size.width / 2, duration: 0))
    }
    
    func revealMagmoor() {
        let riseDuration: TimeInterval = 6
        
        func flickerSprite(off: Bool) -> SKAction {
            let fadeDuration: TimeInterval = 0.1
            
            return SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.fadeAlpha(to: off ? 0 : 1, duration: fadeDuration),
                SKAction.wait(forDuration: 0.25),
                SKAction.repeat(SKAction.sequence([
                    SKAction.fadeAlpha(to: off ? 1 : 0, duration: fadeDuration),
                    SKAction.wait(forDuration: 0.1),
                    SKAction.fadeAlpha(to: off ? 0 : 1, duration: fadeDuration),
                    SKAction.wait(forDuration: 0.1),
                ]), count: 1),
                SKAction.repeat(SKAction.sequence([
                    SKAction.fadeAlpha(to: off ? 1 : 0, duration: fadeDuration),
                    SKAction.wait(forDuration: 0),
                    SKAction.fadeAlpha(to: off ? 0 : 1, duration: fadeDuration),
                    SKAction.wait(forDuration: 0)
                ]), count: 11)
            ])
        }
                
        magmoor.sprite.run(SKAction.moveTo(y: risePoint.y, duration: riseDuration))
        magmoor.sprite.run(SKAction.sequence([
            flickerSprite(off: false),
            SKAction.fadeOut(withDuration: 0)
        ])) { [weak self] in
            self?.playScene2()
        }
        
        cursedPrincess.sprite.run(SKAction.moveTo(y: risePoint.y, duration: riseDuration))
        cursedPrincess.sprite.run(flickerSprite(off: true))
        
        AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 3, fadeOut: 1)
        AudioManager.shared.playSound(for: "scarylaugh", currentTime: 0.8, fadeIn: 1, delay: 2.5)
        AudioManager.shared.playSound(for: "magicwarp2", delay: 2)
    }
    
    
}
