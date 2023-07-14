//
//  ActivityIndicatorSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/3/23.
//

import SpriteKit

class ActivityIndicatorSprite: SKNode {
    
    // MARK: - Properties
    
    private(set) var isShowing = false
    private(set) var sprite: SKShapeNode!
    private var player: Player!
    private var label: SKLabelNode!
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.activityIndicator
        
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ActivityIndicatorSprite deinit")
    }
    
    private func setupSprites() {
        sprite = SKShapeNode(rectOf: CGSize(width: 350, height: 350), cornerRadius: 40)
        sprite.fillColor = .black
        sprite.lineWidth = 0
        sprite.alpha = 0.9
                
        player = Player()
        player.sprite.setScale(0.25)
        player.sprite.position = CGPoint(x: 0, y: 30)

        label = SKLabelNode(text: "PLEASE WAIT...")
        label.fontName = UIFont.gameFont
        label.fontColor = UIFont.gameFontColor
        label.fontSize = UIFont.gameFontSizeSmall
        label.position = CGPoint(x: -label.frame.width / 2, y: -125)
        label.horizontalAlignmentMode = .left
        
        addChild(sprite)
        sprite.addChild(player.sprite)
        sprite.addChild(label)
    }
    
    
    // MARK: - Functions
    
    private func animateSprites() {
        let animation = SKAction.animate(with: player.textures[Player.Texture.run.rawValue], timePerFrame: 0.02)
        player.sprite.run(SKAction.repeatForever(animation), withKey: "animatePlayer")
        
        let animateLabel: [SKAction] = [
            SKAction.run { [unowned self] in label.text = "PLEASE WAIT..." },
            SKAction.run { [unowned self] in label.text = "PLEASE WAIT" },
            SKAction.run { [unowned self] in label.text = "PLEASE WAIT." },
            SKAction.run { [unowned self] in label.text = "PLEASE WAIT.." }
        ]
        let wait = SKAction.wait(forDuration: 0.5)
        let sequence = SKAction.sequence([animateLabel[0], wait, wait, animateLabel[1], wait, animateLabel[2], wait, animateLabel[3], wait])

        label.run(SKAction.repeatForever(sequence), withKey: "animateLabel")
    }
    
    private func deAnimateSprites() {
        player.sprite.removeAction(forKey: "animatePlayer")
        label.removeAction(forKey: "animateLabel")
    }
    
    override func move(toParent parent: SKNode) {
        super.move(toParent: parent)
        
        isShowing = true
        animateSprites()
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        
        isShowing = false
        deAnimateSprites()
    }
}
