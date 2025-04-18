//
//  CatwalkScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/8/24.
//

import SpriteKit

protocol CatwalkSceneDelegate: AnyObject {
    func catwalkSceneDidFinish(_ cutscene: CatwalkScene, didStartAtTiki: Bool)
}

class CatwalkScene: SKScene {
    
    // MARK: - Properties
    
    static let keySwordFloatAction = "swordFloatAction"
    static let keySelectSwordPulseAction = "selectSwordPulseAction"
    static let keySelectSwordScaleAction = "selectSwordScaleAction"
    static let keyRainbowCycleAction = "rainbowCycleAction"
    static let keyMagmoorFadeAction = "magmoorFadeAction"
    static let keyMagmoorZoomAction = "magmoorZoomAction"
    static let keyMagmoorFlashZoomAction = "magmoorFlashZoomAction"
    static let tikiNodeName = "tikiStatueNode"
    static let chestNodeName = "treasureChestNode"
    static let catwalkOverworld = "magicdoomloop"
    
    private let catwalkLength: Int = 51
    private let panelCount: Int = 5
    private let panelSpacing: CGFloat = 4
    private var panelSize: CGFloat { size.width / CGFloat(panelCount) }
    private var scaleSize: CGSize { CGSize.zero + panelSize - panelSpacing }
    private var fadeAlphaMultiplier: CGFloat { 1 - CGFloat(currentPanelIndex) / CGFloat(catwalkLength) * 3/4 }
    
    private let gemsThreshold = 180
    private let gemsToFeed = 20
    private var gemsFed = 0
    private var shouldFeedGems: Bool = false
    private var isFeedingGems: Bool = false
    private var canOpenChest: Bool = false
    private var shouldSelectSword: Bool = false
    private var isSelectingSword: Bool = false
    private var shouldStartAtTiki: Bool = false

    private let catwalkPanelNameDelimiter: Character = "_"
    private var catwalkPanelNamePrefix: String { "catwalkPanel\(catwalkPanelNameDelimiter)" }
    private var currentPanelIndex: Int = 0
    private var leftmostPanelIndex: Int = 0
    private var catwalkAngle: CGFloat = 0
    private var currentRainbowIndex = 0 {
        didSet {
            if currentRainbowIndex >= UIColor.rainbowColors.count {
                currentRainbowIndex = 0
            }
        }
    }
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
    private var swordSprite: ChosenSword!
    private var magmoorSprite: SKSpriteNode!
    private var magmoorFlashSprite: SKSpriteNode!
    private var backgroundNode: SKSpriteNode!
    private var inbetweenNode: SKSpriteNode!
    private var bloodOverlay: SKSpriteNode!
    private var fadeNode: SKShapeNode!
    private var swordFadeNode: SKSpriteNode!
    private var endClosedMagic: SKSpriteNode!
    private var catwalkNode: SKSpriteNode!
    private var catwalkPanels: [SKSpriteNode] = []
    
    private var tapPointerEngine: TapPointerEngine!
    private var chatEngine: ChatEngine!
    
    private var dispatchWorkItem: DispatchWorkItem?
    private var elderChatBubble: SpeechBubbleSprite!
    private var elderChatAlreadyPlayed = false
    
    weak var catwalkDelegate: CatwalkSceneDelegate?
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupNodes()
    }
    
    init(startAtTiki: Bool) {
        super.init(size: K.ScreenDimensions.size)
        
        self.shouldStartAtTiki = startAtTiki
        
        if shouldStartAtTiki {
            currentPanelIndex = 33
        }
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CatwalkScene deinit")
        
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil
    }
    
    func cleanupScene() {
        currentPanelIndex = 0
        isMoving = false
        shouldDisableInput = true
        isRedShift = false
        
        removeAllActions()
        removeAllChildren()
        removeFromParent()
        
        tapPointerEngine = nil
        chatEngine = nil
        elderChatBubble.cleanupManually()
        
        AudioManager.shared.adjustVolume(to: 1, for: CatwalkScene.catwalkOverworld)
    }
    
    private func setupNodes() {
        backgroundColor = .black
        
        backgroundNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        backgroundNode.size = size
        backgroundNode.anchorPoint = .zero
        
        inbetweenNode = SKSpriteNode(texture: SKTexture(image: UIImage.gradientTextureSkyBlood))
        inbetweenNode.size = size
        inbetweenNode.anchorPoint = .zero
        inbetweenNode.zPosition = 5
        
        bloodOverlay = SKSpriteNode(color: FireIceTheme.overlayColor, size: size)
        bloodOverlay.anchorPoint = .zero
        bloodOverlay.zPosition = K.ZPosition.fadeTransitionNode - 5
        
        updateBackgroundNode(fadeDuration: 0, completion: nil)
        
        ParticleEngine.shared.animateParticles(type: .inbetween,
                                               toNode: inbetweenNode,
                                               position: .zero,
                                               alpha: 0.33,
                                               zPosition: K.ZPosition.fadeTransitionNode - 15,
                                               duration: 0)
        
        fadeNode = SKShapeNode(rectOf: size)
        fadeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        fadeNode.fillColor = .black
        fadeNode.lineWidth = 0
        fadeNode.zPosition = K.ZPosition.fadeTransitionNode
        
        swordFadeNode = SKSpriteNode(color: UIColor.obtainItem.start, size: size)
        swordFadeNode.alpha = 0
        swordFadeNode.anchorPoint = .zero
        swordFadeNode.zPosition = 2
        
        catwalkNode = SKSpriteNode(color: GameboardSprite.gameboardColor,
                                   size: CGSize(width: CGFloat(catwalkLength + 1) * panelSize + panelSpacing, height: panelSize + 2 * panelSpacing))
        catwalkNode.position = CGPoint(x: catwalkNode.frame.size.width / 2, y: size.height / 2)
        catwalkNode.zPosition = 5
        
        hero = Player(type: .hero)
        hero.sprite.position = CGPoint(x: -catwalkNode.frame.size.width / 2 + scaleSize.width / 2, y: 0)
        hero.sprite.setScale(Player.getGameboardScale(panelSize: panelSize))
        hero.sprite.alpha = 0
        hero.sprite.zPosition = K.ZPosition.player
        
        if shouldStartAtTiki {
            hero.sprite.position += CGPoint(x: CGFloat(currentPanelIndex) * (scaleSize.width + panelSpacing), y: 0)
        }
        
        elder0 = Player(type: .elder0)
        elder0.sprite.alpha = 0
        elder0.sprite.zPosition = K.ZPosition.player - 2
        
        elder1 = Player(type: .elder1)
        elder1.sprite.alpha = 0
        elder1.sprite.zPosition = K.ZPosition.player - 5
        
        elder2 = Player(type: .elder2)
        elder2.sprite.alpha = 0
        elder2.sprite.zPosition = K.ZPosition.player + 5
        
        princess = Player(type: .cursedPrincess)
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
        
        magmoorFlashSprite = SKSpriteNode(imageNamed: "villainRedEyesFlash")
        magmoorFlashSprite.size = magmoorSprite.size
        magmoorFlashSprite.position = magmoorSprite.position
        magmoorFlashSprite.alpha = 0
        magmoorFlashSprite.zPosition = 1
        
        
        //BUGFIX# 241210E01 - Glow node on gate extends boundaries on iPad, iPhone SE. Add this scale property to normalize across all devices.
        var glowScale: CGFloat = 1
        
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
            
            if i == catwalkLength {
                glowScale = catwalkPanel.xScale
                
                catwalkPanel.addGlow(spriteNode: SKSpriteNode(color: .white, size: scaleSize / glowScale), radiusPercentage: 0.25, startingAlpha: 0)
            }
            
            catwalkPanels.append(catwalkPanel)
        }
        
        endClosedMagic = SKSpriteNode(imageNamed: "endClosedMagic")
        endClosedMagic.anchorPoint = .zero
        endClosedMagic.alpha = 0
        endClosedMagic.zPosition = 1
        endClosedMagic.addGlow(spriteNode: SKSpriteNode(color: .white, size: scaleSize / glowScale), radiusPercentage: 0.25, startingAlpha: 0)
        
        shimmerPartyTiles()
        tapPointerEngine = TapPointerEngine()
        chatEngine = ChatEngine()
        chatEngine.delegateCatwalk = self
        
        dispatchWorkItem = DispatchWorkItem(block: {})
        elderChatBubble = SpeechBubbleSprite(width: 400, position: CGPoint(x: 400, y: 400) * UIDevice.spriteScale, tailOrientation: .bottomLeft)
        elderChatBubble.setScale(1 / (Player.getGameboardScale(panelSize: panelSize) * elder1.scaleMultiplier))
    }
    
    
    // MARK: - Main Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(backgroundNode)
        addChild(inbetweenNode)
        addChild(bloodOverlay)
        addChild(fadeNode)
        addChild(swordFadeNode)
        addChild(magmoorSprite)
        addChild(magmoorFlashSprite)
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

        catwalkPanels.last?.addChild(endClosedMagic)
        
        chatEngine.moveSprites(to: self)
        
        fadeNode.run(SKAction.fadeOut(withDuration: 4.5)) { [weak self] in
            guard let self = self else { return }
            
            playDialogue(panelIndex: currentPanelIndex)
        }
        
        if shouldStartAtTiki {
            run(SKAction.sequence([
                SKAction.wait(forDuration: 3.5),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                                        
                    shiftCatwalkNode(panels: currentPanelIndex, moveDuration: 2.3) {
                        self.hero.sprite.run(SKAction.fadeIn(withDuration: 1))
                        self.hero.sprite.run(self.animatePlayer(player: self.hero, type: .idle))
                    }
                    
                    AudioManager.shared.playSound(for: "realmtransition")
                }
            ]))
        }
        else {
            hero.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 3.5),
                SKAction.fadeIn(withDuration: 1)
            ]))
            
            hero.sprite.run(animatePlayer(player: hero, type: .idle))
        }
        
        AudioManager.shared.playSound(for: CatwalkScene.catwalkOverworld, fadeIn: 4.5)
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
        
        if let tikiNode = nodes(at: location).filter({ $0.name == CatwalkScene.tikiNodeName }).first as? SKSpriteNode,
            tikiNode.action(forKey: SKSpriteNode.keyAnimateStatue) == nil {
            
            tikiNode.animateStatue()
            AudioManager.shared.playSound(for: "touchstatue")
            Haptics.shared.addHapticFeedback(withStyle: .heavy)
        }
        
        if canOpenChest {
            guard nodes(at: location).filter({ $0.name == CatwalkScene.chestNodeName }).first != nil else { return }
            
            openChest()
            Haptics.shared.addHapticFeedback(withStyle: .heavy)
        }
        else if shouldSelectSword {
            selectSword(in: location)
        }
        else if shouldFeedGems {
            let didTapGate = nodes(at: location).filter({ $0.name == catwalkPanelNamePrefix + "\(catwalkLength)" }).first != nil
            feedGems(at: location, didTapGate: didTapGate)
        }
        else {
            guard let name = nodes(at: location).filter({ ($0.name ?? "").contains(catwalkPanelNamePrefix) }).first?.name else { return }
            
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
            AudioManager.shared.stopSound(for: runSound)
        }
        
        if leftmostPanelIndex < currentPanelIndex - 2 && currentPanelIndex < catwalkLength - 1 {
            shiftCatwalkNode(panels: 1, moveDuration: moveDuration)
        }
        
        //MUST put this at the end!
        if !isRedShift {
            AudioManager.shared.playSound(for: runSound)
        }
    }
    
    private func getPanelIndex(for panelName: String) -> Int? {
        guard panelName.contains(catwalkPanelNameDelimiter) else { return nil }
        
        return Int(String(panelName.suffix(from: panelName.firstIndex(of: catwalkPanelNameDelimiter)!).dropFirst()))
    }
    
    private func animatePlayer(player: Player, type: Player.Texture) -> SKAction {
        return Player.animate(player: player, type: type, timePerFrameMultiplier: isRedShift ? 2 : 1)
    }
    
    private func playDialogue(panelIndex: Int, selectedSword: Int? = nil) {
        let dialogueNumber = -1000 - panelIndex
        
        shouldDisableInput = true
        
        chatEngine.playDialogue(level: dialogueNumber, anyValue: selectedSword) { [weak self] _ in
            guard let self = self else { return }
            
            shouldDisableInput = false
            hero.sprite.xScale = abs(hero.sprite.xScale)
        }
    }
    
    private func updateBackgroundNode(fadeDuration: TimeInterval, completion: (() -> Void)?) {
        inbetweenNode.run(SKAction.fadeAlpha(to: 0.666, duration: fadeDuration))
        bloodOverlay.run(SKAction.fadeAlpha(to: 0.2, duration: fadeDuration))
        backgroundNode.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)) {
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
        - completion: optional completion handler to process code after function completes
     */
    private func shiftCatwalkNode(panels: Int, moveDuration: TimeInterval, completion: (() -> Void)? = nil) {
        let moveDistance: CGFloat = -1 * CGFloat(panels) * (scaleSize.width + panelSpacing)
        
        catwalkNode.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)) {
            completion?()
        }

        leftmostPanelIndex += panels
        
        if leftmostPanelIndex % 4 == 0 {
            let angleToAdd = -CGFloat(0.1).toRadians()

            catwalkAngle += angleToAdd
            
            catwalkNode.run(SKAction.rotate(byAngle: angleToAdd, duration: moveDuration))
        }
    }
    
    private func openCloseGate(shouldOpen: Bool) {
        guard let gatePanel = catwalkPanels.last else { return }
        
        gatePanel.run(SKAction.setTexture(SKTexture(imageNamed: shouldOpen ? "endOpenMagic" : "endClosedMagic")))
        
        AudioManager.shared.playSound(for: "dooropen")
        Haptics.shared.addHapticFeedback(withStyle: .heavy)
    }
    
    /**
     Shakes the screen. Use effect for certain cataclysmic event
     - parameters:
        - totalDuration: duration of shake. If negative, run indefinitely (5 mins max)
        - completion: completion handler
     */
    func shakeScreen(duration totalDuration: TimeInterval, completion: (() -> Void)?) {
        let shakeMagnitude: CGFloat = 12
        let shakeDuration: TimeInterval = 0.06
        let totalDurationAdjusted: TimeInterval = totalDuration < 0 ? 300 : totalDuration
        
        let shakeAction = SKAction.repeat(SKAction.sequence([
            SKAction.moveBy(x: shakeMagnitude, y: shakeMagnitude, duration: shakeDuration),
            SKAction.moveBy(x: -shakeMagnitude, y: -shakeMagnitude, duration: shakeDuration)
        ]), count: Int(totalDurationAdjusted / (shakeDuration * 2)))
        
        catwalkNode.run(shakeAction) {
            Haptics.shared.stopHapticEngine()
            Haptics.shared.startHapticEngine(shouldInitialize: false)

            completion?()
        }
        
        AudioManager.shared.playSoundThenStop(for: "thunderrumble", currentTime: 5, playForDuration: totalDurationAdjusted + 1, fadeOut: 4)
        Haptics.shared.executeCustomPattern(pattern: .thunder)
    }
    
    private func unshakeScreen(fadeDuration: TimeInterval, completion: (() -> Void)?) {
        AudioManager.shared.stopSound(for: "thunderrumble", fadeDuration: fadeDuration)
        
        run(SKAction.wait(forDuration: fadeDuration)) { [weak self] in
            self?.catwalkNode.removeAllActions()

            Haptics.shared.stopHapticEngine()
            Haptics.shared.startHapticEngine(shouldInitialize: false)
            
            completion?()
        }
    }
    
    
}


// MARK: - ChatEngineCatwalkDelegate

extension CatwalkScene: ChatEngineCatwalkDelegate {
    func spawnEldersCatwalk(faceLeft: Bool) {
        hero.sprite.xScale = abs(hero.sprite.xScale)
        
        spawnElderHelper(
            elder: elder0,
            faceLeft: faceLeft,
            offset: faceLeft ? CGPoint(x: scaleSize.width, y: scaleSize.height * 0.4) : CGPoint(x: scaleSize.width * 1.5, y:scaleSize.height * 0.4))
        spawnElderHelper(
            elder: elder1,
            faceLeft: faceLeft,
            offset: faceLeft ? CGPoint(x: scaleSize.width * 1.75, y: scaleSize.height * 0.8) : CGPoint(x: scaleSize.width * 0.8, y: scaleSize.height * 0.8))
        spawnElderHelper(
            elder: elder2,
            faceLeft: faceLeft,
            offset: faceLeft ? CGPoint(x: scaleSize.width * 1.5, y: -scaleSize.height * 0.1) : CGPoint(x: scaleSize.width * 0.65, y: -scaleSize.height * 0.1))
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
        
        func setPosition(heroPanelOffset: Int) -> CGPoint {
            return getHeroPosition(xPanelOffset: heroPanelOffset, yOffset: -scaleSize.height * 0.1)
        }
        
        princess.sprite.position = setPosition(heroPanelOffset: 1)
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
            SKAction.moveBy(x: -20, y: 20, duration: 0),
            SKAction.scale(by: 1.25, duration: 0),
            
            SKAction.wait(forDuration: 2),
            SKAction.run { [weak self] in
                self?.princess.sprite.position = setPosition(heroPanelOffset: -1)
            },
            SKAction.moveBy(x: 20, y: 10, duration: 0),
            SKAction.scale(to: originalScale, duration: 0),
            SKAction.scaleY(to: originalScale * 1.5, duration: 0),
            
            SKAction.wait(forDuration: 0.5),
            SKAction.moveBy(x: 0, y: 30, duration: 0),
            SKAction.scaleY(to: originalScale, duration: 0),
            SKAction.scale(by: 2, duration: 0),
            
            SKAction.wait(forDuration: 1.2),
            SKAction.run { [weak self] in
                self?.princess.sprite.position = setPosition(heroPanelOffset: 1)
            },
            SKAction.moveBy(x: -40, y: 70, duration: 0),
            SKAction.scale(to: originalScale * 0.75, duration: 0),
            SKAction.scaleX(to: originalScale, duration: 0),
            SKAction.rotate(byAngle: .pi, duration: 0),
            
            SKAction.wait(forDuration: 2),
            SKAction.moveBy(x: 40, y: -70, duration: 0),
            SKAction.scale(to: originalScale, duration: 0),
            SKAction.scaleX(to: -originalScale, duration: 0),
            SKAction.rotate(byAngle: -.pi, duration: 0)
        ])))
    }
    
    func despawnPrincessCatwalk() {
        princess.sprite.removeAllActions()
        princess.sprite.run(SKAction.fadeOut(withDuration: 2))
        AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 1.7)
    }
    
    func spawnMarlinCatwalk() {
        let fadeDuration: TimeInterval = 2
        
        trainer.sprite.position = getHeroPosition(xPanelOffset: 1, yOffset: scaleSize.height * 0.3)
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
    
    func spawnTikiCatwalk(statueNumber: Int, fadeIn: TimeInterval) {
        let marimbaWait: TimeInterval = 0.517
        let overlayAlpha: CGFloat = 0.25
        
        let tiki = SKSpriteNode(imageNamed: "statue\(statueNumber)")
        tiki.position = getHeroPosition(xPanelOffset: 2, yOffset: 0)
        tiki.scale(to: scaleSize)
        tiki.alpha = 0
        tiki.zPosition = K.ZPosition.player - 3
        tiki.name = CatwalkScene.tikiNodeName
        tiki.danceStatue()
        
        catwalkNode.addChild(tiki)
        
        tiki.run(SKAction.fadeIn(withDuration: fadeIn))
        
        bloodOverlay.run(SKAction.group([
            SKAction.fadeAlpha(to: overlayAlpha, duration: 2),
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
    }
    
    func despawnTikiCatwalk(fadeOut: TimeInterval, delay: TimeInterval?) {
        guard let tiki = catwalkNode.childNode(withName: CatwalkScene.tikiNodeName) else { return }
        
        tiki.removeAllActions()
        tiki.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: fadeOut),
            SKAction.removeFromParent()
        ]))
                
        bloodOverlay.removeAllActions()
        bloodOverlay.run(SKAction.colorize(with: FireIceTheme.overlayColor, colorBlendFactor: 1, duration: fadeOut))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: (delay ?? 0) - fadeOut),
            SKAction.run { [weak self] in
                self?.updateBackgroundNode(fadeDuration: fadeOut, completion: nil)
            }
        ]))
    }
    
    func spawnChestCatwalk(spawnDuration: TimeInterval) {
        let chestSprite = SKSpriteNode(imageNamed: "chestclosed")
        chestSprite.position = getHeroPosition(xPanelOffset: 1, yOffset: 300)
        chestSprite.scale(to: scaleSize)
        chestSprite.alpha = 0
        chestSprite.zPosition = K.ZPosition.player - 1
        chestSprite.name = CatwalkScene.chestNodeName
        
        let descendChestAction = SKAction.moveBy(x: 0, y: -300, duration: spawnDuration)
        descendChestAction.timingFunction = { t in
            pow(t, 8)
        }
        
        chestSprite.run(SKAction.group([
            SKAction.fadeIn(withDuration: spawnDuration / 2),
            descendChestAction
        ])) {
            AudioManager.shared.playSound(for: "boyimpact")
        }
        
        chestSprite.removeFromParent()
        catwalkNode.addChild(chestSprite)
    }
    
    func canOpenChestCatwalk() {
        canOpenChest = true
    }
    
    func isSelectingSwordCatwalk() {
        isSelectingSword = true
    }
    
    func isUnselectingSwordCatwalk() {
        isSelectingSword = false
        
        let scaleDuration: TimeInterval = 0.5
        
        for node in catwalkNode.children {
            guard let name = node.name, name.contains(ChosenSword.namePrefix) else { continue }
            
            node.action(forKey: CatwalkScene.keySwordFloatAction)?.speed = 1
            node.removeAction(forKey: CatwalkScene.keySelectSwordPulseAction)
            node.removeAction(forKey: CatwalkScene.keySelectSwordScaleAction)
            node.run(SKAction.scale(to: scaleSize, duration: scaleDuration))
        }
    }
    
    func spawnSwordCatwalk(chosenSword: ChosenSword, spawnDuration: TimeInterval, delay: TimeInterval?, completion: @escaping () -> Void) {
        //IMPORTANT: Call this BEFORE initializing swordSprite!
        didSelectSwordHelper(chosenSword: chosenSword, hideDuration: delay ?? 0)

        swordSprite = ChosenSword(type: chosenSword.type.rawValue)
        swordSprite.spriteNode.position = getHeroPosition(xPanelOffset: 1, yOffset: 300)
        swordSprite.spriteNode.scale(to: scaleSize)
        swordSprite.spriteNode.alpha = 0
        swordSprite.spriteNode.zPosition = K.ZPosition.player - 1
        
        swordSprite.spriteNode.run(SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0),
                SKAction.moveBy(x: 0, y: -300, duration: spawnDuration)
            ])
        ]), completion: completion)
        
        swordSprite.spriteNode.removeFromParent() //just in case...
        catwalkNode.addChild(swordSprite.spriteNode)
    }
    
    func throwShieldCatwalk() {
        let delayDuration: TimeInterval = 0.5
        let throwDuration: TimeInterval = 1
        
        let shieldSprite = SKSpriteNode(imageNamed: "shield")
        shieldSprite.position = getHeroPosition(xPanelOffset: 0, yOffset: 0)
        shieldSprite.scale(to: scaleSize)
        shieldSprite.zPosition = K.ZPosition.player - 1
        
        catwalkNode.addChild(shieldSprite)
        
        shieldSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: delayDuration),
            SKAction.group([
                SKAction.rotate(byAngle: -4 * .pi, duration: throwDuration),
                SKAction.moveBy(x: size.width, y: 0, duration: throwDuration),
            ]),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        AudioManager.shared.playSound(for: "boyattack\(Int.random(in: 1...3))", delay: delayDuration)
        
        if let swordThrowSound = AudioManager.shared.getAudioItem(filename: "swordthrow"),
           let swordThudSound = AudioManager.shared.getAudioItem(filename: "swordthud") {
            AudioManager.shared.playSound(for: swordThrowSound.fileName, delay: delayDuration)
            AudioManager.shared.adjustVolume(to: 0.25, for: swordThudSound.fileName)
            AudioManager.shared.playSound(for: swordThudSound.fileName, delay: delayDuration + swordThudSound.player.duration + 1)
        }
    }
    
    func despawnSwordCatwalk(fadeDuration: TimeInterval, delay: TimeInterval?) {
        swordSprite.spriteNode.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(by: 2, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    func showLargeItem(imageName: String, fadeDuration: TimeInterval, delay: TimeInterval?) {
        let largeItem = SKSpriteNode(imageNamed: imageName)
        largeItem.position = CGPoint(x: size.width / 2, y: size.height / 2)
        largeItem.scale(to: .zero)
        largeItem.zPosition = K.ZPosition.itemsAndEffects
        
        addChild(largeItem)
        
        largeItem.run(SKAction.sequence([
            SKAction.scale(to: scaleSize * 6, duration: 0.25),
            SKAction.scale(to: scaleSize * 4, duration: fadeDuration / 2)
        ]))
        
        largeItem.run(SKAction.sequence([
            SKAction.group([
                SKAction.rotate(byAngle: 2 * .pi, duration: (delay ?? 0) - fadeDuration),
                SKAction.sequence([
                    SKAction.wait(forDuration: (delay ?? 0) - fadeDuration),
                    SKAction.scale(to: scaleSize * 6, duration: 0.25),
                    SKAction.scale(to: 0, duration: 0.25)
                ])
            ]),
            SKAction.removeFromParent()
        ]))
        
        swordFadeNode.color = UIColor.obtainItem.start
        swordFadeNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.run { [weak self] in
                self?.bloodOverlay.isHidden = true
            },
            SKAction.colorize(with: UIColor.obtainItem.end, colorBlendFactor: 1, duration: max(0, (delay ?? 0) - fadeDuration - 0.25)),
            SKAction.fadeOut(withDuration: fadeDuration)
        ])) { [weak self] in
            self?.bloodOverlay.isHidden = false
        }
        
        AudioManager.shared.playSound(for: "pickupitem")
        AudioManager.shared.playSound(for: "titlechapter")
        Haptics.shared.addHapticFeedback(withStyle: .rigid)
        
        ParticleEngine.shared.animateParticles(type: .itemPickup,
                                               toNode: catwalkNode,
                                               position: getHeroPosition(xPanelOffset: 0, yOffset: 0),
                                               scale: 6,
                                               duration: fadeDuration)
    }
    
    func showGateCatwalk(completion: @escaping () -> Void) {
        shiftCatwalkNode(panels: 2, moveDuration: 1, completion: completion)
    }
    
    func feedGemsCatwalk() {
        shouldFeedGems = true
        
        elderChatBubble.removeFromParent()
        dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            elderChatBubble.setText(text: "Tap the gate to feed it your gems, child!",
                                    speed: 0.04,
                                    superScene: self,
                                    parentNode: elder1.sprite,
                                    completion: nil)
        })
        
        if let dispatchWorkItem = dispatchWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: dispatchWorkItem)
        }
    }
    
    func spawnMagmoorCatwalk() {
        magmoorSprite.run(fadeInMagmoorHelper(fadeDuration: 2), withKey: CatwalkScene.keyMagmoorFadeAction)
        AudioManager.shared.playSound(for: "magicheartbeatloop2", delay: 0.5)
        
        dispatchWorkItem?.cancel()
    }
    
    func flashMagmoorCatwalk(quickFlash: Bool) {
        if quickFlash {
            magmoorSprite.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0),
                SKAction.wait(forDuration: 0.12),
                SKAction.fadeOut(withDuration: 0.25)
            ]))
        }
        else {
            flashMagmoorHelper()
        }
    }
    
    func playMusicCatwalk(music: String, startingVolume: Float, fadeIn: TimeInterval, shouldStopOverworld: Bool) {
        AudioManager.shared.adjustVolume(to: startingVolume, for: music)
        AudioManager.shared.playSound(for: music, fadeIn: fadeIn)
        
        if shouldStopOverworld {
            AudioManager.shared.adjustVolume(to: 0.1, for: CatwalkScene.catwalkOverworld, fadeDuration: fadeIn)
        }
    }
    
    func stopMusicCatwalk(music: String, fadeOut: TimeInterval, delay: TimeInterval?, shouldPlayOverworld: Bool) {
        AudioManager.shared.stopSound(for: music, fadeDuration: fadeOut)
        
        run(SKAction.wait(forDuration: fadeOut + 1)) { //add a 1s buffer so there's no overlap!
            AudioManager.shared.adjustVolume(to: 1, for: music)
        }
        
        if shouldPlayOverworld {
            run(SKAction.wait(forDuration: delay ?? 0)) {
                AudioManager.shared.adjustVolume(to: 1, for: CatwalkScene.catwalkOverworld, fadeDuration: fadeOut)
            }
        }
    }
    
    func flashRedCatwalk(message: String, secondaryMessages: [String], completion: @escaping () -> Void) {
        flashRedHelper(message: message, secondaryMessages: secondaryMessages, completion: completion)
    }
    
    func shiftRedCatwalk(shouldShift: Bool, fasterHeartbeat: Bool) {
        shiftRedHelper(shouldShift: shouldShift, fasterHeartbeat: fasterHeartbeat, fadeDuration: 1)
    }
    
    func exitCatwalk(completion: @escaping () -> Void) {
        let audioItem = AudioManager.shared.getAudioItem(filename: "magicheartbeatloop2")
        let audioItemTimeRemaining: TimeInterval = audioItem != nil ? audioItem!.player.duration - audioItem!.player.currentTime : 0
        let audioItemEnd: TimeInterval = (audioItem != nil ? audioItem!.player.duration : 0) + audioItemTimeRemaining - 0.1
        
        let exitDuration: TimeInterval = 0.5
        let fadeDuration: TimeInterval = 2
        let jumpScareDuration: TimeInterval = 0.12
        let scaryLaughDuration: TimeInterval = AudioManager.shared.getAudioItem(filename: "scarylaugh")?.player.duration ?? 0
        let exitAction = SKAction.group([
            animatePlayer(player: hero, type: .run),
            SKAction.scaleX(to: hero.sprite.xScale / 4, y: hero.sprite.yScale / 4, duration: exitDuration),
            SKAction.fadeOut(withDuration: exitDuration)
        ])
        
        hero.sprite.run(exitAction)
        
        catwalkNode.run(SKAction.sequence([
            SKAction.wait(forDuration: exitDuration),
            SKAction.run { [weak self] in
                self?.openCloseGate(shouldOpen: false)
            },
            SKAction.wait(forDuration: fadeDuration / 2),
            SKAction.group([
                SKAction.colorize(with: .black, colorBlendFactor: 1, duration: fadeDuration / 2),
                SKAction.fadeOut(withDuration: fadeDuration / 2)
            ])
        ]))
        
        magmoorSprite.removeAction(forKey: CatwalkScene.keyMagmoorFadeAction)
        magmoorSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: audioItemEnd + scaryLaughDuration - 2 - jumpScareDuration),
            SKAction.fadeOut(withDuration: jumpScareDuration)
        ]))
        
        magmoorFlashSprite.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: audioItemEnd),
            SKAction.run {
                audioItem?.player.stop()
                AudioManager.shared.playSoundThenStop(for: "scarylaugh", playForDuration: scaryLaughDuration)
            },
            SKAction.wait(forDuration: scaryLaughDuration - 2),
            SKAction.run {
                AudioManager.shared.playSound(for: "magichorrorimpact2")
                Haptics.shared.executeCustomPattern(pattern: .enemy)
            },
            SKAction.group([
                SKAction.scale(by: 1.5, duration: jumpScareDuration),
                SKAction.rotate(byAngle: CGFloat(5).toRadians(), duration: jumpScareDuration)
            ]),
            SKAction.fadeOut(withDuration: 0),
            SKAction.wait(forDuration: 3)
        ])) { [weak self] in
            guard let self = self else { return }
            
            completion()
            
            catwalkDelegate?.catwalkSceneDidFinish(self, didStartAtTiki: shouldStartAtTiki)
            
            //Put this last!! This deinitializes EVERYTHING.
            cleanupScene()
        }
        
        unshakeScreen(fadeDuration: fadeDuration * 2, completion: nil)

        AudioManager.shared.playSoundThenStop(for: "movetile\(Int.random(in: 1...3))", playForDuration: 0.2, fadeOut: 0.8)
        AudioManager.shared.stopSound(for: CatwalkScene.catwalkOverworld, fadeDuration: fadeDuration * 2)
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
        elder.sprite.position = getHeroPosition(xPanelOffset: 0, yOffset: scaleSize.height * 0.1)
        elder.sprite.setScale(0)
        elder.sprite.alpha = 1
        elder.sprite.run(animatePlayer(player: elder, type: .idle))
        
        if faceLeft {
            elder.sprite.run(SKAction.group([
                SKAction.scale(to: elderScale, duration: appearDuration),
                SKAction.scaleX(to: faceLeft ? -elderScale : elderScale, duration: appearDuration),
                SKAction.rotate(byAngle: -2 * .pi, duration: appearDuration),
                SKAction.moveBy(x: offset.x, y: offset.y, duration: appearDuration)
            ]))
        }
        else {
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
                particleSFX = "boyimpact"
            default:
                particleType = .magicElderIce
                particleSFX = nil
            }
            
            elder.sprite.run(SKAction.group([
                SKAction.moveBy(x: offset.x, y: offset.y, duration: 0),
                SKAction.scale(to: elderScale, duration: appearDuration * 2),
                SKAction.scaleX(to: faceLeft ? -elderScale : elderScale, duration: appearDuration * 2),
                SKAction.rotate(byAngle: -4 * .pi, duration: appearDuration * 2)
            ]))
            
            elder.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: appearDuration),
                SKAction.run {
                    ParticleEngine.shared.animateParticles(
                        type: particleType,
                        toNode: elder.sprite,
                        position: .zero + CGPoint(x: 0, y: elder.type == .elder1 ? -elder.sprite.size.height / 2 : 0),
                        zPosition: -5,
                        duration: 0)
                    if let particleSFX = particleSFX {
                        AudioManager.shared.playSound(for: particleSFX)
                    }
                },
                SKAction.wait(forDuration: 1),
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
    
    /**
     Opens the treasure chest.
     */
    private func openChest() {
        guard let chestSprite = catwalkNode.childNode(withName: CatwalkScene.chestNodeName) as? SKSpriteNode else { return }
        
        canOpenChest = false
        shouldSelectSword = true
        
        chestSprite.texture = SKTexture(imageNamed: "chestopen")
        AudioManager.shared.playSound(for: "pickupitem")
        
        let moveDuration: TimeInterval = 0.5
        let swordFloatDistance: CGFloat = 20
        let swordChoicesCount: Int = ChosenSword.SwordType.allCases.count
        let swordDivision: Int = Int(ceil(CGFloat(swordChoicesCount) / CGFloat(2)))
        
        for i in 0..<swordChoicesCount {
            let imageName: String
            
            switch i {
            case 0: imageName = "sword1Celestial"
            case 1: imageName = "sword2Heavenly"
            case 2: imageName = "sword3Cosmic"
            case 3: imageName = "sword4Eternal"
            default: imageName = "sword"
            }
            
            let swordNode = SKSpriteNode(imageNamed: imageName)
            swordNode.position = chestSprite.position
            swordNode.scale(to: scaleSize / 2)
            swordNode.zPosition = K.ZPosition.player + 1
            swordNode.name = "\(ChosenSword.namePrefix)\(i)"
            catwalkNode.addChild(swordNode)
            
            
            let isTopRow: Bool = i < swordDivision
            let backgroundSize: CGFloat = backgroundNode.size.width / CGFloat(swordDivision)
            let xOffset: CGFloat = isTopRow ? (1/2 + CGFloat(i)) : (1 + CGFloat(i - swordDivision))
            let yOffset: CGFloat = (isTopRow ? 600 : 300) / UIDevice.spriteScale
            let endPosition: CGPoint = CGPoint(x: xOffset * backgroundSize - catwalkNode.position.x, y: yOffset)
            
            swordNode.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPosition, duration: moveDuration),
                    SKAction.rotate(byAngle: 2 * .pi, duration: moveDuration),
                    SKAction.scale(to: scaleSize, duration: moveDuration)
                ]),
                SKAction.scale(to: scaleSize * 1.2, duration: moveDuration / 2),
                SKAction.scale(to: scaleSize * 0.8, duration: moveDuration / 2),
                SKAction.scale(to: scaleSize, duration: moveDuration / 2)
            ]))
            
            swordNode.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: i % 2 == 0 ? -swordFloatDistance : swordFloatDistance, duration: moveDuration * 4),
                SKAction.moveBy(x: 0, y: i % 2 == 0 ? swordFloatDistance : -swordFloatDistance, duration: moveDuration * 4)
            ])), withKey: CatwalkScene.keySwordFloatAction)
        } //end for
    }//end openChest()
    
    /**
     Selects a ChosenSword, based on availability.
     */
    private func selectSword(in location: CGPoint) {
        guard !isSelectingSword else { return }
        guard let swordNode = nodes(at: location).filter({ ($0.name ?? "").contains(ChosenSword.namePrefix) }).first as? SKSpriteNode,
              let swordName = swordNode.name,
              let swordType = Int(String(swordName.suffix(from: swordName.firstIndex(of: "_")!).dropFirst())) else { return }

        let scaleDuration: TimeInterval = 0.25
        
        swordNode.action(forKey: CatwalkScene.keySwordFloatAction)?.speed = 0
        
        swordNode.run(SKAction.sequence([
            SKAction.wait(forDuration: scaleDuration * 6),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: scaleSize * 2, duration: scaleDuration * 0.5),
                SKAction.scale(to: scaleSize * 2.5, duration: scaleDuration * 4)
            ]))
        ]), withKey: CatwalkScene.keySelectSwordPulseAction)
        
        swordNode.run(SKAction.sequence([
            SKAction.scale(to: scaleSize * 3, duration: scaleDuration),
            SKAction.scale(to: scaleSize * 2, duration: scaleDuration),
            SKAction.scale(to: scaleSize * 2.5, duration: scaleDuration * 4)
        ]), withKey: CatwalkScene.keySelectSwordScaleAction)
        
        ButtonTap.shared.tap(type: .buttontap1)
        
        playDialogue(panelIndex: -2, selectedSword: swordType)
    }
    
    private func didSelectSwordHelper(chosenSword: ChosenSword, hideDuration: TimeInterval) {
        shouldSelectSword = false
        FIRManager.updateFirestoreRecordChosenSword(chosenSword.type.rawValue)
        
        guard let chestSprite = catwalkNode.childNode(withName: CatwalkScene.chestNodeName) as? SKSpriteNode else { return }
        
        catwalkNode.children.forEach { node in
            guard let name = node.name, name.contains(ChosenSword.namePrefix), let nonchosenSword = node as? SKSpriteNode else { return }
            
            let isChosenSword = nonchosenSword.name == chosenSword.name
            
            nonchosenSword.run(SKAction.sequence([
                SKAction.group([
                    SKAction.rotate(byAngle: -2 * .pi, duration: hideDuration),
                    SKAction.move(to: chestSprite.position + CGPoint(x: 0, y: isChosenSword ? 300 : 0), duration: hideDuration),
                    SKAction.scale(to: isChosenSword ? scaleSize : scaleSize / 2, duration: hideDuration),
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        chestSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: hideDuration),
            SKAction.setTexture(SKTexture(imageNamed: "chestclosed")),
            SKAction.fadeOut(withDuration: hideDuration * 2),
            SKAction.removeFromParent()
        ]))
        
        print("Sword selected: \(chosenSword.type)")
    }
    
    /**
     Feeds gems into the gateway to Magmoor.
     - parameters:
        - location: location of where the gems will feed into
        - didTapGate: true if the panel tapped was the gate
     */
    private func feedGems(at location: CGPoint, didTapGate: Bool) {
        guard !isFeedingGems else { return }
        
        isFeedingGems = true
        
        let fadeDuration: TimeInterval = 1.5
        let cycleSpeed: TimeInterval = 0.25
        let delaySpeed: TimeInterval = 0.1
        
        animateFeedGems(at: location, didTapGate: didTapGate, maxGems: gemsToFeed) { [weak self] in
            guard let self = self else { return }
            
            if gemsFed >= gemsThreshold {
                unshakeScreen(fadeDuration: fadeDuration) { [weak self] in
                    self?.isFeedingGems = false
                    self?.shouldFeedGems = false
                    self?.isRedShift = true
                }
                
                openCloseGate(shouldOpen: true)
                catwalkPanels.last?.animateAppearGlow(fadeDuration: fadeDuration, waitDuration: 0.5)
                endClosedMagic.removeFromParent()
                AudioManager.shared.playSound(for: "ydooropen")
                
                dispatchWorkItem?.cancel()
                dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
                    guard let self = self else { return }
                    elderChatBubble.removeFromParent()
                    elderChatBubble.setText(text: "Huzzah!!! Now, onward we go! 👉🏼",
                                            speed: 0.04,
                                            superScene: self,
                                            parentNode: elder2.sprite,
                                            completion: nil)
                })
                
                if let dispatchWorkItem = dispatchWorkItem {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: dispatchWorkItem)
                }
            }
            else {
                isFeedingGems = false
            }
        }
        
        AudioManager.shared.playSound(for: didTapGate ? "revive" : "buttontap6")
        Haptics.shared.addHapticFeedback(withStyle: .heavy)
        
        
        //Ensure the gate was tapped, otherwise skip all the below rigamaroll
        guard didTapGate else { return }
        
        dispatchWorkItem?.cancel()
        if !elderChatAlreadyPlayed {
            dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
                guard let self = self else { return }
                elderChatAlreadyPlayed = true
                elderChatBubble.removeFromParent()
                elderChatBubble.setText(text: "That's it boy!! Keep tapping the gate until it opens!",
                                        speed: 0.04,
                                        superScene: self,
                                        parentNode: elder1.sprite,
                                        completion: nil)
            })
            
            if let dispatchWorkItem = dispatchWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: dispatchWorkItem)
            }
        }
        
        if let gatePanel = catwalkPanels.last {
            gatePanel.animateAppearGlow(fadeDuration: fadeDuration * 1/4, waitDuration: fadeDuration * 1/2)
            
            gatePanel.run(SKAction.sequence([
                SKAction.colorize(with: UIColor.rainbowColors[currentRainbowIndex], colorBlendFactor: 1, duration: fadeDuration * 1/4),
                SKAction.wait(forDuration: fadeDuration * 1/4),
                SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration * 1/2)
            ]))
        }
        
        currentRainbowIndex += 1

        //Incrementally add effects per each tap.
        if gemsFed > gemsToFeed * 6 && gemsFed <= gemsToFeed * 7 {
            run(SKAction.sequence([
                SKAction.wait(forDuration: fadeDuration),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    for (i, panel) in catwalkPanels.enumerated() {
                        panel.removeAllActions()
                        panel.run(animateRainbowCycle(cycleSpeed: cycleSpeed, delay: TimeInterval(catwalkLength - i) * delaySpeed), withKey: CatwalkScene.keyRainbowCycleAction)
                    }
                    
                    endClosedMagic.animateAppearGlow(fadeDuration: fadeDuration, waitDuration: 5)

                    endClosedMagic.run(animateRainbowCycle(cycleSpeed: cycleSpeed, delay: nil))
                    endClosedMagic.run(SKAction.fadeIn(withDuration: fadeDuration))
                    backgroundNode.run(SKAction.fadeOut(withDuration: fadeDuration))
                    inbetweenNode.run(SKAction.fadeOut(withDuration: fadeDuration))
                    bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
                    
                    elder0.sprite.run(animateRainbowCycle(cycleSpeed: cycleSpeed, delay: 3 * delaySpeed), withKey: CatwalkScene.keyRainbowCycleAction)
                    elder1.sprite.run(animateRainbowCycle(cycleSpeed: cycleSpeed, delay: 4 * delaySpeed), withKey: CatwalkScene.keyRainbowCycleAction)
                    elder2.sprite.run(animateRainbowCycle(cycleSpeed: cycleSpeed, delay: 5 * delaySpeed), withKey: CatwalkScene.keyRainbowCycleAction)
                    hero.sprite.run(animateRainbowCycle(cycleSpeed: cycleSpeed, delay: 6 * delaySpeed), withKey: CatwalkScene.keyRainbowCycleAction)
                    
                    AudioManager.shared.adjustVolume(to: 0, for: CatwalkScene.catwalkOverworld, fadeDuration: fadeDuration)
                },
            ]))
        }
        else if gemsFed > gemsToFeed * 3 && gemsFed <= gemsToFeed * 4 {
            run(SKAction.sequence([
                SKAction.wait(forDuration: fadeDuration),
                SKAction.run { [weak self] in
                    self?.shakeScreen(duration: -1, completion: nil)
                },
            ]))
        }
    }
    
    /**
     Recursive helper function that animates gems feeding into the magic door to open it.
     - parameters:
        - location: location of where the tap occured
        - currentGem: initialized to 0, don't set this usually
        - maxGems: maximum # of gems before base case is executed
        - completion: handler to execute after last gem animates
     */
    private func animateFeedGems(at location: CGPoint, didTapGate: Bool, currentGem: Int = 0, maxGems: Int, completion: @escaping () -> Void) {
        //Recursion - Base case
        guard currentGem <= maxGems else { return }

        //Position properties
        let spawnPosition: CGPoint = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
        let distanceToTouch: CGFloat = sqrt(pow(location.x - spawnPosition.x, 2) + pow(location.y - spawnPosition.y, 2))
        let maxDistance: CGFloat = sqrt(pow(location.x, 2) + pow(location.y, 2))
        
        //Scaling properties
        let maxScale: CGFloat = 6
        let scaleDivisions: CGFloat = maxDistance / maxScale
        let startScale: CGFloat = min(distanceToTouch / scaleDivisions + 1, maxScale)
        let startAlpha: CGFloat = 1 / startScale
        let fadeDuration: TimeInterval = TimeInterval(startScale) / TimeInterval(4/3 * maxScale)
        
        let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: "gem"))
        gemSprite.position = spawnPosition
        gemSprite.setScale(startScale)
        gemSprite.alpha = 0
        gemSprite.zPosition = K.ZPosition.itemsAndEffects
        
        addChild(gemSprite)
        
        gemSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(currentGem) * TimeInterval.random(in: 0.03...0.05)),
            SKAction.fadeAlpha(to: startAlpha, duration: 0),
            SKAction.group([
                SKAction.fadeIn(withDuration: fadeDuration),
                SKAction.move(to: location, duration: fadeDuration),
                SKAction.scale(to: .zero, duration: fadeDuration)
            ]),
            SKAction.removeFromParent()
        ])) {
            if currentGem >= maxGems {
                completion()
            }
        }
        
        
        //Important Logic
        let gemIncrement = 1
        
        if didTapGate {
            gemsFed += gemIncrement
        }
        
        //Recursion call
        animateFeedGems(at: location, didTapGate: didTapGate, currentGem: currentGem + gemIncrement, maxGems: maxGems, completion: completion)
    }
    
    /**
     Animates a rainbow cycle of color blend factors.
     - parameters:
        - lightenColorFactor: lighten the color if needed
        - cycleSpeed: the speed at which the rainbow colors cycle
        - delay: add a delay before starting the rainbow cycle
     - returns: the SKAction
     */
    private func animateRainbowCycle(cycleSpeed: TimeInterval, delay: TimeInterval?) -> SKAction {
        return SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.repeatForever(SKAction.colorizeWithRainbowColorSequence(duration: cycleSpeed))
        ])
    }
    
    /**
     Animates a color cycle.
     - parameters:
        - color: the color of choice to animate a cycle
        - shouldFlicker: adds a creepy flicker to the sprite
        - delay: add a delay before starting the rainbow cycle
     - returns: the SKAction
     */
    private func animateColorCycle(color: UIColor, shouldFlicker: Bool, delay: TimeInterval?) -> SKAction {
        let blackColorBlendFactor: CGFloat = 0.94
        let flickerFade: TimeInterval = 0.1
        let flickerDuration: TimeInterval = 1
        
        let flickerAction: SKAction = SKAction.repeat(SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0),
            SKAction.colorize(with: .black, colorBlendFactor: blackColorBlendFactor, duration: flickerFade),
        ]), count: Int(flickerDuration * 10))

        return SKAction.repeatForever(SKAction.sequence([
            SKAction.colorize(with: .black, colorBlendFactor: blackColorBlendFactor, duration: 0),
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.colorize(with: color, colorBlendFactor: 1, duration: 1),
            SKAction.wait(forDuration: 0.65 - (delay ?? 0)),
            SKAction.colorize(with: .black, colorBlendFactor: blackColorBlendFactor, duration: 0.35),
            SKAction.wait(forDuration: 2 - flickerDuration),
            shouldFlicker ? flickerAction : SKAction.wait(forDuration: flickerDuration)
        ]))
    }
    
    private func zoomMagmoorHelper(scaleBy: CGFloat, fadeDuration: TimeInterval) -> SKAction {
        let totalFade: TimeInterval = fadeDuration * 24
        let spiralFactor: CGFloat = 4
        var time: CGFloat = 0
        
        func spiralMagmoorAction() -> SKAction {
            let action = SKAction.customAction(withDuration: totalFade) { [weak self] node, _ in
                guard let self = self else { return }
                
                time += 0.01 * spiralFactor
                
                let r = time / spiralFactor
                let x = size.width / 2 + r * cos(time)
                let y = size.height * (3/5) + r * sin(time)
                
                node.position = CGPoint(x: x, y: y)
            }
            
            return action
        }
        
        return SKAction.sequence([
            SKAction.group([
                spiralMagmoorAction(),
                SKAction.scale(by: scaleBy, duration: totalFade)
            ]),
            SKAction.move(to: CGPoint(x: size.width / 2, y: size.height * 3/5), duration: 3)
        ])
    }
    
    private func fadeInMagmoorHelper(fadeDuration: TimeInterval) -> SKAction {
        return SKAction.fadeIn(withDuration: fadeDuration * 4)
    }
    
    private func flashMagmoorHelper() {
        let baselineAlpha = magmoorSprite.alpha
        let baselineScale: CGFloat = magmoorSprite.xScale
        let scaleBy: CGFloat = 1.5
        let zoomFadeDuration: TimeInterval = 1
        let flashPauseDuration: TimeInterval = getFlashSequence(shouldFlash: false).duration
        
        func getFlashSequence(shouldFlash: Bool) -> (action: SKAction, duration: TimeInterval) {
            let count: Int = 12
            let waitDuration: TimeInterval = 0.01
            let fadeOutDuration: TimeInterval = 0.5
            
            let flashSequence = SKAction.sequence([
                SKAction.scale(to: baselineScale * 1.1, duration: 0),
                SKAction.repeat(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0),
                    SKAction.wait(forDuration: waitDuration),
                    SKAction.fadeAlpha(to: shouldFlash ? baselineAlpha : 0, duration: 0),
                    SKAction.wait(forDuration: waitDuration)
                ]), count: count),
                SKAction.group([
                    SKAction.scale(to: baselineScale, duration: fadeOutDuration),
                    SKAction.fadeAlpha(to: shouldFlash ? 0 : baselineAlpha, duration: fadeOutDuration)
                ])
            ])
            
            let duration: TimeInterval = TimeInterval(count) * (2 * waitDuration) + fadeOutDuration
            
            return (flashSequence, duration)
        }
        
        magmoorSprite.removeAction(forKey: CatwalkScene.keyMagmoorZoomAction)
        magmoorFlashSprite.removeAction(forKey: CatwalkScene.keyMagmoorFlashZoomAction)
        
        
        //magmoorSprite
        magmoorSprite.run(getFlashSequence(shouldFlash: false).action)
        
        magmoorSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: flashPauseDuration),
            zoomMagmoorHelper(scaleBy: scaleBy, fadeDuration: zoomFadeDuration)
        ]), withKey: CatwalkScene.keyMagmoorZoomAction)
        
        magmoorSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: flashPauseDuration),
            fadeInMagmoorHelper(fadeDuration: zoomFadeDuration)
        ]), withKey: CatwalkScene.keyMagmoorFadeAction)
        
        
        //magmoorFlashSprite
        magmoorFlashSprite.run(getFlashSequence(shouldFlash: true).action)
        
        magmoorFlashSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: flashPauseDuration),
            zoomMagmoorHelper(scaleBy: scaleBy, fadeDuration: zoomFadeDuration)
        ]), withKey: CatwalkScene.keyMagmoorFlashZoomAction)
        
        
        //tiles and heroes red cycle
        let delaySpeed: TimeInterval = 0.1
        
        for (i, panel) in catwalkPanels.enumerated() {
            panel.removeAction(forKey: CatwalkScene.keyRainbowCycleAction)
            panel.run(animateColorCycle(color: .red, shouldFlicker: panel == catwalkPanels.last, delay: TimeInterval(catwalkLength - i) * delaySpeed))
        }
        
        catwalkNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0),
            SKAction.wait(forDuration: flashPauseDuration),
            SKAction.fadeIn(withDuration: 0.1)
        ]))
        
        elder0.sprite.removeAction(forKey: CatwalkScene.keyRainbowCycleAction)
        elder1.sprite.removeAction(forKey: CatwalkScene.keyRainbowCycleAction)
        elder2.sprite.removeAction(forKey: CatwalkScene.keyRainbowCycleAction)
        hero.sprite.removeAction(forKey: CatwalkScene.keyRainbowCycleAction)
        
        elder0.sprite.run(animateColorCycle(color: .red, shouldFlicker: true, delay: 4 * delaySpeed))
        elder1.sprite.run(animateColorCycle(color: .red, shouldFlicker: true, delay: 5 * delaySpeed))
        elder2.sprite.run(animateColorCycle(color: .red, shouldFlicker: true, delay: 5.5 * delaySpeed))
        hero.sprite.run(animateColorCycle(color: .red, shouldFlicker: true, delay: 3 * delaySpeed))
        
        
        //audio et al.
        AudioManager.shared.playSound(for: "magichorrorimpact")
        AudioManager.shared.playSound(for: "magmoorcreepypulse")
        AudioManager.shared.playSound(for: "magmoorcreepystrings")
        Haptics.shared.executeCustomPattern(pattern: .horrorimpact)
    }
    
    private func flashRedHelper(message: String, secondaryMessages: [String], completion: @escaping () -> Void) {
        guard !isRedShift else { return }
        
        let fadeDuration: TimeInterval = 1
        let colorizeRed = SKAction.colorize(with: FireIceTheme.overlayColor, colorBlendFactor: 1, duration: 0)
        let colorizeNone = SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration)
        let colorizeSequence = SKAction.sequence([colorizeRed, SKAction.wait(forDuration: fadeDuration), colorizeNone])
        
        inbetweenNode.run(SKAction.fadeOut(withDuration: 0))
        bloodOverlay.run(SKAction.fadeOut(withDuration: 0))
        backgroundNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0),
            SKAction.wait(forDuration: fadeDuration),
            SKAction.run { [weak self] in
                self?.updateBackgroundNode(fadeDuration: fadeDuration, completion: nil)
            }
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
        messageNode.setScale(1.5)
        messageNode.addDropShadow()
        messageNode.zPosition = 5
        
        let messageSecondNode = SKLabelNode(text: message)
        messageSecondNode.position = messageNode.position
        messageSecondNode.fontName = messageNode.fontName
        messageSecondNode.fontColor = UIFont.chatFontColor
        messageSecondNode.fontSize = messageNode.fontSize
        messageSecondNode.setScale(2)
        messageSecondNode.alpha = 0.1
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
            SKAction.run {
                AudioManager.shared.adjustVolume(to: 1, for: CatwalkScene.catwalkOverworld, fadeDuration: fadeDuration * 2)
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
            
            messageTertiaryNode.fontName = messageNode.fontName
            messageTertiaryNode.fontColor = UIFont.chatFontColor
            messageTertiaryNode.fontSize = messageNode.fontSize
            messageTertiaryNode.setScale(CGFloat.random(in: 1...4))
            messageTertiaryNode.xScale *= Int.random(in: 0...4) == 0 ? -1 : 1
            messageTertiaryNode.alpha = CGFloat.random(in: 0.06...0.08)
            messageTertiaryNode.zRotation = rotation
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
        
        AudioManager.shared.adjustVolume(to: 0.1, for: CatwalkScene.catwalkOverworld)
        AudioManager.shared.playSoundThenStop(for: "magicheartbeatloop1", playForDuration: fadeDuration)
        Haptics.shared.executeCustomPattern(pattern: .heartbeat)
    }
    
    private func shiftRedHelper(shouldShift: Bool, fasterHeartbeat: Bool, fadeDuration: TimeInterval) {
        if shouldShift {
            let colorizeRed = SKAction.colorize(with: FireIceTheme.overlayColor, colorBlendFactor: 1, duration: fadeDuration)
            isRedShift = true
            
            backgroundNode.run(SKAction.fadeOut(withDuration: fadeDuration))
            inbetweenNode.run(SKAction.fadeOut(withDuration: fadeDuration))
            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
            hero.sprite.run(colorizeRed)
            elder0.sprite.run(colorizeRed)
            elder1.sprite.run(colorizeRed)
            elder2.sprite.run(colorizeRed)
            
            for catwalkPanel in catwalkPanels {
                catwalkPanel.removeAllActions()
                catwalkPanel.run(colorizeRed)
            }
            
            AudioManager.shared.playSound(for: "magicheartbeatloop\(fasterHeartbeat ? 2 : 1)", interruptPlayback: false)
            AudioManager.shared.adjustVolume(to: 0.1, for: CatwalkScene.catwalkOverworld)
        }
        else {
            let colorizeNone = SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration)
            
            hero.sprite.run(colorizeNone) { [weak self] in
                guard let self = self else { return }
                
                updateBackgroundNode(fadeDuration: fadeDuration) { [weak self] in
                    self?.isRedShift = false
                }
                
                AudioManager.shared.adjustVolume(to: 1, for: CatwalkScene.catwalkOverworld, fadeDuration: fadeDuration * 2)
            }
            
            elder0.sprite.run(colorizeNone)
            elder1.sprite.run(colorizeNone)
            elder2.sprite.run(colorizeNone)
            
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
