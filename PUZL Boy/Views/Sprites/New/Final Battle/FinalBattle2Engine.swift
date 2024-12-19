//
//  FinalBattle2Engine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/15/24.
//

import SpriteKit

class FinalBattle2Engine {
    
    // MARK: - Properties
    
    private(set) var gameEngine: GameEngine!

    private let startPosition: K.GameboardPosition = (6, 3)
    private let ignorePositions: [K.GameboardPosition] = [(3, 3), (6, 3)]
    private let maxCount: Int = 1000

    private var spawnPanels0: [K.GameboardPosition] = []
    private var spawnPanels1: [K.GameboardPosition] = []
    private var spawnPanels2: [K.GameboardPosition] = []
    
    
    // MARK: - Initialization
    
    init() {
        setupScene()
    }
    
    deinit {
        print("FinalBattle2Engine deinit")
    }
    
    private func setupScene() {
        gameEngine = GameEngine(level: Level.finalLevel + 1, shouldSpawn: true)
        
        //Make sure to initialize GameboardSprite BEFORE initializing these!!!
        populateSpawnPanels(spawnPanels: &spawnPanels0, startPosition: startPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels1, startPosition: startPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels2, startPosition: startPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        
        animatePanels(spawnPanels: spawnPanels0, with: .start)
//        animatePanels(spawnPanels: spawnPanels1, with: .start)
//        animatePanels(spawnPanels: spawnPanels2, with: .start)
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        gameEngine.moveSprites(to: superScene)
    }
    
    
    // MARK: - Functions
    
    func populateSpawnPanels(spawnPanels: inout [K.GameboardPosition], startPosition: K.GameboardPosition, ignorePositions: [K.GameboardPosition] = [], count: Int = 0, maxCount: Int = 100) {
        
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
        } while nextPosition.row < 0 || nextPosition.row >= gameEngine.gameboardSprite.panelCount || nextPosition.col < 0 || nextPosition.col >= gameEngine.gameboardSprite.panelCount || ignorePositions.contains { $0.row == nextPosition.row && $0.col == nextPosition.col }
        
        return nextPosition
    }
    
    // TODO: - WIP
    private func animatePanels(spawnPanels: [K.GameboardPosition], with terrain: LevelType) {
        for (i, spawnPanel) in spawnPanels.enumerated() {
            guard let originalTerrain = gameEngine.gameboardSprite.getPanelSprite(at: spawnPanel).terrain else { continue }

            let waitDuration: TimeInterval = 0.1
            let newTerrain = SKSpriteNode(imageNamed: terrain.description)

            newTerrain.anchorPoint = .zero
            newTerrain.alpha = 0
            newTerrain.zPosition = 1
            originalTerrain.addChild(newTerrain)
            
            newTerrain.run(SKAction.sequence([
                SKAction.wait(forDuration: waitDuration * TimeInterval(i)),
                SKAction.fadeIn(withDuration: 0),
                SKAction.wait(forDuration: waitDuration),
                SKAction.fadeOut(withDuration: waitDuration * 10),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    
}
