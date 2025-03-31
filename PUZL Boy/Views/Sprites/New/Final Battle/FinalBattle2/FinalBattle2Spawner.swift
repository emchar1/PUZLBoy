//
//  FinalBattle2Spawner.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/4/25.
//

import SpriteKit

protocol FinalBattle2SpawnerDelegate: AnyObject {
    func didSpawnSafePanel(spawnPanel: K.GameboardPosition, index: Int)
    func didDespawnSafePanel(spawnPanel: K.GameboardPosition, index: Int)
    func didChangeSpeed(speed: FinalBattle2Spawner.SpawnerSpeed)
}

class FinalBattle2Spawner {
    
    // MARK: - Properties
    
    static let safePanelName: String = "safePanel"
    static let platformPanelName: String = "platformPanel"
    static let poisonPanelName: String = "poisonPanel"
    static let keyParticleNodeFade = "particleNodeFade"
    static let startPosition: K.GameboardPosition = (6, 3)
    static let endPosition: K.GameboardPosition = (3, 3)
    static var isPlatformOn: Bool = false
    
    //IMPORTANT!! breakLimit should be a multiple of maxCount!! These are panel spawning speed and max panels properties
    private let maxCount: Int = 1000
    private let breakLimit: Int = 75
    private var animationDuration: TimeInterval { currentSpeed.rawValue }
    private(set) var currentSpeed: SpawnerSpeed = .slow {
        didSet {
            delegate?.didChangeSpeed(speed: currentSpeed)
        }
    }
    
    private var gameboard: GameboardSprite
    private var spawnPanels: [K.GameboardPosition]
    private var ignorePositions: [K.GameboardPosition]
    
    weak var delegate: FinalBattle2SpawnerDelegate?
    
    enum SpawnerSpeed: TimeInterval {
        case slow = 3.0
        case medium = 2.0
        case fast = 1.0
    }

    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite) {
        self.gameboard = gameboard
        self.spawnPanels = []
        self.ignorePositions = [FinalBattle2Spawner.startPosition, FinalBattle2Spawner.endPosition]
        
        if let startPanel = gameboard.getPanelSprite(at: FinalBattle2Spawner.startPosition).terrain {
            let panel = SKSpriteNode(imageNamed: "start")
            panel.anchorPoint = .zero
            panel.zPosition = 4
            startPanel.addChild(panel)
        }
        
        if let endPanel = gameboard.getPanelSprite(at: FinalBattle2Spawner.endPosition).terrain {
            let panel = SKSpriteNode(imageNamed: "endClosed")
            panel.anchorPoint = .zero
            panel.zPosition = 4
            endPanel.addChild(panel)
        }
    }
    
    deinit {
        print("deinit FinalBattle2Spawner")
    }
    
    
    // MARK: - Functions
    
    /**
     Populates the Spawner.
     */
    func populateSpawner() {
        populateSpawnPanels()
    }
    
    /**
     Animates the Spawner, initialized to speed = 3.
     */
    func animateSpawner() {
        let terrainPanel: LevelType = FireIceTheme.levelTypeSandSnow
        
        animateSpawnPanels(with: terrainPanel)
    }
    
    /**
     Installs a platform covering the entire gameboard, which is safe to stand on.
     - parameters:
        - shouldShow: determines whether to animate showing of the platform or hiding of the platform.
        - positions: player and villain positions at time of function call (only the villain position is needed).
     */
    func showPlatform(shouldShow: Bool, positions: FinalBattle2Controls.PlayerPositions) {
        animateShowPlatform(shouldShow: shouldShow, positions: positions)
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Populates the spawnPanels array with randomized "moving" panels
     */
    private func populateSpawnPanels() {
        func spawnNextPosition(startPosition: K.GameboardPosition, ignorePositions: [K.GameboardPosition]) -> K.GameboardPosition {
            var nextPosition: K.GameboardPosition
            
            repeat {
                let spawnCol = Bool.random()
                let spawnOffset = Bool.random() ? -1 : 1
                
                nextPosition = (startPosition.row + (spawnCol ? 0 : spawnOffset), startPosition.col + (spawnCol ? spawnOffset : 0))
            }
            while nextPosition.row < 0
                    || nextPosition.row >= gameboard.panelCount
                    || nextPosition.col < 0
                    || nextPosition.col >= gameboard.panelCount
                    || ignorePositions.contains { $0 == nextPosition }
            
            return nextPosition
        }
        
        
        let spawnPanelsIgnoreSize: Int = 2
        var startPosition = FinalBattle2Spawner.startPosition
        
        for _ in 0..<maxCount {
            let spawnPanelsToIgnore: [K.GameboardPosition] = self.ignorePositions + (self.spawnPanels.count >= spawnPanelsIgnoreSize ? Array(self.spawnPanels.suffix(spawnPanelsIgnoreSize)) : [])
            
            let nextPosition = spawnNextPosition(startPosition: startPosition, ignorePositions: spawnPanelsToIgnore)
            self.spawnPanels.append(nextPosition)
            
            startPosition = nextPosition
        }
    }
    
    /**
     Helper function that animates the spawn panels (recursively) with the specified terrain panel.
     - parameters:
        - terrain: LevelType that is to be spawned
        - index: current index for spawnPanels. LEAVE ALONE! This is to be used by the recursive function only!!
     */
    private func animateSpawnPanels(with terrain: LevelType, index: Int = 0) {
        //Recursive base case
        guard index < self.spawnPanels.count else { return }
        
        let spawnPanel = self.spawnPanels[index]
        
        guard let originalTerrain = gameboard.getPanelSprite(at: spawnPanel).terrain else { return }
        
        let newTerrain = SKSpriteNode(imageNamed: terrain.description)
        newTerrain.anchorPoint = .zero
        newTerrain.alpha = 0
        newTerrain.zPosition = 4
        newTerrain.name = FinalBattle2Spawner.safePanelName
        
        originalTerrain.addChild(newTerrain)
        
        newTerrain.run(SKAction.sequence([
            SKAction.run { [weak self] in
                self?.delegate?.didSpawnSafePanel(spawnPanel: spawnPanel, index: index)
                self?.handleParticles(spawnPanel: spawnPanel)
            },
            SKAction.fadeIn(withDuration: animationDuration * 0.25),
            SKAction.wait(forDuration: animationDuration * 0.75),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                
                calculateSpawnerSpeed(index: index)
                
                //Recursive call
                animateSpawnPanels(with: terrain, index: index + 1)
            },
            SKAction.wait(forDuration: animationDuration * 2),
            dissolveTerrainAction(reverse: false),
            SKAction.removeFromParent()
        ])) { [weak self] in
            self?.delegate?.didDespawnSafePanel(spawnPanel: spawnPanel, index: index)
        }
    } //end animateSpawnPanels()
    
    /**
     Animates the showing/hiding of the platform.
     - parameters:
        - shouldShow: determines whether to animate showing of the platform or hiding of the platform.
        - positions: player and villain positions at time of function call (only the villain position is needed).
     */
    private func animateShowPlatform(shouldShow: Bool, positions: FinalBattle2Controls.PlayerPositions) {
        for row in 0..<gameboard.panelCount {
            for col in 0..<gameboard.panelCount {
                let panel: K.GameboardPosition = (row: row, col: col)
                
                guard panel != FinalBattle2Spawner.startPosition && panel != FinalBattle2Spawner.endPosition else { continue }
                guard let terrainPanel = gameboard.getPanelSprite(at: panel).terrain else { continue }
                
                if shouldShow {
                    let waitFactor: Int = abs(positions.villain.col - col) + abs(positions.villain.row - row)
                    let waitDuration: TimeInterval = TimeInterval(waitFactor) / TimeInterval(gameboard.panelCount)
                    let fadeDuration: TimeInterval = 0.25
                    
                    let platformPanel = SKSpriteNode(imageNamed: FireIceTheme.levelTypeSandSnow.description)
                    platformPanel.anchorPoint = .zero
                    platformPanel.alpha = 0
                    platformPanel.zPosition = 5
                    platformPanel.name = FinalBattle2Spawner.platformPanelName
                    
                    //IMPORTANT!! Only add platform once, i.e. the first spawner, if there are multiple spawners running!
                    if !FinalBattle2Spawner.isPlatformOn {
                        terrainPanel.addChild(platformPanel)
                    }
                    
                    platformPanel.run(SKAction.sequence([
                        SKAction.wait(forDuration: waitDuration),
                        SKAction.fadeIn(withDuration: fadeDuration)
                    ])) { [weak self] in
                        terrainPanel.speed = 0
                        self?.delegate?.didSpawnSafePanel(spawnPanel: panel, index: -1)
                    }
                }
                else {
                    guard let platformPanel = terrainPanel.childNode(withName: FinalBattle2Spawner.platformPanelName) else { continue }
                    
                    terrainPanel.speed = 1
                    
                    platformPanel.run(SKAction.sequence([
                        dissolveTerrainAction(reverse: row % 2 == 0),
                        SKAction.removeFromParent()
                    ])) { [weak self] in
                        self?.delegate?.didDespawnSafePanel(spawnPanel: panel, index: -1)
                    }
                }
                
                //This needs to go at the end of the for-for loop!!
                terrainPanel.childNode(withName: FinalBattle2Spawner.safePanelName)?.isHidden = shouldShow
            }
        }
        
        //This needs to go at the end AFTER the for-for loop!!
        FinalBattle2Spawner.isPlatformOn = shouldShow
        
        //Don't forget to hide the lava bubbles when the platform comes on, and vice versa!!!
        for particleNode in gameboard.sprite.children {
            guard let name = particleNode.name, name.hasPrefix(ParticleEngine.nodeNamePrefix) else { continue }
            
            particleNode.isHidden = shouldShow
        }
    } //end animateShowPlatform()
    
    /**
     SKAction that animates dissolving of primary (sand/snow) panel to secondary (lava/water).
     - parameter reverse: if true, reverses the dissolve animation from right to left instead of left to right. Adds variety to the visual.
     - returns: an SKAction of the dissolving terrain.
     */
    private func dissolveTerrainAction(reverse: Bool) -> SKAction {
        let offsetDuration: TimeInterval = 0 //DON'T TOUCH THIS LEAVE AT 0!!!
        let pulseDuration: TimeInterval = 0.1
        let sandShift: CGFloat = 10 * (reverse ? -1 : 1)
        let animationDuration = SpawnerSpeed.slow.rawValue
        
        let sandAction = SKAction.sequence([
            SKAction.moveBy(x: sandShift / 2, y: 0, duration: offsetDuration),
            SKAction.group([
                SKAction.repeat(SKAction.sequence([
                    SKAction.moveBy(x: -sandShift, y: 0, duration: pulseDuration),
                    SKAction.moveBy(x: sandShift, y: 0, duration: pulseDuration)
                ]), count: Int(animationDuration / (2 * pulseDuration))),
                SKAction.fadeOut(withDuration: animationDuration)
            ])
        ])
        
        let snowAction = SKAction.sequence([
            SKAction.repeat(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.6, duration: pulseDuration),
                SKAction.fadeAlpha(to: 0.8, duration: pulseDuration)
            ]), count: Int(animationDuration / (2 * pulseDuration))),
            SKAction.fadeOut(withDuration: offsetDuration)
        ])
        
        return FireIceTheme.isFire ? sandAction : snowAction
    }
    
    /**
     Handles particles for sand-lava or snow-water (depending on fire/ice).
     - parameter spawnPanel: the panel position in which to handle the particles.
     */
    private func handleParticles(spawnPanel: K.GameboardPosition) {
        if FireIceTheme.isFire {
            for node in gameboard.sprite.children {
                guard node.name == ParticleEngine.getNodeName(at: spawnPanel) else { continue }
                
                node.removeAction(forKey: FinalBattle2Spawner.keyParticleNodeFade)
                node.alpha = 0
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: animationDuration * 3),
                    SKAction.fadeIn(withDuration: animationDuration)
                ]), withKey: FinalBattle2Spawner.keyParticleNodeFade)
                
                break
            }
        }
        else {
            ParticleEngine.shared.animateParticles(type: .snowfall,
                                                   toNode: gameboard.sprite,
                                                   position: gameboard.getLocation(at: spawnPanel),
                                                   scale: 3 / CGFloat(gameboard.panelCount),
                                                   nameGameboardPosition: spawnPanel,
                                                   duration: animationDuration * 3 + animationDuration)
        }
    }
    
    /**
     Calculates the spawner speed based on current index and breakLimit.
     - parameter index: current spawned panel index.
     - note: This function should only be used in private function, FinalBattle2Spawner.animateSpawnPanels() because it is the only function that keeps track of the current spawned panel index.
     */
    private func calculateSpawnerSpeed(index: Int) {
        switch index {
        case 0 * breakLimit:    currentSpeed = .slow
        case 1 * breakLimit:    currentSpeed = .medium
        case 2 * breakLimit:    currentSpeed = .fast
        default:                break
        }
    }
    
    
}
