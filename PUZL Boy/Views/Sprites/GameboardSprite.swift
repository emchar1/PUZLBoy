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
    let spriteScale: CGFloat = 0.94

    var xPosition: CGFloat { (K.iPhoneWidth * (1 - spriteScale)) / 2 }
    var yPosition: CGFloat { (K.height - gameboardSize * spriteScale) / 2 }
    var gameboardSize: CGFloat { CGFloat(panelCount) * panelSize }
    
    var grass: LevelType { tiles[LevelType.grass.rawValue] }
    var ice: LevelType { tiles[LevelType.ice.rawValue] }
    var endOpen: LevelType { tiles[LevelType.endOpen.rawValue] }
    
    private var panels: [[SKSpriteNode]]
    private(set) var panelCount: Int
    private(set) var panelSize: CGFloat
    private(set) var sprite: SKSpriteNode

    
    // MARK: - Initialization
    
    init(level: Level) {
        panelCount = level.gameboard.count
        panelSize = K.iPhoneWidth / CGFloat(panelCount)
        panels = Array(repeating: Array(repeating: SKSpriteNode(), count: panelCount), count: panelCount)
        
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: "gameboardTexture"),
                              size: CGSize(width: CGFloat(panelCount) * panelSize, height: CGFloat(panelCount) * panelSize))
        sprite.anchorPoint = .zero
        sprite.position = CGPoint(x: xPosition, y: yPosition)
        sprite.zPosition = K.ZPosition.gameboard
        sprite.setScale(spriteScale)

        for row in 0..<panelCount {
            for col in 0..<panelCount {
                updatePanels(at: (row: row, col: col), with: tiles[level.gameboard[row][col].rawValue])
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    func updatePanels(at position: K.GameboardPosition, with tile: LevelType) {
        let spacing: CGFloat = 4
        
        panels[position.row][position.col] = SKSpriteNode(imageNamed: tile.description)
        panels[position.row][position.col].scale(to: CGSize(width: panelSize - spacing, height: panelSize - spacing))
        panels[position.row][position.col].position = CGPoint(x: CGFloat(position.col) * panelSize + spacing / 2,
                                                              y: CGFloat(panelCount - 1 - position.row) * panelSize + spacing / 2)
        panels[position.row][position.col].anchorPoint = .zero
        panels[position.row][position.col].zPosition = K.ZPosition.panel
        panels[position.row][position.col].name = "\(position.row),\(position.col)"

        sprite.addChild(panels[position.row][position.col])
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
        }
        else {
            sprite.run(SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: animationDuration), completion: completion!)
        }
    }
}
