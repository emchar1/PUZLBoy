//
//  GameboardSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/28/22.
//

import SpriteKit

class GameboardSprite {
    
    // MARK: - Properties
    
    //Static Properties
    static let gameboardColor: UIColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
    static let delimiter = ","
    static let overlayTag = "-O"
    static let spriteScale: CGFloat = UIDevice.isiPad ? 0.75 : 0.94
    static let padding: CGFloat = 12
    static var offsetPosition: CGPoint {
        CGPoint(x: (K.ScreenDimensions.size.width * (1 - GameboardSprite.spriteScale)) / 2 - (padding / 2),
                y: (K.ScreenDimensions.size.height - K.ScreenDimensions.size.width * GameboardSprite.spriteScale - K.ScreenDimensions.topMargin - 283) - (padding / 2))
    }

    //Warp Properties
    typealias WarpTuple = (first: K.GameboardPosition?, second: K.GameboardPosition?)
    private(set) var warps: WarpTuple = (nil, nil)
    private(set) var warps2: WarpTuple = (nil, nil)
    private(set) var warps3: WarpTuple = (nil, nil)

    //Misc Properties
    private let panelSpacing: CGFloat = 4
    private var scaleSize: CGSize { CGSize.zero + panelSize - panelSpacing }
    private var panels: [[SKSpriteNode]]
    private var endPanel: K.GameboardPosition?
    private(set) var panelCount: Int
    private(set) var panelSize: CGFloat
    private(set) var sprite: SKSpriteNode
    
    enum RotateDirectionType {
        case none, flipHorizontal, rotateClockwise, rotateCounterClockwise
    }

    
    // MARK: - Initialization
    
    init(level: Level) {
        panelCount = level.gameboard.count
        panelSize = K.ScreenDimensions.size.width / CGFloat(panelCount)
        panels = Array(repeating: Array(repeating: SKSpriteNode(), count: panelCount), count: panelCount)
        
        sprite = SKSpriteNode(color: GameboardSprite.gameboardColor, size: CGSize.zero + CGFloat(panelCount) * panelSize + GameboardSprite.padding)
        sprite.anchorPoint = .zero
        sprite.position = GameboardSprite.offsetPosition
        sprite.zPosition = K.ZPosition.gameboard
        sprite.setScale(GameboardSprite.spriteScale)

        for row in 0..<panelCount {
            for col in 0..<panelCount {
                let levelType: K.GameboardPanel = level.gameboard[row][col]
                
                if levelType.terrain == .endClosed || levelType.terrain == .endOpen {
                    endPanel = (row: row, col: col)
                }
                
                updatePanels(at: (row: row, col: col), with: levelType)
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

    ///Returns the panel at the location provided, offset by the offsetPosition.
    func getPanel(at location: CGPoint) -> K.GameboardPosition? {
        guard let node = sprite.nodes(at: location - GameboardSprite.offsetPosition).first else { return nil }
        guard let nodeName = node.name?.replacingOccurrences(of: GameboardSprite.overlayTag, with: "") else { return nil }
        guard let range = nodeName.range(of: GameboardSprite.delimiter) else { return nil }
        guard let row = Int(nodeName[..<range.lowerBound]) else { return nil }
        guard let col = Int(nodeName[range.upperBound...]) else { return nil }
        guard row >= 0 && row < panelCount && col >= 0 && col < panelCount else { return nil }
        
        //Finally!
        return (row: row, col: col)
    }

    func updatePanels(at position: K.GameboardPosition, with tile: K.GameboardPanel) {
        panels[position.row][position.col] = SKSpriteNode(imageNamed: tile.terrain.description)
        panels[position.row][position.col].scale(to: scaleSize)
        panels[position.row][position.col].position = getSpritePosition(at: position) + GameboardSprite.padding / 2
        panels[position.row][position.col].anchorPoint = .zero
        panels[position.row][position.col].zPosition = K.ZPosition.terrain
        panels[position.row][position.col].name = GameboardSprite.getNodeName(row: position.row, col: position.col)
        
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
            overlayPanel.position = getSpritePosition(at: position) + GameboardSprite.padding / 2 + scaleSize.width / 2
            overlayPanel.zPosition = K.ZPosition.overlay
            overlayPanel.name = GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)
            
            switch tile.overlay {
            case .warp, .warp2, .warp3, .warp4:
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
        overlayPanel.position = getSpritePosition(at: position) + GameboardSprite.padding / 2 + scaleSize.width / 2
        overlayPanel.zPosition = itemOverlay == .warp4 ? K.ZPosition.itemsAndEffects - 10 : K.ZPosition.overlay
        overlayPanel.name = GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)

        switch itemOverlay {
        case .warp, .warp2, .warp3, .warp4:
            rotateWarp(node: overlayPanel, slow: true, repeatForever: true)
        default:
            break
        }
        
        overlayPanel.run(SKAction.sequence([
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
    
    ///Spawns a short animation of the whereabouts of the princess being captured by the villain.
    func spawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        guard let endPanel = endPanel else { return print("Can't spawn, there's no endPanel!") }

        for node in sprite.children {
            if let nodeName = node.name,
               nodeName.contains(GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)) {
                //Exit function if there's an overlay item, like a gem or dragon
                return print("Can't spawn here, there's an overlay!")
            }
        }
        
        let playerOffset = CGPoint(x: panelSize / 4, y: 0)
        let villainOffset = CGPoint(x: 0, y: 20)
        let startPoint = getLocation(at: position)
        let endPoint = getLocation(at: endPanel)
        let facingMultiplier: CGFloat = endPoint.x > startPoint.x ? -1 : 1

        let overlayPanel = SKSpriteNode(imageNamed: LevelType.endOpen.description)
        overlayPanel.scale(to: scaleSize)
        overlayPanel.position = getSpritePosition(at: endPanel) + GameboardSprite.padding / 2
        overlayPanel.anchorPoint = .zero
        overlayPanel.zPosition = K.ZPosition.overlay
        overlayPanel.name = "captureEndOpen"
        sprite.addChild(overlayPanel)
        
        AudioManager.shared.playSound(for: "magicdoomloop", fadeIn: 3, interruptPlayback: false)
        AudioManager.shared.playSound(for: "littlegirllaugh", fadeIn: 3, interruptPlayback: false)
        AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 3, interruptPlayback: false)
        AudioManager.shared.adjustVolume(to: 0, for: AudioManager.shared.currentTheme, fadeDuration: 5)
        
        spawnItem(at: position, with: .warp4) { [unowned self] in
            AudioManager.shared.playSound(for: "magicwarp")
            ParticleEngine.shared.animateParticles(type: .warp4,
                                                   toNode: sprite,
                                                   position: getLocation(at: position),
                                                   scale: 3 / CGFloat(panelCount),
                                                   duration: 0)

            let princess = Player(type: .princess)
            princess.sprite.position = startPoint
            princess.sprite.setScale(0)
            princess.sprite.zPosition = K.ZPosition.itemsAndEffects + 30
            princess.sprite.run(SKAction.repeatForever(SKAction.animate(with: princess.textures[Player.Texture.jump.rawValue], timePerFrame: 0.02)))
            princess.sprite.name = "capturePrincess"
            
            let villain = Player(type: .villain)
            villain.sprite.position = startPoint + villainOffset
            villain.sprite.setScale(0)
            villain.sprite.zPosition = K.ZPosition.itemsAndEffects + 20
            villain.sprite.run(SKAction.repeatForever(SKAction.animate(with: villain.textures[Player.Texture.idle.rawValue], timePerFrame: 0.1)))
            villain.sprite.name = "captureVillain"
                        
            
            let waitDuration: TimeInterval = 1
            let appearDuration: TimeInterval = 0.5

            princess.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: waitDuration),
                SKAction.group([
                    SKAction.scaleX(to: facingMultiplier * Player.getStandardScale(panelSize: panelSize) * princess.scaleMultiplier, duration: appearDuration),
                    SKAction.scaleY(to: Player.getStandardScale(panelSize: panelSize) * princess.scaleMultiplier, duration: appearDuration),
                    SKAction.moveBy(x: facingMultiplier * playerOffset.x, y: playerOffset.y, duration: appearDuration)
                ])
            ]))
            
            villain.sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: waitDuration),
                SKAction.group([
                    SKAction.scaleX(to: facingMultiplier * Player.getStandardScale(panelSize: panelSize) * villain.scaleMultiplier, duration: appearDuration),
                    SKAction.scaleY(to: Player.getStandardScale(panelSize: panelSize) * villain.scaleMultiplier, duration: appearDuration),
                    SKAction.moveBy(x: -facingMultiplier * playerOffset.x, y: playerOffset.y, duration: appearDuration)
                ])
            ]))
            
            sprite.addChild(princess.sprite)
            sprite.addChild(villain.sprite)
            
            sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.run { [unowned self] in
                    // FIXME: - Does this create a retain cycle?
                    despawnItem(at: position, completion: completion)
                }
            ]))
        }
    }
    
    ///Despawns the princess being captured by the villain, as he escapes through the back door.
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void) {
        guard let endPanel = endPanel else { return print("Can't despawn here, there's no endPanel!")}
        
        let playerOffset = CGPoint(x: panelSize / 4, y: 0)
        let villainOffset = CGPoint(x: 0, y: 20)
        let startPoint = getLocation(at: position)
        let endPoint = getLocation(at: endPanel)
        let facingMultiplier: CGFloat = endPoint.x > startPoint.x ? -1 : 1

        let actionDuration: TimeInterval = 1
        let blinkDivision: Int = 10
        let exitDoorScale: CGFloat = 0.25
        
        for node in sprite.children {
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
                let villainScaleMultiplier: CGFloat = 1.5
                var illusionStep = 1
                
                node.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: actionDuration / 2),
                        SKAction.run {
                            AudioManager.shared.playSound(for: "magicteleport")
                        },
                        SKAction.repeat(SKAction.sequence([
                            SKAction.run { [unowned self] in
                                let illusionSprite = SKSpriteNode(imageNamed: node.texture?.getFilename() ?? "VillainIdle (1)")
                                illusionSprite.size = Player.size
                                illusionSprite.xScale = facingMultiplier * Player.getStandardScale(panelSize: panelSize) * villainScaleMultiplier
                                illusionSprite.yScale = Player.getStandardScale(panelSize: panelSize) * villainScaleMultiplier
                                illusionSprite.position = SpriteMath.Trigonometry.getMidpoint(startPoint: startPoint - facingMultiplier * playerOffset + villainOffset, endPoint: endPoint - facingMultiplier * playerOffset + villainOffset, step: illusionStep, totalSteps: blinkDivision)
                                illusionSprite.zPosition = K.ZPosition.itemsAndEffects + 20 - CGFloat(blinkDivision - illusionStep)
                                illusionSprite.name = "escapeVillain\(illusionStep)"
                                
                                sprite.addChild(illusionSprite)
                            },
                            SKAction.wait(forDuration: actionDuration / TimeInterval(blinkDivision)),
                            SKAction.run { [unowned self] in
                                if let illusionSprite = sprite.childNode(withName: "escapeVillain\(illusionStep)") {
                                    illusionSprite.run(SKAction.sequence([
                                        SKAction.fadeOut(withDuration: actionDuration / 2),
                                        SKAction.removeFromParent()
                                    ]))
                                }
                                
                                illusionStep += 1
                            }
                        ]), count: blinkDivision)
                    ]),
                    SKAction.run {
                        let angleOfAttack: CGFloat = SpriteMath.Trigonometry.getAngles(startPoint: startPoint + playerOffset + villainOffset, endPoint: endPoint + playerOffset + villainOffset).beta * (endPoint.y < startPoint.y ? 1 : -1)
                        
                        AudioManager.shared.playSound(for: "magicblast")
                        
                        ParticleEngine.shared.animateParticles(type: .magicBlast,
                                                               toNode: node,
                                                               position: CGPoint(x: 160, y: 100),
                                                               angle: angleOfAttack,
                                                               duration: actionDuration * 3.5)
                    },
                    SKAction.move(to: endPoint - facingMultiplier * playerOffset + villainOffset, duration: 0),
                    SKAction.fadeIn(withDuration: 0),
                    SKAction.wait(forDuration: actionDuration * 3.5),
                    SKAction.sequence([
                        SKAction.group([
                            SKAction.scaleX(to: node.xScale * exitDoorScale, y: node.yScale * exitDoorScale, duration: actionDuration / 2),
                            SKAction.moveBy(x: facingMultiplier * playerOffset.x / 2, y: 0, duration: actionDuration / 2)
                        ]),
                        SKAction.fadeOut(withDuration: actionDuration / 2)
                    ]),
                    SKAction.removeFromParent()
                ]))
            }
            else if node.name == "captureEndOpen" {
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 5.5 * actionDuration),
                    SKAction.removeFromParent(),
                    SKAction.run {
                        AudioManager.shared.playSound(for: "dooropen")
                        AudioManager.shared.stopSound(for: "magicdoomloop", fadeDuration: 5)
                        AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 5)
                        AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 5)
                        AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme, fadeDuration: 3)
                    }
                ]), completion: completion)
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
    
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool) {
        guard let panel = getIlluminatedPanel(at: position, useOverlay: useOverlay) else { return }
                
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
    
    func animateBreatheFireIdle(position: K.GameboardPosition) {
        guard let dragonNode = sprite.childNode(withName: GameboardSprite.getNodeName(row: position.row, col: position.col, includeOverlayTag: true)) else { return }
        
        var wait1: TimeInterval { TimeInterval.random(in: 0...1) }
        var wait2: TimeInterval { TimeInterval.random(in: 3...5) }
        
        dragonNode.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: wait1),
            SKAction.run {
                ParticleEngine.shared.animateParticles(type: .dragonFireIdle,
                                                       toNode: dragonNode,
                                                       position: CGPoint(x: 0, y: 35),
                                                       scale: UIDevice.isiPad ? 0.25 : 0.5,
                                                       zPosition: 10,
                                                       duration: 0)
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
