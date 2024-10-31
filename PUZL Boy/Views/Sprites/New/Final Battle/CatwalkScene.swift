//
//  CatwalkScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/8/24.
//

import SpriteKit

class CatwalkScene: SKScene {
    
    // MARK: - Properties
    
    private let panelCount: Int = 5
    private let catwalkLength: Int = 20
    private let panelSpacing: CGFloat = 4
    private var panelSize: CGFloat { size.width / CGFloat(panelCount) }
    private var scaleSize: CGSize { CGSize.zero + panelSize - panelSpacing }
    
    private let catwalkPanelNameDelimiter: Character = "_"
    private var catwalkPanelNamePrefix: String { "catwalkPanel\(catwalkPanelNameDelimiter)" }
    private var currentPanelIndex: Int = 0
    private var isMoving: Bool = false
    private var shouldDisableInput: Bool = false
    private var isRedShift: Bool = false
    
    private var hero: Player!
    private var elder0: Player!
    private var elder1: Player!
    private var elder2: Player!
    private var magmoorSprite: SKSpriteNode!
    private var backgroundNode: SKSpriteNode!
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
        print("FinalGameboard deinit")
    }
    
    func cleanupScene() {
        currentPanelIndex = 0
        isMoving = false
        shouldDisableInput = false
        isRedShift = false

        catwalkPanels.forEach { $0.removeFromParent() }
        hero.sprite.removeFromParent()
        magmoorSprite.removeFromParent()
        catwalkNode.removeFromParent()
        backgroundNode.removeFromParent()
        removeFromParent()
        
        chatEngine = nil
    }
    
    private func setupNodes() {
        backgroundColor = .black
        
        backgroundNode = SKSpriteNode(texture: SKTexture(image: DayTheme.getSkyImage()))
        backgroundNode.size = size
        backgroundNode.anchorPoint = .zero
        
        catwalkNode = SKShapeNode(rectOf: CGSize(width: CGFloat(catwalkLength + 1) * panelSize + panelSpacing,
                                                 height: panelSize + 2 * panelSpacing))
        catwalkNode.position = CGPoint(x: catwalkNode.frame.size.width / 2, y: size.height / 2)
        catwalkNode.fillColor = GameboardSprite.gameboardColor
        catwalkNode.lineWidth = 0
        catwalkNode.zPosition = 5
        
        hero = Player(type: .hero)
        hero.sprite.position = CGPoint(x: -catwalkNode.frame.size.width / 2 + scaleSize.width / 2, y: 0)
        hero.sprite.setScale(Player.getGameboardScale(panelSize: panelSize))
        hero.sprite.zPosition = K.ZPosition.player + 1
        hero.sprite.run(animatePlayer(player: hero, type: .idle))
        
        elder0 = Player(type: .elder0)
        elder0.sprite.zPosition = K.ZPosition.player + 4
        
        elder1 = Player(type: .elder1)
        elder1.sprite.zPosition = K.ZPosition.player + 3
        
        elder2 = Player(type: .elder2)
        elder2.sprite.zPosition = K.ZPosition.player + 2
        
        magmoorSprite = SKSpriteNode(imageNamed: "villainRedEyes")
        magmoorSprite.size = CGSize(width: size.width, height: size.width)
        magmoorSprite.position = CGPoint(x: size.width / 2, y: size.height * 3/5)
        magmoorSprite.alpha = 0
        magmoorSprite.zPosition = 2
        
        for i in 0...catwalkLength {
            let image: String = i == 0 ? "start" : (i == catwalkLength ? "endOpen" : "partytile")
            
            let catwalkPanel = SKSpriteNode(imageNamed: image)
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
        addChild(magmoorSprite)
        addChild(catwalkNode)
        catwalkNode.addChild(hero.sprite)
        catwalkNode.addChild(elder0.sprite)
        catwalkNode.addChild(elder1.sprite)
        catwalkNode.addChild(elder2.sprite)
        
        for catwalkPanel in catwalkPanels {
            catwalkNode.addChild(catwalkPanel)
        }
        
        chatEngine.moveSprites(to: self)
        playDialogue(panelIndex: currentPanelIndex)
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
        
        let moveDuration: TimeInterval = isRedShift ? 2 : 1
        let moveFactor: CGFloat = panelIndex > currentPanelIndex ? 1 : -1
        let moveDistance: CGFloat = moveFactor * (scaleSize.width + panelSpacing)
        let runSound = "movetile\(Int.random(in: 1...3))"
        
        currentPanelIndex += Int(moveFactor)
        isMoving = true
        
        hero.sprite.run(animatePlayer(player: hero, type: .run))
        hero.sprite.xScale = moveFactor * abs(hero.sprite.xScale)
        hero.sprite.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)) { [weak self] in
            guard let self = self else { return }
            
            hero.sprite.run(animatePlayer(player: hero, type: .idle))
            isMoving = false

            playDialogue(panelIndex: currentPanelIndex)
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
        }
        
        if (moveFactor > 0 && (currentPanelIndex > 2 && currentPanelIndex <= catwalkLength - 2)) ||
            (moveFactor < 0 && (currentPanelIndex >= 2 && currentPanelIndex < catwalkLength - 2)) {
            catwalkNode.run(SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration))
        }
        
        
        
        
        // FIXME: - Testing of Red Shift Feature
        if currentPanelIndex == 4 {
            shiftRed(shouldShift: true, fadeDuration: moveDuration)
        }
        else if currentPanelIndex == 8 {
            shiftRed(shouldShift: false, fadeDuration: moveDuration)
        }
        
        
        
        
        //MUST put this at the end!
        if !isRedShift {
            updateBackgroundNode(fadeDuration: moveDuration, completion: nil)
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
            default:        timePerFrame = 0.06
            }
        case .run:
            timePerFrame = 0.04
        default:
            timePerFrame = 0.04
        }
        
        timePerFrame *= isRedShift ? 2 : 1
        
        return SKAction.repeatForever(SKAction.animate(with: player.textures[type.rawValue], timePerFrame: timePerFrame))
    }
    
    private func playDialogue(panelIndex: Int) {
        let dialogueNumber = -1000 - panelIndex
        
        shouldDisableInput = true
        
        chatEngine.playDialogue(level: dialogueNumber) { [weak self] _ in
            self?.shouldDisableInput = false
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
    
    private func shiftRed(shouldShift: Bool, fadeDuration: TimeInterval) {
        if shouldShift {
            let colorizeRed = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: fadeDuration)
            isRedShift = true
            
            backgroundNode.run(SKAction.fadeOut(withDuration: fadeDuration))
            magmoorSprite.run(SKAction.sequence([
                SKAction.wait(forDuration: fadeDuration),
                SKAction.group([
                    SKAction.fadeIn(withDuration: fadeDuration),
                    SKAction.scale(to: 2, duration: fadeDuration * 20)
                ])
            ]))
            hero.sprite.run(colorizeRed)
            
            for catwalkPanel in catwalkPanels {
                catwalkPanel.removeAllActions()
                catwalkPanel.run(colorizeRed)
            }
            
            if !AudioManager.shared.isPlaying(audioKey: "magicheartbeatloop1") {
                AudioManager.shared.playSound(for: "magicheartbeatloop1")
            }
        }
        else {
            let colorizeNone = SKAction.colorize(withColorBlendFactor: 0, duration: fadeDuration)
            
            magmoorSprite.run(SKAction.fadeOut(withDuration: fadeDuration)) { [weak self] in
                self?.updateBackgroundNode(fadeDuration: fadeDuration) {
                    self?.isRedShift = false
                }
            }
            hero.sprite.run(colorizeNone)
            
            for catwalkPanel in catwalkPanels {
                catwalkPanel.removeAllActions()
                catwalkPanel.run(colorizeNone)
            }

            shimmerPartyTiles()
            AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: fadeDuration)
        }
    }
    
    
}


// MARK: - ChatEngineDelegate UNUSED

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
    
    func spawnElders() {
        hero.sprite.xScale = abs(hero.sprite.xScale)
        
        spawnElderHelper(elder: elder0, offset: CGPoint(x: 200, y: 0))
        spawnElderHelper(elder: elder1, offset: CGPoint(x: 350, y: 100))
        spawnElderHelper(elder: elder2, offset: CGPoint(x: 350, y: -100))
    }
    
    func despawnElders() {
        despawnElderHelper(elder: elder0)
        despawnElderHelper(elder: elder1)
        despawnElderHelper(elder: elder2)
    }
    
    private func spawnElderHelper(elder: Player, offset: CGPoint) {
        let appearDuration: TimeInterval = 0.5
        let elderScale: CGFloat = Player.getGameboardScale(panelSize: panelSize) * elder.scaleMultiplier
        
        //Preliminarty setup, first...
        elder.sprite.position = hero.sprite.position + CGPoint(x: 0, y: 20)
        elder.sprite.setScale(0)
        elder.sprite.run(animatePlayer(player: elder, type: .idle))

        elder.sprite.run(SKAction.group([
            SKAction.scale(to: elderScale, duration: appearDuration),
            SKAction.scaleX(to: -elderScale, duration: appearDuration),
            SKAction.rotate(byAngle: -2 * .pi, duration: appearDuration),
            SKAction.moveBy(x: offset.x, y: offset.y, duration: appearDuration)
        ]))
    }
    
    private func despawnElderHelper(elder: Player) {
        let disappearDuration: TimeInterval = 0.5
        
        elder.sprite.run(SKAction.group([
            SKAction.scale(to: 0, duration: disappearDuration),
            SKAction.rotate(byAngle: 2 * .pi, duration: disappearDuration),
            SKAction.move(to: hero.sprite.position, duration: disappearDuration)
        ]))
    }
    
    
}
