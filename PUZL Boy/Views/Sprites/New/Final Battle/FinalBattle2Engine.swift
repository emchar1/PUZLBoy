//
//  FinalBattle2Engine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/15/24.
//

import SpriteKit

class FinalBattle2Engine {
    
    // MARK: - Properties
    
    private(set) var gameboard: GameboardSprite!
    private(set) var hero: Player!
    private(set) var villain: Player!
    
    private let size: CGSize
    private let startPosition: K.GameboardPosition = (6, 3)
    private let ignorePositions: [K.GameboardPosition] = [(3, 3), (6, 3)]
    private let maxCount: Int = 1000
    
    private var spawnPanels0: [K.GameboardPosition] = []
    private var spawnPanels1: [K.GameboardPosition] = []
    private var spawnPanels2: [K.GameboardPosition] = []
    
    
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
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboard.getLocation(at: startPosition)
        hero.sprite.setScale(playerScale * hero.scaleMultiplier)
        hero.sprite.zPosition = K.ZPosition.player
        
        villain = Player(type: .villain)
        villain.sprite.position = gameboard.getLocation(at: (3, 3)) + CGPoint(x: 0, y: 50)
        villain.sprite.setScale(playerScale * villain.scaleMultiplier)
        villain.sprite.xScale *= -1
        villain.sprite.zPosition = K.ZPosition.player - 2

        populateSpawnPanels(spawnPanels: &spawnPanels0, startPosition: startPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels1, startPosition: startPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels2, startPosition: startPosition, ignorePositions: ignorePositions, maxCount: maxCount)
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        superScene.addChild(gameboard.sprite)
        
        gameboard.sprite.addChild(hero.sprite)
        gameboard.sprite.addChild(villain.sprite)
    }
    
    
    // MARK: - Functions
    
    func safePanelFound(in nodes: [SKNode]) -> Bool {
        let terrainName = GameboardSprite.getNodeName(row: startPosition.row, col: startPosition.col)
        
        return nodes.contains(where: { $0.name == "safePanel" || $0.name == terrainName })
    }
    
    ///Animates all the components
    func animateSprites() {
        hero.sprite.run(Player.animate(player: hero, type: .idle))
        villain.sprite.run(Player.animateIdleLevitate(player: villain))

        animateSpawnPanels(spawnPanels: spawnPanels0, with: .start)
//        animateSpawnPanels(spawnPanels: spawnPanels1, with: .start)
//        animateSpawnPanels(spawnPanels: spawnPanels2, with: .start)
    }
    
    
    // MARK: - Helper Functions
    
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

            let waitDuration: TimeInterval = 1
            let newTerrain = SKSpriteNode(imageNamed: terrain.description)

            newTerrain.anchorPoint = .zero
            newTerrain.alpha = 0
            newTerrain.zPosition = 1
            newTerrain.name = "safePanel"
            
            originalTerrain.addChild(newTerrain)
            
            newTerrain.run(SKAction.sequence([
                SKAction.wait(forDuration: waitDuration * TimeInterval(i)),
                SKAction.fadeIn(withDuration: 0),
                SKAction.wait(forDuration: waitDuration * 3),
                SKAction.fadeOut(withDuration: waitDuration),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    
}
