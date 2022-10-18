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
        UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),       //end
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
    
    var panelSize: CGFloat
    var sprite: SKSpriteNode
    
    
    // MARK: - Initialization
    
    init(level: Level) {
        let size = level.gameboard.count
        let spriteScale: CGFloat = 0.94
        var panels: [[SKSpriteNode]] = Array(repeating: Array(repeating: SKSpriteNode(), count: size), count: size)
        
        panelSize = K.iPhoneWidth / CGFloat(size)
        sprite = SKSpriteNode(color: .clear, size: CGSize(width: panelSize * CGFloat(size), height: panelSize * CGFloat(size)))
        sprite.anchorPoint = .zero
        sprite.position = CGPoint(x: K.iPhoneWidth * (1 - spriteScale) / 2, y: K.height - (panelSize * CGFloat(size) + K.topMargin + 100))
        sprite.setScale(spriteScale)

        for row in 0..<size {
            for col in 0..<size {
                //FIXME: - Eventually will replace this with SKSpriteNode of the texture image, not the color
                panels[row][col] = SKSpriteNode(color: colors[level.gameboard[row][col].rawValue + 2], size: CGSize(width: panelSize, height: panelSize))
                panels[row][col].position = CGPoint(x: CGFloat(col) * panelSize, y: CGFloat((size - 1) - row) * panelSize)
                panels[row][col].anchorPoint = .zero
                panels[row][col].zPosition = K.ZPosition.gameboard
                
                sprite.addChild(panels[row][col])
            }
        }
        
    }
}

