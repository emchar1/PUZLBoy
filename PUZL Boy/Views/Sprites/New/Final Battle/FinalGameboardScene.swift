//
//  FinalGameboardScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/8/24.
//

import SpriteKit

class FinalGameboardScene: SKScene {
    
    // MARK: - Properties
    
    private let panelCount: Int = 5
    private let catwalkLength: Int = 20
    private let panelSpacing: CGFloat = 4
    private var panelSize: CGFloat { size.width / CGFloat(panelCount) }
    private var scaleSize: CGSize { CGSize.zero + panelSize - panelSpacing }

    private let catwalkPanelDelimiter: Character = "_"
    private var catwalkPanelNamePrefix: String { "catwalkPanel\(catwalkPanelDelimiter)" }
    private var currentPanel: Int = 0
    private var isMoving: Bool = false
    
    private var catwalkNode: SKShapeNode!
    private var gameboardNode: SKShapeNode!
    private var terrainPanels: [[SKSpriteNode]] = []
    private var overlayPanels: [[SKSpriteNode]] = []
    private var catwalkPanels: [SKSpriteNode] = []
    
    private var hero: Player!
    private var villain: Player!
    
    
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
        
        //Setup Players
        
        hero = Player(type: .hero)
        hero.sprite.position = CGPoint(x: scaleSize.width / 2, y: 0)
        hero.sprite.setScale(Player.getGameboardScale(panelSize: panelSize))
        hero.sprite.zPosition = K.ZPosition.player + 1
        hero.sprite.run(animatePlayer(player: hero, type: .idle))
        
        villain = Player(type: .villain)
        villain.sprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        villain.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * 1.25)
        villain.sprite.xScale *= -1
        villain.sprite.zPosition = K.ZPosition.player
        villain.sprite.run(animatePlayer(player: villain, type: .idle))
        
        
        //Setup Catwalk
        
        catwalkNode = SKShapeNode(rectOf: CGSize(width: CGFloat(catwalkLength + 1) * panelSize + panelSpacing * CGFloat(catwalkLength),
                                                 height: panelSize + 2 * panelSpacing))
        catwalkNode.position = CGPoint(x: 0, y: size.height / 2)
        catwalkNode.fillColor = GameboardSprite.gameboardColor
        catwalkNode.lineWidth = 0
        catwalkNode.zPosition = 5
        
        for i in 0...catwalkLength {
            let image: String = i == 0 ? "start" : (FireIceTheme.isFire ? "sand" : "snow")
            
            let catwalkPanel = SKSpriteNode(imageNamed: image)
            catwalkPanel.scale(to: scaleSize)
            catwalkPanel.position = CGPoint(x: catwalkPanel.size.width * CGFloat(i) + panelSpacing * CGFloat(i + 1),
                                            y: -catwalkPanel.size.height / 2)
            catwalkPanel.anchorPoint = .zero
            catwalkPanel.zPosition = K.ZPosition.terrain
            catwalkPanel.name = catwalkPanelNamePrefix + "\(i)"
            
            catwalkPanels.append(catwalkPanel)
        }
    }
    
    
    // MARK: - Main Functions
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(catwalkNode)
        catwalkNode.addChild(hero.sprite)
//        addChild(villain.sprite)
        
        for catwalkPanel in catwalkPanels {
            catwalkNode.addChild(catwalkPanel)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        nodes(at: location).forEach { node in
            guard let name = node.name else { return }
                        
            moveHero(to: name)
            print("panel: \(name), index: \(getPanelIndex(for: name) ?? -1), currentPanel: \(currentPanel)")
        }
        
        
    }
    
    
    // MARK: - Helper Functions
    
    private func moveHero(to panelName: String) {
        guard !isMoving else { return }
        guard let panelIndex = getPanelIndex(for: panelName), panelIndex > currentPanel else { return }
        
        let moveDuration: TimeInterval = 1
        let runSound = currentPanel == 0 ? "movetile\(Int.random(in: 1...3))" : FireIceTheme.soundMovementSandSnow
        currentPanel += 1
        isMoving = true
        
        hero.sprite.run(animatePlayer(player: hero, type: .run))
        hero.sprite.run(SKAction.moveBy(x: scaleSize.width + panelSpacing, y: 0, duration: moveDuration)) { [unowned self] in
            hero.sprite.run(animatePlayer(player: hero, type: .idle))
            isMoving = false
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
        }
        
        if currentPanel > 2 {
            catwalkNode.run(SKAction.moveBy(x: -scaleSize.width - panelSpacing, y: 0, duration: moveDuration))
        }
        
        AudioManager.shared.playSound(for: runSound)
    }
    
    private func getPanelIndex(for panelName: String) -> Int? {
        return Int(String(panelName.suffix(from: panelName.firstIndex(of: catwalkPanelDelimiter)!).dropFirst()))
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
    
    
    
}
