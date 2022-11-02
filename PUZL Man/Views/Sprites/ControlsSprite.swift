//
//  ControlsSprite.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/2/22.
//

//import SpriteKit
//import UIKit
//
//class ControlsSprite {
//    let offsetPosition = CGPoint(x: 100, y: 200)
//    
//    var sprite: SKSpriteNode
//    var up: SKSpriteNode
//    var down: SKSpriteNode
//    var left: SKSpriteNode
//    var right: SKSpriteNode
//    
//    init() {
//        let size: CGFloat = 125
//        
//        up = SKSpriteNode(color: UIColor(red: 1, green: 0.1, blue: 0.1, alpha: 1), size: CGSize(width: size, height: size))
//        up.position = CGPoint(x: size, y: 2 * size)
//        up.anchorPoint = .zero
//        up.zPosition = K.ZPosition.controls
//        
//        down = SKSpriteNode(color: UIColor(red: 0.1, green: 0.1, blue: 1, alpha: 1), size: CGSize(width: size, height: size))
//        down.position = CGPoint(x: size, y: 0)
//        down.anchorPoint = .zero
//        down.zPosition = K.ZPosition.controls
//        
//        left = SKSpriteNode(color: UIColor(red: 1, green: 1, blue: 0.1, alpha: 1), size: CGSize(width: size, height: size))
//        left.position = CGPoint(x: 0, y: size)
//        left.anchorPoint = .zero
//        left.zPosition = K.ZPosition.controls
//        
//        right = SKSpriteNode(color: UIColor(red: 0.1, green: 1, blue: 0.1, alpha: 1), size: CGSize(width: size, height: size))
//        right.position = CGPoint(x: 2 * size, y: size)
//        right.anchorPoint = .zero
//        right.zPosition = K.ZPosition.controls
//        
//        sprite = SKSpriteNode(color: .clear, size: CGSize(width: 3 * size, height: 4 * size))
//        sprite.position = CGPoint(x: offsetPosition.x, y: offsetPosition.y)
//        sprite.anchorPoint = .zero
//
//        sprite.addChild(up)
//        sprite.addChild(down)
//        sprite.addChild(left)
//        sprite.addChild(right)
//    }
//}
