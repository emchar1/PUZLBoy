//
//  GameboardSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 9/28/22.
//

import SpriteKit

class GameboardSprite {
    
    // MARK: - Properties
    
    let tiles: [String] = ["start", "endClosed", "endOpen", "gem", "gemOnIce", "grass", "marsh", "ice", "hammer", "sword", "boulder", "enemy", "warp"]
    let spriteScale: CGFloat = 0.94

    var xPosition: CGFloat { (K.iPhoneWidth * (1 - spriteScale)) / 2 }
    var yPosition: CGFloat { (K.height - gameboardSize * spriteScale) / 2 }
    var gameboardSize: CGFloat { CGFloat(panelCount) * panelSize }
    var grass: String { tiles[5] }
    var ice: String { tiles[7] }
    var endOpen: String { tiles[2] }
    
    var panels: [[SKSpriteNode]]
    var panelCount: Int
    var panelSize: CGFloat
    var sprite: SKSpriteNode

    
    // MARK: - Initialization
    
    init(level: Level) {
        panelCount = level.gameboard.count
        panelSize = K.iPhoneWidth / CGFloat(panelCount)
        panels = Array(repeating: Array(repeating: SKSpriteNode(), count: panelCount), count: panelCount)
        
        sprite = SKSpriteNode(color: .white, size: CGSize(width: CGFloat(panelCount) * panelSize, height: CGFloat(panelCount) * panelSize))
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
    
    func updatePanels(at position: K.GameboardPosition, with tile: String) {
        let spacing: CGFloat = 4
        
        panels[position.row][position.col] = SKSpriteNode(imageNamed: tile)
        panels[position.row][position.col].scale(to: CGSize(width: panelSize - spacing, height: panelSize - spacing))
        panels[position.row][position.col].position = CGPoint(x: CGFloat(position.col) * panelSize + spacing / 2,
                                                              y: CGFloat(panelCount - 1 - position.row) * panelSize + spacing / 2)
        panels[position.row][position.col].anchorPoint = .zero
        panels[position.row][position.col].zPosition = K.ZPosition.panel
        panels[position.row][position.col].name = "\(position.row),\(position.col)"

        sprite.addChild(panels[position.row][position.col])
    }
}
