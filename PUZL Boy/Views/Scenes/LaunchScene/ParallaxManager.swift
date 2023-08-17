//
//  ParallaxManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/14/23.
//

import SpriteKit

class ParallaxManager: SKNode {
    
    // MARK: - Properties
    
    private(set) var backgroundSprite: SKSpriteNode!
    private(set) var set: ParallaxObject.SetType
    private var parallaxSprites: [ParallaxSprite] = []
    private var xOffsetsArray: [ParallaxSprite.SpriteXPositions]?
    private var shouldWalk: Bool

    var speedFactor: TimeInterval {
        let walk: TimeInterval = 3
        let run: TimeInterval = 1
        let slowRun: TimeInterval = 1.5

        if !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) {
            if shouldWalk {
                return walk
            }
            
            return run
        }
                
        switch DayTheme.currentTheme {
        case .dawn:         return walk
        case .morning:      return run
        case .afternoon:    return slowRun
        case .night:        return walk
        }
    }
        
    
    // MARK: - Initialization
    
    init(useSet set: ParallaxObject.SetType, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?, shouldWalk: Bool = false) {
        self.set = set
        self.xOffsetsArray = xOffsetsArray
        self.shouldWalk = shouldWalk

        super.init()
        
        if !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) {
            self.set = .grass
        }
                
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        backgroundSprite = SKSpriteNode(color: .clear, size: K.ScreenDimensions.screenSize)
        
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
            backgroundSprite.addChild(sprite)
        }
        
        scene.addChild(backgroundSprite)
    }
    
        
    // MARK: - Animate Functions
    
    func animate() {
        for sprite in parallaxSprites {
            sprite.animate()
        }
    }
    
    func stopAnimation() {
        for sprite in parallaxSprites {
            sprite.stopAnimation(excludeSkyObjects: true)
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
