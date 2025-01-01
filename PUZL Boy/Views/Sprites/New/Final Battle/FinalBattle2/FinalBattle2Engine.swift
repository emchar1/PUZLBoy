//
//  FinalBattle2Engine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/15/24.
//

import SpriteKit

class FinalBattle2Engine {
    
    // MARK: - Properties
    
    static let villainFloatOffset = CGPoint(x: 0, y: 25)
    static let startPosition: K.GameboardPosition = (6, 3)
    static let endPosition: K.GameboardPosition = (3, 3)
    
    private let size: CGSize
    private let maxCount: Int = 1000
    private var ignorePositions: [K.GameboardPosition] { [FinalBattle2Engine.startPosition, FinalBattle2Engine.endPosition] }
    private var heroPosition: K.GameboardPosition!
    private var villainPosition: K.GameboardPosition!
    private var gameboard: GameboardSprite!
    private var hero: Player!
    private var villain: Player!

    private var backgroundPattern: FinalBattle2Background!
    private var controls: FinalBattle2Controls!
    private var health: FinalBattle2Health!
    
    private var spawnPanels0: [K.GameboardPosition] = []
    private var spawnPanels1: [K.GameboardPosition] = []
    private var spawnPanels2: [K.GameboardPosition] = []
    private var spawnPanels3: [K.GameboardPosition] = []
    
    private var superScene: SKScene?
    private var backgroundSprite: SKSpriteNode!
    private var bloodOverlay: SKSpriteNode!
    private var flashGameboard: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    init(size: CGSize) {
        self.size = size
        
        setupScene()
    }
    
    deinit {
        print("FinalBattle2Engine deinit")
    }
    
    private func setupScene() {
        heroPosition = FinalBattle2Engine.startPosition
        villainPosition = FinalBattle2Engine.endPosition
        gameboard = GameboardSprite(level: LevelBuilder.levels[Level.finalLevel + 1], fadeIn: false)
        
        //Make sure to initialize GameboardSprite BEFORE initializing these!!!
        let playerScale: CGFloat = Player.getGameboardScale(panelSize: size.width / CGFloat(gameboard.panelCount))
        
        backgroundSprite = SKSpriteNode(color: .black, size: size)
        backgroundSprite.anchorPoint = .zero
        
        bloodOverlay = SKSpriteNode(color: .systemPink, size: size)
        bloodOverlay.anchorPoint = .zero
        bloodOverlay.alpha = FinalBattle2Background.defaultBloodOverlayAlpha
        bloodOverlay.zPosition = gameboard.sprite.zPosition + K.ZPosition.bloodOverlay
        
        flashGameboard = SKSpriteNode(color: .white, size: gameboard.sprite.size)
        flashGameboard.setScale(1 / gameboard.sprite.xScale)
        flashGameboard.anchorPoint = .zero
        flashGameboard.alpha = 0
        flashGameboard.zPosition = K.ZPosition.terrain + 2
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboard.getLocation(at: heroPosition)
        hero.sprite.setScale(playerScale * hero.scaleMultiplier)
        hero.sprite.color = FireIceTheme.isFire ? .red : .blue
        hero.sprite.colorBlendFactor = 0
        hero.sprite.zPosition = K.ZPosition.player
        
        villain = Player(type: .villain)
        villain.sprite.position = gameboard.getLocation(at: villainPosition) + FinalBattle2Engine.villainFloatOffset
        villain.sprite.setScale(playerScale * villain.scaleMultiplier)
        villain.sprite.xScale *= -1
        villain.sprite.zPosition = K.ZPosition.player + 2
        
        //Initialize after gameboard, hero and heroPosition!
        controls = FinalBattle2Controls(gameboard: gameboard,
                                        player: hero,
                                        villain: villain,
                                        playerPosition: heroPosition,
                                        villainPosition: villainPosition)
        controls.delegate = self
        
        health = FinalBattle2Health(position: CGPoint(x: size.width / 2, y: K.ScreenDimensions.topOfGameboard))
        backgroundPattern = FinalBattle2Background(backgroundSprite: backgroundSprite, bloodOverlay: bloodOverlay, flashGameboard: flashGameboard)
        
        populateSpawnPanels(spawnPanels: &spawnPanels0, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels1, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels2, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels3, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene
        
        superScene.addChild(backgroundSprite)
        superScene.addChild(bloodOverlay)

        superScene.addChild(gameboard.sprite)
        gameboard.sprite.addChild(flashGameboard)
        gameboard.sprite.addChild(hero.sprite)
        gameboard.sprite.addChild(villain.sprite)
        
        health.addToParent(superScene)
    }
    
    
    // MARK: - Functions
    
    func handleControls(in location: CGPoint) {
        controls.handleControls(in: location, playerPosition: &heroPosition, villainPosition: &villainPosition, safePanelFound: safePanelFound()) { [weak self] in
            guard let self = self else { return }
            
            if safePanelFound() || startPanelFound() || endPanelFound() {
                health.updateHealth(type: .regen, player: hero)
            }
            else {
                health.updateHealth(type: .lavaHit, player: hero)
                health.updateHealth(type: .drain, player: hero)
            }
        }
    }
    
    ///Animates all the components
    func animateSprites() {
        hero.sprite.run(Player.animate(player: hero, type: .idle))
        villain.sprite.run(Player.animateIdleLevitate(player: villain))
        
        health.showHealth()
        backgroundPattern.animate(pattern: .normal, fadeDuration: 0)
        
        let terrainPanel: LevelType = FireIceTheme.isFire ? .sand : .snow
        
        animateSpawnPanels(spawnPanels: spawnPanels0, with: terrainPanel)
        animateSpawnPanels(spawnPanels: spawnPanels1, with: terrainPanel)
        animateSpawnPanels(spawnPanels: spawnPanels2, with: terrainPanel)
        animateSpawnPanels(spawnPanels: spawnPanels3, with: terrainPanel)
    }
    
    func flashHeroAttacked(duration: TimeInterval = 0.5) {
        flashGameboard.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0),
            SKAction.fadeOut(withDuration: duration)
        ]))
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
    
    /**
     Checks if the location requested to move to is a valid one, i.e. a "safePanel".
     - returns: true if requested panel is a valid one
     */
    private func safePanelFound() -> Bool {
        guard let superScene = superScene else {
            print("superScene nil in FinalBattle2Engine.safePanelFound()")
            return false
        }
        
        //I had to multiply gameboard.getLocation(at:) by UIDevice.spriteScale to NORMALIZE it, otherwise it gets messed up on iPad!!! 12/31/24
        let heroPositionGameboardOffset = gameboard.sprite.position + gameboard.getLocation(at: heroPosition) * UIDevice.spriteScale
        
        return superScene.nodes(at: heroPositionGameboardOffset).contains(where: { $0.name == "safePanel" })
    }
    
    /**
     Checks if hero is at startPanel.
     */
    private func startPanelFound() -> Bool {
        return heroPosition == FinalBattle2Engine.startPosition
    }
    
    /**
     Checks if hero is at endPanel.
     */
    private func endPanelFound() -> Bool {
        return heroPosition == FinalBattle2Engine.endPosition
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
        let waitDuration: TimeInterval = 1
        
        ///SKAction that animates dissolving of primary (sand/snow) panel to secondary (lava/water).
        func dissolveTerrainAction(pulseDuration: TimeInterval) -> SKAction {
            let offsetDuration: TimeInterval = 0 //DON'T TOUCH THIS LEAVE AT 0!!!
            
            let sandAction = SKAction.sequence([
                SKAction.moveBy(x: 5, y: 0, duration: offsetDuration),
                SKAction.group([
                    SKAction.repeat(SKAction.sequence([
                        SKAction.moveBy(x: -10, y: 0, duration: pulseDuration),
                        SKAction.moveBy(x: 10, y: 0, duration: pulseDuration)
                    ]), count: Int(waitDuration / (2 * pulseDuration))),
                    SKAction.fadeOut(withDuration: waitDuration)
                ])
            ])
            
            let snowAction = SKAction.sequence([
                SKAction.repeat(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.6, duration: pulseDuration),
                    SKAction.fadeAlpha(to: 0.8, duration: pulseDuration)
                ]), count: Int(waitDuration / (2 * pulseDuration))),
                SKAction.fadeOut(withDuration: offsetDuration)
            ])
            
            return FireIceTheme.isFire ? sandAction : snowAction
        }
        
        ///Handles particles for sand-lava or snow-water (depending on fire/ice).
        func handleParticles(spawnPanel: K.GameboardPosition) {
            if FireIceTheme.isFire {
                for node in gameboard.sprite.children {
                    guard node.name == ParticleEngine.getNodeName(at: spawnPanel) else { continue }
                    
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
                                                       duration: waitDuration * 3 + waitDuration)
            }
        }
        
        
        for (i, spawnPanel) in spawnPanels.enumerated() {
            guard let originalTerrain = gameboard.getPanelSprite(at: spawnPanel).terrain else { continue }
            
            let newTerrain = SKSpriteNode(imageNamed: terrain.description)
            newTerrain.anchorPoint = .zero
            newTerrain.alpha = 0
            newTerrain.zPosition = 4
            newTerrain.name = "safePanel"
            
            originalTerrain.addChild(newTerrain)
            
            newTerrain.run(SKAction.sequence([
                SKAction.wait(forDuration: waitDuration * TimeInterval(i)),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    handleParticles(spawnPanel: spawnPanel)
                    
                    if spawnPanel == heroPosition {
                        health.updateHealth(type: .regen, player: hero)
                    }
                },
                SKAction.fadeIn(withDuration: waitDuration * 0.25),
                SKAction.wait(forDuration: waitDuration * 2.75),
                dissolveTerrainAction(pulseDuration: 0.1),
                SKAction.removeFromParent()
            ])) { [weak self] in
                guard let self = self else { return }
                
                //Added "&& !safePanelFound() && !endPanelFound()" as an extra added layer in case an overlapping safePanel spawns after the first one is removed.
                if spawnPanel == heroPosition && !safePanelFound() && !startPanelFound() && !endPanelFound() {
                    health.updateHealth(type: .drain, player: hero)
                }
            } //end newTerrain.run
        }//end for
    }//end animateSpawnPanels()
    
    
}


// MARK: - FinalBattle2ControlsDelegate

extension FinalBattle2Engine: FinalBattle2ControlsDelegate {
    func didHeroAttack(chosenSword: ChosenSword) {
        health.updateHealth(type: .heroAttack, player: hero, dmgMultiplier: chosenSword.attackRatingPercentage)
    }
    
    func didVillainDisappear(fadeDuration: TimeInterval) {
        backgroundPattern.animate(pattern: .blackout, fadeDuration: fadeDuration)
    }
    
    func didVillainReappear() {
        backgroundPattern.animate(pattern: .convulse, fadeDuration: 2)
    }
    
    func didBreakShield() {
        backgroundPattern.animate(pattern: .normal, fadeDuration: 2, shouldFlashGameboard: true)
    }
    
    
}
