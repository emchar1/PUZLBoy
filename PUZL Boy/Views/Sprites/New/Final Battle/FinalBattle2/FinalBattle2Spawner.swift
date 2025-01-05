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
}

class FinalBattle2Spawner {
    
    // MARK: - Properties
    
    static let startPosition: K.GameboardPosition = (6, 3)
    static let endPosition: K.GameboardPosition = (3, 3)
    
    // FIXME: - NO!!!
    private let maxCount: Int = 1000
    
    private var gameboard: GameboardSprite
    private var spawnPanelCount: Int?
    private var spawnPanels: [[K.GameboardPosition]]?
    
    weak var delegate: FinalBattle2SpawnerDelegate?

    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite) {
        self.gameboard = gameboard
    }
    
    
    // MARK: - Functions
    
    /**
     Populates the Spawner.
     - parameter spawnPanelCount: the number of spawner tiles
     */
    func populateSpawner(spawnPanelCount: Int) {
        self.spawnPanelCount = max(1, spawnPanelCount)
        spawnPanels = Array(repeating: [], count: spawnPanelCount)
        
        let spawnPanelRange: Range<Int> = 0..<spawnPanelCount
        
        spawnPanelRange.forEach { i in
            populateSpawnPanels(spawnPanels: &spawnPanels![i],
                                startPosition: FinalBattle2Spawner.startPosition,
                                ignorePositions: [FinalBattle2Spawner.startPosition, FinalBattle2Spawner.endPosition],
                                maxCount: maxCount)
        }
    }
    
    /**
     Animates the Spawner.
     - parameter speed:
     */
    func animateSpawner(speed: TimeInterval) {
        guard let spawnPanelCount = spawnPanelCount, let spawnPanels = spawnPanels else { return print("Need to call populateSpawner() first!") }
        
        let terrainPanel: LevelType = FireIceTheme.isFire ? .sand : .snow
        let spawnPanelRange: Range<Int> = 0..<spawnPanelCount

        spawnPanelRange.forEach { i in
            animateSpawnPanels(spawnPanels: spawnPanels[i], with: terrainPanel, waitDuration: speed)
        }
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Populates the spawnPanels array with randomized "moving" panels
     - parameters:
        - spawnPanels: the array that is to be mutated and sent back to the argument passed
        - startPosition: origin of the spawer.
        - ignorePositions: i.e. start, endPanels, etc.
        - count: LEAVE ALONE! This is to be used by the recursive function only!!
        - maxCount: number of position elements to add to the array
     */
    private func populateSpawnPanels(spawnPanels: inout [K.GameboardPosition], startPosition: K.GameboardPosition, ignorePositions: [K.GameboardPosition] = [], count: Int = 0, maxCount: Int = 1000) {
        
        //Base case
        guard count < maxCount else { return }
        
        let nextPosition = spawnNextPosition(startPosition: startPosition, ignorePositions: ignorePositions)
        spawnPanels.append(nextPosition)
        
        let spawnPanelsIgnoreSize: Int = 2
        let spawnPanelsToIgnore = spawnPanels.count >= spawnPanelsIgnoreSize ? Array(spawnPanels.suffix(spawnPanelsIgnoreSize)) : []
        
        //Recursion!
        populateSpawnPanels(spawnPanels: &spawnPanels,
                            startPosition: nextPosition,
                            ignorePositions: [FinalBattle2Spawner.startPosition, FinalBattle2Spawner.endPosition] + spawnPanelsToIgnore,
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
    private func animateSpawnPanels(spawnPanels: [K.GameboardPosition], with terrain: LevelType, waitDuration: TimeInterval) {
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
                    self?.delegate?.didSpawnSafePanel(spawnPanel: spawnPanel)
                    handleParticles(spawnPanel: spawnPanel)
                },
                SKAction.fadeIn(withDuration: waitDuration * 0.25),
                SKAction.wait(forDuration: waitDuration * 2.75),
                dissolveTerrainAction(pulseDuration: 0.1),
                SKAction.removeFromParent()
            ])) { [weak self] in
                self?.delegate?.didDespawnSafePanel(spawnPanel: spawnPanel)
            }
        }//end for
    }//end animateSpawnPanels()
    
    
}
