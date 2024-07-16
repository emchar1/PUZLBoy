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
    private var animateForCutscene: Bool

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
    
    init(useSet set: ParallaxObject.SetType, xOffsetsArray: [ParallaxSprite.SpriteXPositions]?, forceSpeed: Speed? = nil, animateForCutscene: Bool) {
        self.set = set
        self.xOffsetsArray = xOffsetsArray
        self.forceSpeed = forceSpeed
        self.animateForCutscene = animateForCutscene

        super.init()
        
        if animateForCutscene {
            self.set = .grass
        }
                
        backgroundSprite = SKSpriteNode(color: .clear, size: K.ScreenDimensions.size)
        backgroundSprite.name = LaunchScene.nodeName_backgroundNode

        changeSet(set: self.set)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeSet(set: ParallaxObject.SetType) {
        self.set = set
        
        switch set {
        case .grass:
            parallaxSprites = makeSprite(layers: 6, size: CGSize(width: 8192, height: 1550), skyObjectNodes: [2, 4])
        case .marsh:
            parallaxSprites = makeSprite(layers: 5, size: CGSize(width: 8192, height: 1823), skyObjectNodes: [3, 4])
        case .ice:
            parallaxSprites = makeSprite(layers: 5, size: CGSize(width: 8192, height: 1824), skyObjectNodes: [3, 4])
        case .sand:
            parallaxSprites = makeSprite(layers: 5, size: CGSize(width: 8192, height: 1824), skyObjectNodes: [1, 4])
        case .lava:
            parallaxSprites = makeSprite(layers: 4, size: CGSize(width: 8192, height: 1824), skyObjectNodes: [2, 3])
        case .planet:
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
            let sprite = ParallaxSprite(object: object, xOffsets: xOffsetsArray?[i], animateForCutscene: animateForCutscene)
            
            sprites.append(sprite)
        }
        
        return sprites
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds the parallaxSprites to the backgroundSprite, then to the parentNode or scene (if parentNode is nil).
     - parameters:
        - scene: The parent scene that calls this class
        - node: optional parent node to set the backgroundSprite to. If not nil, use this, otherwise set it to the scene.
     */
    func addSpritesToParent(scene: SKScene, node parentNode: SKNode? = nil) {
        //Prevents app crashing if backgroundSprite was previously added to a parentNode or scene.
        backgroundSprite.removeFromParent()
        backgroundSprite.removeAllActions()
        backgroundSprite.removeAllChildren()
        
        //Adds the individual sprite scene components
        for sprite in parallaxSprites {
            backgroundSprite.addChild(sprite)
        }
        
        //Adds the backgroundSprite to the parentNode or scene, if parentNode is nil.
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
    
    func addSplitGroundSprite(animationDuration: TimeInterval = 0.25, completion: @escaping () -> Void) {
        guard let grassLayer1 = getSpriteFor(set: ParallaxObject.SetType.grass.rawValue, layer: 1) else {
            completion()
            return
        }

        grassLayer1.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: animationDuration),
            SKAction.removeFromParent()
        ]))

        for i in 0...3 {
            let size = CGSize(width: 1840, height: 1550)
            let zPosition: CGFloat = K.ZPosition.parallaxLayer0 - 5 * CGFloat(1) + CGFloat(i)
            let object = ParallaxObject(set: .grass, layer: 10 + i, type: .ground, speed: 0, size: size, zPosition: zPosition)
            let sprite = ParallaxSprite(object: object, xOffsets: nil, animateForCutscene: true)

            sprite.alpha = 0
            
            if i < 3 {
                sprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: TimeInterval(i) * animationDuration),
                    SKAction.fadeIn(withDuration: 0),
                    SKAction.wait(forDuration: animationDuration),
                    SKAction.fadeOut(withDuration: animationDuration),
                    SKAction.removeFromParent()
                ]))
            }
            else {
                sprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: TimeInterval(i) * animationDuration),
                    SKAction.fadeIn(withDuration: 0)
                ]), completion: completion)
            }
            
            backgroundSprite.addChild(sprite)
        }
    }
    
    func getSpriteFor(set: Int, layer: Int) -> SKNode? {
        let spriteTag = ParallaxSprite.getSetAndLayer(set: set, layer: layer)
        
        return backgroundSprite.childNode(withName: LaunchScene.nodeName_groundObjectNode + spriteTag)
    }
    
    //BUGFIX# 240125E01 - Reset sprite xPositions so tree doesn't get in the way when dragon is flying across, for example.
    ///Resets the requested sprite's' xPositions to the leftmost side.
    func resetxPositions(index: Int) {
        guard index < parallaxSprites.count else { return }
        
        let xOffsetsReset: ParallaxSprite.SpriteXPositions = (0, parallaxSprites[index].parallaxObject.sizeScaled)

        parallaxSprites[index].setxPositions(xOffsets: xOffsetsReset)
    }
}
