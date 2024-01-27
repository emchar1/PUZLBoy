//
//  ParallaxSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/12/23.
//

import SpriteKit

class ParallaxSprite: SKNode {
    
    // MARK: - Properties
    
    typealias SpriteXPositions = (first: CGFloat, second: CGFloat)

    private(set) var parallaxObject: ParallaxObject
    private var sprites: [SKSpriteNode] = []
    private var xOffsets: SpriteXPositions?
    
    
    // MARK: - Initialization
    
    init(object: ParallaxObject, xOffsets: SpriteXPositions?) {
        self.parallaxObject = object
        self.xOffsets = xOffsets
        
        super.init()

        setupSprites()
        
        // IMPORTANT!! Put node name here, not in individual sprites so LaunchScene can iterate through node names correctly
        name = parallaxObject.nodeName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        for i in 0...1 {
            let sprite = SKSpriteNode(imageNamed: parallaxObject.imageName)
            sprite.anchorPoint = .zero

            if let xOffsets = xOffsets {
                sprite.position = CGPoint(x: i == 0 ? xOffsets.first : xOffsets.second, y: 0)
            }
            else {
                sprite.position = CGPoint(x: CGFloat(i) * parallaxObject.sizeScaled, y: 0)
            }
                
            if UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) {
                sprite.color = DayTheme.spriteColor
                sprite.colorBlendFactor = DayTheme.spriteShade
            }

            sprite.setScale(parallaxObject.scale * 3)
            sprite.zPosition = parallaxObject.zPosition
                        
            addChild(sprite)

            sprites.append(sprite)
        }
    }
    
    
    // MARK: - Functions
    
    func animate() {
        let moveAction = SKAction.moveBy(x: -parallaxObject.sizeScaled, y: 0, duration: parallaxObject.speed)
        let resetAction = SKAction.moveTo(x: parallaxObject.sizeScaled, duration: 0)
        
        sprites[0].run(SKAction.repeatForever(SKAction.sequence([moveAction, resetAction, moveAction])))
        sprites[1].run(SKAction.repeatForever(SKAction.sequence([moveAction, moveAction, resetAction])))
    }
    
    func stopAnimation(excludeSkyObjects: Bool) {
        //I know this looks confusing, but basically if excludeSkyObjects == true, allow clouds to keep animating. Otherwise stop everything.
        guard !(excludeSkyObjects && name == LaunchScene.nodeName_skyObjectNode) else { return }

        sprites[0].removeAllActions()
        sprites[1].removeAllActions()
    }
    
    func pollxOffsets() -> SpriteXPositions {
        let offsets: SpriteXPositions = (sprites[0].position.x, sprites[1].position.x)
        
        xOffsets = offsets
        
        return offsets
    }
    
    func setxPositions(xOffsets: SpriteXPositions) {
        sprites[0].position.x = xOffsets.first
        sprites[1].position.x = xOffsets.second
    }
}
