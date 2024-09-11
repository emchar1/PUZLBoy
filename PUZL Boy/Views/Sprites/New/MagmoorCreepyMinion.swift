//
//  MagmoorCreepyMinion.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/5/24.
//

import SpriteKit

class MagmoorCreepyMinion: SKNode {
    
    // MARK: - Properties
    
    ///Max length (or width) of the creepy .png image
    private let creepyLengthMax: CGFloat = 1679
    private var scale: CGFloat
    private var gameboardScaleSize: CGSize
    private var spawnPoint: CGPoint
    
    private var leftHand: SKSpriteNode!
    private var leftArm: SKSpriteNode!
    private var rightHand: SKSpriteNode!
    private var rightArm: SKSpriteNode!
    private var face1: SKSpriteNode!
    private var face2: SKSpriteNode!
    private var face3: SKSpriteNode!
    private var body1: SKSpriteNode!
    private var body2: SKSpriteNode!
    private var body3: SKSpriteNode!
    private var body4: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    init(scale: CGFloat = 3.5, gameboardScaleSize: CGSize, spawnPoint: CGPoint) {
        self.scale = scale
        self.gameboardScaleSize = gameboardScaleSize
        self.spawnPoint = spawnPoint
        
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit MagmoorCreepyMinion")
    }
    
    private func setupNodes() {
        leftHand = setupCreepy("LeftHand", creepySize: 1116, positionMultiplierOffset: CGPoint(x: -0.8, y: 1), zOffset: 110)
        leftHand.anchorPoint = CGPoint(x: 0.95, y: 0.95)
        
        leftArm = setupCreepy("LeftArm", creepySize: 812, positionMultiplierOffset: CGPoint(x: -1.1, y: 0.4), zOffset: 109)
        rightHand = setupCreepy("RightHand", creepySize: 1291, positionMultiplierOffset: CGPoint(x: -0.1, y: -1.5), zOffset: 108)
        rightArm = setupCreepy("RightArm", creepySize: 569, positionMultiplierOffset: CGPoint(x: 0.4, y: -1), zOffset: 107)
        face1 = setupCreepy("Face1", creepySize: 1278, positionMultiplierOffset: CGPoint(x: -1.2, y: -1.2), zOffset: 106)
        face2 = setupCreepy("Face2", zOffset: 105)
        face3 = setupCreepy("Face3", zOffset: 104)
        body1 = setupCreepy("Body1", zOffset: 103)
        body2 = setupCreepy("Body2", zOffset: 102)
        body3 = setupCreepy("Body3", zOffset: 101)
        body4 = setupCreepy("Body4", zOffset: 100)
    }
    
    private func setupCreepy(_ suffix: String, creepySize: CGFloat? = nil, positionMultiplierOffset: CGPoint? = nil, zOffset: CGFloat) -> SKSpriteNode {
        let magmoorCreepy = "MagmoorCreepy"
        
        let node = SKSpriteNode(imageNamed: magmoorCreepy + suffix)
        node.scale(to: scale * gameboardScaleSize * (creepySize ?? creepyLengthMax) / creepyLengthMax)
        node.position = getPosition(positionMultiplierOffset: positionMultiplierOffset)
        node.alpha = 0
        node.zPosition = K.ZPosition.overlay + zOffset
        node.name = magmoorCreepy + suffix
        
        return node
    }
    
    /**
     Gets the position of the spawned items in relation to the gameboard panel from where the spawn point originates.
     - parameters:
        - positionMultiplierOffset: explicit offset from the original spawn point
        - onSpawnPoint: so the actual spawn point occurs at (-1, 1) from the origin spawn point, but onSpawnPoint makes this offset (0, 0).
     - returns: the point of spawning
     */
    private func getPosition(positionMultiplierOffset: CGPoint? = nil, onSpawnPoint: Bool = false) -> CGPoint {
        let gameboardPosition: CGPoint = CGPoint(x: gameboardScaleSize.width, y: gameboardScaleSize.height)
        let scaleOffset: CGFloat = onSpawnPoint ? 0 : -2
        
        //This formula was funky to figure out. The "(scale + scaleOffset) / 2" and later, "scale / 3" seemed arbitrary, but they work (for scale = 3.5)!
        return spawnPoint + gameboardPosition * (scale + scaleOffset) / 2 + (positionMultiplierOffset ?? .zero) * gameboardPosition * scale / 3 + GameboardSprite.padding / 2
    }
    
    
    // MARK: - Functions
    
    func addToParent(_ parentNode: SKNode) {
        addChild(leftHand)
        addChild(leftArm)
        addChild(rightHand)
        addChild(rightArm)
        addChild(face1)
        addChild(face2)
        addChild(face3)
        addChild(body1)
        addChild(body2)
        addChild(body3)
        addChild(body4)
        
        parentNode.addChild(self)
    }
    
    /**
     Magmoor's minion peeks its head from a tile, with optional delay.
     - parameters:
        - delay: delay before peeking
        - duration: time before retreating again
        - completion: completion handler
     */
    func peekAnimation(delay: TimeInterval? = nil, duration: TimeInterval, completion: @escaping () -> Void) {
        face3.position = getPosition(positionMultiplierOffset: nil, onSpawnPoint: true)
        
        face3.run(SKAction.sequence([
            SKAction.wait(forDuration: delay ?? 0),
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: duration),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]), completion: completion)
        
        AudioManager.shared.playSoundThenStop(for: "littlegirllaugh",
                                              currentTime: TimeInterval.random(in: 0...8),
                                              playForDuration: duration, fadeOut: 1, delay: delay ?? 0)
    }
    
    /**
     Animates the minion, in all it's creepy glory.
     - parameter delay: time delay before the animation begins.
     */
    func beginAnimation(delay: TimeInterval) {
        //Appear animation
        animateAppearNode(node: leftHand, delay: delay + 0.5)
        animateAppearNode(node: leftArm, delay: delay + 0.5)
        animateAppearNode(node: rightHand, delay: delay + 0.3)
        animateAppearNode(node: rightArm, delay: delay + 0.3)
        animateAppearNode(node: face1, delay: delay + 0.4)
        animateAppearNode(node: face2, delay: delay + 0.3)
        animateAppearNode(node: face3, delay: delay)
        animateAppearNode(node: body1, delay: delay + 0.3)
        animateAppearNode(node: body2, delay: delay + 0.2)
        animateAppearNode(node: body3, delay: delay + 0.1)
        animateAppearNode(node: body4, delay: delay)

        //Jitter
        var randomTimeFace: TimeInterval { TimeInterval.random(in: 0...3) }
        var randomTimeHand: TimeInterval { TimeInterval.random(in: 0...1) }
        let jitterAction: SKAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle: -.pi / 64, duration: 0.05),
            SKAction.rotate(byAngle: .pi / 64, duration: 0.05)
        ]))
        
        leftHand.run(jitterAction)
        leftArm.run(jitterAction)
        rightHand.run(jitterAction)
        rightArm.run(jitterAction)
        face1.run(jitterAction)
        body1.run(jitterAction)

        //Move face
        face1.run(SKAction.sequence([
            SKAction.wait(forDuration: delay + 0.4),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.rotate(toAngle: -.pi / 2, duration: 0.25),
                SKAction.wait(forDuration: randomTimeFace),
                SKAction.rotate(byAngle: .pi / 8, duration: 0.25),
                SKAction.wait(forDuration: randomTimeFace),
                SKAction.rotate(byAngle: .pi / 6, duration: 0.25),
                SKAction.wait(forDuration: randomTimeFace),
                SKAction.rotate(byAngle: .pi / 8, duration: 0.25),
                SKAction.wait(forDuration: randomTimeFace),
                SKAction.rotate(byAngle: .pi / 6, duration: 0.25),
                SKAction.wait(forDuration: randomTimeFace)
            ]))
        ]))
        
        //Rake hand
        leftHand.run(SKAction.sequence([
            SKAction.wait(forDuration: delay + 0.5),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.rotate(byAngle: -.pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand),
                SKAction.rotate(byAngle: -.pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand),
                SKAction.rotate(byAngle: -.pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand),
                SKAction.rotate(byAngle: -.pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand),
                SKAction.rotate(byAngle: .pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand),
                SKAction.rotate(byAngle: .pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand),
                SKAction.rotate(byAngle: .pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand),
                SKAction.rotate(byAngle: .pi / 10, duration: 0),
                SKAction.wait(forDuration: randomTimeHand)
            ]))
        ]))
    }
    
    /**
     Executes the reverse of beginAnimation(), i.e. the creepy minion retreats to the underworld.
     - parameter: delay: time delay before the hiding animation occurs.
     */
    func endAnimation(delay: TimeInterval) {
        let moveLeftArmHand: SKAction = SKAction.sequence([
            SKAction.wait(forDuration: delay + 0.1),
            SKAction.moveBy(x: 0, y: -40, duration: 0),
            SKAction.wait(forDuration: 0.1),
            SKAction.moveBy(x: 0, y: -40, duration: 0)
        ])
        
        leftArm.run(moveLeftArmHand)
        leftHand.run(moveLeftArmHand)
        
        animateRemoveNode(node: leftHand, delay: delay + 0.3)
        animateRemoveNode(node: leftArm, delay: delay + 0.3)
        animateRemoveNode(node: rightHand, delay: delay + 0.1)
        animateRemoveNode(node: rightArm, delay: delay + 0.1)
        animateRemoveNode(node: face1, delay: delay + 0.3)
        animateRemoveNode(node: face2, delay: delay + 0.4)
        animateRemoveNode(node: face3, delay: delay + 3.0, fadeOut: 0.25)
        animateRemoveNode(node: body1, delay: delay + 0.1)
        animateRemoveNode(node: body2, delay: delay + 0.2)
        animateRemoveNode(node: body3, delay: delay + 0.3)
        animateRemoveNode(node: body4, delay: delay + 0.4)
    }
    
    /**
     Helper function to facilitate with showing the minion nodes.
     */
    private func animateAppearNode(node: SKNode, delay: TimeInterval) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.fadeIn(withDuration: 0)
        ]))
    }
    
    /**
     Helper function to facilitate with hiding the minion nodes.
     */
    private func animateRemoveNode(node: SKNode, delay: TimeInterval, fadeOut: TimeInterval? = nil) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.fadeOut(withDuration: fadeOut ?? 0),
            SKAction.removeFromParent()
        ]))
    }
    
    
}
