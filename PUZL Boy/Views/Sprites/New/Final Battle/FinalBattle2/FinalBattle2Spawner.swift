//
//  FinalBattle2Spawner.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/4/25.
//

import SpriteKit

protocol FinalBattle2SpawnerDelegate: AnyObject {
    func didSpawnSafePanel(spawnPanel: K.GameboardPosition)
    func didDespawnSafePanel(spawnPanel: K.GameboardPosition)
    func didChangeSpeed(speed: FinalBattle2Spawner.SpawnerSpeed)
}

class FinalBattle2Spawner {
    
    // MARK: - Properties
    
    static let startPosition: K.GameboardPosition = (6, 3)
    static let endPosition: K.GameboardPosition = (3, 3)
    
    //IMPORTANT!! breakLimit should be a multiple of maxCount!! These are panel spawning speed and max panels properties
    private let maxCount: Int = 1000
    private let breakLimit: Int = 50
    private var animationDuration: TimeInterval = 3
    private(set) var currentSpeed: SpawnerSpeed = .slow {
        didSet {
            delegate?.didChangeSpeed(speed: currentSpeed)
        }
    }
    
    private var gameboard: GameboardSprite
    private var spawnPanels: [K.GameboardPosition]
    private var ignorePositions: [K.GameboardPosition]
    
    weak var delegate: FinalBattle2SpawnerDelegate?
    
    enum SpawnerSpeed {
        case slow, medium, fast
    }

    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite) {
        self.gameboard = gameboard
        self.spawnPanels = []
        self.ignorePositions = [FinalBattle2Spawner.startPosition, FinalBattle2Spawner.endPosition]
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
        let terrainPanel: LevelType = FireIceTheme.isFire ? .sand : .snow
        
        animateSpawnPanels(with: terrainPanel)
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
            } while nextPosition.row < 0 || nextPosition.row >= gameboard.panelCount || nextPosition.col < 0 || nextPosition.col >= gameboard.panelCount || ignorePositions.contains { $0 == nextPosition }
            
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
     Helper function that animates the spawn panels (iteratively) with the specified terrain panel.
     - parameter terrain: LevelType that is to be spawned
     */
    private func animateSpawnPanels(with terrain: LevelType) {
        ///SKAction that animates dissolving of primary (sand/snow) panel to secondary (lava/water).
        func dissolveTerrainAction(pulseDuration: TimeInterval) -> SKAction {
            let offsetDuration: TimeInterval = 0 //DON'T TOUCH THIS LEAVE AT 0!!!
            
            let sandAction = SKAction.sequence([
                SKAction.moveBy(x: 5, y: 0, duration: offsetDuration),
                SKAction.group([
                    SKAction.repeat(SKAction.sequence([
                        SKAction.moveBy(x: -10, y: 0, duration: pulseDuration),
                        SKAction.moveBy(x: 10, y: 0, duration: pulseDuration)
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
        
        ///Handles particles for sand-lava or snow-water (depending on fire/ice).
        func handleParticles(spawnPanel: K.GameboardPosition) {
            if FireIceTheme.isFire {
                for node in gameboard.sprite.children {
                    guard node.name == ParticleEngine.getNodeName(at: spawnPanel) else { continue }
                    
                    node.removeAction(forKey: "particleNodeFade")
                    node.alpha = 0
                    node.run(SKAction.sequence([
                        SKAction.wait(forDuration: animationDuration * 3),
                        SKAction.fadeIn(withDuration: animationDuration)
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
                                                       duration: animationDuration * 3 + animationDuration)
            }
        }
        
        for (i, spawnPanel) in spawnPanels.enumerated() {
            guard let originalTerrain = gameboard.getPanelSprite(at: spawnPanel).terrain else { continue }
            
            let fadeInWaitDuration = animationDuration * 0.25 + animationDuration * 0.75
            
            let newTerrain = SKSpriteNode(imageNamed: terrain.description)
            newTerrain.anchorPoint = .zero
            newTerrain.alpha = 0
            newTerrain.zPosition = 4
            newTerrain.name = "safePanel"
            
            originalTerrain.addChild(newTerrain)
            
            newTerrain.run(SKAction.sequence([
                SKAction.wait(forDuration: fadeInWaitDuration * TimeInterval(i)),
                SKAction.run { [weak self] in
                    self?.delegate?.didSpawnSafePanel(spawnPanel: spawnPanel)
                    handleParticles(spawnPanel: spawnPanel)
                },
                SKAction.fadeIn(withDuration: animationDuration * 0.25),
                SKAction.wait(forDuration: animationDuration * 0.75),
                SKAction.run { [weak self] in
                    self?.calculateSpawnerSpeed(index: i)
                },
                SKAction.wait(forDuration: animationDuration * 2),
                dissolveTerrainAction(pulseDuration: 0.1),
                SKAction.removeFromParent()
            ])) { [weak self] in
                self?.delegate?.didDespawnSafePanel(spawnPanel: spawnPanel)
            }
        } //end for
    } //end animateSpawnPanels()
    
    /**
     Calculates the spawner speed based on current index and breakLimit.
     - parameter index: current spawned panel index.
     - note: This function should only be used in private function, FinalBattle2Spawner.animateSpawnPanels() because it is the only function that keeps track of the current spawned panel index.
     */
    private func calculateSpawnerSpeed(index: Int) {
        switch index {
        case 0 * breakLimit:
            currentSpeed = .slow
            animationDuration = 3
        case 1 * breakLimit:
            currentSpeed = .medium
            animationDuration = 2
        case 3 * breakLimit:
            currentSpeed = .fast
            animationDuration = 1
        default:
            break
        }
    }
    
    
}
