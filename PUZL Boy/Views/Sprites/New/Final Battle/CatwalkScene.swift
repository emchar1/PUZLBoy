//
//  CatwalkScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/8/24.
//

import SpriteKit

class CatwalkScene: SKScene {
    
    // MARK: - Properties
    
    private let catwalkOverworld = "magicdoomloop"
    private let panelCount: Int = 5
    private let catwalkLength: Int = 40
    private let panelSpacing: CGFloat = 4
    private var panelSize: CGFloat { size.width / CGFloat(panelCount) }
    private var scaleSize: CGSize { CGSize.zero + panelSize - panelSpacing }
    private var fadeAlphaMultiplier: CGFloat { 1 - CGFloat(currentPanelIndex) / CGFloat(catwalkLength) * 3/4 }
    
    private let catwalkPanelNameDelimiter: Character = "_"
    private var catwalkPanelNamePrefix: String { "catwalkPanel\(catwalkPanelNameDelimiter)" }
    private var currentPanelIndex: Int = 0
    private var leftmostPanelIndex: Int = 0
    private var isMoving: Bool = false
    private var shouldDisableInput: Bool = true
    private var isRedShift: Bool = false
    
    private var hero: Player!
    private var elder0: Player!
    private var elder1: Player!
    private var elder2: Player!
    private var princess: Player!
    private var trainer: Player!
    private var villain: Player!
    private var magmoorSprite: SKSpriteNode!
    private var backgroundNode: SKSpriteNode!
    private var inbetweenNode: SKSpriteNode!
    private var bloodOverlay: SKSpriteNode!
    private var fadeNode: SKShapeNode!
    private var catwalkNode: SKShapeNode!
    private var catwalkPanels: [SKSpriteNode] = []
    
    private var chatEngine: ChatEngine!
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CatwalkScene deinit")
    }
    
    func cleanupScene() {
        currentPanelIndex = 0
        isMoving = false
        shouldDisableInput = true
        isRedShift = false
        
        removeAllActions()
        removeAllChildren()
        removeFromParent()
        
        chatEngine = nil
    }
    
    private func setupNodes() {
        backgroundColor = .black
        
        backgroundNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        backgroundNode.size = size
        backgroundNode.anchorPoint = .zero
        
        inbetweenNode = SKSpriteNode(texture: SKTexture(image: UIImage.gradientTextureSkyBlood))
        inbetweenNode.size = size
        inbetweenNode.alpha = 0.81
        inbetweenNode.anchorPoint = .zero
        inbetweenNode.zPosition = 5
        
        bloodOverlay = SKSpriteNode(color: .red, size: size)
        bloodOverlay.anchorPoint = .zero
        bloodOverlay.alpha = 0.26
        bloodOverlay.zPosition = K.ZPosition.fadeTransitionNode - 5
        
        ParticleEngine.shared.animateParticles(type: .inbetween,
                                               toNode: inbetweenNode,
                                               position: .zero,
                                               alpha: 0.76,
                                               zPosition: K.ZPosition.fadeTransitionNode - 15,
                                               duration: 0)
        
        fadeNode = SKShapeNode(rectOf: size)
        fadeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        fadeNode.fillColor = .black
        fadeNode.lineWidth = 0
        fadeNode.zPosition = K.ZPosition.fadeTransitionNode
        
        catwalkNode = SKShapeNode(rectOf: CGSize(width: CGFloat(catwalkLength + 1) * panelSize + panelSpacing,
                                                 height: panelSize + 2 * panelSpacing))
        catwalkNode.position = CGPoint(x: catwalkNode.frame.size.width / 2, y: size.height / 2)
        catwalkNode.zRotation = -CGFloat(0.666).toRadians()
        catwalkNode.fillColor = GameboardSprite.gameboardColor
        catwalkNode.lineWidth = 0
        catwalkNode.zPosition = 5
        
        hero = Player(type: .hero)
        hero.sprite.position = CGPoint(x: -catwalkNode.frame.size.width / 2 + scaleSize.width / 2, y: 0)
        hero.sprite.setScale(Player.getGameboardScale(panelSize: panelSize))
        hero.sprite.zPosition = K.ZPosition.player
        hero.sprite.run(animatePlayer(player: hero, type: .idle))
        
        elder0 = Player(type: .elder0)
        elder0.sprite.alpha = 0
        elder0.sprite.zPosition = K.ZPosition.player - 1
        
        elder1 = Player(type: .elder1)
        elder1.sprite.alpha = 0
        elder1.sprite.zPosition = K.ZPosition.player + 1
        
        elder2 = Player(type: .elder2)
        elder2.sprite.alpha = 0
        elder2.sprite.zPosition = K.ZPosition.player + 2
        
        princess = Player(type: .princess)
        princess.sprite.alpha = 0
        
        trainer = Player(type: .trainer)
        trainer.sprite.alpha = 0
        
        villain = Player(type: .villain)
        villain.sprite.alpha = 0
        
        magmoorSprite = SKSpriteNode(imageNamed: "villainRedEyes")
        magmoorSprite.size = CGSize(width: size.width, height: size.width)
        magmoorSprite.position = CGPoint(x: size.width / 2, y: size.height * 3/5)
        magmoorSprite.alpha = 0
        magmoorSprite.zPosition = 2
        
        for i in 0...catwalkLength {
            let image: String = i == 0 ? "start" : (i == catwalkLength ? "endClosed" : "partytile")
            
            let catwalkPanel = SKSpriteNode(texture: SKTexture(imageNamed: image))
            catwalkPanel.scale(to: scaleSize)
            catwalkPanel.position = CGPoint(
                x: -catwalkNode.frame.size.width / 2 + catwalkPanel.size.width * CGFloat(i) + panelSpacing * CGFloat(i + 1),
                y: -catwalkPanel.size.height / 2)
            catwalkPanel.anchorPoint = .zero
            catwalkPanel.zPosition = K.ZPosition.terrain
            catwalkPanel.name = catwalkPanelNamePrefix + "\(i)"
            
            catwalkPanels.append(catwalkPanel)
        }
        
        shimmerPartyTiles()
        chatEngine = ChatEngine()
        chatEngine.delegate = self
    }
    
    
    // MARK: - Main Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(backgroundNode)
        addChild(inbetweenNode)
        addChild(bloodOverlay)
        addChild(fadeNode)
        addChild(magmoorSprite)
        addChild(catwalkNode)
        catwalkNode.addChild(hero.sprite)
        catwalkNode.addChild(elder0.sprite)
        catwalkNode.addChild(elder1.sprite)
        catwalkNode.addChild(elder2.sprite)
        catwalkNode.addChild(princess.sprite)
        catwalkNode.addChild(trainer.sprite)
        catwalkNode.addChild(villain.sprite)
        
        for catwalkPanel in catwalkPanels {
            catwalkNode.addChild(catwalkPanel)
        }
        
        chatEngine.moveSprites(to: self)
        
        fadeNode.run(SKAction.fadeOut(withDuration: 4.5)) { [weak self] in
            guard let self = self else { return }
            
            playDialogue(panelIndex: currentPanelIndex)
        }
        
        AudioManager.shared.playSound(for: catwalkOverworld, fadeIn: 4.5)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        chatEngine.touchDown(in: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        chatEngine.didTapButton(in: location)
        chatEngine.touchUp()

        nodes(at: location).forEach { node in
            guard let name = node.name else { return }
                        
            moveHero(to: name)
        }
    }
    
    
    // MARK: - Helper Functions
    
    private func moveHero(to panelName: String) {
        guard !isMoving else { return }
        guard !shouldDisableInput else { return }
        guard let panelIndex = getPanelIndex(for: panelName), currentPanelIndex != panelIndex else { return }
        guard panelIndex > currentPanelIndex else {
            isMoving = true
            
            hero.sprite.xScale *= -1
            hero.sprite.run(SKAction.sequence([
                SKAction.moveBy(x: -10, y: 0, duration: 0),
                SKAction.wait(forDuration: 0.25),
                SKAction.moveBy(x: 10, y: 0, duration: 0)
            ])) { [weak self] in
                self?.isMoving = false
                self?.playDialogue(panelIndex: -1)
            }
            
            Haptics.shared.executeCustomPattern(pattern: .boulder)
            AudioManager.shared.playSound(for: "boygrunt\(Int.random(in: 1...2))")
            
            return
        }
        
        let moveDuration: TimeInterval = isRedShift ? 2 : 1
        let moveDistance: CGFloat = scaleSize.width + panelSpacing
        let runSound = "movetile\(Int.random(in: 1...3))"
        
        currentPanelIndex += 1
        isMoving = true
        
        hero.sprite.run(animatePlayer(player: hero, type: .run))
        hero.sprite.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)) { [weak self] in
            guard let self = self else { return }
            
            hero.sprite.run(animatePlayer(player: hero, type: .idle))
            isMoving = false

            playDialogue(panelIndex: currentPanelIndex)
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
        }
        
        if leftmostPanelIndex < currentPanelIndex - 2 && currentPanelIndex < catwalkLength - 2 {
            shiftCatwalkNode(panels: 1, moveDuration: moveDuration)
        }
        
        //MUST put this at the end!
        if !isRedShift {
            updateBackgroundNode(fadeDuration: moveDuration, completion: nil)
            inbetweenNode.run(SKAction.fadeAlpha(to: 0.81 * fadeAlphaMultiplier, duration: moveDuration))
            bloodOverlay.run(SKAction.fadeAlpha(to: 0.26 * fadeAlphaMultiplier, duration: moveDuration))
            AudioManager.shared.playSound(for: runSound)
        }
    }
    
    private func getPanelIndex(for panelName: String) -> Int? {
        guard panelName.contains(catwalkPanelNameDelimiter) else { return nil }
        
        return Int(String(panelName.suffix(from: panelName.firstIndex(of: catwalkPanelNameDelimiter)!).dropFirst()))
    }
    
    private func animatePlayer(player: Player, type: Player.Texture) -> SKAction {
        var timePerFrame: TimeInterval
        
        switch type {
        case .idle:
            switch player.type {
            case .elder0:   timePerFrame = 0.1
            case .elder1:   timePerFrame = 0.09
            case .elder2:   timePerFrame = 0.05
            case .princess: timePerFrame = 0.09
            case .villain:  timePerFrame = 0.12
            default:        timePerFrame = 0.06
            }
        case .run:
            timePerFrame = 0.04
        default:
            timePerFrame = 0.04
        }
        
        if player.type == .hero {
            timePerFrame *= isRedShift ? 2 : 1
        }
        
        return SKAction.repeatForever(SKAction.animate(with: player.textures[type.rawValue], timePerFrame: timePerFrame))
    }
    
    private func playDialogue(panelIndex: Int) {
        let dialogueNumber = -1000 - panelIndex
        
        shouldDisableInput = true
        
        chatEngine.playDialogue(level: dialogueNumber) { [weak self] _ in
            guard let self = self else { return }
            
            shouldDisableInput = false
            hero.sprite.xScale = abs(hero.sprite.xScale)
        }
    }
    
    private func updateBackgroundNode(fadeDuration: TimeInterval, completion: (() -> Void)?) {
        backgroundNode.run(SKAction.fadeAlpha(to: 1 - CGFloat(currentPanelIndex) / CGFloat(catwalkLength), duration: fadeDuration + 0.25)) {
            completion?()
        }
    }
    
    private func shimmerPartyTiles() {
        for (i, catwalkPanel) in catwalkPanels.enumerated() {
            guard i > 0 && i < catwalkLength else { continue }
            
            catwalkPanel.animatePartyTileShimmer(gameboardColor: GameboardSprite.gameboardColor)
        }
    }
    
    /**
     Moves the catwalkNode and keeps track of which panel is the leftmost panel (e.g. so you can keep PUZL Boy centered in the frame.)
     - parameters:
        - panels: number of panels to shift over
        - moveDuration: the speed at which the shifting animates
     */
    private func shiftCatwalkNode(panels: Int, moveDuration: TimeInterval) {
        let moveDistance: CGFloat = -1 * CGFloat(panels) * (scaleSize.width + panelSpacing)
        
        catwalkNode.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))

        leftmostPanelIndex += panels
    }
    
    
}


// MARK: - ChatEngineDelegate

extension CatwalkScene: ChatEngineDelegate {
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {}
    func deilluminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {}
    func illuminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName) {}
    func deilluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName) {}
    func illuminateMinorButton(for button: PauseResetEngine.MinorButton) {}
    func deilluminateMinorButton(for button: PauseResetEngine.MinorButton) {}
    func spawnTrainer(at position: K.GameboardPosition, to direction: Controls) {}
    func despawnTrainer(to position: K.GameboardPosition?) {}
    func spawnTrainerWithExit(at position: K.GameboardPosition, to direction: Controls) {}
    func despawnTrainerWithExit(moves: [K.GameboardPosition]) {}
    func spawnPrincessCapture(at position: K.GameboardPosition, shouldAnimateWarp: Bool, completion: @escaping () -> Void) {}
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void) {}
    func flashPrincess(at position: K.GameboardPosition, completion: @escaping () -> Void) {}
    func inbetweenRealmEnter(levelInt: Int, mergeHalfway: Bool, moves: [K.GameboardPosition]) {}
    func inbetweenRealmExit(persistPresence: Bool, completion: @escaping () -> Void) {}
    func inbetweenFlashPlayer(playerType: Player.PlayerType, position: K.GameboardPosition, persistPresence: Bool) {}
    func empowerPrincess(powerDisplayDuration: TimeInterval) {}
    func encagePrincess() {}
    func peekMinion(at position: K.GameboardPosition, duration: TimeInterval, completion: @escaping () -> Void) {}
    func spawnDaemon(at position: K.GameboardPosition) {}
    func spawnMagmoorMinion(at position: K.GameboardPosition, chatDelay: TimeInterval) {}
    func despawnMagmoorMinion(at position: K.GameboardPosition, fadeDuration: TimeInterval) {}
    func minionAttack(duration: TimeInterval, completion: @escaping () -> Void) {}
    func spawnElder(minionPosition: K.GameboardPosition, positions: [K.GameboardPosition], completion: @escaping () -> Void) {}
    func despawnElders(to position: K.GameboardPosition, completion: @escaping () -> Void) {}
    func getGift(lives: Int) {}
    
    
    // MARK: - Catwalk Protocol Functions
    
    func spawnEldersCatwalk(faceLeft: Bool) {
        hero.sprite.xScale = abs(hero.sprite.xScale)
        
        spawnElderHelper(elder: elder0, faceLeft: faceLeft, offset: faceLeft ? CGPoint(x: 200, y: 0) : CGPoint(x: 300, y: 0))
        spawnElderHelper(elder: elder1, faceLeft: faceLeft, offset: faceLeft ? CGPoint(x: 350, y: 100) : CGPoint(x: 200, y: 125))
        spawnElderHelper(elder: elder2, faceLeft: faceLeft, offset: faceLeft ? CGPoint(x: 350, y: -100) : CGPoint(x: 200, y: -125))
    }
    
    func despawnEldersCatwalk() {
        despawnElderHelper(elder: elder0)
        despawnElderHelper(elder: elder1)
        despawnElderHelper(elder: elder2)
    }
        
    func spawnPrincessCatwalk() {
        let originalScale: CGFloat = Player.getGameboardScale(panelSize: panelSize) * princess.scaleMultiplier
        let fadeDuration: TimeInterval = 2
        let alphaPersistence: CGFloat = 0.5
        let blinkAction = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0),
            SKAction.wait(forDuration: 0.04),
            SKAction.fadeAlpha(to: alphaPersistence, duration: 0)
        ])
        
        princess.sprite.position = getHeroPosition(xPanelOffset: 1, yOffset: -15)
        princess.sprite.setScale(originalScale)
        princess.sprite.xScale *= -1
        princess.sprite.alpha = 0
        
        princess.sprite.run(animatePlayer(player: princess, type: .idle))
        princess.sprite.run(SKAction.fadeAlpha(to: alphaPersistence, duration: fadeDuration))
        
        princess.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.repeat(SKAction.sequence([blinkAction, SKAction.wait(forDuration: 0.1)]), count: 3),
            SKAction.wait(forDuration: 0.5),
            SKAction.repeat(SKAction.sequence([blinkAction, SKAction.wait(forDuration: 0.06)]), count: 5),
            SKAction.wait(forDuration: 1),
            SKAction.repeat(SKAction.sequence([blinkAction, SKAction.wait(forDuration: 0.08)]), count: 2),
            SKAction.wait(forDuration: 0.8),
            blinkAction
        ])))
        
        princess.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.moveBy(x: -20, y: 10, duration: 0),
            SKAction.scale(by: 1.25, duration: 0),
            
            SKAction.wait(forDuration: 2),
            SKAction.moveBy(x: 20, y: -30, duration: 0),
            SKAction.scale(to: originalScale, duration: 0),
            SKAction.scaleY(to: originalScale * 1.5, duration: 0),
            
            SKAction.wait(forDuration: 0.5),
            SKAction.moveBy(x: 0, y: 20, duration: 0),
            SKAction.scaleY(to: originalScale, duration: 0),
            SKAction.scale(by: 2, duration: 0),
            
            SKAction.wait(forDuration: 1.2),
            SKAction.moveBy(x: 60, y: 40, duration: 0),
            SKAction.scale(to: originalScale * 0.75, duration: 0),
            SKAction.scaleX(to: -originalScale, duration: 0),
            SKAction.rotate(byAngle: .pi / 2, duration: 0),
            
            SKAction.wait(forDuration: 2),
            SKAction.moveBy(x: -60, y: -40, duration: 0),
            SKAction.scale(to: originalScale, duration: 0),
            SKAction.scaleX(to: -originalScale, duration: 0),
            SKAction.rotate(byAngle: -.pi / 2, duration: 0)
        ])))
        
        shiftCatwalkNode(panels: 1, moveDuration: fadeDuration)
    }
    
    func despawnPrincessCatwalk() {
        princess.sprite.removeAllActions()
        princess.sprite.run(SKAction.fadeOut(withDuration: 2))
        AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 1.7)
    }
    
    func spawnMarlinCatwalk() {
        let fadeDuration: TimeInterval = 2
        
        trainer.sprite.position = getHeroPosition(xPanelOffset: 1, yOffset: 40)
        trainer.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * trainer.scaleMultiplier)
        trainer.sprite.xScale *= -1
        trainer.sprite.alpha = 0
        
        trainer.sprite.run(animatePlayer(player: trainer, type: .glide))
        trainer.sprite.run(SKAction.fadeAlpha(to: 0.5, duration: fadeDuration))
        
        trainer.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 1),
            SKAction.moveBy(x: 0, y: 5, duration: 1),
            SKAction.moveBy(x: 0, y: -20, duration: 1),
            SKAction.moveBy(x: 0, y: -5, duration: 1)
        ])))
        
        shiftCatwalkNode(panels: 1, moveDuration: fadeDuration)
        
        ParticleEngine.shared.animateParticles(type: .magicMerge,
                                               toNode: trainer.sprite,
                                               position: .zero,
                                               scale: 3,
                                               alpha: 0.5,
                                               zPosition: -5,
                                               duration: 0)
    }
    
    func despawnMarlinCatwalk() {
        trainer.sprite.run(SKAction.fadeOut(withDuration: 2))
    }
    
    func spawnTikiCatwalk(statue: ChatItem.ChatProfile, fadeIn: TimeInterval) {
        let marimbaWait: TimeInterval = 0.517
        let overlayAlpha: CGFloat = 0.25
        
        let tiki = SKSpriteNode(texture: ChatItem.getChatProfileTexture(profile: statue))
        tiki.position = getHeroPosition(xPanelOffset: 2, yOffset: 0)
        tiki.scale(to: scaleSize * 3/4)
        tiki.alpha = 0
        tiki.zPosition = K.ZPosition.player - 4
        tiki.name = "tikiStatueNode"
        tiki.danceStatue()
        
        catwalkNode.addChild(tiki)
        
        tiki.run(SKAction.fadeIn(withDuration: fadeIn))
        
        bloodOverlay.run(SKAction.group([
            SKAction.fadeAlpha(to: overlayAlpha, duration: fadeIn),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.colorize(with: .yellow, colorBlendFactor: 1, duration: 0),
                SKAction.fadeOut(withDuration: marimbaWait),
                SKAction.fadeAlpha(to: overlayAlpha, duration: 0),
                
                SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0),
                SKAction.fadeOut(withDuration: marimbaWait),
                SKAction.fadeAlpha(to: overlayAlpha, duration: 0),
                
                SKAction.colorize(with: .cyan, colorBlendFactor: 1, duration: 0),
                SKAction.fadeOut(withDuration: marimbaWait),
                SKAction.fadeAlpha(to: overlayAlpha, duration: 0),

                SKAction.colorize(with: .systemPink, colorBlendFactor: 1, duration: 0),
                SKAction.fadeOut(withDuration: marimbaWait),
                SKAction.fadeAlpha(to: overlayAlpha, duration: 0)
            ]))
        ]))
        
        backgroundNode.run(SKAction.fadeOut(withDuration: fadeIn))
        inbetweenNode.run(SKAction.fadeOut(withDuration: fadeIn))
        shiftCatwalkNode(panels: 1, moveDuration: 2)
        AudioManager.shared.adjustVolume(to: 0.1, for: catwalkOverworld, fadeDuration: fadeIn)
    }
    
    func despawnTikiCatwalk(fadeOut: TimeInterval) {
        guard let tiki = catwalkNode.childNode(withName: "tikiStatueNode") else { return }
        
        tiki.removeAllActions()
        tiki.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: fadeOut),
            SKAction.removeFromParent()
        ]))
                
        bloodOverlay.removeAllActions()
        bloodOverlay.run(SKAction.group([
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: fadeOut),
            SKAction.fadeAlpha(to: 0.26 * fadeAlphaMultiplier, duration: fadeOut)
        ]))
        
        updateBackgroundNode(fadeDuration: fadeOut, completion: nil)
        inbetweenNode.run(SKAction.fadeAlpha(to: 0.81 * fadeAlphaMultiplier, duration: fadeOut))
        AudioManager.shared.adjustVolume(to: 1, for: catwalkOverworld, fadeDuration: fadeOut)
    }
    
    func spawnSwordCatwalk() {
        let duration: TimeInterval = 0.25
        let bounceFactor: CGFloat = scaleSize.width * 0.25
        
        let swordSprite = SKSpriteNode(imageNamed: "sword")
        swordSprite.scale(to: .zero)
        swordSprite.position = getHeroPosition(xPanelOffset: 1, yOffset: 0)
        swordSprite.zPosition = K.ZPosition.overlay
        swordSprite.name = "sword"
        
        swordSprite.run(SKAction.sequence([
            SKAction.scale(to: scaleSize + bounceFactor, duration: duration),
            SKAction.scale(to: scaleSize, duration: duration),
        ]))
        
        catwalkNode.addChild(swordSprite)
    }
    
    func despawnSwordCatwalk() {
        guard let swordSprite = catwalkNode.childNode(withName: "sword") else { return }
        
        swordSprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(by: 2, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
        
        AudioManager.shared.playSound(for: "pickupitem")
        Haptics.shared.addHapticFeedback(withStyle: .rigid)
        
        ParticleEngine.shared.animateParticles(type: .itemPickup,
                                               toNode: catwalkNode,
                                               position: getHeroPosition(xPanelOffset: 0, yOffset: 0),
                                               duration: 2)
        
        ScoringEngine.updateStatusIconsAnimation(icon: .sword,
                                                 amount: 1,
                                                 originSprite: catwalkNode,
                                                 location: getHeroPosition(xPanelOffset: 0, yOffset: 0))
    }
    
    func spawnMagmoorCatwalk() {
        let fadeDuration: TimeInterval = 2
        
        villain.sprite.position = getHeroPosition(xPanelOffset: 3, yOffset: 20)
        villain.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * villain.scaleMultiplier)
        villain.sprite.xScale *= -1
        villain.sprite.alpha = 0
        
        villain.sprite.run(animatePlayer(player: villain, type: .idle))
        villain.sprite.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        
        shiftCatwalkNode(panels: 2, moveDuration: fadeDuration * 1.5)
    }
    
    func despawnMagmoorCatwalk(completion: @escaping () -> Void) {
        despawnMagmoorHelper(completion: completion)
    }
    
    func playMusicCatwalk(music: String, startingVolume: Float, fadeIn: TimeInterval) {
        AudioManager.shared.adjustVolume(to: startingVolume, for: music)
        AudioManager.shared.playSound(for: music, fadeIn: fadeIn)
    }
    
    func stopMusicCatwalk(music: String, fadeOut: TimeInterval) {
        AudioManager.shared.stopSound(for: music, fadeDuration: fadeOut)
    }
    
    func flashRedCatwalk(message: String, secondaryMessages: [String], completion: @escaping () -> Void) {
        flashRedHelper(message: message, secondaryMessages: secondaryMessages, completion: completion)
    }
    
    func shiftRedCatwalk(shouldShift: Bool, showMagmoorScary: Bool) {
        shiftRedHelper(shouldShift: shouldShift, showMagmoorScary: showMagmoorScary, fadeDuration: 1)
    }
    
    func exitCatwalk(completion: @escaping () -> Void) {
        let audioItem = AudioManager.shared.getAudioItem(filename: "magicheartbeatloop2")
        let audioItemTimeRemaining: TimeInterval = audioItem != nil ? audioItem!.player.duration - audioItem!.player.currentTime : 0
        let audioItemEnd: TimeInterval = (audioItem != nil ? audioItem!.player.duration : 0) + audioItemTimeRemaining - 0.1
        
        let exitDuration: TimeInterval = 0.5
        let fadeDuration: TimeInterval = 2
        let exitAction = SKAction.group([
            animatePlayer(player: hero, type: .run),
            SKAction.scaleX(to: hero.sprite.xScale / 4, y: hero.sprite.yScale / 4, duration: exitDuration),
            SKAction.fadeOut(withDuration: exitDuration)
        ])
        
        hero.sprite.run(exitAction)
        
        fadeNode.run(SKAction.sequence([
            SKAction.wait(forDuration: exitDuration),
            SKAction.fadeIn(withDuration: fadeDuration)
        ]))
        
        run(SKAction.wait(forDuration: audioItemEnd)) { [weak self] in
            audioItem?.player.stop()
            AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 1.7)

            self?.cleanupScene()
            completion()
        }
        
        AudioManager.shared.playSoundThenStop(for: "movetile\(Int.random(in: 1...3))", playForDuration: 0.2, fadeOut: 0.8)
        AudioManager.shared.stopSound(for: catwalkOverworld, fadeDuration: fadeDuration * 2)
        AudioManager.shared.stopSound(for: "magmoorcreepypulse", fadeDuration: fadeDuration * 2)
        AudioManager.shared.stopSound(for: "magmoorcreepystrings", fadeDuration: fadeDuration * 2)
    }
    
    
    // MARK: - Catwalk Helper Functions
    
    private func getHeroPosition(xPanelOffset: Int, yOffset: CGFloat) -> CGPoint {
        return hero.sprite.position + CGPoint(x: catwalkPanels[0].size.width * CGFloat(xPanelOffset), y: yOffset)
    }
    
    private func spawnElderHelper(elder: Player, faceLeft: Bool = true, offset: CGPoint) {
        let appearDuration: TimeInterval = 0.5
        let elderScale: CGFloat = Player.getGameboardScale(panelSize: panelSize) * elder.scaleMultiplier
        
        //Preliminarty setup, first...
        elder.sprite.position = getHeroPosition(xPanelOffset: 0, yOffset: 20)
        elder.sprite.setScale(0)
        elder.sprite.alpha = 1
        elder.sprite.run(animatePlayer(player: elder, type: .idle))
        
        elder.sprite.run(SKAction.group([
            SKAction.scale(to: elderScale, duration: appearDuration),
            SKAction.scaleX(to: faceLeft ? -elderScale : elderScale, duration: appearDuration),
            SKAction.rotate(byAngle: -2 * .pi, duration: appearDuration),
            SKAction.moveBy(x: offset.x, y: offset.y, duration: appearDuration)
        ]))
        
        if !faceLeft {
            let particleType: ParticleEngine.ParticleType
            let particleSFX: String?
            
            switch elder.type {
            case .elder0:
                particleType = .magicElderIce
                particleSFX = "enemyice"
            case .elder1:
                particleType = .magicElderFire2
                particleSFX = "enemyflame"
            case .elder2:
                particleType = .magicElderEarth2
                particleSFX = nil
            default:
                particleType = .magicElderIce
                particleSFX = nil
            }
            
            elder.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: appearDuration),
                SKAction.run {
                    ParticleEngine.shared.animateParticles(type: particleType,
                                                           toNode: elder.sprite,
                                                           position: .zero,
                                                           zPosition: -5,
                                                           duration: 0)
                    if let particleSFX = particleSFX {
                        AudioManager.shared.playSound(for: particleSFX)
                    }
                },
                SKAction.colorize(withColorBlendFactor: 0, duration: 1)
            ]))
        }
    }
    
    private func despawnElderHelper(elder: Player) {
        let disappearDuration: TimeInterval = 0.5
        
        elder.sprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0, duration: disappearDuration),
                SKAction.rotate(byAngle: 2 * .pi, duration: disappearDuration),
                SKAction.move(to: hero.sprite.position, duration: disappearDuration)
            ]),
            SKAction.fadeOut(withDuration: 0)
        ]))
    }
    
    private func despawnMagmoorHelper(completion: @escaping () -> Void) {
        let scale: CGFloat = 0.9
        let fadeDuration: TimeInterval = 2
        let attackSprite = SKSpriteNode(texture: SKTexture(imageNamed: "iconSword"))
        attackSprite.position = getHeroPosition(xPanelOffset: 1, yOffset: 0)
        attackSprite.zPosition = K.ZPosition.itemsAndEffects
        attackSprite.setScale(scale * (panelSize / attackSprite.size.width))
        
        let animation = SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.run {
                AudioManager.shared.playSound(for: "chatclose")
            },
            SKAction.rotate(byAngle: -3 * .pi / 2, duration: 0.25),
            SKAction.fadeAlpha(to: 0, duration: 0.5),
            SKAction.removeFromParent()
        ])
        
        catwalkNode.addChild(attackSprite)
        
        attackSprite.run(animation) { [weak self] in
            AudioManager.shared.playSound(for: "scarylaugh")
            
            self?.villain.sprite.run(SKAction.group([
                SKAction.scale(by: 1.25, duration: fadeDuration),
                SKAction.fadeOut(withDuration: fadeDuration)
            ])) { [weak self] in
                if let endClosed = self?.catwalkPanels.last as? SKSpriteNode {
                    endClosed.run(SKAction.setTexture(SKTexture(imageNamed: "endOpen")))
                    
                    AudioManager.shared.playSound(for: "dooropen")
                }
                
                AudioManager.shared.playSound(for: "magmoorcreepypulse")
                AudioManager.shared.playSound(for: "magmoorcreepystrings")

                completion()
            }
        }
        
        shiftCatwalkNode(panels: 1, moveDuration: fadeDuration / 2)
    }
    
    private func flashRedHelper(message: String, secondaryMessages: [String], completion: @escaping () -> Void) {
        guard !isRedShift else { return }
        
        let fadeDuration: TimeInterval = 1
        let colorizeRed = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0)
        let colorizeNone = SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration)
        let colorizeSequence = SKAction.sequence([colorizeRed, colorizeNone])
        
        backgroundNode.run(SKAction.fadeOut(withDuration: 0))
        updateBackgroundNode(fadeDuration: fadeDuration * 2, completion: nil)
        inbetweenNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0),
            SKAction.fadeAlpha(to: 0.81 * fadeAlphaMultiplier, duration: fadeDuration * 2)
        ]))
        bloodOverlay.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0),
            SKAction.fadeAlpha(to: 0.26 * fadeAlphaMultiplier, duration: fadeDuration * 2)
        ]))
        
        hero.sprite.run(colorizeSequence)
        
        for (i, catwalkPanel) in catwalkPanels.enumerated() {
            catwalkPanel.removeAllActions()
            catwalkPanel.run(colorizeSequence) { [weak self] in
                guard let self = self else { return }
                
                if i >= catwalkPanels.count - 1 {
                    shimmerPartyTiles()
                }
            }
        }
        
        let messageNode = SKLabelNode(text: message)
        messageNode.position = CGPoint(x: CGFloat.random(in: (size.width * 1/3)...(size.width * 2/3)),
                                       y: CGFloat.random(in: (size.height * 2/3)...(size.height * 3/4)))
        messageNode.fontName = UIFont.chatFont
        messageNode.fontColor = .red.lightenColor(factor: 6)
        messageNode.fontSize = UIFont.chatFontSizeLarge
        messageNode.addDropShadow()
        messageNode.zPosition = 5
        
        let messageSecondNode = SKLabelNode(text: message)
        messageSecondNode.position = messageNode.position
        messageSecondNode.setScale(2)
        messageSecondNode.fontName = messageNode.fontName
        messageSecondNode.fontColor = UIFont.chatFontColor
        messageSecondNode.fontSize = messageNode.fontSize
        messageSecondNode.alpha = 0.08
        messageSecondNode.zPosition = messageNode.zPosition - 1
        
        addChild(messageNode)
        addChild(messageSecondNode)
        
        messageNode.run(SKAction.wait(forDuration: fadeDuration), completion: completion)
        messageNode.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: fadeDuration * 2),
                SKAction.fadeOut(withDuration: fadeDuration * 2)
            ]),
            SKAction.removeFromParent()
        ]))
        
        messageSecondNode.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(by: 1.25, duration: fadeDuration * 3),
                SKAction.fadeOut(withDuration: fadeDuration * 3)
            ]),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                AudioManager.shared.adjustVolume(to: 1, for: catwalkOverworld, fadeDuration: fadeDuration * 2.5)
            }
        ]))
        
        for secondaryMessage in secondaryMessages {
            let randomDelay = TimeInterval.random(in: 0...0.5)
            let rotation: CGFloat = Int.random(in: 0...4) == 0 ? .pi / 2 : 0
            
            let messageTertiaryNode = SKLabelNode(text: secondaryMessage)
            messageTertiaryNode.position = rotation == .pi / 2 ?
            CGPoint(x: CGFloat.random(in: (size.width * 1/8)...(size.width * 7/8)),
                    y: CGFloat.random(in: (size.height * 1/4)...(size.height * 3/4))) :
            CGPoint(x: CGFloat.random(in: (size.width * 1/4)...(size.width * 3/4)),
                    y: CGFloat.random(in: (size.height * 1/8)...(size.height * 7/8)))
            
            messageTertiaryNode.setScale(CGFloat.random(in: 1...4))
            messageTertiaryNode.xScale *= Int.random(in: 0...4) == 0 ? -1 : 1
            messageTertiaryNode.zRotation = rotation
            messageTertiaryNode.fontName = messageNode.fontName
            messageTertiaryNode.fontColor = UIFont.chatFontColor
            messageTertiaryNode.fontSize = messageNode.fontSize
            messageTertiaryNode.alpha = CGFloat.random(in: 0.08...0.1)
            messageTertiaryNode.zPosition = messageNode.zPosition - 2
            
            addChild(messageTertiaryNode)
            
            messageTertiaryNode.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(by: CGFloat.random(in: 1.25...1.5), duration: fadeDuration * 3 + randomDelay),
                    SKAction.fadeOut(withDuration: fadeDuration * 3 + randomDelay)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        AudioManager.shared.adjustVolume(to: 0.1, for: catwalkOverworld)
        AudioManager.shared.playSoundThenStop(for: "magicheartbeatloop1", playForDuration: fadeDuration)
        Haptics.shared.executeCustomPattern(pattern: .heartbeat)
    }
    
    private func shiftRedHelper(shouldShift: Bool, showMagmoorScary: Bool, fadeDuration: TimeInterval) {
        let heartbeatIndex: Int = showMagmoorScary ? 2 : 1
        
        if shouldShift {
            let colorizeRed = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: fadeDuration)
            isRedShift = true
            
            backgroundNode.run(SKAction.fadeOut(withDuration: fadeDuration))
            inbetweenNode.run(SKAction.fadeOut(withDuration: fadeDuration))
            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
            hero.sprite.run(colorizeRed)
            elder0.sprite.run(colorizeRed)
            elder1.sprite.run(colorizeRed)
            elder2.sprite.run(colorizeRed)
            
            if showMagmoorScary {
                magmoorSprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: fadeDuration),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: fadeDuration * 10),
                        SKAction.scale(to: 1.5, duration: fadeDuration * 30)
                    ])
                ]))
            }
            
            for catwalkPanel in catwalkPanels {
                catwalkPanel.removeAllActions()
                catwalkPanel.run(colorizeRed)
            }
            
            if !AudioManager.shared.isPlaying(audioKey: "magicheartbeatloop\(heartbeatIndex)") {
                AudioManager.shared.playSound(for: "magicheartbeatloop\(heartbeatIndex)")
                AudioManager.shared.adjustVolume(to: 0.1, for: catwalkOverworld)
            }
        }
        else {
            let colorizeNone = SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration)
            
            hero.sprite.run(colorizeNone)
            elder0.sprite.run(colorizeNone)
            elder1.sprite.run(colorizeNone)
            elder2.sprite.run(colorizeNone)
            
            magmoorSprite.removeAllActions()
            magmoorSprite.run(SKAction.fadeOut(withDuration: fadeDuration)) { [weak self] in
                guard let self = self else { return }
                
                updateBackgroundNode(fadeDuration: fadeDuration) {
                    self.isRedShift = false
                }
                inbetweenNode.run(SKAction.fadeAlpha(to: 0.81 * fadeAlphaMultiplier, duration: fadeDuration))
                bloodOverlay.run(SKAction.fadeAlpha(to: 0.26 * fadeAlphaMultiplier, duration: fadeDuration))
                
                AudioManager.shared.adjustVolume(to: 1, for: catwalkOverworld, fadeDuration: fadeDuration * 2.5)
            }
            
            for catwalkPanel in catwalkPanels {
                catwalkPanel.removeAllActions()
                catwalkPanel.run(colorizeNone)
            }
            
            shimmerPartyTiles()
            AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: fadeDuration)
            AudioManager.shared.stopSound(for: "magicheartbeatloop2", fadeDuration: fadeDuration)
        }
    }
    
    
}
