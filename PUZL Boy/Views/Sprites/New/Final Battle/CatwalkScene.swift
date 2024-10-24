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
    
    private var hero: Player!
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
            
            if i > 0 && i < catwalkLength {
                catwalkPanel.animatePartyTileShimmer(gameboardColor: GameboardSprite.gameboardColor)
            }
            
            catwalkPanels.append(catwalkPanel)
        }
        
        chatEngine = ChatEngine()
        chatEngine.delegate = self
    }
    
    
    // MARK: - Main Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(backgroundNode)
        addChild(catwalkNode)
        catwalkNode.addChild(hero.sprite)
        
        for catwalkPanel in catwalkPanels {
            catwalkNode.addChild(catwalkPanel)
        }
        
        chatEngine.moveSprites(to: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        chatEngine.touchDown(in: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        nodes(at: location).forEach { node in
            guard let name = node.name else { return }
                        
            moveHero(to: name)
        }
        
        chatEngine.didTapButton(in: location)
        chatEngine.touchUp()
    }
    
    
    // MARK: - Helper Functions
    
    private func moveHero(to panelName: String) {
        guard !isMoving else { return }
        guard !shouldDisableInput else { return }
        guard let panelIndex = getPanelIndex(for: panelName), currentPanelIndex != panelIndex else { return }
        
        let moveDuration: TimeInterval = 1
        let moveFactor: CGFloat = panelIndex > currentPanelIndex ? 1 : -1
        let moveDistance: CGFloat = moveFactor * (scaleSize.width + panelSpacing)
        let runSound = "movetile\(Int.random(in: 1...3))"
        
        currentPanelIndex += Int(moveFactor)
        isMoving = true
        
        
        
        // TODO: - ChatEngine
        playDialogue(panelIndex: currentPanelIndex)
        
        
        
        
        hero.sprite.run(animatePlayer(player: hero, type: .run))
        hero.sprite.xScale = moveFactor * abs(hero.sprite.xScale)
        hero.sprite.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)) { [unowned self] in
            hero.sprite.run(animatePlayer(player: hero, type: .idle))
            isMoving = false
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
        }
        
        if (moveFactor > 0 && (currentPanelIndex > 2 && currentPanelIndex <= catwalkLength - 2)) ||
            (moveFactor < 0 && (currentPanelIndex >= 2 && currentPanelIndex < catwalkLength - 2)) {
            catwalkNode.run(SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration))
        }
        
        backgroundNode.run(SKAction.fadeAlpha(to: 1 - CGFloat(currentPanelIndex) / CGFloat(catwalkLength), duration: moveDuration + 0.25))
        
        AudioManager.shared.playSound(for: runSound)
    }
    
    private func getPanelIndex(for panelName: String) -> Int? {
        guard panelName.contains(catwalkPanelNameDelimiter) else { return nil }
        
        return Int(String(panelName.suffix(from: panelName.firstIndex(of: catwalkPanelNameDelimiter)!).dropFirst()))
    }
    
    private func animatePlayer(player: Player, type: Player.Texture) -> SKAction {
        var timePerFrame: TimeInterval
        
        switch type {
        case .idle:     timePerFrame = 0.06
        case .run:      timePerFrame = 0.04
        default:        timePerFrame = 0.04
        }
        
        timePerFrame = player.type == .villain ? timePerFrame * 4/3 : timePerFrame
        
        return SKAction.repeatForever(SKAction.animate(with: player.textures[type.rawValue], timePerFrame: timePerFrame))
    }
    
    private func playDialogue(panelIndex: Int) {
        let dialogueNumber = -1000 - panelIndex
        
        shouldDisableInput = true
        
        chatEngine.playDialogue(level: dialogueNumber) { [unowned self] _ in
            shouldDisableInput = false
        }
    }
    
}


// MARK: - ChatEngineDelegate

// TODO: - ChatEngine Delegate - I hate that I don't use any of these functions, but I gotta include them...
extension CatwalkScene: ChatEngineDelegate {
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {
        //needs implementation?
    }
    
    func deilluminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {
        //needs implementation?
    }
    
    func illuminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName) {
        //needs implementation?
    }
    
    func deilluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName) {
        //needs implementation?
    }
    
    func illuminateMinorButton(for button: PauseResetEngine.MinorButton) {
        //needs implementation?
    }
    
    func deilluminateMinorButton(for button: PauseResetEngine.MinorButton) {
        //needs implementation?
    }
    
    func spawnTrainer(at position: K.GameboardPosition, to direction: Controls) {
        //needs implementation?
    }
    
    func despawnTrainer(to position: K.GameboardPosition) {
        //needs implementation?
    }
    
    func spawnTrainerWithExit(at position: K.GameboardPosition, to direction: Controls) {
        //needs implementation?
    }
    
    func despawnTrainerWithExit(moves: [K.GameboardPosition]) {
        //needs implementation?
    }
    
    func spawnPrincessCapture(at position: K.GameboardPosition, shouldAnimateWarp: Bool, completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func flashPrincess(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func inbetweenRealmEnter(levelInt: Int, mergeHalfway: Bool, moves: [K.GameboardPosition]) {
        //needs implementation?
    }
    
    func inbetweenRealmExit(persistPresence: Bool, completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func inbetweenFlashPlayer(playerType: Player.PlayerType, position: K.GameboardPosition, persistPresence: Bool) {
        //needs implementation?
    }
    
    func empowerPrincess(powerDisplayDuration: TimeInterval) {
        //needs implementation?
    }
    
    func encagePrincess() {
        //needs implementation?
    }
    
    func peekMinion(at position: K.GameboardPosition, duration: TimeInterval, completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func spawnDaemon(at position: K.GameboardPosition) {
        //needs implementation?
    }
    
    func spawnMagmoorMinion(at position: K.GameboardPosition, chatDelay: TimeInterval) {
        //needs implementation?
    }
    
    func despawnMagmoorMinion(at position: K.GameboardPosition, fadeDuration: TimeInterval) {
        //needs implementation?
    }
    
    func minionAttack(duration: TimeInterval, completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func spawnElder(minionPosition: K.GameboardPosition, positions: [K.GameboardPosition], completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func despawnElders(to position: K.GameboardPosition, completion: @escaping () -> Void) {
        //needs implementation?
    }
    
    func getGift(lives: Int) {
        //needs implementation?
    }
    
    
}
