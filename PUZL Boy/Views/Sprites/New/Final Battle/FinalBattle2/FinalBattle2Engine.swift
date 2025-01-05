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
    
    private let size: CGSize
    private var heroPosition: K.GameboardPosition!
    private var villainPosition: K.GameboardPosition!
    private var gameboard: GameboardSprite!
    private var hero: Player!
    private var villain: Player!
    
    private var backgroundPattern: FinalBattle2Background!
    private var controls: FinalBattle2Controls!
    private var health: FinalBattle2Health!
    private var panelSpawner: FinalBattle2Spawner!
    
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
        heroPosition = FinalBattle2Spawner.startPosition
        villainPosition = FinalBattle2Spawner.endPosition
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
        
        ParticleEngine.shared.animateParticles(type: .magmoorSmoke,
                                               toNode: villain.sprite,
                                               position: .zero,
                                               duration: 0)
        
        //Initialize after gameboard, hero and heroPosition!
        controls = FinalBattle2Controls(gameboard: gameboard,
                                        player: hero,
                                        villain: villain,
                                        playerPosition: heroPosition,
                                        villainPosition: villainPosition)
        controls.delegate = self
        
        panelSpawner = FinalBattle2Spawner(gameboard: gameboard)
        panelSpawner.populateSpawner(spawnPanelCount: 3)
        panelSpawner.delegate = self
        
        health = FinalBattle2Health(position: CGPoint(x: size.width / 2, y: K.ScreenDimensions.topOfGameboard))
        backgroundPattern = FinalBattle2Background(backgroundSprite: backgroundSprite, bloodOverlay: bloodOverlay, flashGameboard: flashGameboard)
    }
    
    
    // MARK: - Functions
    
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
    
    ///Animates all the components
    func animateSprites() {
        hero.sprite.run(Player.animate(player: hero, type: .idle))
        villain.sprite.run(Player.animateIdleLevitate(player: villain))
        
        health.showHealth()
        backgroundPattern.animate(pattern: .normal, fadeDuration: 0)
        panelSpawner.animateSpawner(speed: 3)
    }
    
    
    func handleControls(in location: CGPoint) {
        controls.handleControls(in: location, playerPosition: &heroPosition, villainPosition: &villainPosition, safePanelFound: safePanelFound()) { [weak self] in
            guard let self = self else { return }
            
            if safePanelFound() || startPanelFound() || endPanelFound() {
                health.updateHealth(type: .regen, player: hero)
            }
            else {
                health.updateHealth(type: .drain, player: hero)
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
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
        return heroPosition == FinalBattle2Spawner.startPosition
    }
    
    /**
     Checks if hero is at endPanel.
     */
    private func endPanelFound() -> Bool {
        return heroPosition == FinalBattle2Spawner.endPosition
    }
    
    
    // MARK: - Attack (Helper) Functions
    
    private func shieldExplodeDamagePanels(at homePosition: K.GameboardPosition) {
        func isValidPosition(row: Int, col: Int) -> Bool {
            return row >= 0 && row < gameboard.panelCount && col >= 0 && col < gameboard.panelCount
        }
        
        @discardableResult func addEdgePosition(row: Int, col: Int) -> Bool {
            guard isValidPosition(row: row, col: col) else { return false }
            
            affectedPanels.append(K.GameboardPosition(row: row, col: col))
            
            return true
        }
        
        var affectedPanels: [K.GameboardPosition] = []
        affectedPanels.append(homePosition)
        
        //First add the immediate square
        for row in (homePosition.row - 1)...(homePosition.row + 1) {
            for col in (homePosition.col - 1)...(homePosition.col + 1) {
                guard isValidPosition(row: row, col: col) else { continue }
                
                affectedPanels.append(K.GameboardPosition(row: row, col: col))
            }
        }
        
        //Then add the edge positions
        addEdgePosition(row: homePosition.row - 2, col: homePosition.col)
        addEdgePosition(row: homePosition.row + 2, col: homePosition.col)
        addEdgePosition(row: homePosition.row, col: homePosition.col - 2)
        addEdgePosition(row: homePosition.row, col: homePosition.col + 2)
        
        //Panel animation
        for panel in affectedPanels {
            guard let originalTerrain = gameboard.getPanelSprite(at: panel).terrain else { continue }
            
            let damagePanel = SKSpriteNode(imageNamed: "water")
            damagePanel.anchorPoint = .zero
            damagePanel.color = .red
            damagePanel.colorBlendFactor = 1
            damagePanel.alpha = 0
            damagePanel.zPosition = 6
            
            originalTerrain.addChild(damagePanel)
            
            damagePanel.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.25),
                SKAction.wait(forDuration: 0.75),
                SKAction.fadeOut(withDuration: 1),
                SKAction.removeFromParent()
            ]))
        }
        
        //Update health
        if affectedPanels.contains(where: { $0 == heroPosition }) {
            health.updateHealth(type: .villainShieldExplode, player: hero)
        }
    }
    
    
}


// MARK: - FinalBattle2ControlsDelegate

extension FinalBattle2Engine: FinalBattle2ControlsDelegate {
    func didHeroAttack(chosenSword: ChosenSword) {
        health.updateHealth(type: .heroAttack, player: hero, dmgMultiplier: chosenSword.attackRatingPercentage)
    }
    
    func didVillainDisappear(fadeDuration: TimeInterval) {
        backgroundPattern.animate(pattern: .blackout, fadeDuration: fadeDuration)
    }
    
    func willVillainReappear() {
        backgroundPattern.adjustOverworldMusic(volume: 0.5, fadeDuration: 1)
    }
    
    func didVillainReappear() {
        backgroundPattern.animate(pattern: .wave, fadeDuration: 2, shouldFlashGameboard: true)
    }
    
    func willDamageShield() {
        backgroundPattern.animate(pattern: .convulse, fadeDuration: 0.04)
    }
    
    func didDamageShield() {
        backgroundPattern.animate(pattern: .wave, fadeDuration: 2)
    }
    
    func willBreakShield(fadeDuration: TimeInterval) {
        bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
        flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
        backgroundPattern.adjustOverworldMusic(volume: 0, fadeDuration: fadeDuration)
    }
    
    /**
     I don't like how this villainPosition doesn't sync up with global villainPosition, so I'm passing the correct one as an argument.
     - parameter villainPosition: the sync'ed version that is correct
     */
    func didBreakShield(at villainPosition: K.GameboardPosition) {
        backgroundPattern.animate(pattern: .normal, fadeDuration: 2, shouldFlashGameboard: true)
        shieldExplodeDamagePanels(at: villainPosition)
    }
    
    
}


// MARK: - FinalBattle2SpawnerDelegate

extension FinalBattle2Engine: FinalBattle2SpawnerDelegate {
    func didSpawnSafePanel(spawnPanel: K.GameboardPosition) {
        guard spawnPanel == heroPosition else { return }
        
        health.updateHealth(type: .regen, player: hero)
    }
    
    func didDespawnSafePanel(spawnPanel: K.GameboardPosition) {
        guard spawnPanel == heroPosition && !safePanelFound() && !startPanelFound() && !endPanelFound() else { return }
        
        health.updateHealth(type: .drain, player: hero)
    }
}
