//
//  ParallaxManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/14/23.
//

import SpriteKit

class ParallaxManager: SKNode {
    
    // MARK: - Properties
    
    private(set) var set: ParallaxObject.SetType
    private var parallaxSprites: [ParallaxSprite] = []
    private var xOffsetsArray: [ParallaxSprite.SpriteXPositions]?

    var speedFactor: TimeInterval {
        switch DayTheme.currentTheme {
        case .dawn:         return 3
        case .morning:      return 1
        case .afternoon:    return 1.5
        case .night:        return 3
        }
    }
        
    
    // MARK: - Initialization
    
    init(useSet set: ParallaxObject.SetType, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?) {
        self.set = set
        self.xOffsetsArray = xOffsetsArray

        super.init()
                
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        switch set {
        case .grass:
            parallaxSprites = makeSprite(layers: 6, size: CGSize(width: 8192, height: 1550), skyObjectNodes: [2, 4])
        case .marsh:
            parallaxSprites = makeSprite(layers: 5, size: CGSize(width: 8192, height: 1847), skyObjectNodes: [3, 4])
        case .ice:
            parallaxSprites = makeSprite(layers: 5, size: CGSize(width: 8192, height: 1824), skyObjectNodes: [3, 4])
        case .sand:
            parallaxSprites = makeSprite(layers: 5, size: CGSize(width: 8192, height: 1824), skyObjectNodes: [1, 4])
        case .lava:
            parallaxSprites = makeSprite(layers: 4, size: CGSize(width: 8192, height: 1824), skyObjectNodes: [2, 3])
        }
    }
    
    private func makeSprite(layers: Int, size: CGSize, skyObjectNodes: [Int]) -> [ParallaxSprite] {
        var sprites: [ParallaxSprite] = []
        
        for i in 0..<layers {
            var type: ParallaxObject.ObjectType = .ground
            var speed: TimeInterval = max(20, TimeInterval(i) * 100)

            for skyObject in skyObjectNodes {
                if i == skyObject {
                    type = .sky
                    speed = 2000 - TimeInterval(i) * 250
                }
            }
            
            let size: CGSize = size
            let zPosition: CGFloat = K.ZPosition.parallaxLayer0 - 5 * CGFloat(i)
            let object = ParallaxObject(set: set, layer: i, type: type, speed: speed * speedFactor, size: size, zPosition: zPosition)
            let sprite = ParallaxSprite(object: object, xOffsets: xOffsetsArray?[i])
            
            sprites.append(sprite)
        }
        
        return sprites
    }
    
    /**
     Call this method to correctly add all the parallaxSprites children to the parent scene.
     - parameter scene: The parent scene that calls this class
     */
    func addSpritesToParent(scene: SKScene) {
        for sprite in parallaxSprites {
            scene.addChild(sprite)
        }
    }
    
        
    // MARK: - Animate Functions
    
    func animate() {
        for sprite in parallaxSprites {
            sprite.animate()
        }
    }
    
    func pollxOffsetsArray() -> [ParallaxSprite.SpriteXPositions] {
        var offsetsArray: [ParallaxSprite.SpriteXPositions] = []
        
        for sprite in parallaxSprites {
            offsetsArray.append(sprite.pollxOffsets())
        }
        
        xOffsetsArray = offsetsArray
        
        return offsetsArray
    }
}
