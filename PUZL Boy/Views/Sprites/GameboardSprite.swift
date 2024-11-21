//
//  GameboardSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/28/22.
//

import SpriteKit

class GameboardSprite {
    
    // MARK: - Properties: Static

    static let gameboardColor: UIColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
    static let delimiter = ","
    static let overlayTag = "-O"
    static let padding: CGFloat = 12
    static var dayThemeSpriteColor: UIColor { DayTheme.spriteColor }
    static var dayThemeSpriteShade: CGFloat { DayTheme.spriteShade / 2 }
    static var offsetPosition: CGPoint {
        let screen = K.ScreenDimensions.self
        let displayHeaderHeight: CGFloat = 283
        
        return CGPoint(
            x: screen.size.width * (1 - UIDevice.spriteScale) / 2 - padding / 2,
            y: screen.size.height - screen.size.width * UIDevice.spriteScale - screen.topMargin - displayHeaderHeight - padding / 2
        )
    }

    // MARK: - Properties: Warps
    
    typealias WarpTuple = (first: K.GameboardPosition?, second: K.GameboardPosition?)
    private(set) var warps: WarpTuple = (nil, nil)
    private(set) var warps2: WarpTuple = (nil, nil)
    private(set) var warps3: WarpTuple = (nil, nil)
    
    // MARK: - Properties: Elders
    
    private var elder0 = Player(type: .elder0)
    private var elder1 = Player(type: .elder1)
    private var elder2 = Player(type: .elder2)
    private(set) var magmoorCreepyMinion: MagmoorCreepyMinion?

    // MARK: - Properties: Misc
    
    private let panelSpacing: CGFloat = 4
    private var scaleSize: CGSize { CGSize.zero + panelSize - panelSpacing }
    private var panels: [[SKSpriteNode]]
    private var endPanel: K.GameboardPosition?
    private var circle: Circle
    private(set) var panelCount: Int
    private(set) var panelSize: CGFloat
    private(set) var sprite: SKSpriteNode
    
    enum RotateDirectionType {
        case none, flipHorizontal, rotateClockwise, rotateCounterClockwise
    }

    
    // MARK: - Initialization
    
    init(level: Level, fadeIn: Bool) {
        panelCount = level.gameboard.count
        panelSize = K.ScreenDimensions.size.width / CGFloat(panelCount)
        panels = Array(repeating: Array(repeating: SKSpriteNode(), count: panelCount), count: panelCount)
        
        sprite = SKSpriteNode()
        sprite.color = fadeIn ? .black : GameboardSprite.gameboardColor
        sprite.colorBlendFactor = fadeIn ? 1 : 0
        sprite.size = CGSize.zero + CGFloat(panelCount) * panelSize + GameboardSprite.padding
        sprite.anchorPoint = .zero
        sprite.position = GameboardSprite.offsetPosition
        sprite.zPosition = K.ZPosition.gameboard
        sprite.setScale(UIDevice.spriteScale)
        
        circle = Circle(side: sprite.size.width / 2, 
                        initialAngle: -3 * .pi / 4,
                        center: sprite.position + CGPoint(x: sprite.size.width, y: sprite.size.height) / 2)
        
        for row in 0..<panelCount {
            for col in 0..<panelCount {
                let levelType: K.GameboardPanel = level.gameboard[row][col]
                
                if levelType.terrain == .endClosed || levelType.terrain == .endOpen {
                    endPanel = (row: row, col: col)
                }
                
                updatePanels(at: (row: row, col: col), with: levelType, fadeIn: fadeIn)
            }
        }
    }
    
    
    // MARK: - Getter/Setter Functions
    
    /**
     Returns a string formatted to be used as a node name for the gameboard panel.
     - parameters:
        - row: The row number of the panel
        - col: The column number of the panel
        - overlay: True if using the overlay tag, otherwise it's a terrain panel
     - returns: A string in the format: R,C<-O> with the optional overlay tag
     */
    static func getNodeName(row: Int, col: Int, includeOverlayTag: Bool = false) -> String {
        return "\(row)\(GameboardSprite.delimiter)\(col)" + (includeOverlayTag ? GameboardSprite.overlayTag : "")
    }
    
    ///Helper function that takes in the gameboard position and returns where it lies on the screen's CGPoint coordinates.
    private func getSpritePosition(at position: K.GameboardPosition) -> CGPoint {
        return CGPoint(x: panelSize * CGFloat(position.col) + panelSpacing / 2,
                       y: panelSize * CGFloat(panelCount - 1 - position.row) + panelSpacing / 2)
    }
    
    ///Similar to getSpritePosition(at:) but different in where it situates the returned CGPoint.
    func getLocation(rowf: CGFloat, colf: CGFloat) -> CGPoint {
        return CGPoint(x: panelSize * (colf + 0.5), y: panelSize * (CGFloat(panelCount) - rowf - 0.5))
    }

    ///Conveniece function to getLocation(rowf:colf) that takes in a K.GameboardPosition as its argument.
    func getLocation(at position: K.GameboardPosition) -> CGPoint {
        return getLocation(rowf: CGFloat(position.row), colf: CGFloat(position.col))
    }

    ///Returns the K.GameboardPosition at the location provided, offset by the offsetPosition.
    func getGameboardPosition(at location: CGPoint) -> K.GameboardPosition? {
        guard let node = sprite.nodes(at: location - GameboardSprite.offsetPosition).first else { return nil }
        guard let nodeName = node.name?.replacingOccurrences(of: GameboardSprite.overlayTag, with: "") else { return nil }
        guard let range = nodeName.range(of: GameboardSprite.delimiter) else { return nil }
        guard let row = Int(nodeName[..<range.lowerBound]) else { return nil }
        guard let col = Int(nodeName[range.upperBound...]) else { return nil }
        guard row >= 0 && row < panelCount && col >= 0 && col < panelCount else { return nil }
        
        //Finally!
        return (row: row, col: col)
    }
    
    ///Returns the K.GameboardPanel's SKSpriteNodes (terrain and overlay) at the given K.GameboardPosition.
    func getPanel(at position: K.GameboardPosition) -> K.GameboardPanelSprite {
        let terrainName = GameboardSprite.getNodeName(row: position.row, col: position.col)
        let overlayName = GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)

        let terrainNode = sprite.childNode(withName: terrainName) as? SKSpriteNode
        let overlayNode = sprite.childNode(withName: overlayName) as? SKSpriteNode
        
        return (terrainNode, overlayNode)
    }

    func updatePanels(at position: K.GameboardPosition, with tile: K.GameboardPanel, fadeIn: Bool = false) {
        
        //Setup Terrain Panel
        let terrainPanel: SKSpriteNode

        if !FireIceTheme.isFire {
            switch tile.terrain {
            case .sand:         terrainPanel = SKSpriteNode(imageNamed: "snow" + AgeOfRuin.ruinSuffix)
            case .lava:         terrainPanel = SKSpriteNode(imageNamed: "water" + AgeOfRuin.ruinSuffix)
            default:            terrainPanel = SKSpriteNode(imageNamed: tile.terrain.description + AgeOfRuin.ruinSuffix)
            }
        }
        else {
            terrainPanel = SKSpriteNode(imageNamed: tile.terrain.description + AgeOfRuin.ruinSuffix)
        }
        
        terrainPanel.scale(to: scaleSize)
        terrainPanel.position = getSpritePosition(at: position) + GameboardSprite.padding / 2
        terrainPanel.anchorPoint = .zero
        terrainPanel.color = fadeIn ? .black : GameboardSprite.dayThemeSpriteColor
        terrainPanel.colorBlendFactor = fadeIn ? 1 : GameboardSprite.dayThemeSpriteShade
        terrainPanel.zPosition = K.ZPosition.terrain
        terrainPanel.name = GameboardSprite.getNodeName(row: position.row, col: position.col)
        
        if tile.terrain == .partytile {
            terrainPanel.animatePartyTileShimmer(gameboardColor: GameboardSprite.gameboardColor)
        }
        else if tile.terrain == .marsh {
            ParticleEngine.shared.animateParticles(type: .poisonBubbles,
                                                   toNode: sprite,
                                                   position: getLocation(at: position),
                                                   scale: 3 / CGFloat(panelCount),
                                                   duration: 0)
        }
        else if tile.terrain == .lava && FireIceTheme.isFire {
            ParticleEngine.shared.animateParticles(type: .lavaSizzle,
                                                   toNode: sprite,
                                                   position: getLocation(at: position),
                                                   scale: 3 / CGFloat(panelCount),
                                                   duration: 0)
        }
        else if tile.terrain == .sand && !FireIceTheme.isFire {
            ParticleEngine.shared.animateParticles(type: .snowfall,
                                                   toNode: sprite,
                                                   position: getLocation(at: position),
                                                   scale: 3 / CGFloat(panelCount),
                                                   nameGameboardPosition: position,
                                                   duration: 0)
        }

        panels[position.row][position.col] = terrainPanel
        sprite.addChild(panels[position.row][position.col])
        
        
        if tile.overlay != .boundary {
            
            //Setup Overlay Panel
            let overlayPanel: SKSpriteNode

            if !FireIceTheme.isFire && tile.overlay == .enemy {
                overlayPanel = SKSpriteNode(imageNamed: "enemyIce" + AgeOfRuin.ruinSuffix)
            }
            else {
                let overlayIsStatue = tile.overlay == .statue0 || tile.overlay == .statue1 || tile.overlay == .statue2 || tile.overlay == .statue3 || tile.overlay == .statue4
                
                overlayPanel = SKSpriteNode(imageNamed: tile.overlay.description + (AgeOfRuin.isActive && overlayIsStatue ? "Disabled" : "") + AgeOfRuin.ruinSuffix)
                
                if !AgeOfRuin.isActive && overlayIsStatue {
                    overlayPanel.danceStatue()
                }
            }
            
            overlayPanel.scale(to: scaleSize)
            overlayPanel.position = getSpritePosition(at: position) + GameboardSprite.padding / 2 + scaleSize.width / 2
            overlayPanel.color = fadeIn ? .black : GameboardSprite.dayThemeSpriteColor
            overlayPanel.colorBlendFactor = fadeIn ? 1 : GameboardSprite.dayThemeSpriteShade
            overlayPanel.zPosition = K.ZPosition.overlay
            overlayPanel.name = GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)
            
            switch tile.overlay {
            case .warp, .warp2, .warp3, .warp4, .warp5:
                rotateWarp(node: overlayPanel, slow: true, repeatForever: true)
            default:
                break
            }

            sprite.addChild(overlayPanel)
        }
        
        if tile.overlay == .warp {
            if warps.first == nil {
                warps.first = position
            }
            else {
                warps.second = position
            }
        }
        
        if tile.overlay == .warp2 {
            if warps2.first == nil {
                warps2.first = position
            }
            else {
                warps2.second = position
            }
        }
        
        if tile.overlay == .warp3 {
            if warps3.first == nil {
                warps3.first = position
            }
            else {
                warps3.second = position
            }
        }
        
        if tile.overlay == .enemy {
            animateBreatheFireIdle(position: position)
        }
        
        if tile.overlay == .heart {
            animateHeartbeat(position: position)
        }
    }
    
    
    // MARK: - Spawn Item Functions
    
    /**
     Spawns an item in a panel with a little growth animation.
     - parameters:
        - position: position on the gameboard to spawn
        - itemOverlay: the item LevelType to spawn
     */
    func spawnItem(at position: K.GameboardPosition, with itemOverlay: LevelType, delay: TimeInterval? = nil, completion: @escaping () -> Void) {
        let duration: TimeInterval = 0.25
        let bounceFactor: CGFloat = scaleSize.width * 0.25
        
        let overlayPanel = SKSpriteNode(imageNamed: itemOverlay.description + AgeOfRuin.ruinSuffix)
        overlayPanel.scale(to: .zero)
        overlayPanel.position = getSpritePosition(at: position) + GameboardSprite.padding / 2 + scaleSize.width / 2
        overlayPanel.zPosition = itemOverlay == .warp4 ? K.ZPosition.itemsAndEffects - 10 : K.ZPosition.overlay
        overlayPanel.name = GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)

        switch itemOverlay {
        case .warp, .warp2, .warp3, .warp4, .warp5:
            rotateWarp(node: overlayPanel, slow: true, repeatForever: true)
        default:
            break
        }
        
        overlayPanel.run(SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.scale(to: scaleSize + bounceFactor, duration: duration),
            SKAction.scale(to: scaleSize, duration: duration),
        ]), completion: completion)

        sprite.addChild(overlayPanel)
    }
    
    /**
     The opposite of spawning, this removes an item with a shrink to 0 animation.
     - parameters:
        - position: the position on the gameboard to despawn
        - itemOverlay: the item to remove, assuming the item exists on that panel position
     */
    func despawnItem(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        let duration: TimeInterval = 0.25
        let bounceFactor: CGFloat = scaleSize.width * 0.25
        let itemOverlays = sprite.children.filter({ $0.name == GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true) })
        
        for itemOverlay in itemOverlays {
            itemOverlay.run(SKAction.sequence([
                SKAction.scale(to: scaleSize + bounceFactor, duration: duration),
                SKAction.scale(to: 0, duration: duration),
                SKAction.removeFromParent()
            ]), completion: completion)
        }
    }
    
    
    // MARK: - Spawn Trainer Functions
    
    /**
     Spawns the trainer at the specified position, and moves him one spot in the direction indicated.
     - parameters:
        - position: Initial position to spawn
        - direction: the direction in which to move when spawning
     */
    func spawnTrainer(at position: K.GameboardPosition, to direction: Controls = .right) {
        let directionToAdd: K.GameboardPosition
        
        switch direction {
        case .left:     directionToAdd = (0, -1)
        case .right:    directionToAdd = (0, 1)
        case .up:       directionToAdd = (-1, 0)
        case .down:     directionToAdd = (1, 0)
        case .unknown:  directionToAdd = (0, 0)
        }
        
        let directionFacing: CGFloat = (direction == .left || direction == .unknown) ? 1 : -1
        let startPoint = getLocation(at: position)
        let endPoint = getLocation(at: (position.row + directionToAdd.row, position.col + directionToAdd.col))
        let moveDuration: TimeInterval = 0.5
        
        let trainer = Player(type: .trainer)
        let trainerScale = Player.getGameboardScale(panelSize: panelSize) * trainer.scaleMultiplier
        trainer.sprite.position = startPoint
        trainer.sprite.setScale(trainerScale)
        trainer.sprite.xScale *= directionFacing
        trainer.sprite.alpha = 0
        trainer.sprite.name = "marlinSprite"

        //I don't like how this is set. If direction is .unknown, place Marlin above MagmoorScary (in Bonus Levels). It looked weird when MagmoorScary was above Marlin. I'll need to remember to only use the .unknown case in Bonus Levels, otherwise Marlin will appear above the blood overlay. 8/31/24
        trainer.sprite.zPosition = direction == .unknown ? K.ZPosition.chatDialogue + 10 : K.ZPosition.player - 1

        trainer.sprite.run(SKAction.repeatForever(SKAction.animate(with: trainer.textures[Player.Texture.idle.rawValue], timePerFrame: 0.16)))
        trainer.sprite.run(SKAction.group([
            SKAction.fadeIn(withDuration: moveDuration),
            SKAction.move(to: endPoint, duration: moveDuration)
        ]))
        
        sprite.addChild(trainer.sprite)
    }
    
    /**
     Despawns the trainer at the specified position.
     - parameter position: final position to despawn
     */
    func despawnTrainer(to position: K.GameboardPosition?) {
        guard let trainerSprite = sprite.childNode(withName: "marlinSprite") else { return print("Marlin not found!") }
        
        let endPoint = position == nil ? nil : getLocation(at: position!)
        let moveDuration: TimeInterval = 0.5
        
        trainerSprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.move(to: endPoint ?? trainerSprite.position, duration: moveDuration),
                SKAction.fadeOut(withDuration: moveDuration),
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    /**
     Spawns the trainer at the specified position, and moves him one spot in the direction indicated. Also opens the end panel temporarily for a hasty escape!
     - parameters:
        - position: Initial position to spawn
        - direction: the direction in which to move when spawning
     */
    func spawnTrainerWithExit(at position: K.GameboardPosition, to direction: Controls) {
        guard let endPanel = endPanel else {
            print("Unable to execute GameboardSprite.spawnTrainerWithExit(); there's no endPanel!")
            return
        }
        
        let overlayPanel = SKSpriteNode(imageNamed: LevelType.endOpen.description + AgeOfRuin.ruinSuffix)
        overlayPanel.scale(to: scaleSize)
        overlayPanel.position = getSpritePosition(at: endPanel) + GameboardSprite.padding / 2
        overlayPanel.anchorPoint = .zero
        overlayPanel.zPosition = K.ZPosition.overlay
        overlayPanel.name = "captureEndOpen"
        sprite.addChild(overlayPanel)
        
        spawnTrainer(at: position, to: direction)
    }
    
    /**
     Despawns the trainer with a specified move set. The first move in the moves array should be the initial position, i.e. where trainer originally spawned.
     - parameter moves: an array of moves/path for trainer to follow, with the initial element being the initial spawn spot.
     */
    func despawnTrainerWithExit(moves: [K.GameboardPosition]) {
        guard let trainerSprite = sprite.childNode(withName: "marlinSprite") else { return print("Marlin not found!") } //NO
        
        var remainingMoves = moves
        let firstMove = remainingMoves.removeFirst()
        let trainer = Player(type: .trainer)

        func trainerMoveActions(positions: [K.GameboardPosition]) -> (actions: [SKAction], waitDuration: TimeInterval) {
            let moveDuration: TimeInterval = 0.4
            var waitDuration: TimeInterval = 0
            var lastPosition: K.GameboardPosition = firstMove
            var actions: [SKAction] = []

            for nextPosition in positions {
                let moveAction = SKAction.group([
                    SKAction.move(to: getLocation(at: nextPosition), duration: moveDuration),
                    SKAction.scaleX(to: (lastPosition.col > nextPosition.col ? 1 : -1) * trainerSprite.xScale, duration: 0.0)
                ])
                
                lastPosition = nextPosition
                waitDuration += moveDuration
                
                actions.append(moveAction)
            }
            
            return (actions, waitDuration)
        }
        
        let trainerMoves = trainerMoveActions(positions: remainingMoves)
        
        trainerSprite.run(SKAction.repeatForever(SKAction.animate(with: trainer.textures[Player.Texture.walk.rawValue], timePerFrame: 0.12)))
        trainerSprite.run(SKAction.sequence([
            SKAction.sequence(trainerMoves.actions),
            SKAction.group([
                SKAction.scale(to: 0, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5)
            ])
        ]))
        
        if let endOpen = sprite.childNode(withName: "captureEndOpen") {
            endOpen.run(SKAction.sequence([
                SKAction.wait(forDuration: trainerMoves.waitDuration + 0.5),
                SKAction.removeFromParent()
            ])) {
                AudioManager.shared.playSound(for: "dooropen")
            }
        }
    }
    
    
    // MARK: - Spawn Princess Functions
    
    ///Spawns a short animation of the whereabouts of the princess being captured by the villain.
    func spawnPrincessCapture(at position: K.GameboardPosition, shouldAnimateWarp: Bool, completion: @escaping () -> Void) {
        guard let endPanel = endPanel else {
            print("Unable to execute GameboardSprite.spawnPrincessCapture(); there's no endPanel!")
            completion()
            return
        }

        for node in sprite.children {
            if let nodeName = node.name,
               nodeName.contains(GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)) {
                //Exit function if there's an overlay item, like a gem or dragon
                print("Unable to execute GameboardSprite.spawnPrincessCapture(); there's an overlay!")
                completion()
                return
            }
        }
        
        let overlayPanel = SKSpriteNode(imageNamed: LevelType.endOpen.description + AgeOfRuin.ruinSuffix)
        overlayPanel.scale(to: scaleSize)
        overlayPanel.position = getSpritePosition(at: endPanel) + GameboardSprite.padding / 2
        overlayPanel.anchorPoint = .zero
        overlayPanel.color = GameboardSprite.dayThemeSpriteColor
        overlayPanel.colorBlendFactor = GameboardSprite.dayThemeSpriteShade
        overlayPanel.zPosition = K.ZPosition.overlay
        overlayPanel.name = "captureEndOpen"
        sprite.addChild(overlayPanel)
        
        let waitDuration: TimeInterval = shouldAnimateWarp ? 1 : 0
        let appearDuration: TimeInterval = shouldAnimateWarp ? 0.5 : 0
        let currentThemeFade: TimeInterval = shouldAnimateWarp ? 5 : 0

        AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3, delay: waitDuration, interruptPlayback: false)
        AudioManager.shared.playSound(for: "littlegirllaugh", fadeIn: 3, delay: waitDuration, interruptPlayback: false)
        AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 3, delay: waitDuration, interruptPlayback: false)
        AudioManager.shared.adjustVolume(to: 0, for: AudioManager.shared.currentTheme.overworld, fadeDuration: currentThemeFade)

        if shouldAnimateWarp {
            AudioManager.shared.playSound(for: "magicwarp")
            AudioManager.shared.playSound(for: "magicwarp2")

            spawnItem(at: position, with: .warp4) { [weak self] in
                guard let self = self else { return }
                
                ParticleEngine.shared.animateParticles(type: .warp4,
                                                       toNode: sprite,
                                                       position: getLocation(at: position),
                                                       scale: 3 / CGFloat(panelCount),
                                                       duration: 0)
                
                handleSpawnPrincessVillain(position: position, endPanel: endPanel, waitDuration: waitDuration, appearDuration: appearDuration)
                
                sprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: 3),
                    SKAction.run {
                        self.despawnItem(at: position, completion: completion)
                    }
                ]))
            }
        }
        else {
            handleSpawnPrincessVillain(position: position, endPanel: endPanel, waitDuration: waitDuration, appearDuration: appearDuration)
            completion()
        }
    }
    
    ///Helper function to spawnPrincessCapture() that animates the appearance of princess and villain.
    private func handleSpawnPrincessVillain(position: K.GameboardPosition, endPanel: K.GameboardPosition, waitDuration: TimeInterval, appearDuration: TimeInterval) {
        
        let playerOffset = CGPoint(x: panelSize / 4, y: panelSize / 4)
        let villainOffset = CGPoint(x: -panelSize / 4, y: 20)
        let startPoint = getLocation(at: position)
        let endPoint = getLocation(at: endPanel)
        let facingMultiplier: CGFloat = endPoint.x > startPoint.x ? -1 : 1

        let princess = Player(type: .princess)
        princess.sprite.position = startPoint
        princess.sprite.setScale(0)
        princess.sprite.zPosition = K.ZPosition.itemsAndEffects + 30
        princess.sprite.name = "capturePrincess"
        princess.sprite.run(SKAction.repeatForever(SKAction.animate(with: princess.textures[Player.Texture.jump.rawValue], timePerFrame: 0.02)), withKey: "writhe")
        
        let villain = Player(type: .villain)
        villain.sprite.position = startPoint
        villain.sprite.setScale(0)
        villain.sprite.zPosition = K.ZPosition.itemsAndEffects + 20
        villain.sprite.name = "captureVillain"
        villain.sprite.run(getMagmoorIdleAction(), withKey: "magmoorIdle")
                    
        princess.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.group([
                SKAction.scaleX(to: facingMultiplier * Player.getGameboardScale(panelSize: panelSize) * princess.scaleMultiplier, duration: appearDuration),
                SKAction.scaleY(to: Player.getGameboardScale(panelSize: panelSize) * princess.scaleMultiplier, duration: appearDuration),
                SKAction.moveBy(x: facingMultiplier * playerOffset.x, y: playerOffset.y, duration: appearDuration)
            ])
        ]))
        
        villain.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: waitDuration),
            SKAction.group([
                SKAction.scaleX(to: facingMultiplier * Player.getGameboardScale(panelSize: panelSize) * villain.scaleMultiplier, duration: appearDuration),
                SKAction.scaleY(to: Player.getGameboardScale(panelSize: panelSize) * villain.scaleMultiplier, duration: appearDuration),
                SKAction.moveBy(x: facingMultiplier * villainOffset.x, y: villainOffset.y, duration: appearDuration)
            ])
        ]))
        
        ParticleEngine.shared.animateParticles(type: .magmoorSmoke,
                                               toNode: villain.sprite,
                                               position: .zero,
                                               zPosition: 11,
                                               duration: 0)
        
        sprite.addChild(princess.sprite)
        sprite.addChild(villain.sprite)
    }
    
    private func getMagmoorIdleAction() -> SKAction {
        let villain = Player(type: .villain)
        
        return SKAction.repeatForever(SKAction.group([
            SKAction.animate(with: villain.textures[Player.Texture.idle.rawValue], timePerFrame: 0.1),
            SKAction.sequence([
                SKAction.moveBy(x: 0, y: 20, duration: 1 + TimeInterval.random(in: 0...1)),
                SKAction.moveBy(x: 0, y: -20, duration: 1 + TimeInterval.random(in: 0...1))
            ])
        ]))
    }
    
    func flashPrincess(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        for node in sprite.children {
            guard let node = node as? SKSpriteNode, node.name == "capturePrincess" else { continue }
            
            let princess = Player(type: .princess)

            node.removeAction(forKey: "writhe")
            node.run(SKAction.sequence([
                SKAction.repeat(SKAction.sequence([
                    SKAction.moveBy(x: -8, y: -4, duration: 0.0625),
                    SKAction.moveBy(x: 8, y: 4, duration: 0.0625)
                ]), count: 24),
                SKAction.colorize(with: UIColor(red: 255 / 255, green: 128 / 255, blue: 255 / 255, alpha: 1), colorBlendFactor: 1, duration: 0),
                SKAction.wait(forDuration: 1),
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.5),
                SKAction.repeatForever(SKAction.animate(with: princess.textures[Player.Texture.jump.rawValue], timePerFrame: 0.02))
            ]), completion: completion)
            
            sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 3)
            ])) {
                AudioManager.shared.playSound(for: "winlevelageofruin")
                ParticleEngine.shared.animateParticles(type: .gemSparkle,
                                                       toNode: node,
                                                       position: .zero,
                                                       scale: UIDevice.spriteScale * 3,
                                                       duration: 2)
            }

            return
        }
    }
    
    ///Despawns the princess being captured by the villain, as he escapes through the back door.
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        guard let endPanel = endPanel else {
            print("Unable to execute GameboardSprite.despawnPrincessCapture(); there's no endPanel!")
            completion()
            return
        }
        
        let playerOffset = CGPoint(x: panelSize / 4, y: 0)
        let villainOffset = CGPoint(x: 0, y: 20)
        let startPoint = getLocation(at: position)
        let endPoint = getLocation(at: endPanel)
        let facingMultiplier: CGFloat = endPoint.x > startPoint.x ? -1 : 1

        let actionDuration: TimeInterval = 1
        let exitDoorScale: CGFloat = 0.25
        
        ParticleEngine.shared.hideParticles(fromNode: sprite, fadeDuration: 5)
        
        for node in sprite.children {
            if let nodeName = node.name,
               nodeName.contains(GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)) {
                //Exit function if there's an overlay item, like a gem or dragon
                print("Unable to execute GameboardSprite.despawnPrincessCapture(); there's an overlay!")

                ParticleEngine.shared.removeParticles(fromNode: sprite)

                completion()
                return
            }
            
            guard let node = node as? SKSpriteNode else { continue }
            
            if node.name == "capturePrincess" {
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: actionDuration * 2.5),
                    SKAction.move(to: endPoint + facingMultiplier * playerOffset, duration: actionDuration * 2),
                    SKAction.sequence([
                        SKAction.group([
                            SKAction.scaleX(to: node.xScale * exitDoorScale, y: node.yScale * exitDoorScale, duration: actionDuration / 2),
                            SKAction.moveBy(x: -facingMultiplier * playerOffset.x / 2, y: 0, duration: actionDuration / 2)
                        ]),
                        SKAction.fadeOut(withDuration: actionDuration / 2)
                    ]),
                    SKAction.removeFromParent()
                ]))
            }
            else if node.name == "captureVillain" {
                let villain = Player(type: .villain)
                let moveWithIllusionsDuration: TimeInterval = 1
                
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: moveWithIllusionsDuration),
                    SKAction.run {
                        node.removeAction(forKey: "magmoorIdle")
                    },
                    SKAction.group([
                        SKAction.animate(with: villain.textures[Player.Texture.attack.rawValue], timePerFrame: 0.06),
                        SKAction.wait(forDuration: actionDuration * 3.5 - 1)
                    ]),
                    getMagmoorIdleAction()
                ]), withKey: "attackAnimation")
                
                node.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: actionDuration / 2),
                        SKAction.run {
                            AudioManager.shared.stopSound(for: "magicheartbeatloop1")
                            AudioManager.shared.playSound(for: "magicheartbeatloop2")
                        },
                        Player.moveWithIllusions(
                            playerNode: node, backgroundNode: sprite, 
                            color: .black, playSound: true,
                            startPoint: startPoint - facingMultiplier * playerOffset + villainOffset,
                            endPoint: endPoint - facingMultiplier * playerOffset + villainOffset,
                            startScale: facingMultiplier * Player.getGameboardScale(panelSize: panelSize) * villain.scaleMultiplier),
                    ]),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        
                        let angleOfAttack: CGFloat = SpriteMath.Trigonometry.getAngles(startPoint: startPoint + playerOffset + villainOffset, endPoint: endPoint + playerOffset + villainOffset).beta * (endPoint.y < startPoint.y ? 1 : -1)
                        
                        AudioManager.shared.playSound(for: "magicblast")
                        
                        ParticleEngine.shared.animateParticles(type: .magicBlast,
                                                               toNode: node,
                                                               position: CGPoint(x: 200, y: -120),
                                                               scale: UIDevice.spriteScale * CGFloat(panelCount) / 4,
                                                               angle: angleOfAttack,
                                                               duration: actionDuration * 3.5)
                    },
                    SKAction.move(to: endPoint - facingMultiplier * playerOffset + villainOffset, duration: 0),
                    SKAction.fadeIn(withDuration: 0),
                    SKAction.wait(forDuration: actionDuration * 3.5),
                    SKAction.run {
                        ParticleEngine.shared.hideParticles(fromNode: node, fadeDuration: actionDuration / 2)
                    },
                    SKAction.sequence([
                        SKAction.group([
                            SKAction.scaleX(to: node.xScale * exitDoorScale, y: node.yScale * exitDoorScale, duration: actionDuration / 2),
                            SKAction.moveBy(x: facingMultiplier * playerOffset.x / 2, y: -villainOffset.y, duration: actionDuration / 2)
                        ]),
                        SKAction.fadeOut(withDuration: actionDuration / 2)
                    ]),
                    SKAction.removeFromParent()
                ]), withKey: "movementAnimation")
            }
            else if node.name == "captureEndOpen" {
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 5.5 * actionDuration),
                    SKAction.removeFromParent()
                ])) { [weak self] in
                    guard let self = self else { return }
                    
                    //Final completion handler...
                    ParticleEngine.shared.removeParticles(fromNode: sprite)
                    AudioManager.shared.playSound(for: "dooropen")
                    AudioManager.shared.stopSound(for: "magicheartbeatloop2", fadeDuration: 5)
                    AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 5)
                    AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 5)

                    completion()
                }
            }
        }
    }
    
    
    // MARK: - Inbetween Realm Functions
    
    ///Spawns princess and Magmoor in the Inbetween Realm.
    func spawnInbetween(level: Level, mergeHalfway: Bool, moves: [K.GameboardPosition]) {
        let princess = Player(type: .princess)
        let villain = Player(type: .villain)
        let trainer = Player(type: .trainer)

        let playerOffset = CGPoint(x: 0, y: 20)
        let trainerMergeType: [SKTexture] = trainer.textures[mergeHalfway ? Player.Texture.glide.rawValue : Player.Texture.idle.rawValue]

        let fadeDuration: TimeInterval = 1
        let princessTimePerFrame: TimeInterval = 0.08
        
        func princessMoveActions(positions: [K.GameboardPosition]) -> [SKAction] {
            let moveDuration: TimeInterval = Double(princess.textures[Player.Texture.walk.rawValue].count) * princessTimePerFrame
            var lastPosition: K.GameboardPosition = level.start
            var actions: [SKAction] = []
            
            for nextPosition in positions {
                let moveAction = SKAction.sequence([
                    SKAction.group([
                        SKAction.animate(with: princess.textures[Player.Texture.walk.rawValue], timePerFrame: princessTimePerFrame),
                        SKAction.move(to: getLocation(at: nextPosition), duration: moveDuration),
                        SKAction.scaleX(to: (lastPosition.col > nextPosition.col ? -1 : 1) * princess.sprite.xScale, duration: 0.0)
                    ]),
                    SKAction.wait(forDuration: TimeInterval.random(in: 0...3))
                ])
                
                lastPosition = nextPosition
                
                actions.append(moveAction)
            }
            
            return actions
        }
        
        colorizeGameboard(fadeOut: false, isInbetween: true, completion: nil)
        
        princess.sprite.position = getLocation(at: (level.start.row + 1, level.start.col + 1))
        princess.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * princess.scaleMultiplier)
        princess.sprite.alpha = 0
        princess.sprite.zPosition = K.ZPosition.itemsAndEffects + 30
        princess.sprite.name = "inbetweenPrincess"
        princess.sprite.run(SKAction.repeatForever(SKAction.animate(with: princess.textures[Player.Texture.idle.rawValue], timePerFrame: princessTimePerFrame)))
                    
        villain.sprite.position = getLocation(at: (level.start.row, level.start.col + 3)) + playerOffset
        villain.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * villain.scaleMultiplier)
        villain.sprite.xScale *= -1
        villain.sprite.alpha = 0
        villain.sprite.zPosition = K.ZPosition.itemsAndEffects + 20
        villain.sprite.name = "inbetweenVillain"
        villain.sprite.run(SKAction.repeatForever(SKAction.animate(with: villain.textures[Player.Texture.idle.rawValue], timePerFrame: 0.1)))
        
        trainer.sprite.position = getLocation(at: (level.start.row, level.start.col + 1)) + playerOffset
        trainer.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * trainer.scaleMultiplier)
        trainer.sprite.alpha = 0
        trainer.sprite.zPosition = K.ZPosition.itemsAndEffects + 20
        trainer.sprite.name = "inbetweenTrainer"
        trainer.sprite.run(SKAction.repeatForever(SKAction.animate(with: trainerMergeType, timePerFrame: 0.1)))
        trainer.sprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 1),
            SKAction.moveBy(x: 0, y: 5, duration: 1),
            SKAction.moveBy(x: 0, y: -20, duration: 1),
            SKAction.moveBy(x: 0, y: -5, duration: 1)
        ])))

                        
        princess.sprite.run(SKAction.fadeIn(withDuration: fadeDuration))
        villain.sprite.run(SKAction.fadeIn(withDuration: fadeDuration))
        trainer.sprite.run(SKAction.fadeIn(withDuration: fadeDuration))

        ParticleEngine.shared.animateParticles(type: .magmoorSmoke,
                                               toNode: villain.sprite,
                                               position: .zero,
                                               zPosition: 5,
                                               duration: 0)
        
        ParticleEngine.shared.animateParticles(type: .magicMerge,
                                               toNode: trainer.sprite,
                                               position: .zero,
                                               scale: 3,
                                               zPosition: -5,
                                               duration: 0)

        sprite.addChild(princess.sprite)
        sprite.addChild(villain.sprite)
        sprite.addChild(trainer.sprite)
        
        
        //Princess Movement
        princess.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.sequence(princessMoveActions(positions: moves))
        ]), withKey: "princessMoves")
    }
    
    ///Flashes a player in the in-between realm.
    func inbetweenFlashPlayer(playerType: Player.PlayerType, position: K.GameboardPosition, persistPresence: Bool) {
        let player = Player(type: playerType)
        player.sprite.position = getLocation(at: position)
        player.sprite.setScale(Player.getGameboardScale(panelSize: panelSize) * player.scaleMultiplier)
        player.sprite.alpha = 0
        player.sprite.zPosition = K.ZPosition.itemsAndEffects + 20
        player.sprite.name = "inbetweenPlayer"
        player.sprite.run(SKAction.repeatForever(SKAction.animate(with: player.textures[Player.Texture.idle.rawValue], timePerFrame: 0.1)))

        let flashDuration: TimeInterval = 0.08
        let fadeDuration: TimeInterval = 2


        func flashAction(fromAlpha: CGFloat, toAlpha: CGFloat = 0, flashDuration: TimeInterval) -> SKAction {
            return SKAction.sequence([
                SKAction.fadeAlpha(to: fromAlpha, duration: 0),
                SKAction.wait(forDuration: flashDuration),
                SKAction.fadeAlpha(to: toAlpha, duration: 0),
                SKAction.wait(forDuration: flashDuration)
            ])
        }
        
        let flashSeriesAction = SKAction.sequence([
            flashAction(fromAlpha: 0.5, flashDuration: flashDuration),
            flashAction(fromAlpha: 0.6, flashDuration: flashDuration),
            flashAction(fromAlpha: 0.7, flashDuration: flashDuration),
            flashAction(fromAlpha: 0.8, flashDuration: flashDuration),
            flashAction(fromAlpha: 0.9, flashDuration: flashDuration)
        ])

        if persistPresence {
            player.sprite.run(SKAction.sequence([
                flashSeriesAction,
                SKAction.repeatForever(flashAction(fromAlpha: 0.5, toAlpha: 0.4, flashDuration: flashDuration))
            ]), withKey: "playerFlash")
        }
        else {
            player.sprite.run(SKAction.sequence([
                flashSeriesAction,
                SKAction.repeat(flashAction(fromAlpha: 0.5, toAlpha: 0.4, flashDuration: flashDuration),
                                count: Int(fadeDuration / flashDuration / 2)),
                SKAction.fadeOut(withDuration: fadeDuration)
            ]), withKey: "playerFlash")
        }
        
        sprite.addChild(player.sprite)
        
        if let princessNode = sprite.childNode(withName: "inbetweenPrincess") {
            princessNode.removeAction(forKey: "princessMoves")
            princessNode.xScale *= princessNode.xScale > 0 ? -1 : 1
        }
    }
    
    ///Despawns princess and Magmoor from the Inbetween Realm, in preparation for Puzzle Realm transition.
    func despawnInbetween(persistPresence: Bool) {
        let fadeDuration: TimeInterval = 1

        let fadeActionPersist = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: fadeDuration),
            SKAction.wait(forDuration: fadeDuration * 3),
            SKAction.fadeOut(withDuration: fadeDuration * 3),
            SKAction.removeFromParent()
        ])

        let fadeActionNonPersist = SKAction.sequence([
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ])
                        
        for node in sprite.children {
            switch node.name {
            case "inbetweenPrincess", "inbetweenVillain", "inbetweenTrainer":
                node.run(persistPresence ? fadeActionPersist : fadeActionNonPersist) {
                    ParticleEngine.shared.removeParticles(fromNode: node)
                }
            case "inbetweenPlayer":
                node.removeAction(forKey: "playerFlash")
                
                node.run(fadeActionNonPersist) {
                    ParticleEngine.shared.removeParticles(fromNode: node)
                }
            default:
                continue
            }
        }
        
        flipGameboard()
        colorizeGameboard(fadeOut: false, fadeOutDuration: 2, isInbetween: false, completion: nil)
    }
    
    ///Princess makes a second attempt at displaying her latent powers. Magmoor is impressed, and a little intimidated, so he encases her in a prison cage to prevent her from thwarting his plans.
    func empowerPrincess(duration: TimeInterval) {
        guard let princessNode = sprite.childNode(withName: "inbetweenPrincess") as? SKSpriteNode else { return print("GameboardSprite.empowerPrinces() failed.") }
        
        princessNode.removeAction(forKey: "princessMoves")
        
        ParticleEngine.shared.animateParticles(type: .magicPrincessExplode,
                                               toNode: princessNode,
                                               position: .zero,
                                               zPosition: -3,
                                               duration: 0)
        
        ParticleEngine.shared.animateParticles(type: .magicPrincess,
                                               toNode: princessNode,
                                               position: .zero,
                                               zPosition: -2,
                                               duration: 0)

        ParticleEngine.shared.animateParticles(type: .magicLight,
                                               toNode: princessNode,
                                               position: .zero,
                                               scale: 4,
                                               zPosition: -1,
                                               duration: 0)
        
        AudioManager.shared.playSound(for: "magicelderexplosion")
        colorizeGameboard(fadeOut: false, fadeOutDuration: 1, isInbetween: false, completion: nil)
        
        princessNode.run(SKAction.sequence([
            SKAction.colorize(with: .systemPink, colorBlendFactor: 1, duration: 0),
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in
                ParticleEngine.shared.removeParticles(fromNode: princessNode, fadeDuration: 3)
                self?.colorizeGameboard(fadeOut: false, fadeOutDuration: 3, isInbetween: true, completion: nil)
            },
            SKAction.colorize(withColorBlendFactor: 0, duration: 3)
        ]))
    }
    
    ///Initiates the princess encagement action sequence.
    func encagePrincess() {
        guard let villainNode = sprite.childNode(withName: "inbetweenVillain") as? SKSpriteNode,
              let princessNode = sprite.childNode(withName: "inbetweenPrincess") as? SKSpriteNode else {
            print("GameboardSprite.encagePrincess(): No villain and/or princess nodes available.")
            return
        }
        
        let princessCage = PrincessCageSprite(villainNode: villainNode, princessNode: princessNode)
        princessCage.encagePrincess()
    }
    
    ///Flips the gameboard when transitioning from in-between realm back to puzzle realm.
    private func flipGameboard() {
        let anglesCount: CGFloat = 64 //Needs to match count of rotateAction() calls, below!!
        let flipDuration: TimeInterval = 2
        
        func rotateAction(i: CGFloat, angles: CGFloat, duration: TimeInterval) -> SKAction {
            let angleToRotate: CGFloat = -2 * .pi / angles
            
            //properties related to duration
            let division: TimeInterval = i / TimeInterval(angles)
            let halvsies: TimeInterval = duration / (angles / 2 + 0.5)
            let durationBezier: TimeInterval = (division * division * (3 - 2 * division)) * halvsies
            
            return SKAction.group([
                SKAction.rotate(byAngle: angleToRotate, duration: durationBezier),
                SKAction.move(to: circle.getPointOnCircle(angleRad: i * angleToRotate), duration: durationBezier)
            ])
        }
        
        AudioManager.shared.playSound(for: "realmtransition")
        
        sprite.run(SKAction.sequence([
            //Is there a way to do this in a loop, both for readability and scalability?
            rotateAction(i: 1, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 2, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 3, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 4, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 5, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 6, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 7, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 8, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 9, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 10, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 11, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 12, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 13, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 14, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 15, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 16, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 17, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 18, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 19, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 20, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 21, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 22, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 23, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 24, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 25, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 26, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 27, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 28, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 29, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 30, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 31, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 32, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 33, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 34, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 35, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 36, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 37, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 38, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 39, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 40, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 41, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 42, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 43, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 44, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 45, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 46, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 47, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 48, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 49, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 50, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 51, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 52, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 53, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 54, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 55, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 56, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 57, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 58, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 59, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 60, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 61, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 62, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 63, angles: anglesCount, duration: flipDuration),
            rotateAction(i: 64, angles: anglesCount, duration: flipDuration)
        ]))
    }
    
    
    // MARK: - Tiki/Magmoor Minion

    /**
     Magmoor's minion just peeks out briefly from behind one of the tiles and hides again.
      - parameters:
        - position: the location of the tile from which to peek
        - duration: time before minion goes into hiding
        - completion: completion handler
     */
    func peekMagmoorMinion(at position: K.GameboardPosition, duration: TimeInterval, completion: @escaping () -> Void) {
        let fadeDuration: TimeInterval = 1

        let peekPanel = getPanel(at: position)
        peekPanel.terrain?.run(SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: fadeDuration),
            SKAction.wait(forDuration: duration),
            SKAction.colorize(with: GameboardSprite.dayThemeSpriteColor,
                              colorBlendFactor: GameboardSprite.dayThemeSpriteShade,
                              duration: fadeDuration)
        ]))
        
        magmoorCreepyMinion = MagmoorCreepyMinion(scale: 3.5, gameboardScaleSize: scaleSize, spawnPoint: getSpritePosition(at: position))
        magmoorCreepyMinion!.addToParent(sprite)
        magmoorCreepyMinion!.peekAnimation(delay: fadeDuration, duration: duration) { [weak self] in
            self?.magmoorCreepyMinion = nil
            completion()
        }
    }
    
    /**
     Spawns Daemon the Destroyer. MUST call this before spawnMagmoorMinion!
     - parameter position: row and column center where Daemon spawns.
     */
    func spawnDaemon(at position: K.GameboardPosition) {
        //Daemon the Destroyer
        let statue5 = SKSpriteNode(imageNamed: "statue5")
        statue5.scale(to: scaleSize)
        statue5.position = getSpritePosition(at: position) + GameboardSprite.padding / 2 + scaleSize.width / 2
        statue5.zPosition = K.ZPosition.overlay + 200
        statue5.name = "DaemonTheDestroyer"
        
        sprite.addChild(statue5)
    }
    
    /**
     Spawns Magmoor's creepy minion at the designated position.
     - parameter position: row and column center where creepy will spawn
     */
    func spawnMagmoorMinion(at position: K.GameboardPosition) {
        let panelCount: Int = 9
        let positionFinal = getSpritePosition(at: (row: position.row + 1, col: position.col - 1)) + GameboardSprite.padding / 2 + scaleSize.width / 2
        let chatDelay: TimeInterval = 8
        let statue5bAnimateDuration: TimeInterval = 5
        let terrainAppearDuration: TimeInterval = 0.25
        let fadeDuration: TimeInterval = 1
        let panelDuration: TimeInterval = terrainAppearDuration * TimeInterval(panelCount)
        let totalDelay: TimeInterval = chatDelay + statue5bAnimateDuration + fadeDuration + panelDuration

        
        //Daemon the Destroyer... WILL NOT SHOW UP IF HE WASN'T SPAWNED FIRST!!
        let statue5 = sprite.childNode(withName: "DaemonTheDestroyer") as? SKSpriteNode
        statue5?.animateDaemon(newTexture: SKTexture(imageNamed: "statue5b"), delay: chatDelay)
        statue5?.run(SKAction.sequence([
            SKAction.wait(forDuration: chatDelay),
            SKAction.move(to: positionFinal, duration: statue5bAnimateDuration),
            SKAction.wait(forDuration: panelDuration + fadeDuration),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()
        ]))


        //Panels
        let panels = getSurroundingPanels(at: position)
        
        for (i, panel) in panels.enumerated() {
            panel.terrain?.run(SKAction.sequence([
                SKAction.wait(forDuration: chatDelay + statue5bAnimateDuration),
                SKAction.wait(forDuration: TimeInterval(i) * terrainAppearDuration),
                SKAction.colorize(with: .red, colorBlendFactor: 1, duration: fadeDuration),
            ]))
        }
        
        
        //Magmoor Creepy
        magmoorCreepyMinion = MagmoorCreepyMinion(scale: 3.5, gameboardScaleSize: scaleSize, spawnPoint: getSpritePosition(at: position))
        magmoorCreepyMinion!.addToParent(sprite)
        magmoorCreepyMinion!.beginAnimation(delay: totalDelay)
        
        
        //AudioManager
        AudioManager.shared.playSound(for: "magichorrorimpact", delay: totalDelay + 0.5)
        AudioManager.shared.playSound(for: "magmoorcreepystrings", delay: totalDelay + 0.5)
        AudioManager.shared.playSound(for: "magmoorcreepypulse", delay: totalDelay + 0.5)
    }
    
    /**
     Depawns Magmoor's creepy minion at the designated position.
     - parameter position: position should match spawnMagmoorMinion() position.
     */
    func despawnMagmoorMinion(at position: K.GameboardPosition, fadeDuration: TimeInterval) {
        guard let magmoorCreepyMinion = magmoorCreepyMinion else { return }
        
        //Panels
        let panels = getSurroundingPanels(at: position)
        
        for panel in panels {
            panel.terrain?.run(SKAction.colorize(with: GameboardSprite.dayThemeSpriteColor,
                                                 colorBlendFactor: GameboardSprite.dayThemeSpriteShade,
                                                 duration: fadeDuration))
        }

        //Magmoor Creepy
        magmoorCreepyMinion.endAnimation(delay: 0) { [weak self] in
            self?.magmoorCreepyMinion = nil
        }
        
        despawnPartyTilesForElders(fadeDuration: fadeDuration)
        
        //AudioManager
        AudioManager.shared.stopSound(for: "magmoorcreepystrings", fadeDuration: fadeDuration)
        AudioManager.shared.stopSound(for: "magmoorcreepypulse", fadeDuration: fadeDuration)
    }
    
    /**
     Calls on Magmoor's Minion to bring the pain, i.e. issue a series of attacks lasting for the prescribed duration.
     */
    func minionAttackSeries(duration: TimeInterval, completion: @escaping () -> Void) {
        guard let magmoorCreepyMinion = magmoorCreepyMinion else { return }
        
        let taptap = InstructionalSprite(iconFileName: "taptaptap", text: "Tap to Defend",
                                         position: CGPoint(x: sprite.position.x + sprite.size.width / 2, y: 20))
        taptap.addToParent(sprite)
        taptap.animateNodes(duration: 6) {
            taptap.removeFromParent()
        }
        
        magmoorCreepyMinion.minionAttackSeries(duration: duration, completion: completion)
    }

    /**
     Gets a 9 grid of panels from which to spawn, with the postion being the center point.
     - parameter position: center point of the 9 box panel where to spawn
     */
    private func getSurroundingPanels(at position: K.GameboardPosition) -> [K.GameboardPanelSprite] {
        var panels: [K.GameboardPanelSprite] = []
        panels.append(getPanel(at: position))
        panels.append(getPanel(at: (row: position.row, col: position.col - 1)))
        panels.append(getPanel(at: (row: position.row - 1, col: position.col - 1)))
        panels.append(getPanel(at: (row: position.row - 1, col: position.col)))
        panels.append(getPanel(at: (row: position.row - 1, col: position.col + 1)))
        panels.append(getPanel(at: (row: position.row, col: position.col + 1)))
        panels.append(getPanel(at: (row: position.row + 1, col: position.col + 1)))
        panels.append(getPanel(at: (row: position.row + 1, col: position.col)))
        panels.append(getPanel(at: (row: position.row + 1, col: position.col - 1)))
        
        return panels
    }
    
    
    // MARK: - Spawn Elder Functions
    
    func spawnElder(minionPosition: K.GameboardPosition, positions: [K.GameboardPosition], completion: @escaping () -> Void) {
        guard positions.count == 3 else {
            fatalError("GameboardSprite.spawnElder() incorrect number of array elements for positions.")
        }

        for node in sprite.children {
            if let nodeName = node.name,
               nodeName.contains(GameboardSprite.getNodeName(row: positions[0].row, col: positions[0].col, includeOverlayTag: true)) || nodeName.contains(GameboardSprite.getNodeName(row: positions[1].row, col: positions[1].col, includeOverlayTag: true)) || nodeName.contains(GameboardSprite.getNodeName(row: positions[2].row, col: positions[2].col, includeOverlayTag: true)) {
                //Exit function if there's an overlay item, like a gem or dragon
                print("Unable to execute GameboardSprite.spawnElder(); there's an overlay!")
                completion()

                return
            }
        }
        
        spawnPartyTilesForElders(minionPosition: minionPosition)
        
        spawnElderHelper(elder: elder0, positions: [positions[0], positions[1], positions[2]], completion: completion)
        spawnElderHelper(elder: elder1, positions: [positions[1], positions[2], positions[0]], completion: {})
        spawnElderHelper(elder: elder2, positions: [positions[2], positions[0], positions[1]], completion: {})
        
        AudioManager.shared.playSound(for: "magicelderreduce")
        AudioManager.shared.playSound(for: "magicelderexplosion")
    }
    
    private func spawnPartyTilesForElders(minionPosition: K.GameboardPosition) {
        let panelsToIgnore = getSurroundingPanels(at: minionPosition)
        let fadeDuration: TimeInterval = 2
        
        for row in 0..<panelCount {
            for col in 0..<panelCount {
                let nodeName = GameboardSprite.getNodeName(row: row, col: col)
                var isPanelToIgnore = false
                
                //Skip the center 9 squares where minion resides
                for panel in panelsToIgnore {
                    if panel.terrain?.name == nodeName {
                        isPanelToIgnore = true
                        break
                    }
                }
                
                guard !isPanelToIgnore else { continue }
                
                let terrainPanel = SKSpriteNode(imageNamed: "partytile" + AgeOfRuin.ruinSuffix)
                terrainPanel.anchorPoint = .zero
                terrainPanel.alpha = 0
                terrainPanel.zPosition = 20
                terrainPanel.name = GameboardSprite.getNodeName(row: row, col: col) + "partytile"
                
                terrainPanel.run(SKAction.fadeIn(withDuration: fadeDuration))
                terrainPanel.animatePartyTileShimmer(gameboardColor: GameboardSprite.gameboardColor)
                
                sprite.childNode(withName: nodeName)?.addChild(terrainPanel)
            }
        }
        
    }
    
    private func spawnElderHelper(elder: Player, positions: [K.GameboardPosition], completion: @escaping () -> Void) {
        let elderOffset = CGPoint(x: panelSize / 8, y: panelSize / 8)
        let appearDuration: TimeInterval = 1
        let rotateSpeed: TimeInterval = 1
        let rotateSpeedCircular: TimeInterval = 0.0625
        let divisionsOf2Pi: CGFloat = 32
        let idleSpeed: TimeInterval
        let particleType: ParticleEngine.ParticleType
        let particleScale: CGFloat
        let nameSuffix: String
        
        //Defunct as of 9/24/24.
        func moveWithIllusionsTriangular(startIndex: Int, endIndex: Int) -> SKAction {
            return SKAction.group([
                SKAction.move(to: getLocation(at: positions[endIndex]) + elderOffset, duration: rotateSpeed),
                Player.moveWithIllusions(
                    playerNode: elder.sprite, backgroundNode: sprite, tag: nameSuffix, color: .white, playSound: false,
                    startPoint: getLocation(at: positions[startIndex]) + elderOffset, endPoint: getLocation(at: positions[endIndex]) + elderOffset,
                    startScale: -Player.getGameboardScale(panelSize: panelSize) * elder.scaleMultiplier)
            ])
        }
        
        func moveWithIllusionsCircular(positions: [K.GameboardPosition]) -> [SKAction] {
            let trailColor: UIColor = .yellow
            let allPositions = SpriteMath.Circle.getPositions(positions: positions, divisionsOf2Pi: divisionsOf2Pi)
            var circularActions: [SKAction] = []
            
            for position in allPositions {
                let movePoint = getLocation(rowf: position.row, colf: position.col) + elderOffset
                
                circularActions.append(SKAction.group([
                    SKAction.move(to: movePoint, duration: rotateSpeedCircular),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        
                        elder.moveWithIllusions2(backgroundNode: sprite, trailColor: trailColor, trailLength: 20, trailTightness: 0.03)
                    }
                ]))
            }
            
            return circularActions
        }

        switch elder.type {
        case .elder0:
            nameSuffix = "0"
            particleType = .magicElderIce
            particleScale = 2 / CGFloat(panelCount)
            idleSpeed = 0.1
        case .elder1:
            nameSuffix = "1"
            particleType = .magicElderFire2
            particleScale = 3 / CGFloat(panelCount) / 2
            idleSpeed = 0.09
        case .elder2:
            nameSuffix = "2"
            particleType = .magicElderEarth2
            particleScale = 3 / CGFloat(panelCount)
            idleSpeed = 0.05
        default:
            nameSuffix = ""
            particleType = .warp
            particleScale = 3 / CGFloat(panelCount)
            idleSpeed = 0.1
        }
        
        elder.sprite.position = getLocation(at: positions[0])
        elder.sprite.setScale(0)
        elder.sprite.zPosition = K.ZPosition.itemsAndEffects + 20
        elder.sprite.name = "spawnElder\(nameSuffix)"
        elder.sprite.run(SKAction.repeatForever(SKAction.animate(with: elder.textures[Player.Texture.idle.rawValue], timePerFrame: idleSpeed)))
                
        sprite.addChild(elder.sprite)

        spawnItem(at: positions[0], with: .warp5) { [weak self] in
            guard let self = self else { return }
            
            elder.sprite.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scaleX(to: -Player.getGameboardScale(panelSize: panelSize) * elder.scaleMultiplier, duration: appearDuration),
                    SKAction.scaleY(to: Player.getGameboardScale(panelSize: panelSize) * elder.scaleMultiplier, duration: appearDuration),
                    SKAction.moveBy(x: elderOffset.x, y: elderOffset.y, duration: appearDuration)
                ]),
//                SKAction.sequence([
//                    moveWithIllusionsTriangular(startIndex: 0, endIndex: 1),
//                    moveWithIllusionsTriangular(startIndex: 1, endIndex: 2),
//                    moveWithIllusionsTriangular(startIndex: 2, endIndex: 0)
//                ]),
                SKAction.run {
                    ParticleEngine.shared.animateParticles(type: .magicLight,
                                                           toNode: elder.sprite,
                                                           position: .zero,
                                                           scale: 4,
                                                           zPosition: -1,
                                                           duration: 0)
                },
                SKAction.sequence(moveWithIllusionsCircular(positions: positions)),
                SKAction.run {
                    ParticleEngine.shared.removeParticles(fromNode: elder.sprite, fadeDuration: 3)
                }
            ]), completion: completion)
            
            sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 2),
                SKAction.run {
                    self.despawnItem(at: positions[0], completion: {})
                }
            ]))
            
            ParticleEngine.shared.animateParticles(type: particleType,
                                                   toNode: sprite,
                                                   position: getLocation(at: positions[0]),
                                                   scale: particleScale,
                                                   duration: 0)

        } //end spawnItem()
    }
    
    func despawnElders(to position: K.GameboardPosition, completion: @escaping () -> Void) {
        let endPoint = getLocation(at: position)

        func getDespawnAction(elder: Player) -> SKAction {
            let despawnDuration: TimeInterval = 2
            let fadeDuration: TimeInterval = 0.5
            
            let despawnAction = SKAction.group([
                SKAction.move(to: endPoint, duration: despawnDuration),
                SKAction.sequence([
                    SKAction.wait(forDuration: despawnDuration - fadeDuration),
                    SKAction.fadeOut(withDuration: fadeDuration)
                ])
            ])
            
            return despawnAction
        }

        elder0.sprite.run(SKAction.repeatForever(SKAction.animate(with: elder0.textures[Player.Texture.run.rawValue], timePerFrame: 0.1)))
        elder1.sprite.run(SKAction.repeatForever(SKAction.animate(with: elder1.textures[Player.Texture.run.rawValue], timePerFrame: 0.05)))
        elder2.sprite.run(SKAction.repeatForever(SKAction.animate(with: elder2.textures[Player.Texture.run.rawValue], timePerFrame: 0.05)))

        elder0.sprite.run(getDespawnAction(elder: elder0), completion: completion)
        elder1.sprite.run(getDespawnAction(elder: elder1))
        elder2.sprite.run(getDespawnAction(elder: elder2))
    }
    
    private func despawnPartyTilesForElders(fadeDuration: TimeInterval) {
        // FIXME: - There's got to be a less nesty way to do this.
        for node in sprite.children {
            for partyNode in node.children {
                if let nodeName = partyNode.name, nodeName.contains("partytile") {
                    partyNode.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: fadeDuration),
                        SKAction.removeFromParent()
                    ]))
                }
            }
        }
    }

    
    // MARK: - Panel Highlight/Colorization Functions
    
    func colorizeGameboard(fadeOut: Bool, fadeOutDuration: TimeInterval = 0.5, isInbetween: Bool, completion: (() -> Void)?) {
        let colorizeKey = "colorizeGameboard"
        let inbetweenSpriteColor: UIColor = FireIceTheme.overlayColor
        let inbetweenSpriteShade: CGFloat = 0.75

        let colorizeSpriteAction = SKAction.colorize(
            with:              fadeOut ? .black : GameboardSprite.gameboardColor,
            colorBlendFactor:  fadeOut ? 1.0 : 0.0,
            duration:          fadeOut ? 1.0 : fadeOutDuration)
        
        let colorizePanelAction = SKAction.colorize(
            with:               fadeOut ? .black : (isInbetween ? inbetweenSpriteColor : GameboardSprite.dayThemeSpriteColor),
            colorBlendFactor:   fadeOut ? 1.0 : (isInbetween ? inbetweenSpriteShade : GameboardSprite.dayThemeSpriteShade),
            duration:           fadeOut ? 1.0 : fadeOutDuration)
        
        //Update Terrain Panels
        for (row, panelRows) in panels.enumerated() {
            for (col, _) in panelRows.enumerated() {
                //First remove any existing actions on key, colorizeKey, before setting the new one!
                panels[row][col].removeAction(forKey: colorizeKey)
                panels[row][col].run(colorizePanelAction, withKey: colorizeKey)
                
                //if lavaPanel exists...
                for lavaPanel in panels[row][col].children {
                    lavaPanel.removeAction(forKey: colorizeKey)
                    lavaPanel.run(colorizePanelAction, withKey: colorizeKey)
                }
            }
        }
        
        //Update Overlay Panels
        for child in sprite.children {
            //3/4/23 I removed the completion handler call in this for loop because it was causing writes to Firestore to happen too many times. Would've been an accounting nightmare!
            guard let overlayNode = child as? SKSpriteNode,
                  let name = overlayNode.name,
                  name.contains(GameboardSprite.overlayTag) else { continue }
            
            overlayNode.removeAction(forKey: colorizeKey)
            overlayNode.run(colorizePanelAction, withKey: colorizeKey)
        }
        
        //Call Completion Handler
        sprite.run(colorizeSpriteAction) {
            completion?()
        }
    }

    func highlightPanel(color: UIColor, at position: K.GameboardPosition) {
        guard position.row >= 0 && position.row < panelCount && position.col >= 0 && position.col < panelCount else { return }
        
        let highlightborder = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 512, height: 512), cornerRadius: 20)
        highlightborder.fillColor = .clear
        highlightborder.strokeColor = color
        highlightborder.setScale(1 / 3)
        highlightborder.lineWidth = 20
        highlightborder.zPosition = 10
        
        panels[position.row][position.col].addChild(highlightborder)
        
        highlightborder.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {
        guard let panel = getIlluminatedPanel(at: position, useOverlay: useOverlay) else { return }
                
        panel.zPosition = K.ZPosition.chatDimOverlay + (useOverlay ? K.ZPosition.overlay : K.ZPosition.terrain)
        
        if !useOverlay {
//            let hintborderOffset = CGPoint(x: -49, y: -41) / CGFloat(panelCount) //x: [0] 49---(511)---560 [609]; y: [0] 41---(512)---553 [593]
            let hintborder = SKSpriteNode(imageNamed: "hintborder")
            hintborder.anchorPoint = .zero
            hintborder.zPosition = 10
            hintborder.name = "hintborder"
            
            let pulseAnimation = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.0, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.25),
                SKAction.wait(forDuration: 0.5)
            ])
            
            panel.addChild(hintborder)
            
            hintborder.run(SKAction.repeatForever(pulseAnimation))
        }
    }
    
    func deIlluminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {
        guard let panel = getIlluminatedPanel(at: position, useOverlay: useOverlay) else { return }
        
        panel.zPosition = useOverlay ? K.ZPosition.overlay : K.ZPosition.terrain
        panel.children.filter({ $0.name == "hintborder" }).first?.removeFromParent()
    }
    
    private func getIlluminatedPanel(at position: K.GameboardPosition, useOverlay: Bool) -> SKNode? {
        let panelName = GameboardSprite.getNodeName(row: position.row, col: position.col)
        
        if useOverlay {
            return sprite.childNode(withName: panelName + GameboardSprite.overlayTag)
        }
        else {
            for panelRows in panels {
                for panel in panelRows {
                    if panel.name == panelName {
                        return panel
                    }
                }
            }
        }
        
        return nil
    }
    
    
    // MARK: - Panel Animation Functions
    
    /**
     Rotates an overlay object if it exists (returns if not) using 4 directional types.
     - parameters:
        - position: the gameboard position of the overlay
        - directionType: no rotation, flipHorizontally, rotateClockwise, or rotateCounterClockwise
        - duration: duration of the animation
        - completion: the handler to run after all is said and done.
     */
    func rotateEnemy(at position: K.GameboardPosition, directionType: RotateDirectionType, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let overlay = sprite.childNode(withName: GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)) else { return }

        let action: SKAction
        
        switch directionType {
        case .none:
            action = SKAction.wait(forDuration: duration)
        case .flipHorizontal:
            action = SKAction.scaleX(to: -overlay.xScale, duration: duration)
        case .rotateClockwise:
            action = SKAction.rotate(byAngle: .pi / 2, duration: duration)
        case .rotateCounterClockwise:
            action = SKAction.rotate(byAngle: -.pi / 2, duration: duration)
        }

        overlay.run(action) {
            completion?()
        }
    }
    
    private func rotateWarp(node: SKNode, slow: Bool, repeatForever: Bool) {
        let rotationAngle: CGFloat = 2 * .pi
        let durationFast: TimeInterval = 2 * PartyModeSprite.shared.speedMultiplier
        var durationSlow: TimeInterval { durationFast * 8 }
        let rotateAction = SKAction.rotate(byAngle: -rotationAngle, duration: slow ? durationSlow : durationFast)
        
        if repeatForever {
            node.run(SKAction.repeatForever(rotateAction))
        }
        else {
            node.run(rotateAction)
        }
    }
    
    func warpTo(warpType: LevelType, initialPosition: K.GameboardPosition) -> K.GameboardPosition? {
        let chooseWarps: WarpTuple

        switch warpType {
        case .warp:
            chooseWarps = warps
        case .warp2:
            chooseWarps = warps2
        case .warp3:
            chooseWarps = warps3
        default:
            print("Invalid warp type!")
            return nil
        }
        
        guard let first = chooseWarps.first,
              let second = chooseWarps.second,
              let warpFirst = sprite.childNode(withName: GameboardSprite.getNodeName(row: first.row, col: first.col, includeOverlayTag: true)),
              let warpSecond = sprite.childNode(withName: GameboardSprite.getNodeName(row: second.row, col: second.col, includeOverlayTag: true))
        else {
            print("Level has no warps!")
            return nil
        }
        
        rotateWarp(node: warpFirst, slow: false, repeatForever: false)
        rotateWarp(node: warpSecond, slow: false, repeatForever: false)
        
        return first == initialPosition ? second : first
    }
    
    func animateDissolveSand(position: K.GameboardPosition) {
        let sandNode = SKSpriteNode(imageNamed: "sand" + AgeOfRuin.ruinSuffix)
        sandNode.color = GameboardSprite.dayThemeSpriteColor
        sandNode.colorBlendFactor = GameboardSprite.dayThemeSpriteShade
        sandNode.anchorPoint = .zero
        sandNode.zPosition = 10
        
        let lavaNode = SKSpriteNode(imageNamed: "lava" + AgeOfRuin.ruinSuffix)
        lavaNode.color = GameboardSprite.dayThemeSpriteColor
        lavaNode.colorBlendFactor = GameboardSprite.dayThemeSpriteShade
        lavaNode.anchorPoint = .zero
        lavaNode.zPosition = 5
        lavaNode.addChild(sandNode)

        updatePanels(at: position, with: (terrain: LevelType.lava, overlay: LevelType.boundary))
        panels[position.row][position.col].addChild(lavaNode)
        
        AudioManager.shared.playSound(for: "lavaappear\(Int.random(in: 1...3))")
        Haptics.shared.executeCustomPattern(pattern: .sand)
        
        //Animation Stuff
        let shakeDistance: CGFloat = 4
        let sandShake: TimeInterval = 0.06
        let sandAnimationDuration: TimeInterval = 1.0
        let sandSequence = SKAction.sequence([
            SKAction.moveBy(x: -shakeDistance, y: 0, duration: sandShake),
            SKAction.moveBy(x: shakeDistance, y: 0, duration: sandShake)
        ])
        
        panels[position.row][position.col].run(SKAction.repeat(sandSequence, count: Int(sandAnimationDuration / sandShake / 2)))
        sandNode.run(SKAction.fadeOut(withDuration: sandAnimationDuration))
        lavaNode.run(SKAction.fadeIn(withDuration: sandAnimationDuration))
        
        ParticleEngine.shared.animateParticles(type: .lavaAppear,
                                               toNode: sprite,
                                               position: getLocation(at: position),
                                               scale: 3 / CGFloat(panelCount),
                                               duration: 3)
    }
    
    func animateMeltSnow(position: K.GameboardPosition) {
        let snowNode = SKSpriteNode(imageNamed: "snow" + AgeOfRuin.ruinSuffix)
        snowNode.color = GameboardSprite.dayThemeSpriteColor
        snowNode.colorBlendFactor = GameboardSprite.dayThemeSpriteShade
        snowNode.anchorPoint = .zero
        snowNode.zPosition = 10
        
        let waterNode = SKSpriteNode(imageNamed: "water" + AgeOfRuin.ruinSuffix)
        waterNode.color = GameboardSprite.dayThemeSpriteColor
        waterNode.colorBlendFactor = GameboardSprite.dayThemeSpriteShade
        waterNode.anchorPoint = .zero
        waterNode.zPosition = 5
        waterNode.addChild(snowNode)

        updatePanels(at: position, with: (terrain: LevelType.water, overlay: LevelType.boundary))
        panels[position.row][position.col].addChild(waterNode)

        AudioManager.shared.playSoundThenStop(for: "waterappear\(Int.random(in: 1...3))", playForDuration: 1, fadeOut: 2)
        Haptics.shared.executeCustomPattern(pattern: .snow)
        
        //Animation Stuff
        let repeatCount = 6
        let snowAnimationDuration: TimeInterval = 1.0
        let snowSequence = SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: snowAnimationDuration / TimeInterval(repeatCount * 2)),
            SKAction.fadeAlpha(to: 1, duration: snowAnimationDuration / TimeInterval(repeatCount * 2))
        ])
        
        panels[position.row][position.col].run(SKAction.repeat(snowSequence, count: repeatCount))
        snowNode.run(SKAction.fadeOut(withDuration: snowAnimationDuration))
        waterNode.run(SKAction.fadeIn(withDuration: snowAnimationDuration))
        
        ParticleEngine.shared.removeParticles(fromNode: sprite, nameGameboardPosition: position)
    }
    
    func animateBreatheFireIdle(position: K.GameboardPosition) {
        guard let dragonNode = sprite.childNode(withName: GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)) else { return }
        
        var wait1: TimeInterval { TimeInterval.random(in: 0...1) }
        var wait2: TimeInterval { TimeInterval.random(in: 3...5) }
        
        dragonNode.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: wait1),
            SKAction.run {
                ParticleEngine.shared.animateParticles(type: FireIceTheme.particleTypeDragonFireIdle,
                                                       toNode: dragonNode,
                                                       position: CGPoint(x: 0, y: 35),
                                                       scale: UIDevice.isiPad ? 0.25 : 0.5,
                                                       zPosition: 10,
                                                       duration: 2)
            },
            SKAction.wait(forDuration: wait2),
        ])))
    }
    
    func animateHeartbeat(position: K.GameboardPosition) {
        guard let heartNode = sprite.childNode(withName: GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)) else { return }
        
        let originalScale: CGFloat = heartNode.xScale
        let scaleOffsetPercentage: CGFloat = originalScale * 0.1
        let timingExponent: Float = 2
        let beatDuration: TimeInterval = 0.2
        let pulseRate: TimeInterval = 60
        let bpmDuration: TimeInterval = 60 / pulseRate - 3 * beatDuration + TimeInterval.random(in: -0.02...0.02)
        
        let scaleUp = SKAction.scale(to: originalScale + scaleOffsetPercentage, duration: beatDuration)
        scaleUp.timingFunction = { time in
            pow(time, timingExponent)
        }
        
        let scaleDown = SKAction.scale(to: originalScale - scaleOffsetPercentage, duration: beatDuration)
        scaleDown.timingFunction = { time in
            pow(time, 1 / timingExponent)
        }
        
        heartNode.run(SKAction.repeatForever(SKAction.sequence([
            scaleUp,
            scaleDown,
            SKAction.scale(to: originalScale, duration: beatDuration),
            SKAction.wait(forDuration: bpmDuration)
        ])))
    }
}
