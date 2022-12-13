//
//  GameboardSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/28/22.
//

import SpriteKit

class GameboardSprite {
    
    // MARK: - Properties
    
    private let tiles: [LevelType] = LevelType.allCases
    let overlayTag = "-O"
    let spriteScale: CGFloat = 0.94

    var xPosition: CGFloat { (K.ScreenDimensions.iPhoneWidth * (1 - spriteScale)) / 2 }
    var yPosition: CGFloat { (K.ScreenDimensions.height - gameboardSize * spriteScale) / 2 }
    var gameboardSize: CGFloat { CGFloat(panelCount) * panelSize }

    private var panels: [[SKSpriteNode]]
    private(set) var panelCount: Int
    private(set) var panelSize: CGFloat
    private(set) var warps: (first: K.GameboardPosition?, second: K.GameboardPosition?)
    private(set) var sprite: SKSpriteNode

    
    // MARK: - Initialization
    
    init(level: Level) {
        panelCount = level.gameboard.count
        panelSize = K.ScreenDimensions.iPhoneWidth / CGFloat(panelCount)
        panels = Array(repeating: Array(repeating: SKSpriteNode(), count: panelCount), count: panelCount)
        
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: "gameboardTexture"),
                              size: CGSize(width: CGFloat(panelCount) * panelSize, height: CGFloat(panelCount) * panelSize))
        sprite.anchorPoint = .zero
        sprite.position = CGPoint(x: xPosition, y: yPosition)
        sprite.zPosition = K.ZPosition.gameboard
        sprite.setScale(spriteScale)

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
        panels[position.row][position.col].position = spritePosition
        panels[position.row][position.col].anchorPoint = .zero
        panels[position.row][position.col].zPosition = K.ZPosition.panel
        panels[position.row][position.col].name = "\(position.row),\(position.col)"

        sprite.addChild(panels[position.row][position.col])
        
        if tile.overlay != .boundary {
            let overlayPanel = SKSpriteNode(imageNamed: tile.overlay.description)
            overlayPanel.scale(to: scaleSize)
            overlayPanel.position = spritePosition
            overlayPanel.anchorPoint = .zero
            overlayPanel.zPosition = K.ZPosition.overlay
            overlayPanel.name = "\(position.row),\(position.col)\(overlayTag)"

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
    }
    
    func getLocation(at position: K.GameboardPosition) -> CGPoint {
        return CGPoint(x: panelSize * (CGFloat(position.col) + 0.5), y: panelSize * (CGFloat(panelCount - 1 - position.row) + 0.5))
    }
    
    func colorizeGameboard(color: UIColor, blendFactor: CGFloat, animationDuration: TimeInterval, completion: (() -> ())?) {
        for (row, panelRows) in panels.enumerated() {
            for (col, _) in panelRows.enumerated() {
                panels[row][col].run(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: animationDuration))
            }
        }
        
        if completion == nil {
            sprite.run(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: animationDuration))
            
            for overlayObject in sprite.children {
                overlayObject.run(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: animationDuration))
            }
        }
        else {
            sprite.run(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: animationDuration), completion: completion!)

            for overlayObject in sprite.children {
                overlayObject.run(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: animationDuration), completion: completion!)
            }
        }
    }
    
    func warpTo(from initialPosition: K.GameboardPosition) -> K.GameboardPosition? {
        guard let first = warps.first, let second = warps.second else {
            print("Level has no warps!")
            return nil
        }
        
        return first == initialPosition ? second : first
    }
}
