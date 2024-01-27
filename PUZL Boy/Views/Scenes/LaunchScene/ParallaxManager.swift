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
    private var forceSpeed: Speed?

    var speedFactor: TimeInterval {
        if let forceSpeed = forceSpeed {
            return forceSpeed.rawValue
        }
                
        switch DayTheme.currentTheme {
        case .dawn:         return Speed.walk.rawValue
        case .morning:      return Speed.run.rawValue
        case .afternoon:    return Speed.slowRun.rawValue
        case .night:        return Speed.walk.rawValue
        }
    }
    
    enum Speed: TimeInterval {
        case walk = 3, run = 1, slowRun = 1.5
    }
        
    
    // MARK: - Initialization
    
    init(useSet set: ParallaxObject.SetType, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?, forceSpeed: Speed? = nil) {
        self.set = set
        self.xOffsetsArray = xOffsetsArray
        self.forceSpeed = forceSpeed

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
        backgroundSprite = SKSpriteNode(color: .clear, size: K.ScreenDimensions.size)
        backgroundSprite.name = LaunchScene.nodeName_backgroundNode
        
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
     - parameters:
        - scene: The parent scene that calls this class
        - node: optional parent node to set the backgroundSprite to. If not nil, use this, otherwise set it to the scene.
     */
    func addSpritesToParent(scene: SKScene, node parentNode: SKNode? = nil) {
        for sprite in parallaxSprites {
            backgroundSprite.addChild(sprite)
        }
        
        if let parentNode = parentNode {
            parentNode.addChild(backgroundSprite)
        }
        else {
            scene.addChild(backgroundSprite)
        }
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
    
    
    // MARK: - xPositions Functions
    
    func pollxOffsetsArray() -> [ParallaxSprite.SpriteXPositions] {
        var offsetsArray: [ParallaxSprite.SpriteXPositions] = []
        
        for sprite in parallaxSprites {
            offsetsArray.append(sprite.pollxOffsets())
        }
        
        xOffsetsArray = offsetsArray
        
        return offsetsArray
    }
    
    func setxPositions(xOffsetsArray: [ParallaxSprite.SpriteXPositions]) {
        for (i, sprite) in parallaxSprites.enumerated() {
            sprite.setxPositions(xOffsets: xOffsetsArray[i])
        }
    }
    
    // BUGFIX# 240125E01 - Reset sprite xPositions so tree doesn't get in the way when dragon is flying across, for example.
    ///Resets the requested sprite's' xPositions to the leftmost side.
    func resetxPositions(index: Int) {
        guard index < parallaxSprites.count else { return }
        
        let xOffsetsReset: ParallaxSprite.SpriteXPositions = (0, parallaxSprites[index].parallaxObject.sizeScaled)

        parallaxSprites[index].setxPositions(xOffsets: xOffsetsReset)
    }
}
