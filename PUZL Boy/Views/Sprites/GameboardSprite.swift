//
//  GameboardSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/28/22.
//

import SpriteKit

class GameboardSprite {
    
    // MARK: - Properties
    
    static let gameboardColor: UIColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
    static let overlayTag = "-O"
    static let spriteScale: CGFloat = UIDevice.isiPad ? 0.75 : 0.94

    static let padding: CGFloat = 12
    static var offsetPosition: CGPoint {
        CGPoint(x: (K.ScreenDimensions.iPhoneWidth * (1 - GameboardSprite.spriteScale)) / 2 - (padding / 2),
                y: (K.ScreenDimensions.height - K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale - K.ScreenDimensions.topMargin - 283) - (padding / 2))
    }

    typealias WarpTuple = (first: K.GameboardPosition?, second: K.GameboardPosition?)
    
    private let panelSpacing: CGFloat = 4
    private var scaleSize: CGSize { CGSize(width: panelSize - panelSpacing, height: panelSize - panelSpacing) }
    private var panels: [[SKSpriteNode]]
    private(set) var panelCount: Int
    private(set) var panelSize: CGFloat
    private(set) var warps: WarpTuple = (nil, nil)
    private(set) var warps2: WarpTuple = (nil, nil)
    private(set) var warps3: WarpTuple = (nil, nil)
    private(set) var sprite: SKSpriteNode

    
    // MARK: - Initialization
    
    init(level: Level) {
        panelCount = level.gameboard.count
        panelSize = K.ScreenDimensions.iPhoneWidth / CGFloat(panelCount)
        panels = Array(repeating: Array(repeating: SKSpriteNode(), count: panelCount), count: panelCount)
        
        sprite = SKSpriteNode(color: GameboardSprite.gameboardColor,
                              size: CGSize(width: CGFloat(panelCount) * panelSize + GameboardSprite.padding,
                                           height: CGFloat(panelCount) * panelSize + GameboardSprite.padding))
        sprite.anchorPoint = .zero
        sprite.position = CGPoint(x: GameboardSprite.offsetPosition.x, y: GameboardSprite.offsetPosition.y)
        sprite.zPosition = K.ZPosition.gameboard
        sprite.setScale(GameboardSprite.spriteScale)

        for row in 0..<panelCount {
            for col in 0..<panelCount {
                let levelType: K.GameboardPanel = level.gameboard[row][col]
                
                updatePanels(at: (row: row, col: col), with: levelType)
            }
        }
    }
    
    
    // MARK: - Getter/Setter Functions
    
    ///Helper function that takes in the gameboard position and returns where it lies on the screen's CGPoint coordinates.
    private func getSpritePosition(at position: K.GameboardPosition) -> CGPoint {
        return CGPoint(x: panelSize * CGFloat(position.col) + panelSpacing / 2,
                       y: panelSize * CGFloat(panelCount - 1 - position.row) + panelSpacing / 2)
    }
    
    ///SImilar to getSpritePosition(at:) but different in where it situates the returned CGPoint.
    func getLocation(at position: K.GameboardPosition) -> CGPoint {
        return CGPoint(x: panelSize * (CGFloat(position.col) + 0.5),
                       y: panelSize * (CGFloat(panelCount - 1 - position.row) + 0.5))
    }
    
    ///Returns the panel at the location provided, offset by the offsetPosition.
    func getPanel(at location: CGPoint) -> K.GameboardPosition? {
        guard let node = sprite.nodes(at: location - GameboardSprite.offsetPosition).first else { return nil }
        guard let nodeName = node.name?.replacingOccurrences(of: GameboardSprite.overlayTag, with: "") else { return nil }
        guard let range = nodeName.range(of: ",") else { return nil }
        guard let row = Int(nodeName[..<range.lowerBound]) else { return nil }
        guard let col = Int(nodeName[range.upperBound...]) else { return nil }
        guard row >= 0 && row < panelCount && col >= 0 && col < panelCount else { return nil }
        
        //Finally!
        return (row: row, col: col)
    }

    func updatePanels(at position: K.GameboardPosition, with tile: K.GameboardPanel) {
        panels[position.row][position.col] = SKSpriteNode(imageNamed: tile.terrain.description)
        panels[position.row][position.col].scale(to: scaleSize)
        panels[position.row][position.col].position = getSpritePosition(at: position) + CGPoint(x: GameboardSprite.padding / 2, y: GameboardSprite.padding / 2)
        panels[position.row][position.col].anchorPoint = .zero
        panels[position.row][position.col].zPosition = K.ZPosition.terrain
        panels[position.row][position.col].name = "\(position.row),\(position.col)"
        
        if tile.terrain == .partytile {
            let randomHue = UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            let randomDuration = TimeInterval.random(in: 0.75...1.0)

            panels[position.row][position.col].run(SKAction.repeatForever(SKAction.sequence([
                SKAction.colorize(with: GameboardSprite.gameboardColor, colorBlendFactor: 0.0, duration: randomDuration),
                SKAction.colorize(with: randomHue, colorBlendFactor: 1.0, duration: randomDuration)
            ])))
        }
        else if tile.terrain == .marsh {
            ParticleEngine.shared.animateParticles(type: .poisonBubbles,
                                                   toNode: sprite,
                                                   position: getLocation(at: position),
                                                   scale: 3 / CGFloat(panelCount),
                                                   duration: 0)
        }
        else if tile.terrain == .lava {
            ParticleEngine.shared.animateParticles(type: .lavaSizzle,
                                                   toNode: sprite,
                                                   position: getLocation(at: position),
                                                   scale: 3 / CGFloat(panelCount),
                                                   duration: 0)
        }

        sprite.addChild(panels[position.row][position.col])
        
        if tile.overlay != .boundary {
            let overlayPanel = SKSpriteNode(imageNamed: tile.overlay.description)
            overlayPanel.scale(to: scaleSize)
            overlayPanel.position = getSpritePosition(at: position)
            overlayPanel.anchorPoint = .zero
            overlayPanel.zPosition = K.ZPosition.overlay
            overlayPanel.name = "\(position.row),\(position.col)\(GameboardSprite.overlayTag)"

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
    }
    
    
    // MARK: - Spawn Functions
    
    /**
     Spawns an item in a panel with a little growth animation.
     - parameters:
        - position: position on the gameboard to spawn
        - itemOverlay: the item LevelType to spawn
     */
    func spawnItem(at position: K.GameboardPosition, with itemOverlay: LevelType, completion: @escaping () -> Void) {
        let duration: TimeInterval = 0.25
        let bounceFactor: CGFloat = scaleSize.width * 0.25
        let overlayPanel = SKSpriteNode(imageNamed: itemOverlay.description)

        overlayPanel.scale(to: .zero)
        overlayPanel.position = getSpritePosition(at: position) + CGPoint(x: scaleSize.width / 2, y: scaleSize.height / 2)
        overlayPanel.anchorPoint = .zero
        overlayPanel.zPosition = K.ZPosition.overlay
        overlayPanel.name = "\(position.row),\(position.col)\(GameboardSprite.overlayTag)"

        sprite.addChild(overlayPanel)
        
        overlayPanel.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: scaleSize + CGSize(width: bounceFactor, height: bounceFactor), duration: duration),
                SKAction.move(to: getSpritePosition(at: position) - CGPoint(x: bounceFactor / 2, y: bounceFactor / 2), duration: duration)
            ]),
            SKAction.group([
                SKAction.scale(to: scaleSize, duration: duration),
                SKAction.move(to: getSpritePosition(at: position), duration: duration)
            ])
        ]), completion: completion)
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
        let itemOverlays = sprite.children.filter({ $0.name == "\(position.row),\(position.col)\(GameboardSprite.overlayTag)" })
        
        for itemOverlay in itemOverlays {
            itemOverlay.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: scaleSize + CGSize(width: bounceFactor, height: bounceFactor), duration: duration),
                    SKAction.move(to: getSpritePosition(at: position) - CGPoint(x: bounceFactor / 2, y: bounceFactor / 2), duration: duration)
                ]),
                SKAction.group([
                    SKAction.scale(to: 0, duration: duration),
                    SKAction.move(to: getSpritePosition(at: position) + CGPoint(x: scaleSize.width / 2, y: scaleSize.height / 2), duration: duration)
                ])
            ])) {
                itemOverlay.removeFromParent()
                completion()
            }
        }
    }
    
    
    // MARK: - Panel Highlight/Colorization Functions
    
    func colorizeGameboard(color: UIColor, blendFactor: CGFloat, animationDuration: TimeInterval, completion: (() -> Void)?) {
        let colorizeAction = SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: animationDuration)

        for (row, panelRows) in panels.enumerated() {
            for (col, _) in panelRows.enumerated() {
                panels[row][col].run(colorizeAction)
                
                //if lavaPanel exists...
                for lavaPanel in panels[row][col].children {
                    lavaPanel.run(colorizeAction)
                }
            }
        }
        
        if completion == nil {
            sprite.run(colorizeAction)
        }
        else {
            sprite.run(colorizeAction, completion: completion!)
        }
        
        for overlayObject in sprite.children {
            //3/4/23 I removed the completion handler call in this for loop because it was causing writes to Firestore to happen too many times. Would've been an accounting nightmare!
            overlayObject.run(colorizeAction)
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
    
    func illuminatePanel(at spriteName: (row: Int, col: Int), useOverlay: Bool) {
        guard let panel = getIlluminatedPanel(at: spriteName, useOverlay: useOverlay) else { return }
                
        panel.zPosition = K.ZPosition.chatDimOverlay + (useOverlay ? K.ZPosition.overlay : K.ZPosition.terrain)
        
        if !useOverlay {
            let hintborder = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 512, height: 512), cornerRadius: 20)
            hintborder.fillColor = .clear
            hintborder.strokeColor = .systemYellow
            hintborder.setScale(1 / 3)
            hintborder.lineWidth = 20
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
    
    func deIlluminatePanel(at spriteName: (row: Int, col: Int), useOverlay: Bool) {
        guard let panel = getIlluminatedPanel(at: spriteName, useOverlay: useOverlay) else { return }
        
        panel.zPosition = useOverlay ? K.ZPosition.overlay : K.ZPosition.terrain
        panel.children.filter({ $0.name == "hintborder" }).first?.removeFromParent()
    }
    
    private func getIlluminatedPanel(at spriteName: (row: Int, col: Int), useOverlay: Bool) -> SKNode? {
        let panelName = "\(spriteName.row),\(spriteName.col)"
        
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
    
    
    // MARK: - Other Functions
    
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
        
        guard let first = chooseWarps.first, let second = chooseWarps.second else {
            print("Level has no warps!")
            return nil
        }
        
        return first == initialPosition ? second : first
    }
    
    func animateDissolveSand(position: K.GameboardPosition) {
        let sandNode = SKSpriteNode(imageNamed: "sand")
        sandNode.anchorPoint = .zero
        sandNode.zPosition = 10
        
        let lavaNode = SKSpriteNode(imageNamed: "lava")
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
}
