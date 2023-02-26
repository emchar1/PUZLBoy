//
//  ActivityIndicatorSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/3/23.
//

import SpriteKit

class ActivityIndicatorSprite: SKNode {
    
    // MARK: - Properties
    
    private(set) var sprite: SKShapeNode
    private(set) var isShowing = false
    
    
    // MARK: - Initialization
    
    override init() {
        sprite = SKShapeNode(rectOf: CGSize(width: 350, height: 350), cornerRadius: 40)
        sprite.fillColor = .black
        sprite.lineWidth = 0
        sprite.alpha = 0.9
                
        super.init()
        
        let player = Player()
        let animation = SKAction.animate(with: player.textures[Player.Texture.run.rawValue], timePerFrame: 0.02)
        player.sprite.run(SKAction.repeatForever(animation))
        player.sprite.setScale(0.25)
        player.sprite.position = CGPoint(x: 0, y: 30)
        
        let label = SKLabelNode(text: "Please wait...")
        label.fontName = UIFont.gameFont
        label.fontColor = UIFont.gameFontColor
        label.fontSize = UIFont.gameFontSizeSmall
        label.position = CGPoint(x: -label.frame.width / 2, y: -125)
        label.horizontalAlignmentMode = .left
        
        let animateLabel: [SKAction] = [
            SKAction.run { label.text = "Please wait..." },
            SKAction.run { label.text = "Please wait" },
            SKAction.run { label.text = "Please wait." },
            SKAction.run { label.text = "Please wait.." }
        ]
        let wait = SKAction.wait(forDuration: 0.5)
        let sequence = SKAction.sequence([animateLabel[0], wait, wait, animateLabel[1], wait, animateLabel[2], wait, animateLabel[3], wait])

        label.run(SKAction.repeatForever(sequence))
        
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.activityIndicator
        
        addChild(sprite)
        sprite.addChild(player.sprite)
        sprite.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    override func move(toParent parent: SKNode) {
        super.move(toParent: parent)
        
        isShowing = true
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        
        isShowing = false
    }
}
