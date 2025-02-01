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
    private let panelSpawnerCount: Int = 3
    private var gameboard: GameboardSprite!
    private var hero: Player!
    private var villain: Player!
    
    private var backgroundPattern: FinalBattle2Background!
    private var controls: FinalBattle2Controls!
    private var health: FinalBattle2Health!
    private var panelSpawner: [FinalBattle2Spawner] = []
    
    private var superScene: SKScene?
    private var backgroundSprite: SKSpriteNode!
    private var bloodOverlay: SKSpriteNode!
    private var flashGameboard: SKSpriteNode!
    
    
    
    // FIXME: - Debug Speed
    private var labelDebug: SKLabelNode!
    private var timerDebug: Timer = Timer()
    private var timerDebugCount: TimeInterval = 0
    
    
    
    // FIXME: - For use with build# 1.28(30).
    private var fadeBackgroundSprite: SKShapeNode!
    
    
    // MARK: - Initialization
    
    init(size: CGSize) {
        self.size = size
        
        setupScene()
    }
    
    deinit {
        print("FinalBattle2Engine deinit")
    }
    
    private func setupScene() {
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
        
        
        
        // FIXME: - Debug Speed
        labelDebug = SKLabelNode(text: "SPEED UPDATING...")
        labelDebug.position = CGPoint(x: 40, y: 200)
        labelDebug.fontName = UIFont.gameFont
        labelDebug.fontSize = UIFont.gameFontSizeLarge
        labelDebug.fontColor = UIFont.gameFontColor
        labelDebug.horizontalAlignmentMode = .left
        labelDebug.numberOfLines = 0
        
        
        
        // FIXME: - For use with build# 1.28(30).
        fadeBackgroundSprite = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        fadeBackgroundSprite.fillColor = .black
        fadeBackgroundSprite.strokeColor = .clear
        fadeBackgroundSprite.lineWidth = 0
        fadeBackgroundSprite.alpha = 0
        fadeBackgroundSprite.zPosition = K.ZPosition.messagePrompt
        
        
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboard.getLocation(at: FinalBattle2Spawner.startPosition)
        hero.sprite.setScale(playerScale * hero.scaleMultiplier)
        hero.sprite.color = FireIceTheme.isFire ? .red : .blue
        hero.sprite.colorBlendFactor = 0
        hero.sprite.zPosition = K.ZPosition.player
        
        villain = Player(type: .villain)
        villain.sprite.position = gameboard.getLocation(at: FinalBattle2Spawner.endPosition)
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
                                        positions: (player: FinalBattle2Spawner.startPosition, villain: FinalBattle2Spawner.endPosition))
        controls.delegate = self
        
        for i in 0..<panelSpawnerCount {
            panelSpawner.append(FinalBattle2Spawner(gameboard: gameboard))
            panelSpawner[i].delegate = self
            panelSpawner[i].populateSpawner()
        }
        
        health = FinalBattle2Health(player: hero, position: CGPoint(x: size.width / 2, y: K.ScreenDimensions.topOfGameboard))
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
        
        
        
        // FIXME: - For use with build# 1.28(30).
        superScene.addChild(fadeBackgroundSprite)
        
        
        
        superScene.addChild(gameboard.sprite)
        gameboard.sprite.addChild(flashGameboard)
        gameboard.sprite.addChild(hero.sprite)
        gameboard.sprite.addChild(villain.sprite)
        
        health.addToParent(superScene)
        
        // FIXME: - Uncomment for debugging
        superScene.addChild(labelDebug)
    }
    
    ///Animates all the components
    func animateSprites() {
        hero.sprite.run(Player.animate(player: hero, type: .idle))
        villain.sprite.run(Player.animateIdleLevitate(player: villain))
        
        health.showHealth()
        backgroundPattern.animate(pattern: .normal, fadeDuration: 0)
        
        for i in 0..<panelSpawner.count {
            panelSpawner[i].animateSpawner()
        }
    }
    
    
    func handleControls(in location: CGPoint) {
        controls.handleControls(in: location,
                                safePanelFound: safeOrPlatformFound(),
                                poisonPanelFound: namePanelFound(FinalBattle2Spawner.poisonPanelName),
                                isPoisoned: health.isPoisoned) { [weak self] in
            
            guard let self = self else { return }
            
            if namePanelFound(FinalBattle2Spawner.poisonPanelName) {
                health.updateHealth(type: .drainPoison, dmgMultiplier: controls.chosenSword.defenseRating)
            }
            else if safeOrPlatformFound() || startPanelFound() || endPanelFound() {
                health.updateHealth(type: .stopDrain)
            }
            else {
                health.updateHealth(type: .drain, dmgMultiplier: controls.chosenSword.defenseRating)
            }
        }
    }
    
    func animateCleanup(completion: @escaping () -> Void) {
        // FIXME: - For use with build# 1.28(30).
        fadeBackgroundSprite.run(SKAction.fadeIn(withDuration: 2)) { [weak self] in
            //Need to call these (2) explicitly because the stubborn bastards won't deinitialize on their own!!
            self?.controls.magmoorShield.cleanup()
            self?.health.cleanup()
            
            completion()
        }
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Checks if the panel requested to move to matches the name String passed in.
     - parameter name: the node name to check for
     - returns: true if requested panel is a valid one
     */
    private func namePanelFound(_ name: String) -> Bool {
        guard let superScene = superScene else {
            print("superScene nil in FinalBattle2Engine.namePanelFound()")
            return false
        }
        
        //I had to multiply gameboard.getLocation(at:) by UIDevice.spriteScale to NORMALIZE it, otherwise it gets messed up on iPad!!! 12/31/24
        let heroPositionGameboardOffset = gameboard.sprite.position + gameboard.getLocation(at: controls.positions.player) * UIDevice.spriteScale
        
        return superScene.nodes(at: heroPositionGameboardOffset).contains(where: { $0.name == name })
    }
    
    /**
     Checks if hero is at startPanel.
     */
    private func startPanelFound() -> Bool {
        return controls.positions.player == FinalBattle2Spawner.startPosition
    }
    
    /**
     Checks if hero is at endPanel.
     */
    private func endPanelFound() -> Bool {
        return controls.positions.player == FinalBattle2Spawner.endPosition
    }
    
    /**
     Checks if hero is on either a safe panel or a platform panel.
     */
    private func safeOrPlatformFound() -> Bool {
        return namePanelFound(FinalBattle2Spawner.safePanelName) || namePanelFound(FinalBattle2Spawner.platformPanelName)
    }
    
    
    // MARK: - Attack (Helper) Functions
    
    private func villainAttackNormal(at position: K.GameboardPosition, pattern: MagmoorAttacks.AttackPattern, chosenSword: ChosenSword) {
        let panelColor: UIColor
        let healthType: FinalBattle2Health.HealthType
        
        switch pattern {
        case .freeze:
            panelColor = .cyan
            healthType = .villainAttackFreeze
        case .poison:
            panelColor = .green
            healthType = .villainAttackPoison
        default:
            panelColor = .red
            healthType = .villainAttackNormal
        }
        
        showDamagePanel(at: position, color: panelColor, isPoison: pattern == .poison, withExplosion: false)
        
        if position == controls.positions.player {
            health.updateHealth(type: healthType, dmgMultiplier: chosenSword.defenseRating)
        }
    }
    
    private func villainAttackTimed(at homePosition: K.GameboardPosition, isLarge: Bool, chosenSword: ChosenSword) {
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
                
        //Add the edge positions. Use 'continue' NOT 'return' in the for loops!!!
        for i in 1..<homePosition.row + 1 {
            guard isLarge || i == 1 else { continue }
            addEdgePosition(row: homePosition.row - i, col: homePosition.col)
        }
        for i in 1..<gameboard.panelCount - homePosition.row + 1 {
            guard isLarge || i == 1 else { continue }
            addEdgePosition(row: homePosition.row + i, col: homePosition.col)
        }
        for i in 1..<homePosition.col + 1 {
            guard isLarge || i == 1 else { continue }
            addEdgePosition(row: homePosition.row, col: homePosition.col - i)
        }
        for i in 1..<gameboard.panelCount - homePosition.col + 1 {
            guard isLarge || i == 1 else { continue }
            addEdgePosition(row: homePosition.row, col: homePosition.col + i)
        }
        
        //Panel animation
        affectedPanels.forEach { showDamagePanel(at: $0, withExplosion: true) }
        
        //Update health
        if affectedPanels.contains(where: { $0 == controls.positions.player }) {
            if controls.villainAttackTimedBombCanHurtPlayer() {
                health.updateHealth(type: .villainAttackTimed, dmgMultiplier: chosenSword.defenseRating)
            }
        }
        
        //Harm villain if needed
        if affectedPanels.contains(where: { $0 == controls.positions.villain }) {
            controls.villainAttackTimedBombHurtVillain()
        }
    }
    
    private func shieldExplodeDamagePanels(at homePosition: K.GameboardPosition, chosenSword: ChosenSword) {
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
        let shouldPoison: Bool = controls.magmoorShield.resetCount == 4 || controls.magmoorShield.resetCount >= 6
        affectedPanels.forEach { showDamagePanel(at: $0, color: shouldPoison ? .green : .red, isPoison: shouldPoison, withExplosion: true) }
        
        //Update health
        if affectedPanels.contains(where: { $0 == controls.positions.player }) {
            if shouldPoison {
                health.updateHealth(type: .villainAttackPoison, dmgMultiplier: chosenSword.defenseRating)
                health.updateHealth(type: .drainPoison, dmgMultiplier: chosenSword.defenseRating)
            }
            else {
                health.updateHealth(type: .villainShieldExplode, dmgMultiplier: chosenSword.defenseRating)
            }
        }
    }
    
    private func showDamagePanel(at position: K.GameboardPosition, color: UIColor = .red, isPoison: Bool = false, withExplosion: Bool) {
        guard let originalTerrain = gameboard.getPanelSprite(at: position).terrain else { return }
        
        let waitDuration: TimeInterval = isPoison ? 6.75 : 0.75
        let pulseDuration: TimeInterval = 0.1
        let shakeAction: SKAction = isPoison ? SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0),
            SKAction.group([
                SKAction.repeat(SKAction.sequence([
                    SKAction.moveBy(x: -10, y: 0, duration: pulseDuration),
                    SKAction.moveBy(x: 10, y: 0, duration: pulseDuration)
                ]), count: Int(1 / (2 * pulseDuration))),
                SKAction.fadeOut(withDuration: 1)
            ])
        ]) : SKAction.fadeOut(withDuration: 1)
        
        let damagePanel = SKSpriteNode(imageNamed: "water")
        damagePanel.anchorPoint = .zero
        damagePanel.color = color
        damagePanel.colorBlendFactor = 1
        damagePanel.alpha = 0
        damagePanel.zPosition = 6
        
        if isPoison {
            damagePanel.name = FinalBattle2Spawner.poisonPanelName
        }
        
        originalTerrain.addChild(damagePanel)
        
        damagePanel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.wait(forDuration: waitDuration),
            shakeAction,
            SKAction.removeFromParent()
        ]))
        
        if withExplosion {
            let particleType: ParticleEngine.ParticleType = isPoison ? .magicElderEarth2: .magicElderFire3
            let particleScale: CGFloat = (isPoison ? 2 : 1) * UIDevice.spriteScale / CGFloat(gameboard.panelCount)
            let particleDuration: TimeInterval = isPoison ? 8 : 1
            
            ParticleEngine.shared.animateParticles(type: particleType,
                                                   toNode: gameboard.sprite,
                                                   position: gameboard.getLocation(at: position),
                                                   scale: particleScale,
                                                   duration: particleDuration)
        }
    }
    
    
}


// MARK: - FinalBattle2ControlsDelegate

extension FinalBattle2Engine: FinalBattle2ControlsDelegate {
    func didHeroAttack(chosenSword: ChosenSword) {
        health.updateHealth(type: .heroAttack, dmgMultiplier: chosenSword.attackRating)
    }
    
    func didVillainDisappear(fadeDuration: TimeInterval) {
        backgroundPattern.animate(pattern: .blackout, fadeDuration: fadeDuration)
    }
    
    func willVillainReappear() {
        backgroundPattern.adjustOverworldMusic(volume: 0.5, fadeDuration: 1)
    }
    
    func didVillainFlee(didReappear: Bool) {
        // FIXME: - Debug Speed
        updateDebugLabelTest()
        
        
        
        guard didReappear else { return }
        
        if !panelSpawner.isEmpty {
            controls.updateVillainMovementAndAttacks(speed: panelSpawner[0].currentSpeed)
        }
        
        backgroundPattern.animate(pattern: .wave, fadeDuration: 2, shouldFlashGameboard: true)
    }
    
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, chosenSword: ChosenSword, position: K.GameboardPosition) {
        switch pattern {
        case .normal, .freeze, .poison:
            villainAttackNormal(at: position, pattern: pattern, chosenSword: chosenSword)
        case .timed:
            villainAttackTimed(at: position, isLarge: false, chosenSword: chosenSword)
        case .timedLarge:
            villainAttackTimed(at: position, isLarge: true, chosenSword: chosenSword)
        case .duplicates:
            for i in 0..<panelSpawnerCount {
                panelSpawner[i].showPlatform(shouldShow: true)
            }
        }
    }
    
    func didVillainAttackBecomeVisible() {
        for i in 0..<panelSpawnerCount {
            panelSpawner[i].showPlatform(shouldShow: false)
        }
    }
    
    func handleShield(willDamage: Bool, didDamage: Bool, willBreak: Bool, didBreak: Bool, fadeDuration: TimeInterval?, chosenSword: ChosenSword, villainPosition: K.GameboardPosition?) {
        if willDamage {
            backgroundPattern.animate(pattern: .convulse, fadeDuration: 0.04)
        }
        else if didDamage {
            if !panelSpawner.isEmpty {
                controls.updateVillainMovementAndAttacks(speed: panelSpawner[0].currentSpeed)
            }
            
            
            
            // FIXME: - Debug Speed
            updateDebugLabelTest()
            
            
            
            backgroundPattern.animate(pattern: .wave, fadeDuration: 2)
        }
        else if willBreak {
            let fadeDuration = fadeDuration ?? 0

            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
            flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
            backgroundPattern.adjustOverworldMusic(volume: 0, fadeDuration: fadeDuration)
        }
        else if didBreak {
            let villainPosition = villainPosition ?? (0, 0)
            
            backgroundPattern.animate(pattern: .normal, fadeDuration: 2, shouldFlashGameboard: true)
            shieldExplodeDamagePanels(at: villainPosition, chosenSword: chosenSword)
        }
    }
    
    
}


// MARK: - FinalBattle2SpawnerDelegate

extension FinalBattle2Engine: FinalBattle2SpawnerDelegate {
    func didSpawnSafePanel(spawnPanel: K.GameboardPosition, index: Int) {
        guard spawnPanel == controls.positions.player else { return }
        health.updateHealth(type: .stopDrain)
    }
    
    func didDespawnSafePanel(spawnPanel: K.GameboardPosition, index: Int) {
        guard spawnPanel == controls.positions.player && !safeOrPlatformFound() && !namePanelFound(FinalBattle2Spawner.poisonPanelName) && !startPanelFound() && !endPanelFound() else { return }
        health.updateHealth(type: .drain, dmgMultiplier: controls.chosenSword.defenseRating)
    }
    
    func didChangeSpeed(speed: FinalBattle2Spawner.SpawnerSpeed) {
        controls.updateVillainMovementAndAttacks(speed: speed)
    }
    
    
}
