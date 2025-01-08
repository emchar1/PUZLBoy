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
    private var spawnPanelCount: Int
    private var spawnPanels: [[K.GameboardPosition]]

    private var spawnPanelRange: Range<Int> {
        0..<spawnPanelCount
    }
    
    weak var delegate: FinalBattle2SpawnerDelegate?

    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, spawnPanelCount: Int) {
        self.gameboard = gameboard
        self.spawnPanelCount = max(1, spawnPanelCount)
        self.spawnPanels = Array(repeating: [], count: spawnPanelCount)
    }
    
    
    // MARK: - Functions
    
    /**
     Populates the Spawner.
     */
    func populateSpawner() {
        spawnPanelRange.forEach { spawnPanelIndex in
            populateSpawnPanels(spawnPanelIndex: spawnPanelIndex,
                                startPosition: FinalBattle2Spawner.startPosition,
                                ignorePositions: [FinalBattle2Spawner.startPosition, FinalBattle2Spawner.endPosition],
                                maxCount: maxCount)
        }
    }
    
    /**
     Animates the Spawner.
     - parameter speed: speed at which safe panels drop off; the higher the number, the slower the drop-off
     */
    func animateSpawner(speed: TimeInterval) {
        let terrainPanel: LevelType = FireIceTheme.isFire ? .sand : .snow
        
        spawnPanelRange.forEach { spawnPanelIndex in
            animateSpawnPanels(spawnPanelIndex: spawnPanelIndex, with: terrainPanel, waitDuration: speed)
        }
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Populates the spawnPanels array with randomized "moving" panels
     - parameters:
        - spawnPanelIndex: the array index that is to be populated
        - startPosition: origin of the spawer.
        - ignorePositions: i.e. start, endPanels, etc.
        - count: LEAVE ALONE! This is to be used by the recursive function only!!
        - maxCount: number of position elements to add to the array
     */
    private func populateSpawnPanels(spawnPanelIndex: Int, startPosition: K.GameboardPosition, ignorePositions: [K.GameboardPosition] = [], count: Int = 0, maxCount: Int = 1000) {
        
        //Base case
        guard count < maxCount else { return }
        
        let nextPosition = spawnNextPosition(startPosition: startPosition, ignorePositions: ignorePositions)
        self.spawnPanels[spawnPanelIndex].append(nextPosition)
        
        let spawnPanelsIgnoreSize: Int = 2
        let spawnPanelsToIgnore = self.spawnPanels[spawnPanelIndex].count >= spawnPanelsIgnoreSize ? Array(self.spawnPanels[spawnPanelIndex].suffix(spawnPanelsIgnoreSize)) : []
        
        //Recursion!
        populateSpawnPanels(spawnPanelIndex: spawnPanelIndex,
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
    private func animateSpawnPanels(spawnPanelIndex: Int, with terrain: LevelType, index: Int = 0, waitDuration: TimeInterval) {
        //Recursive base case
        guard index < self.spawnPanels[spawnPanelIndex].count else {
            self.spawnPanels[spawnPanelIndex].removeAll()
            return
        }
        
        let spawnPanel = self.spawnPanels[spawnPanelIndex][index]
        
        guard let originalTerrain = gameboard.getPanelSprite(at: spawnPanel).terrain else { return }
        
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
        
        
        let newTerrain = SKSpriteNode(imageNamed: terrain.description)
        newTerrain.anchorPoint = .zero
        newTerrain.alpha = 0
        newTerrain.zPosition = 4
        newTerrain.name = "safePanel"
        
        originalTerrain.addChild(newTerrain)
        
        newTerrain.run(SKAction.sequence([
            SKAction.run { [weak self] in
                self?.delegate?.didSpawnSafePanel(spawnPanel: spawnPanel)
                handleParticles(spawnPanel: spawnPanel)
            },
            SKAction.fadeIn(withDuration: waitDuration * 0.25),
            SKAction.wait(forDuration: waitDuration * 0.75),
            SKAction.run { [weak self] in
                //Recursive call
                self?.animateSpawnPanels(spawnPanelIndex: spawnPanelIndex, with: terrain, index: index + 1, waitDuration: waitDuration)
            },
            SKAction.wait(forDuration: waitDuration * 2),
            dissolveTerrainAction(pulseDuration: 0.1),
            SKAction.removeFromParent()
        ])) { [weak self] in
            self?.delegate?.didDespawnSafePanel(spawnPanel: spawnPanel)
        }
    }//end animateSpawnPanels()
    
    
}
