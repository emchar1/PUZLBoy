//
//  PreBattleCutscene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/3/25.
//

import SpriteKit

protocol PreBattleCutsceneDelegate: AnyObject {
    func preBattleCutsceneDidFinish(_ cutscene: PreBattleCutscene)
}

class PreBattleCutscene: SKScene {
    
    // MARK: - Properties
    
    //offset positions of hero and elders with respect to gate position
    private let offsetPlayers: [CGPoint] = [
        CGPoint(x: 200, y: -50),    //hero
        CGPoint(x: 25, y: 50),      //elder0
        CGPoint(x: -50, y: -150),   //elder1
        CGPoint(x: -150, y: 40)     //elder2
    ]
    
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
    private var marlin: Player!
    private var princess: Player!
    
    weak var preBattleDelegate: PreBattleCutsceneDelegate?
    
    
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
        removeAllActions()
        removeAllChildren()
        removeFromParent()
        
        tapPointerEngine = nil
        chatEngine = nil
        
        AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 0)
        AudioManager.shared.stopSound(for: "bossbattle0", fadeDuration: 0)
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
        setupPlayer(player: &marlin, type: .trainer, zPosition: 12)
        setupPlayer(player: &princess, type: .princess, zPosition: 14)
    }
    
    
    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        chatEngine.moveSprites(to: self)
        
        addChild(hero.sprite)
        addChild(elder0.sprite)
        addChild(elder1.sprite)
        addChild(elder2.sprite)
        addChild(cursedPrincess.sprite)
        addChild(magmoor.sprite)
        addChild(magmoorUnleashed.sprite)
        addChild(marlin.sprite)
        addChild(princess.sprite)
        
        addChild(fadeNode)
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
    
    
    // MARK: - Scene Functions
    
    /**
     Begins the scene's animation entry point.
     */
    func animateScene() {
        fadeNode.run(.fadeOut(withDuration: 4.5)) { [weak self] in
            self?.playScene1()
        }
        
        gate.run(.repeatForever(.colorizeWithRainbowColorSequence(blendFactor: 1, duration: 0.5)))
    }
    
    /**
     Initial scene. Setup the players positioning and animate their idle stances.
     */
    private func playScene1() {
        let runDuration: TimeInterval = 0.5
        
        func enterGate(player: Player, offset: CGPoint) {
            let keyRunningAction = "runningAction"
            let spriteScale: CGFloat = player.sprite.xScale
            
            player.sprite.run(Player.animate(player: player, type: .run), withKey: keyRunningAction)
            player.sprite.run(.sequence([
                .scaleX(to: (offset.x < 0 ? -1 : 1) * spriteScale / 4, duration: 0),
                .scaleY(to: spriteScale / 4, duration: 0),
                .group([
                    .fadeIn(withDuration: runDuration / 2),
                    .move(to: centerPoint + offset, duration: runDuration),
                    .scaleX(to: (offset.x < 0 ? -1 : 1) * spriteScale, duration: runDuration),
                    .scaleY(to: player.sprite.yScale, duration: runDuration)
                ]),
                .scaleX(to: spriteScale, duration: 0)
            ])) {
                player.sprite.removeAction(forKey: keyRunningAction)
                player.sprite.run(Player.animate(player: player, type: .idle))
            }
        }
        
        enterGate(player: hero, offset: offsetPlayers[0])
        enterGate(player: elder0, offset: offsetPlayers[1])
        enterGate(player: elder1, offset: offsetPlayers[2])
        enterGate(player: elder2, offset: offsetPlayers[3])
        
        cursedPrincess.sprite.position.x = size.width + cursedPrincess.sprite.size.width / 2
        cursedPrincess.sprite.xScale *= -1
        cursedPrincess.sprite.alpha = 1
        cursedPrincess.sprite.run(Player.animate(player: cursedPrincess, type: .idle))
        
        magmoor.sprite.run(Player.animate(player: magmoor, type: .idle))
        
        gate.run(.sequence([
            .wait(forDuration: runDuration),
            .setTexture(SKTexture(imageNamed: "endClosedMagic")),
            .run {
                AudioManager.shared.playSound(for: "dooropen")
            }
        ])) { [weak self] in
            self?.chatEngine.playDialogue(level: -2000, completion: nil)
        }
        
        AudioManager.shared.playSoundThenStop(for: "movetile\(Int.random(in: 1...3))", playForDuration: runDuration, fadeOut: runDuration)
    }
    
    private func revealMagmoorUnleashed() {
        let offsetToMatchMagmoorsEyes = CGPoint(x: -15, y: -35)
        
        hero.sprite.run(.fadeOut(withDuration: 0))
        elder0.sprite.run(.fadeOut(withDuration: 0))
        elder1.sprite.run(.fadeOut(withDuration: 0))
        elder2.sprite.run(.fadeOut(withDuration: 0))
        
        magmoor.sprite.position = risePoint
        magmoor.sprite.xScale = -magmoor.scaleMultiplier
        magmoor.sprite.yScale = magmoor.scaleMultiplier
        magmoor.sprite.alpha = 1
        
        magmoorUnleashed.sprite.position = risePoint + offsetToMatchMagmoorsEyes
        magmoorUnleashed.sprite.xScale = -magmoorUnleashed.scaleMultiplier
        magmoorUnleashed.sprite.yScale = magmoorUnleashed.scaleMultiplier
        
        magmoor.sprite.run(Player.animateIdleLevitate(player: magmoor, randomizeDuration: false))
        magmoorUnleashed.sprite.run(Player.animateIdleLevitate(player: magmoorUnleashed, randomizeDuration: false))
        
        cursedPrincess.sprite.removeFromParent()
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Transitions from one Player to another.
     - parameters:
        - firstPlayer: the original Player to transition from
        - secondPlayer: the new Player to transition to
        - duration: length of the transition
        - delay: adds a delay
        - completion: optional completion handler
     */
    private func transformPlayer(from firstPlayer: Player,
                                 to secondPlayer: Player,
                                 duration: TimeInterval,
                                 delay: TimeInterval = 0,
                                 completion: (() -> Void)?) {
        
        func fadeInAction(reverse: Bool) -> SKAction {
            func fadeInHelper(reverse: Bool, flickerSpeed: CGFloat, factor: CGFloat) -> SKAction {
                let flickerAdjusted: CGFloat = min(factor * flickerSpeed, 1)
                let flickerDuration: TimeInterval = TimeInterval(flickerSpeed)
                
                accumulatedActionDuration += flickerDuration
                
                return .fadeAlpha(to: reverse ? 1 - flickerAdjusted : flickerAdjusted, duration: flickerDuration)
            }
            
            //Customize these two properties for varying visual effects!
            let flickerSpeed: CGFloat = 0.05
            let flickerStagger: Int = 5
            
            let steps: Int = Int(0.5 * (duration - delay) / flickerSpeed)
            var accumulatedActionDuration: TimeInterval = delay
            var actions: [SKAction] = [.wait(forDuration: delay)]
            
            for step in flickerStagger..<(steps + flickerStagger) {
                actions.append(fadeInHelper(reverse: reverse, flickerSpeed: flickerSpeed, factor: CGFloat(step)))
                actions.append(fadeInHelper(reverse: reverse, flickerSpeed: flickerSpeed, factor: CGFloat(step - flickerStagger)))
            }
            
            actions.append(.wait(forDuration: max(0, duration - accumulatedActionDuration)))
            
            return .sequence(actions)
        }
        
        firstPlayer.sprite.run(fadeInAction(reverse: true))
        secondPlayer.sprite.run(fadeInAction(reverse: false)) {
            completion?()
        }
        
    }
    
    /**
     Updates Player to the new position, scaling, and alpha values.
     - parameters:
        - player: the Player to affect
        - position: updated position to move to
        - scale: updated scale value to set to; if negative, flip the sprite horizontally
        - alpha: updated alpha value to set to
        - duration: animation duration of the updates using SKAction
     */
    private func updatePlayer(_ player: Player, position: CGPoint? = nil, scale: CGFloat? = nil, alpha: CGFloat? = nil, duration: TimeInterval = 0) {
        player.sprite.run(.group([
            position == nil ? .wait(forDuration: duration) : .move(to: position!, duration: duration),
            scale == nil ? .wait(forDuration: duration) : .scaleX(to: scale! * player.scaleMultiplier, duration: duration),
            scale == nil ? .wait(forDuration: duration) : .scaleY(to: abs(scale!) * player.scaleMultiplier, duration: duration),
            alpha == nil ? .wait(forDuration: duration) : .fadeAlpha(to: alpha!, duration: duration)
        ]))
    }
}


// MARK: - ChatEngine PreBattle

extension PreBattleCutscene: ChatEnginePreBattleDelegate {
    func zoomWideShot(duration: TimeInterval) {
        let position: (left: CGPoint, right: CGPoint) = (CGPoint(x: 200, y: centerPoint.y), CGPoint(x: size.width - 200, y: centerPoint.y))
        let offsetMultiplier: CGFloat = 0.75
        let scale: CGFloat = 0.375
        
        updatePlayer(hero, position: position.left + offsetMultiplier * offsetPlayers[0], scale: scale, alpha: 1, duration: duration)
        updatePlayer(elder0, position: position.left + offsetMultiplier * offsetPlayers[1], scale: scale, alpha: 1, duration: duration)
        updatePlayer(elder1, position: position.left + offsetMultiplier * offsetPlayers[2], scale: scale, alpha: 1, duration: duration)
        updatePlayer(elder2, position: position.left + offsetMultiplier * offsetPlayers[3], scale: scale, alpha: 1, duration: duration)
        updatePlayer(cursedPrincess, position: position.right, scale: -scale, alpha: 1, duration: duration)
        updatePlayer(magmoor, position: position.right, scale: -scale, alpha: 0, duration: 0)
        
        gateBackground.run(.sequence([
            .group([
                .move(to: position.left, duration: duration),
                .scale(to: 2 * scale, duration: duration)
            ]),
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ]))
    }
    
    func zoomInPrincess() {
        updatePlayer(hero, alpha: 0)
        updatePlayer(elder0, alpha: 0)
        updatePlayer(elder1, alpha: 0)
        updatePlayer(elder2, alpha: 0)
        updatePlayer(cursedPrincess, position: centerPoint, scale: -1, alpha: 1)
        updatePlayer(magmoor, alpha: 0)
    }
    
    func zoomInElders() {
        let offsetMultiplier: CGFloat = 1.25
        
        updatePlayer(hero, position: centerPoint + offsetMultiplier * offsetPlayers[0], scale: hero.scale, alpha: 1)
        updatePlayer(elder0, position: centerPoint + offsetMultiplier * offsetPlayers[1], scale: elder0.scale, alpha: 1)
        updatePlayer(elder1, position: centerPoint + offsetMultiplier * offsetPlayers[2], scale: elder1.scale, alpha: 1)
        updatePlayer(elder2, position: centerPoint + offsetMultiplier * offsetPlayers[3], scale: elder2.scale, alpha: 1)
        updatePlayer(cursedPrincess, alpha: 0)
        updatePlayer(magmoor, alpha: 0)
        updatePlayer(marlin, position: risePoint + CGPoint(x: -300, y: 0), duration: 0)
        updatePlayer(princess, position: CGPoint(x: princess.sprite.position.x, y: risePoint.y), duration: 0)
    }
    
    func zoomInMagmoor() {
        updatePlayer(hero, alpha: 0)
        updatePlayer(elder0, alpha: 0)
        updatePlayer(elder1, alpha: 0)
        updatePlayer(elder2, alpha: 0)
        updatePlayer(cursedPrincess, alpha: 0)
        updatePlayer(magmoor, position: risePoint, scale: -1, alpha: 1)
        updatePlayer(marlin, position: centerPoint + CGPoint(x: -300, y: 0), duration: 0)
        updatePlayer(princess, position: CGPoint(x: princess.sprite.position.x, y: centerPoint.y), duration: 0)
    }
    
    func zoomWideGameboard() {
        let position: (left: CGPoint, right: CGPoint) = (CGPoint(x: 200, y: centerPoint.y), CGPoint(x: size.width - 200, y: risePoint.y))
        let offsetMultiplier: CGFloat = 0.5
        let scale: CGFloat = Player.getGameboardScale(panelSize: size.width / 7) * UIDevice.spriteScale
        
        updatePlayer(hero, position: position.left + offsetMultiplier * offsetPlayers[0], scale: scale, alpha: 1)
        updatePlayer(elder0, position: position.left + offsetMultiplier * offsetPlayers[1], scale: scale, alpha: 1)
        updatePlayer(elder1, position: position.left + offsetMultiplier * offsetPlayers[2], scale: scale, alpha: 1)
        updatePlayer(elder2, position: position.left + offsetMultiplier * offsetPlayers[3], scale: scale, alpha: 1)
        updatePlayer(cursedPrincess, alpha: 0)
        updatePlayer(magmoor, position: position.right, scale: -scale, alpha: 1)
        updatePlayer(magmoorUnleashed, position: position.right, scale: -scale, alpha: 0)
        updatePlayer(marlin, position: CGPoint(x: centerPoint.x - 300, y: centerPoint.y + (risePoint.y - centerPoint.y) / 2), duration: 0)
        updatePlayer(princess, position: CGPoint(x: princess.sprite.position.x, y: centerPoint.y + (risePoint.y - centerPoint.y) / 2), duration: 0)
        
        marlin.sprite.run(.fadeOut(withDuration: 2))
        princess.sprite.run(.fadeOut(withDuration: 2))
        
        transformPlayer(from: magmoor, to: magmoorUnleashed, duration: 16) { [weak self] in
            guard let self = self else { return }
            
            preBattleDelegate?.preBattleCutsceneDidFinish(self)
            
            //Put this last!! This deinitializes EVERYTHING.
            cleanupScene()
        }
        
        AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 2)
        AudioManager.shared.playSound(for: "bossbattle0")
    }
    
    func revealMagmoor() {
        let riseDuration: TimeInterval = 6
        let transformDelay: TimeInterval = 2.5
        
        magmoor.sprite.run(.moveTo(y: risePoint.y, duration: riseDuration))
        cursedPrincess.sprite.run(.moveTo(y: risePoint.y, duration: riseDuration))
        
        transformPlayer(from: cursedPrincess, to: magmoor, duration: riseDuration, delay: transformDelay) { [weak self] in
            self?.revealMagmoorUnleashed()
        }
        
        AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 3, fadeOut: 1)
        AudioManager.shared.playSound(for: "scarylaugh", currentTime: 0.8, fadeIn: 1, delay: transformDelay)
        AudioManager.shared.playSound(for: "magicwarp2", delay: transformDelay)
        AudioManager.shared.playSound(for: "scarymusicbox", delay: riseDuration)
    }
    
    func peekFriends(showMarlin: Bool, showPrincess: Bool) {
        if showMarlin {
            updatePlayer(marlin, position: centerPoint + CGPoint(x: -300, y: 0), scale: marlin.scale, duration: 0)
            
            marlin.sprite.run(.fadeAlpha(to: 0.5, duration: 2))
            marlin.sprite.run(Player.animate(player: marlin, type: .dead))
            
            ParticleEngine.shared.animateParticles(type: .magicMerge,
                                                   toNode: marlin.sprite,
                                                   position: CGPoint(x: 0, y: -marlin.sprite.size.height / 4),
                                                   scale: 3 * UIDevice.spriteScale,
                                                   alpha: 0.5,
                                                   zPosition: -5,
                                                   duration: 0)
        }
        
        if showPrincess {
            updatePlayer(princess, position: centerPoint + CGPoint(x: 200, y: 0), scale: -princess.scale, duration: 0)
            
            princess.sprite.run(.fadeAlpha(to: 0.5, duration: 2))
            princess.sprite.run(Player.animate(player: princess, type: .idle))
            princess.sprite.run(.sequence([
                .wait(forDuration: 2),
                .group([
                    Player.animate(player: princess, type: .walk, timePerFrameMultiplier: 0.25, repeatCount: 1),
                    .moveBy(x: -100, y: 0, duration: 0.3)
                ]),
                .repeatForever(.sequence([
                    .wait(forDuration: 2),
                    .group([
                        Player.animate(player: princess, type: .walk, timePerFrameMultiplier: 0.25, repeatCount: 2),
                        .moveBy(x: 200, y: 0, duration: 0.6),
                        .scaleX(to: abs(princess.sprite.xScale), duration: 0)
                    ]),
                    .wait(forDuration: 2),
                    .group([
                        Player.animate(player: princess, type: .walk, timePerFrameMultiplier: 0.25, repeatCount: 2),
                        .moveBy(x: -200, y: 0, duration: 0.6),
                        .scaleX(to: -abs(princess.sprite.xScale), duration: 0)
                    ])
                ])),
                .wait(forDuration: 2)
            ]))
        }
    }
    
    
}
