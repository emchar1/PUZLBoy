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
    private let maxCount: Int = 1000
    private let ignorePositions: [K.GameboardPosition] = [(3, 3), (6, 3)]
    private let startPosition: K.GameboardPosition = (6, 3)
    private var villainPosition: K.GameboardPosition = (3, 3)
    private var heroPosition: K.GameboardPosition!
    
    private var spawnPanels0: [K.GameboardPosition] = []
    private var spawnPanels1: [K.GameboardPosition] = []
    private var spawnPanels2: [K.GameboardPosition] = []
    
    private var isDisabled: Bool = false
    
    private(set) var gameboard: GameboardSprite!
    private(set) var hero: Player!
    private(set) var villain: Player!
    
    
    // MARK: - Initialization
    
    init(size: CGSize) {
        self.size = size
        
        setupScene()
    }
    
    deinit {
        print("FinalBattle2Engine deinit")
    }
    
    private func setupScene() {
        heroPosition = startPosition
        gameboard = GameboardSprite(level: LevelBuilder.levels[Level.finalLevel + 1], fadeIn: false)
        
        //Make sure to initialize GameboardSprite BEFORE initializing these!!!
        let playerScale: CGFloat = Player.getGameboardScale(panelSize: size.width / CGFloat(gameboard.panelCount))
        
        hero = Player(type: .hero)
        hero.sprite.position = gameboard.getLocation(at: heroPosition)
        hero.sprite.setScale(playerScale * hero.scaleMultiplier)
        hero.sprite.zPosition = K.ZPosition.player
        
        villain = Player(type: .villain)
        villain.sprite.position = gameboard.getLocation(at: villainPosition) + CGPoint(x: 0, y: 50)
        villain.sprite.setScale(playerScale * villain.scaleMultiplier)
        villain.sprite.xScale *= -1
        villain.sprite.zPosition = K.ZPosition.player - 2
        
        populateSpawnPanels(spawnPanels: &spawnPanels0, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels1, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
        populateSpawnPanels(spawnPanels: &spawnPanels2, startPosition: heroPosition, ignorePositions: ignorePositions, maxCount: maxCount)
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
        let startTerrain = GameboardSprite.getNodeName(row: startPosition.row, col: startPosition.col)
        
        return nodes.contains(where: { $0.name == "safePanel" || $0.name == startTerrain })
    }
    
    ///Animates all the components
    func animateSprites() {
        hero.sprite.run(Player.animate(player: hero, type: .idle))
        villain.sprite.run(Player.animateIdleLevitate(player: villain))
        
        animateSpawnPanels(spawnPanels: spawnPanels0, with: .start)
//        animateSpawnPanels(spawnPanels: spawnPanels1, with: .start)
//        animateSpawnPanels(spawnPanels: spawnPanels2, with: .start)
    }
    
    
    // MARK: - Controls Functions
    
    /**
     Handles player movement based on control input.
     - parameter location: Location for which comparison is to occur.
     */
    func handleControls(in location: CGPoint) {
        guard !isDisabled else { return }
        
        if inBounds(location: location, direction: .up) {
            movePlayerHelper(direction: .up)
        }
        else if inBounds(location: location, direction: .down) {
            movePlayerHelper(direction: .down)
        }
        else if inBounds(location: location, direction: .left) {
            hero.sprite.xScale = -abs(hero.sprite.xScale)
            
            movePlayerHelper(direction: .left)
        }
        else if inBounds(location: location, direction: .right) {
            hero.sprite.xScale = abs(hero.sprite.xScale)
            
            movePlayerHelper(direction: .right)
        }
        else {
            //handle default cases here...
        }
    }
    
    
    // MARK: - Controls Helper Functions
    
    /**
     Takes a tap location and compares it to the player's next position.
     - parameters:
        - location: Location of the tap
        - controls: The player's next position, either up, down, left, or right
     */
    private func inBounds(location: CGPoint, direction: Controls) -> Bool {
        let maxDistance = gameboard.panelCount
        let panelSize = gameboard.panelSize * UIDevice.spriteScale
        let gameboardSize = panelSize * CGFloat(maxDistance)
        
        var bottomBound = heroPosition.row + 1
        var rightBound = heroPosition.col + 1
        var topBound = heroPosition.row {
            didSet {
                topBound = max(0, topBound)
            }
        }
        var leftBound = heroPosition.col {
            didSet {
                leftBound = max(0, leftBound)
            }
        }
        
        switch direction {
        case .up:
            topBound = -maxDistance
            bottomBound -= 1
        case .down:
            topBound += 1
            bottomBound = maxDistance
        case .left:
            leftBound = -maxDistance
            rightBound -= 1
        case .right:
            leftBound += 1
            rightBound = maxDistance
        default:
            print("Unknown direction in FinalBattle2Engine.inBounds()")
        }
        
        let locationInsideLeftBound = location.x > GameboardSprite.offsetPosition.x + (CGFloat(leftBound) * panelSize)
        let locationInsideRightBound = location.x < GameboardSprite.offsetPosition.x + (CGFloat(rightBound) * panelSize)
        let locationInsideBottomBound = location.y > GameboardSprite.offsetPosition.y + gameboardSize - (CGFloat(bottomBound) * panelSize)
        let locationInsideTopBound = location.y < GameboardSprite.offsetPosition.y + gameboardSize - (CGFloat(topBound) * panelSize)
        
        return locationInsideLeftBound && locationInsideRightBound && locationInsideBottomBound && locationInsideTopBound
    }
    
    /**
     Helper function that moves the player.
     - parameter direction: The direction the player is moving
     */
    private func movePlayerHelper(direction: Controls) {
        var nextPanel: K.GameboardPosition
        
        switch direction {
        case .up:       nextPanel = (row: heroPosition.row - 1, col: heroPosition.col)
        case .down:     nextPanel = (row: heroPosition.row + 1, col: heroPosition.col)
        case .left:     nextPanel = (row: heroPosition.row, col: heroPosition.col - 1)
        case .right:    nextPanel = (row: heroPosition.row, col: heroPosition.col + 1)
        default:        nextPanel = (row: heroPosition.row, col: heroPosition.col)
        }
        
        let runSound = "movetile\(Int.random(in: 1...3))"
        
        heroPosition = nextPanel
        isDisabled = true
        
        AudioManager.shared.playSound(for: runSound)
        
        hero.sprite.run(Player.animate(player: hero, type: .run))
        hero.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: Player.Texture.run.movementSpeed),
            Player.animate(player: hero, type: .idle)
        ]))
        hero.sprite.run(SKAction.move(to: gameboard.getLocation(at: nextPanel), duration: Player.Texture.run.movementSpeed)) { [weak self] in
            self?.isDisabled = false
            
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
        }
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
