//
//  FinalBattle2Engine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/15/24.
//

import SpriteKit

class FinalBattle2Engine {
    
    // MARK: - Properties
    
    private let size: CGSize
    private let maxCount: Int = 1000
    private let ignorePositions: [K.GameboardPosition] = [(3, 3), (6, 3)]
    private let startPosition: K.GameboardPosition = (6, 3)
    private let endPosition: K.GameboardPosition = (3, 3)
    private var heroPosition: K.GameboardPosition!
    private var villainPosition: K.GameboardPosition!
    
    private var spawnPanels0: [K.GameboardPosition] = []
    private var spawnPanels1: [K.GameboardPosition] = []
    private var spawnPanels2: [K.GameboardPosition] = []
        
    private var superScene: SKScene?
    private var flashBackgroundSprite: SKSpriteNode!
    private var gameboard: GameboardSprite!
    private var hero: Player!
    private var villain: Player!
    private var controls: FinalBattle2Controls!
    
    private var heroHealthTimer: Timer?
    private var heroHealthDrainTimer: Timer?            //a separate timer is needed for the drain health function
    private var heroHealthBar: StatusBarSprite!
    private var heroHealthCounter: Counter!
    enum HeroHealthType {
        case drain, regen, lavaHit
    }
    
    
    // MARK: - Initialization
    
    init(size: CGSize) {
        self.size = size
        
        setupScene()
    }
    
    deinit {
        print("FinalBattle2Engine deinit")
    }
    
    private func setupScene() {
        heroPosition = startPosition
        villainPosition = endPosition
        gameboard = GameboardSprite(level: LevelBuilder.levels[Level.finalLevel + 1], fadeIn: false)
        
        //Make sure to initialize GameboardSprite BEFORE initializing these!!!
        let playerScale: CGFloat = Player.getGameboardScale(panelSize: size.width / CGFloat(gameboard.panelCount))
        
        flashBackgroundSprite = SKSpriteNode(color: .white, size: gameboard.sprite.size)
        flashBackgroundSprite.setScale(1 / gameboard.sprite.xScale)
        flashBackgroundSprite.anchorPoint = .zero
        flashBackgroundSprite.alpha = 0
        flashBackgroundSprite.zPosition = K.ZPosition.bloodOverlay
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboard.getLocation(at: heroPosition)
        hero.sprite.setScale(playerScale * hero.scaleMultiplier)
        hero.sprite.color = FireIceTheme.isFire ? .red : .blue
        hero.sprite.colorBlendFactor = 0
        hero.sprite.zPosition = K.ZPosition.player
        
        villain = Player(type: .villain)
        villain.sprite.position = gameboard.getLocation(at: villainPosition) + CGPoint(x: 0, y: 25)
        villain.sprite.setScale(playerScale * villain.scaleMultiplier)
        villain.sprite.xScale *= -1
        villain.sprite.zPosition = K.ZPosition.player + 2
        
        //Initialize after gameboard, hero and heroPosition!
        controls = FinalBattle2Controls(gameboard: gameboard, player: hero, playerPosition: heroPosition)
        
        heroHealthTimer = Timer()
        heroHealthDrainTimer = Timer()
        heroHealthBar = StatusBarSprite(label: "Determination", shouldHide: true, position: CGPoint(x: size.width / 2, y: K.ScreenDimensions.topOfGameboard + StatusBarSprite.defaultBarHeight + 16))
        heroHealthCounter = Counter(maxCount: 1, step: 0.01, shouldLoop: false)
        heroHealthCounter.setCount(to: 1)
        
        populateSpawnPanels(spawnPanels: &spawnPanels0, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels1, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels2, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene
        
        superScene.addChild(gameboard.sprite)
        gameboard.sprite.addChild(flashBackgroundSprite)
        gameboard.sprite.addChild(hero.sprite)
        gameboard.sprite.addChild(villain.sprite)
        
        heroHealthBar.addToParent(superScene)
    }
    
    
    // MARK: - Functions
    
    func handleControls(in location: CGPoint) {
        controls.handleControls(in: location, playerPosition: &heroPosition) { [weak self] in 
            guard let self = self else { return }
            
            if safePanelFound(in: location) {
                updateHealth(type: .regen)
            }
            else {
                updateHealth(type: .lavaHit)
                updateHealth(type: .drain)
            }
        }
    }
    
    /**
     Checks if the location requested to move to is a valid one, i.e. a "safePanel" or the startPanel.
     - parameter location: location of the request
     - returns: true if requested panel is a valid one
     */
    private func safePanelFound(in location: CGPoint) -> Bool {
        guard let superScene = superScene else {
            print("superScene nil in FinalBattle2Engine.safePanelFound()")
            return false
        }
        
        let startPanel = GameboardSprite.getNodeName(row: startPosition.row, col: startPosition.col)
        
        return superScene.nodes(at: location).contains(where: { $0.name == "safePanel" || $0.name == startPanel })
    }
    
    ///Animates all the components
    func animateSprites() {
        hero.sprite.run(Player.animate(player: hero, type: .idle))
        villain.sprite.run(Player.animateIdleLevitate(player: villain))
        
        heroHealthBar.showStatus()
        
        let terrainPanel: LevelType = FireIceTheme.isFire ? .sand : .snow
        
        animateSpawnPanels(spawnPanels: spawnPanels0, with: terrainPanel)
        animateSpawnPanels(spawnPanels: spawnPanels1, with: terrainPanel)
        animateSpawnPanels(spawnPanels: spawnPanels2, with: terrainPanel)
    }
    
    func flashHeroAttacked(duration: TimeInterval = 0.5) {
        flashBackgroundSprite.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0),
            SKAction.fadeOut(withDuration: duration)
        ]))
    }
    
    
    // MARK: - Health Bar Functions
    
    func updateHealth(type: HeroHealthType) {
        if hero.sprite.action(forKey: "heroBlink") != nil {
            hero.sprite.colorBlendFactor = 1
        }
        
        hero.sprite.removeAction(forKey: "heroBlink")
        hero.sprite.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.5), withKey: "heroColorFade")

        switch type {
        case .drain:
            heroHealthDrainTimer?.invalidate()
            heroHealthDrainTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                                        target: self,
                                                        selector: #selector(updateHealthHelperDrain(_:)),
                                                        userInfo: nil,
                                                        repeats: true)
            
            hero.sprite.removeAction(forKey: "heroColorFade")
            hero.sprite.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.05),
                SKAction.colorize(withColorBlendFactor: 1, duration: 0.05)
            ])), withKey: "heroBlink")
            
            AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
        case .regen:
            heroHealthDrainTimer?.invalidate()
            heroHealthDrainTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                                        target: self,
                                                        selector: #selector(updateHealthHelperRegen(_:)),
                                                        userInfo: nil,
                                                        repeats: true)
        case .lavaHit:
            heroHealthTimer = Timer.scheduledTimer(timeInterval: 0,
                                                   target: self,
                                                   selector: #selector(updateHealthHelperLavaHit(_:)),
                                                   userInfo: nil,
                                                   repeats: false)
        }
    }
    
    @objc private func updateHealthHelperDrain(_ sender: Any) {
        var heroHealthDepletionRate: TimeInterval {
            switch heroHealthCounter.getCount() {
            case let num where num > 0.5:   0.01
            default:                        0.005
            }
        }
        
        heroHealthCounter.decrement(by: heroHealthDepletionRate)
        heroHealthBar.animateAndUpdate(percentage: heroHealthCounter.getCount())
    }
    
    @objc private func updateHealthHelperRegen(_ sender: Any) {
        var heroHealthRegenerationRate: TimeInterval {
            switch heroHealthCounter.getCount() {
            case let num where num > 0.75:  0.005
            default:                        0.01
            }
        }
        
        heroHealthCounter.increment(by: heroHealthRegenerationRate)
        heroHealthBar.animateAndUpdate(percentage: heroHealthCounter.getCount())
    }
    
    @objc private func updateHealthHelperLavaHit(_ sender: Any) {
        var heroHealthLavaHit: TimeInterval {
            switch heroHealthCounter.getCount() {
            case let num where num > 0.5:   0.1
            default:                        0.05
            }
        }

        heroHealthCounter.decrement(by: heroHealthLavaHit)
        heroHealthBar.animateAndUpdate(percentage: heroHealthCounter.getCount())
    }
    
    
    // MARK: - Spawn Panels Functions
    
    private func populateSpawnPanels(spawnPanels: inout [K.GameboardPosition], startPosition: K.GameboardPosition, ignorePositions: [K.GameboardPosition] = [], count: Int = 0, maxCount: Int = 100) {
        
        //Base case
        guard count < maxCount else { return }
        
        let nextPosition = spawnNextPosition(startPosition: startPosition, ignorePositions: ignorePositions)
        spawnPanels.append(nextPosition)
        
        let spawnPanelsToIgnore = spawnPanels.count >= 2 ? Array(spawnPanels.suffix(2)) : []
        
        //Recursion!
        populateSpawnPanels(spawnPanels: &spawnPanels,
                            startPosition: nextPosition,
                            ignorePositions: self.ignorePositions + spawnPanelsToIgnore, //must be class var, ignorePositions
                            count: count + 1,
                            maxCount: maxCount)
    }
    
    private func spawnNextPosition(startPosition: K.GameboardPosition, ignorePositions: [K.GameboardPosition]) -> K.GameboardPosition {
        var nextPosition: K.GameboardPosition
        
        repeat {
            let spawnCol = Bool.random()
            let spawnOffset = Bool.random() ? -1 : 1
            
            nextPosition = (startPosition.row + (spawnCol ? 0 : spawnOffset), startPosition.col + (spawnCol ? spawnOffset : 0))
        } while nextPosition.row < 0 || nextPosition.row >= gameboard.panelCount || nextPosition.col < 0 || nextPosition.col >= gameboard.panelCount || ignorePositions.contains { $0.row == nextPosition.row && $0.col == nextPosition.col }
        
        return nextPosition
    }
    
    // TODO: - Make disappearing floors and harm hero if he steps in lava or ground beneath him disappears.
    private func animateSpawnPanels(spawnPanels: [K.GameboardPosition], with terrain: LevelType) {
        for (i, spawnPanel) in spawnPanels.enumerated() {
            guard let originalTerrain = gameboard.getPanelSprite(at: spawnPanel).terrain else { continue }
            
            let waitDuration: TimeInterval = 0.8
            
            let newTerrain = SKSpriteNode(imageNamed: terrain.description)
            let dissolveTerrain = FireIceTheme.isFire ? SKAction.sequence([
                SKAction.moveBy(x: 5, y: 0, duration: 0.1),
                SKAction.group([
                    SKAction.repeat(SKAction.sequence([
                        SKAction.moveBy(x: -10, y: 0, duration: 0.1),
                        SKAction.moveBy(x: 10, y: 0, duration: 0.1)
                    ]), count: Int(waitDuration / (2 * 0.1))),
                    SKAction.fadeOut(withDuration: waitDuration)
                ])
            ]) : SKAction.sequence([
                SKAction.repeat(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0, duration: 0.08),
                    SKAction.fadeAlpha(to: 1, duration: 0.08)
                ]), count: Int(waitDuration / (2 * 0.08))),
                SKAction.fadeOut(withDuration: 0.1)
            ])
            
            newTerrain.anchorPoint = .zero
            newTerrain.alpha = 0
            newTerrain.zPosition = 1
            newTerrain.name = "safePanel"
            
            originalTerrain.addChild(newTerrain)
            
            newTerrain.run(SKAction.sequence([
                SKAction.wait(forDuration: waitDuration * TimeInterval(i)),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    if FireIceTheme.isFire {
                        for node in gameboard.sprite.children {
                            guard node.name == ParticleEngine.getFullNodeName(at: spawnPanel) else { continue }
                            
                            node.removeAction(forKey: "particleNodeFade")
                            node.alpha = 0
                            
                            node.run(SKAction.sequence([
                                SKAction.wait(forDuration: waitDuration * 3),
                                SKAction.fadeIn(withDuration: waitDuration)
                            ]), withKey: "particleNodeFade")
                            
                            break
                        }
                    }
                    else {
                        ParticleEngine.shared.animateParticles(type: .snowfall,
                                                               toNode: gameboard.sprite,
                                                               position: gameboard.getLocation(at: spawnPanel),
                                                               scale: 3 / CGFloat(gameboard.panelCount),
                                                               nameGameboardPosition: spawnPanel,
                                                               duration: 0)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + waitDuration * 3) {
                            ParticleEngine.shared.removeParticles(fromNode: self.gameboard.sprite,
                                                                  nameGameboardPosition: spawnPanel,
                                                                  fadeDuration: waitDuration)
                        }
                    }
                    
                    if spawnPanel == heroPosition {
                        updateHealth(type: .regen)
                    }
                },
                SKAction.fadeIn(withDuration: 0.25),
                SKAction.wait(forDuration: waitDuration * 2.75),
                dissolveTerrain,
                SKAction.removeFromParent()
            ])) { [weak self] in
                guard let self = self else { return }
                
                if spawnPanel == heroPosition {
                    updateHealth(type: .drain)
                }
            } //end newTerrain.run
        }//end for
    }//end animateSpawnPanels()
    
    
}
