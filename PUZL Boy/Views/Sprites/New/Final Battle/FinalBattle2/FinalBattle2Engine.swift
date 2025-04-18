//
//  FinalBattle2Engine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/15/24.
//

import SpriteKit

class FinalBattle2Engine {
    
    // MARK: - Properties
    
    static let heroName: String = "heroSpriteName"
    
    private let size: CGSize
    private let panelSpawnerCount: Int = 3
    private var gameboard: GameboardSprite!
    private var hero: Player!
    private var villain: Player!
    
    private var backgroundPattern: FinalBattle2Background!
    private var controls: FinalBattle2Controls!
    private var health: FinalBattle2Health!
    private var panelSpawner: [FinalBattle2Spawner] = []
    
    private weak var superScene: SKScene?
    private var backgroundSprite: SKSpriteNode!
    private var infinityOverlay: SKSpriteNode!
    private var bloodOverlay: SKSpriteNode!
    private var flashOverlay: SKSpriteNode!
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
        //Don't forget to reset platform and power up item timers!!!
        FinalBattle2Spawner.isPlatformOn = false
        DuplicateItem.shared.resetTimers()
        
        superScene = nil
        
        print("FinalBattle2Engine deinit")
    }
    
    private func setupScene() {
        gameboard = GameboardSprite(level: LevelBuilder.levels[Level.finalLevel + 1], fadeIn: false)
        
        let endGateMagic = SKSpriteNode(imageNamed: "endClosedMagic")
        endGateMagic.position = gameboard.getSpritePositionAbsolute(at: (3, 3)).terrain
        endGateMagic.scale(to: gameboard.scaleSize)
        endGateMagic.anchorPoint = .zero
        endGateMagic.alpha = 0
        endGateMagic.zPosition = K.ZPosition.terrain + 5
        endGateMagic.name = "endGateMagic"
        
        gameboard.sprite.addChild(endGateMagic)
        
        //Make sure to initialize GameboardSprite BEFORE initializing these!!!
        let playerScale: CGFloat = Player.getGameboardScale(panelSize: size.width / CGFloat(gameboard.panelCount))
        
        backgroundSprite = SKSpriteNode(color: .black, size: size)
        backgroundSprite.anchorPoint = .zero
        
        bloodOverlay = SKSpriteNode(color: .red, size: size)
        bloodOverlay.anchorPoint = .zero
        bloodOverlay.alpha = FinalBattle2Background.defaultBloodOverlayAlpha
        bloodOverlay.zPosition = gameboard.sprite.zPosition + K.ZPosition.bloodOverlay
        
        infinityOverlay = SKSpriteNode(color: .black, size: size)
        infinityOverlay.anchorPoint = .zero
        infinityOverlay.alpha = 0
        infinityOverlay.zPosition = 10
        
        flashOverlay = SKSpriteNode(color: .white, size: size)
        flashOverlay.anchorPoint = .zero
        flashOverlay.alpha = 0
        flashOverlay.zPosition = gameboard.sprite.zPosition + K.ZPosition.bloodOverlay + 10
        
        flashGameboard = SKSpriteNode(color: .white, size: gameboard.sprite.size)
        flashGameboard.setScale(1 / gameboard.sprite.xScale)
        flashGameboard.anchorPoint = .zero
        flashGameboard.alpha = 0
        flashGameboard.zPosition = K.ZPosition.terrain + 2
        
        
        
        // FIXME: - Debug Speed
        labelDebug = SKLabelNode(text: "SPEED UPDATING...")
        labelDebug.position = CGPoint(x: 40, y: 400)
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
        hero.sprite.color = FireIceTheme.overlayColor
        hero.sprite.colorBlendFactor = 0
        hero.sprite.zPosition = K.ZPosition.player
        hero.sprite.name = FinalBattle2Engine.heroName
        
        villain = Player(type: .villain2)
        villain.sprite.position = gameboard.getLocation(at: FinalBattle2Spawner.endPosition)
        villain.sprite.setScale(playerScale * villain.scaleMultiplier)
        villain.sprite.xScale *= -1
        villain.sprite.zPosition = K.ZPosition.player + 2
        
        ParticleEngine.shared.animateParticles(type: .magmoorSmoke,
                                               toNode: villain.sprite,
                                               position: .zero,
                                               zPosition: 2,
                                               duration: 0)
        
        //Initialize after gameboard, hero and heroPosition!
        controls = FinalBattle2Controls(gameboard: gameboard,
                                        player: hero,
                                        villain: villain,
                                        positions: (player: FinalBattle2Spawner.startPosition, villain: FinalBattle2Spawner.endPosition))
        controls.delegateControls = self
        
        for i in 0..<panelSpawnerCount {
            panelSpawner.append(FinalBattle2Spawner(gameboard: gameboard))
            panelSpawner[i].delegate = self
            panelSpawner[i].populateSpawner()
        }
        
        backgroundPattern = FinalBattle2Background(backgroundSprite: backgroundSprite,
                                                   bloodOverlay: bloodOverlay,
                                                   infinityOverlay: infinityOverlay,
                                                   flashGameboard: flashGameboard,
                                                   gameboard: gameboard)
        
        health = FinalBattle2Health(player: hero, position: CGPoint(x: size.width / 2, y: K.ScreenDimensions.topOfGameboard))
        health.delegateHealth = self
        
        //NEED TO RESET THIS!!! Otherwise progressHUDManager timers stack from the previous battle attempt 3/22/25.
        DuplicateItem.shared.resetTimers()
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
        superScene.addChild(infinityOverlay)
        superScene.addChild(flashOverlay)
        
        
        
        // FIXME: - Debug Speed
        superScene.addChild(labelDebug)
        
        // FIXME: - For use with build# 1.28(30).
        superScene.addChild(fadeBackgroundSprite)
        
        
        
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
        backgroundPattern.playOverworldMusic()
        backgroundPattern.animate(pattern: .normal, fadeDuration: 0, delay: nil)
        
        for i in 0..<panelSpawner.count {
            panelSpawner[i].animateSpawner()
        }
    }
    
    
    func handleControls(in location: CGPoint) {
        controls.handleControls(in: location,
                                safePanelFound: safeOrPlatformFound(),
                                poisonPanelFound: namePanelFound(FinalBattle2Spawner.poisonPanelName),
                                isPoisoned: health.isPoisoned,
                                playerHealth: health.counter.getCount()) { [weak self] in
            
            guard let self = self else { return }
            
            if namePanelFound(FinalBattle2Spawner.poisonPanelName) {
                health.updateHealth(type: .drainPoison, dmgMultiplier: controls.chosenSword.defenseRating)
            }
            else if safeOrPlatformFound() || startPanelFound() || endPanelFound() {
                health.updateHealth(type: .stopDrain)
            }
            else if !controls.duplicateItemTimerManager.isRunningBoot {
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
        let explosionType: MagmoorAttacks.ExplosionType
        let healthType: FinalBattle2Health.HealthType
        
        switch pattern {
        case .normal, .sNormal:
            explosionType = .normal
            healthType = .villainAttackNormal
        case .freeze, .sFreeze:
            explosionType = .freeze
            healthType = .villainAttackFreeze
        case .poison, .sPoison:
            explosionType = .poison
            healthType = .villainAttackPoison
        default: // TODO: - .castInvincible
            explosionType = .normal
            healthType = .villainAttackNormal
        }
        
        if position == controls.positions.player && !controls.duplicateItemTimerManager.isRunningShield {
            health.updateHealth(type: healthType, dmgMultiplier: chosenSword.defenseRating)
        }
        
        if !(position == controls.positions.player && controls.duplicateItemTimerManager.isRunningShield) {
            showDamagePanel(at: position, explosionType: explosionType, withExplosion: false, extendDamage: false)
        }
        else {
            guard hero.sprite.childNode(withName: "shieldNode") == nil else { return }
            
            let shieldScale: CGFloat = 6
            let shieldNode = SKSpriteNode(imageNamed: "shield")
            shieldNode.setScale(shieldScale)
            shieldNode.alpha = 0.75
            shieldNode.zPosition = K.ZPosition.itemsAndEffects
            shieldNode.name = "shieldNode"
            
            hero.sprite.addChild(shieldNode)
            
            shieldNode.run(SKAction.sequence([
                SKAction.moveBy(x: -20, y: 0, duration: 0.05),
                SKAction.moveBy(x: 40, y: 0, duration: 0.05),
                SKAction.moveBy(x: -40, y: 0, duration: 0.05),
                SKAction.moveBy(x: 40, y: 0, duration: 0.05),
                SKAction.moveBy(x: -20, y: 0, duration: 0.05),
                SKAction.group([
                    SKAction.scale(to: 2 * shieldScale, duration: 0.25),
                    SKAction.fadeOut(withDuration: 0.25)
                ]),
                SKAction.removeFromParent()
            ]))
            
            AudioManager.shared.playSound(for: "swordparry")
        }
    }
    
    private func villainAttackTimed(at homePosition: K.GameboardPosition, isLarge: Bool, chosenSword: ChosenSword) {
        func isValidPosition(row: Int, col: Int) -> Bool {
            return row >= 0 && row < gameboard.panelCount && col >= 0 && col < gameboard.panelCount
        }
        
        @discardableResult
        func addEdgePosition(row: Int, col: Int) -> Bool {
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
        affectedPanels.forEach {
            showDamagePanel(at: $0, explosionType: .normal, withExplosion: true, extendDamage: false)
        }
        
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
    
    private func shieldExplodeDamagePanels(at homePosition: K.GameboardPosition, chosenSword: ChosenSword) -> Bool {
        func isValidPosition(row: Int, col: Int) -> Bool {
            return row >= 0 && row < gameboard.panelCount && col >= 0 && col < gameboard.panelCount
        }
        
        @discardableResult
        func addEdgePosition(row: Int, col: Int) -> Bool {
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
        let heroHit: Bool = affectedPanels.contains(where: { $0 == controls.positions.player })
        let explosionType: MagmoorAttacks.ExplosionType

        switch controls.magmoorShield.resetCount {
        case let resetCount where resetCount > 7:
            explosionType = .freeze
            AudioManager.shared.playSound(for: "enemyice")
        case 4, 6, 7:
            explosionType = .poison
            AudioManager.shared.playSound(for: "movepoisoned2")
        default:
            explosionType = .normal
        }
        
        affectedPanels.forEach {
            showDamagePanel(at: $0, explosionType: explosionType, withExplosion: true, extendDamage: heroHit)
        }
        
        //Update health
        if heroHit {
            switch explosionType {
            case .normal:
                let defenseMultiplier: CGFloat = controls.magmoorShield.isFirstRound ? 2 : 1
                health.updateHealth(type: .villainShieldExplode, dmgMultiplier: chosenSword.defenseRating / defenseMultiplier)
            case .poison:
                health.updateHealth(type: .villainAttackPoison, dmgMultiplier: chosenSword.defenseRating)
                health.updateHealth(type: .drainPoison, dmgMultiplier: chosenSword.defenseRating)
            case .freeze:
                affectedPanels.forEach {
                    controls.didPlayerFreeze(position: $0, shouldBypassShield: true, freezeDuration: 6)
                }
                
                health.updateHealth(type: .villainAttackFreeze, dmgMultiplier: chosenSword.defenseRating)
                health.updateHealth(type: .villainShieldExplode, dmgMultiplier: chosenSword.defenseRating / 2)
            }
            
            if !controls.magmoorShield.isFirstRound {
                AudioManager.shared.playSoundThenStop(for: "magicdisappear2", fadeIn: 1, playForDuration: 3, fadeOut: 2, delay: 0.4)
                
                flashOverlay.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.4),
                    SKAction.fadeIn(withDuration: 0),
                    SKAction.wait(forDuration: 1.5),
                    SKAction.fadeOut(withDuration: 2.6)
                ]))
            }
            
            return true
        }
        else {
            return false
        }
    }
    
    private func showDamagePanel(at position: K.GameboardPosition, explosionType: MagmoorAttacks.ExplosionType, withExplosion: Bool, extendDamage: Bool) {
        let pulseDuration: TimeInterval = 0.1
        let damageDuration: TimeInterval
        let damagePanelColor: UIColor
        let shakeAction: SKAction
        
        switch explosionType {
        case .normal:
            damageDuration = extendDamage ? 3.5 : 0.75
            damagePanelColor = .red
            shakeAction = SKAction.fadeOut(withDuration: 1)
        case .freeze:
            damageDuration = extendDamage ? 3.5 : 0.75
            damagePanelColor = .cyan
            shakeAction = SKAction.fadeOut(withDuration: 1)
        case .poison:
            damageDuration = 6.75
            damagePanelColor = .green
            shakeAction = SKAction.sequence([
                SKAction.moveBy(x: 5, y: 0, duration: 0),
                SKAction.group([
                    SKAction.repeat(SKAction.sequence([
                        SKAction.moveBy(x: -10, y: 0, duration: pulseDuration),
                        SKAction.moveBy(x: 10, y: 0, duration: pulseDuration)
                    ]), count: Int(1 / (2 * pulseDuration))),
                    SKAction.fadeOut(withDuration: 1)
                ])
            ])
        }
        
        let damagePanel = SKSpriteNode(imageNamed: "water")
        damagePanel.position = gameboard.getSpritePositionAbsolute(at: position).terrain
        damagePanel.scale(to: gameboard.scaleSize)
        damagePanel.anchorPoint = .zero
        damagePanel.color = damagePanelColor
        damagePanel.colorBlendFactor = 1
        damagePanel.alpha = 0
        damagePanel.zPosition = K.ZPosition.terrain + 6
        
        if explosionType == .poison {
            damagePanel.name = FinalBattle2Spawner.poisonPanelName
        }
        
        //Need to add to the gameboard instead of the terrain in case the terrain's speed = 0 in the Platform stage.
        gameboard.sprite.addChild(damagePanel)
        
        damagePanel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.wait(forDuration: damageDuration),
            shakeAction,
            SKAction.removeFromParent()
        ]))
        
        if withExplosion {
            let particleType: ParticleEngine.ParticleType
            let particleScale: CGFloat
            let particleDuration: TimeInterval
            
            switch explosionType {
            case .normal:
                particleType = .magicElderFire3
                particleScale = UIDevice.spriteScale / CGFloat(gameboard.panelCount)
                particleDuration = 2
            case .freeze:
                particleType = .magicElderIce
                particleScale = 2 * UIDevice.spriteScale / CGFloat(gameboard.panelCount)
                particleDuration = 2
            case .poison:
                particleType = .magicElderEarth2
                particleScale = 2 * UIDevice.spriteScale / CGFloat(gameboard.panelCount)
                particleDuration = 4
            }
            
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
//    // FIXME: - Debug Speed
//    private func updateDebugLabelTest() {
//        timerDebugCount = controls.magmoorShield.isEnraged ? controls.villainMovementDelay.enraged : controls.villainMovementDelay.normal
//        
//        timerDebug.invalidate()
//        timerDebug = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerDebug(_:)), userInfo: nil, repeats: true)
//    }
//    
//    @objc private func updateTimerDebug(_ sender: Any) {
//        guard !panelSpawner.isEmpty else { return }
//        guard timerDebugCount >= 0 else {
//            updateDebugLabelTest()
//            return
//        }
//        
//        var speed: TimeInterval
//        
//        switch panelSpawner[0].currentSpeed {
//        case .slow:     speed = 12
//        case .medium:   speed = 10
//        case .fast:     speed = 8
//        }
//        
//        labelDebug.text = "\(panelSpawner[0].currentSpeed): \(panelSpawner[0].index)\n[RESET: \(controls.magmoorShield.resetCount), HP: \(controls.magmoorShield.hitPoints)]\nTIME: \(timerDebugCount)\nSPEED: \(speed) - \(speed - controls.villainMovementDelay.normal)"
//        
//        timerDebugCount -= 1
//    }
    
    
    
    func didHeroAttack(chosenSword: ChosenSword) {
        health.updateHealth(type: .heroAttack, dmgMultiplier: chosenSword.totalAttackRating)
    }
    
    func didVillainDisappear(fadeDuration: TimeInterval) {
        backgroundPattern.animate(pattern: .blackout, fadeDuration: fadeDuration, delay: nil)
        
        if let finalBattleScene = superScene as? FinalBattleScene {
            switch controls.magmoorShield.resetCount {
            case 4:     finalBattleScene.playDialogue(level: -2500)
            case 8:     finalBattleScene.playDialogue(level: -2501)
            default:    break
            }
        }
    }
    
    func willVillainReappear() {
        backgroundPattern.setOverworldMusicVolume(to: 0.5, fadeDuration: 1)
    }
    
    func didVillainFlee(didReappear: Bool) {
        // FIXME: - Debug Speed
//        updateDebugLabelTest()
        
        
        
        guard didReappear else { return }
        
        if !panelSpawner.isEmpty {
            controls.updateVillainMovementAndAttacks(speed: panelSpawner[0].currentSpeed)
        }
        
        backgroundPattern.updateShieldColor(controls.magmoorShield.shieldColor)
        backgroundPattern.animate(pattern: .wave, fadeDuration: 2, delay: nil, shouldFlashGameboard: true)
    }
    
    func didVillainAttack(pattern: MagmoorAttacks.AttackPattern, chosenSword: ChosenSword, position: K.GameboardPosition) {
        switch pattern {
        case .normal, .freeze, .poison, .sNormal, .sFreeze, .sPoison:
            villainAttackNormal(at: position, pattern: pattern, chosenSword: chosenSword)
        case .timed:
            villainAttackTimed(at: position, isLarge: false, chosenSword: chosenSword)
        case .timedLarge:
            villainAttackTimed(at: position, isLarge: true, chosenSword: chosenSword)
        case .duplicates:
            for i in 0..<panelSpawnerCount {
                panelSpawner[i].showPlatform(shouldShow: true, positions: controls.positions)
            }
        case .castInvincible:
            break
        }
    }
    
    func didDuplicateAttack(pattern: MagmoorAttacks.AttackPattern, chosenSword: ChosenSword, playerPosition: K.GameboardPosition) {
        //Reuse this because... why not??
        didVillainAttack(pattern: pattern, chosenSword: chosenSword, position: playerPosition)
    }
    
    func didExplodeDuplicate(chosenSword: ChosenSword) {
        health.updateHealth(type: .destroyDuplicate, dmgMultiplier: nil)
    }
    
    func didVillainAttackBecomeVisible() {
        for i in 0..<panelSpawnerCount {
            panelSpawner[i].showPlatform(shouldShow: false, positions: controls.positions)
        }
    }
    
    func notifyUpdateSword8(isRunningSword8: Bool) {
        backgroundPattern.isRunningSword8 = isRunningSword8
        health.isRunningSword8 = isRunningSword8
    }
    
    func handleShield(willDamage: Bool, didDamage: Bool, willBreak: Bool, didBreak: Bool, fadeDuration: TimeInterval?, chosenSword: ChosenSword, villainPosition: K.GameboardPosition?) {
        
        backgroundPattern.updateShieldColor(controls.magmoorShield.shieldColor)
        
        if willDamage {
            backgroundPattern.animate(pattern: .convulse, fadeDuration: 0.04, delay: nil)
        }
        else if didDamage {
            if !panelSpawner.isEmpty {
                controls.updateVillainMovementAndAttacks(speed: panelSpawner[0].currentSpeed)
            }
            
            
            
            // FIXME: - Debug Speed
//            updateDebugLabelTest()
            
            
            
            backgroundPattern.animate(pattern: .wave, fadeDuration: 2, delay: nil)
        }
        else if willBreak {
            let fadeDuration = fadeDuration ?? 0

            bloodOverlay.run(SKAction.fadeOut(withDuration: fadeDuration))
            flashGameboard.run(SKAction.fadeOut(withDuration: fadeDuration))
            
            if !controls.magmoorShield.isFirstRound {
                backgroundPattern.setOverworldMusicVolume(to: 0, fadeDuration: fadeDuration)
            }
        }
        else if didBreak {
            let villainPosition = villainPosition ?? (0, 0)
            let didAffectPlayer = shieldExplodeDamagePanels(at: villainPosition, chosenSword: chosenSword)
            
            if panelSpawner[0].currentSpeed == .fast {
                backgroundPattern.setOverworldMusicSpeed(to: 1.2)
            }
            
            backgroundPattern.animate(pattern: .normal,
                                      fadeDuration: didAffectPlayer ? 3 : 2,
                                      delay: didAffectPlayer ? 2.5 : nil,
                                      shouldFlashGameboard: true)
        }
    }
    
    func didCollectDuplicateDroppedItem(item: LevelType, chosenSword: ChosenSword) {
        switch item {
        case .heart:
            health.updateHealth(type: .healthUp, dmgMultiplier: nil)
        case .sword2x, .sword3x, .swordInf, .wingedboot, .shield:
            guard let superScene = superScene else { return }
            
            let hudOrigin = CGPoint(x: gameboard.sprite.position.x, y: K.ScreenDimensions.topOfGameboard + StatusBarSprite.defaultBarHeight + 4)
            
            DuplicateItem.shared.displayProgressBarHUD(on: superScene, at: hudOrigin)
        default:
            break
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
        guard spawnPanel == controls.positions.player
                && !safeOrPlatformFound()
                && !namePanelFound(FinalBattle2Spawner.poisonPanelName)
                && !startPanelFound()
                && !endPanelFound()
                && !controls.duplicateItemTimerManager.isRunningBoot
        else { return }
        
        health.updateHealth(type: .drain, dmgMultiplier: controls.chosenSword.defenseRating)
    }
    
    func didChangeSpeed(speed: FinalBattle2Spawner.SpawnerSpeed) {
        controls.updateVillainMovementAndAttacks(speed: speed)
    }
    
    
}


// MARK: - FinalBattle2HealthDelegate

extension FinalBattle2Engine: FinalBattle2HealthDelegate {
    // TODO: - Disabling dynamic defaultBloodOverlayAlpha adjustment, for now... 2/21/25
    func didUpdateHealth(_ healthCounter: Counter, increment: TimeInterval, damping: TimeInterval) {
//        switch healthCounter.getCount() {
//        case let health where health < 0.10:    FinalBattle2Background.defaultBloodOverlayAlpha = 0.5
//        case let health where health < 0.15:    FinalBattle2Background.defaultBloodOverlayAlpha = 0.45
//        case let health where health < 0.20:    FinalBattle2Background.defaultBloodOverlayAlpha = 0.4
//        case let health where health < 0.25:    FinalBattle2Background.defaultBloodOverlayAlpha = 0.35
//        default:                                FinalBattle2Background.defaultBloodOverlayAlpha = 0.25
//        }
//        
//        guard !panelSpawner.isEmpty else { return }
//        
//        let intensityMultiplier: CGFloat
//        
//        switch panelSpawner[0].currentSpeed {
//        case .slow:     intensityMultiplier = 0.5
//        case .medium:   intensityMultiplier = 0.75
//        case .fast:     intensityMultiplier = 1
//        }
//        
//        FinalBattle2Background.defaultBloodOverlayAlpha *= intensityMultiplier
        
        
        
//        // FIXME: - labelDebug DEBUG
//        let inc = round(increment * 1000) / 1000
//        let damp = round(damping * 100) / 100
//        let damage = round(increment * damping * 1000) / 1000
//        let health = round(healthCounter.getCount() * 100) / 100
//        let multiplier = controls.chosenSword.attackMultiplier
//        
//        labelDebug.text = "INC: \(inc), DAMPING: \(damp)\nDAMAGE: \(damage)\nHEALTH: \(health)\nX: \(multiplier)"
        
        labelDebug.text = "HEALTH: \(healthCounter.getCount() * 100)\nPANELS: \(panelSpawner[0].currentIndex) \(panelSpawner[0].currentSpeed)\nRESET COUNT: \(controls.magmoorShield.resetCount)"
    }
    
}
