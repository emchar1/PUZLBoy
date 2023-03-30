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
    static var xPosition: CGFloat { (K.ScreenDimensions.iPhoneWidth * (1 - GameboardSprite.spriteScale)) / 2 - (padding / 2) }
    static var yPosition: CGFloat { (K.ScreenDimensions.height - K.ScreenDimensions.iPhoneWidth * GameboardSprite.spriteScale - K.ScreenDimensions.topMargin - 283) - (padding / 2) }

    typealias WarpTuple = (first: K.GameboardPosition?, second: K.GameboardPosition?)

    private let tiles: [LevelType] = LevelType.allCases
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
        sprite.position = CGPoint(x: GameboardSprite.xPosition, y: GameboardSprite.yPosition)
        sprite.zPosition = K.ZPosition.gameboard
        sprite.setScale(GameboardSprite.spriteScale)

        for row in 0..<panelCount {
            for col in 0..<panelCount {
                let levelType: K.GameboardPanel = level.gameboard[row][col]
                
                updatePanels(at: (row: row, col: col), with: levelType)
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    func updatePanels(at position: K.GameboardPosition, with tile: K.GameboardPanel) {
        let spacing: CGFloat = 4
        let scaleSize = CGSize(width: panelSize - spacing, height: panelSize - spacing)
        let spritePosition = CGPoint(x: CGFloat(position.col) * panelSize + spacing / 2,
                                     y: CGFloat(panelCount - 1 - position.row) * panelSize + spacing / 2)
        
        panels[position.row][position.col] = SKSpriteNode(imageNamed: tile.terrain.description)
        panels[position.row][position.col].scale(to: scaleSize)
        panels[position.row][position.col].position = spritePosition + CGPoint(x: GameboardSprite.padding / 2, y: GameboardSprite.padding / 2)
        panels[position.row][position.col].anchorPoint = .zero
        panels[position.row][position.col].zPosition = K.ZPosition.terrain
        panels[position.row][position.col].name = "\(position.row),\(position.col)"
        
        // FIXME: - Testing for partytile
        if tile.terrain == .partytile {
            let randomHue = UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            let randomDuration = TimeInterval.random(in: 0.75...1.0)

            panels[position.row][position.col].run(SKAction.repeatForever(SKAction.sequence([
                SKAction.colorize(with: GameboardSprite.gameboardColor, colorBlendFactor: 0.0, duration: randomDuration),
                SKAction.colorize(with: randomHue, colorBlendFactor: 1.0, duration: randomDuration)
            ])))
        }

        sprite.addChild(panels[position.row][position.col])
        
        if tile.overlay != .boundary {
            let overlayPanel = SKSpriteNode(imageNamed: tile.overlay.description)
            overlayPanel.scale(to: scaleSize)
            overlayPanel.position = spritePosition
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
    
    func illuminatePanel(at spriteName: (row: Int, col: Int), useOverlay: Bool) {
        guard let panel = getPanel(at: spriteName, useOverlay: useOverlay) else { return }
                
        panel.zPosition = K.ZPosition.chatDimOverlay + (useOverlay ? K.ZPosition.overlay : K.ZPosition.terrain)
        
        if !useOverlay {
            let goldBorder = SKSpriteNode(imageNamed: "goldborder")
            goldBorder.anchorPoint = .zero
            goldBorder.zPosition = 10
            goldBorder.name = "goldborder"
            
            panel.addChild(goldBorder)
        }
    }
    
    func deIlluminatePanel(at spriteName: (row: Int, col: Int), useOverlay: Bool) {
        guard let panel = getPanel(at: spriteName, useOverlay: useOverlay) else { return }
        
        panel.zPosition = useOverlay ? K.ZPosition.overlay : K.ZPosition.terrain
        
        for childPanel in panel.children {
            if childPanel.name == "goldborder" {
                childPanel.removeFromParent()
            }
        }
    }
    
    private func getPanel(at spriteName: (row: Int, col: Int), useOverlay: Bool) -> SKNode? {
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
    
    func getLocation(at position: K.GameboardPosition) -> CGPoint {
        return CGPoint(x: panelSize * (CGFloat(position.col) + 0.5), y: panelSize * (CGFloat(panelCount - 1 - position.row) + 0.5))
    }
    
    func colorizeGameboard(color: UIColor, blendFactor: CGFloat, animationDuration: TimeInterval, completion: (() -> ())?) {
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
        sandNode.zPosition = K.ZPosition.terrain
        
        let lavaNode = SKSpriteNode(imageNamed: "lava")
        lavaNode.anchorPoint = .zero
        lavaNode.zPosition = K.ZPosition.terrain
        lavaNode.addChild(sandNode)

        updatePanels(at: position, with: (terrain: LevelType.lava, overlay: LevelType.boundary))
        panels[position.row][position.col].addChild(lavaNode)
        
        let lavaappear = "lavaappear\(Int.random(in: 1...3))"
        AudioManager.shared.playSound(for: lavaappear)
        AudioManager.shared.adjustVolume(to: 0.5, for: lavaappear)
        AudioManager.shared.stopSound(for: lavaappear, fadeDuration: 1.5)
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
    }
}
