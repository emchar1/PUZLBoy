//
//  GameboardSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 9/28/22.
//

import SpriteKit

class GameboardSprite {
    
    // MARK: - Properties
    
    //FIXME: - Temporary
    let colors: [UIColor] = [
        UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), //start
        UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),       //endClosed
        UIColor(red: 10/255, green: 10/255, blue: 150/255, alpha: 1),    //endOpen
        UIColor(red: 200/255, green: 20/255, blue: 160/255, alpha: 1),  //gemOn
        UIColor(red: 20/255, green: 200/255, blue: 40/255, alpha: 1),   //gemOff
        UIColor(red: 20/255, green: 200/255, blue: 40/255, alpha: 1),   //grass
        UIColor(red: 40/255, green: 100/255, blue: 80/255, alpha: 1),   //marsh
        UIColor(red: 180/255, green: 240/255, blue: 250/255, alpha: 1), //ice
        UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1), //hammer
        UIColor(red: 200/255, green: 180/255, blue: 250/255, alpha: 1), //sword
        UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), //boulder
        UIColor(red: 250/255, green: 5/255, blue: 25/255, alpha: 1),    //enemy
        UIColor(red: 240/255, green: 250/255, blue: 80/255, alpha: 1),  //warp
    ]
    
    let spriteScale: CGFloat = 0.94
    var gemOff: UIColor { colors[4] }
    var endOpen: UIColor { colors[2] }
    var panels: [[SKSpriteNode]]
    var panelCount: Int
    var panelSize: CGFloat
    var gameboardSize: CGFloat { CGFloat(panelCount) * panelSize }
    var sprite: SKSpriteNode
//    var gemCount: Int = 0

    
    // MARK: - Initialization
    
    init(level: Level) {
        panelCount = level.gameboard.count
        panelSize = K.iPhoneWidth / CGFloat(panelCount)
        panels = Array(repeating: Array(repeating: SKSpriteNode(), count: panelCount), count: panelCount)
        
        sprite = SKSpriteNode(color: .clear, size: CGSize(width: CGFloat(panelCount) * panelSize, height: CGFloat(panelCount) * panelSize))
        sprite.anchorPoint = .zero
        sprite.position = CGPoint(x: K.iPhoneWidth * (1 - spriteScale) / 2, y: K.height - (gameboardSize + K.topMargin + 100))
        sprite.setScale(spriteScale)

        for row in 0..<panelCount {
            for col in 0..<panelCount {
                updatePanels(at: (row: row, col: col), with: colors[level.gameboard[row][col].rawValue])
                
                //FIXME: - Eventually will replace this with SKSpriteNode of the texture image, not the color
//                panels[row][col] = SKSpriteNode(color: colors[level.gameboard[row][col].rawValue + 2], size: CGSize(width: panelSize, height: panelSize))
//                panels[row][col].position = CGPoint(x: CGFloat(col) * panelSize, y: CGFloat(panelCount - 1 - row) * panelSize)
//                panels[row][col].anchorPoint = .zero
//                panels[row][col].zPosition = K.ZPosition.gameboard
//
//                //Assign a name if the panel is a gem. This will make it easier to remove when landed on.
//                panels[row][col].name = "\(row),\(col)"
//                if level.gameboard[row][col] == .gemOn {
//                    gemCount += 1
//                }
                
//                sprite.addChild(panels[row][col])
            }
        }
    }
    
    
    // MARK: - Functions
    
    func updatePanels(at position: K.GameboardPosition, with color: UIColor) {
        panels[position.row][position.col] = SKSpriteNode(color: color, size: CGSize(width: panelSize, height: panelSize))
        panels[position.row][position.col].position = CGPoint(x: CGFloat(position.col) * panelSize, y: CGFloat(panelCount - 1 - position.row) * panelSize)
        panels[position.row][position.col].anchorPoint = .zero
        panels[position.row][position.col].zPosition = K.ZPosition.gameboard
        panels[position.row][position.col].name = "\(position.row),\(position.col)"

        sprite.addChild(panels[position.row][position.col])
    }
}

