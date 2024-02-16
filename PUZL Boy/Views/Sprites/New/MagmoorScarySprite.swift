//
//  MagmoorScarySprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/23/24.
//

import SpriteKit

class MagmoorScarySprite: SKNode {
    
    // MARK: - Properties
    
    private var boundingBox: CGRect
    private var sprite: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    init(boundingBox: CGRect?) {
        self.boundingBox = boundingBox ?? .zero
        
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit MagmoorScarySprite")
    }
    
    private func setupNodes() {
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: "villainRedEyes"))
        sprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: boundingBox.origin.y + boundingBox.size.height + 6)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.scale(to: CGSize(width: K.ScreenDimensions.size.width, height: K.ScreenDimensions.size.width))
        sprite.alpha = 0

        addChild(sprite)
    }
    
    
    // MARK: - Functions
    
    func resetAlpha() {
        sprite.alpha = 0
    }
    
    func slowReveal(alpha: CGFloat) {
        sprite.texture = SKTexture(imageNamed: "villainRedEyes")
        sprite.run(SKAction.fadeAlpha(to: alpha, duration: 1))
    }
    
    func flashImage(delay: TimeInterval = 0) {
        AudioManager.shared.playSound(for: "magichorrorimpact")

        sprite.texture = SKTexture(imageNamed: "villainRedEyesFlash")
        sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeOut(withDuration: 0)
        ]))
    }
}
