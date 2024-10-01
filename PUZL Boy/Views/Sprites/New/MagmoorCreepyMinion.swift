//
//  MagmoorCreepyMinion.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/5/24.
//

import SpriteKit

class MagmoorCreepyMinion: SKNode {
    
    // MARK: - Properties
    
    static let creepyName = "MagmoorCreepy"
    
    ///Max length (or width) of the creepy .png image
    private let maxLength: CGFloat = 1679
    private var scale: CGFloat
    private var gameboardScaleSize: CGSize
    private var spawnPoint: CGPoint

    private var braveryBar: StatusBarSprite!
    private var braveryCounter: Counter!
    private var punchCounter: Counter!
    private var isDisabled = true
    private var isAnimating = false
    private var braveryReachedZero = false
    
    private var parentNode: SKNode?
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
        //Setup Bravery
        let braveryBarSpacing: CGFloat = 10
        let braveryBarHeight: CGFloat = 44
        
        punchCounter = Counter(maxCount: 2)
        braveryCounter = Counter(maxCount: 1, step: 0.01, shouldLoop: false)
        braveryCounter.setCount(to: 0.5)

        braveryBar = StatusBarSprite(label: "Bravery", shouldHide: true, percentage: braveryCounter.getCount(),
                                     position: CGPoint(x: 5/6 * K.ScreenDimensions.size.width - braveryBarSpacing,
                                                       y: K.ScreenDimensions.size.width - 2 * braveryBarHeight - braveryBarSpacing),
                                     size: CGSize(width: 1/3 * K.ScreenDimensions.size.width, height: braveryBarHeight))
        braveryBar.zPosition = K.ZPosition.overlay + 120
        
        //Setup actual nodes
        leftHand = setupCreepy("LeftHand", size: 1116, offsetMultiplier: CGPoint(x: -0.8, y: 1), zOffset: 110)
        leftHand.anchorPoint = CGPoint(x: 0.95, y: 0.95)
                               
        leftArm = setupCreepy("LeftArm", size: 812, offsetMultiplier: CGPoint(x: -1.1, y: 0.4), zOffset: 109)
        rightHand = setupCreepy("RightHand", size: 1291, offsetMultiplier: CGPoint(x: -0.1, y: -1.5), zOffset: 108)
        rightArm = setupCreepy("RightArm", size: 569, offsetMultiplier: CGPoint(x: 0.4, y: -1), zOffset: 107)
        face1 = setupCreepy("Face1", size: 1278, offsetMultiplier: CGPoint(x: -1.2, y: -1.2), zOffset: 106)
        face2 = setupCreepy("Face2", zOffset: 105)
        face3 = setupCreepy("Face3", zOffset: 104)
        body1 = setupCreepy("Body1", zOffset: 103)
        body2 = setupCreepy("Body2", zOffset: 102)
        body3 = setupCreepy("Body3", zOffset: 101)
        body4 = setupCreepy("Body4", zOffset: 100)
    }
    
    private func setupCreepy(_ suffix: String, size: CGFloat? = nil, offsetMultiplier: CGPoint? = nil, zOffset: CGFloat) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: MagmoorCreepyMinion.creepyName + suffix)
        node.scale(to: scale * gameboardScaleSize * (size ?? maxLength) / maxLength)
        node.position = getPosition(positionMultiplierOffset: offsetMultiplier)
        node.alpha = 0
        node.zPosition = K.ZPosition.overlay + zOffset
        node.name = MagmoorCreepyMinion.creepyName + suffix
        
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
    
    
    // MARK: - Common Functions
    
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
        braveryBar.addToParent(parentNode)
        
        self.parentNode = parentNode
        self.parentNode!.addChild(self)
    }
    
    func touchHandler(scene: SKScene, for touches: Set<UITouch>) {
        guard !isDisabled else { return }
        guard let location = touches.first?.location(in: scene) else { return }
        
        var landedHit = false
        
        for node in scene.nodes(at: location) {
            guard let name = node.name, name.contains(MagmoorCreepyMinion.creepyName) else { continue }
            
            landedHit = true
            hitMinion()
            break
        }

        if !landedHit && !isAnimating {
            AudioManager.shared.playSound(for: "chatclose")
            punchCounter.reset()
            animateMiss(scene: scene, location: location)
        }
    }
    
    
    // MARK: - Animation Functions
    
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
        ])) { [unowned self] in
            removeFromParent()
            completion()
        }
        
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
        animateAppearNode(node: leftHand, delay: delay + 0.5) { [unowned self] in
            braveryBar.showStatus()
        }
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
    }
    
    /**
     Executes the reverse of beginAnimation(), i.e. the creepy minion retreats to the underworld.
     - parameters:
        - delay: time delay before the hiding animation occurs.
        - completion: completion handler to clean up after function ends, for example.
     */
    func endAnimation(delay: TimeInterval, completion: (() -> Void)?) {
        let moveLeftArmHand: SKAction = SKAction.sequence([
            SKAction.rotate(toAngle: 0, duration: 0),
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
        animateRemoveNode(node: body1, delay: delay + 0.1)
        animateRemoveNode(node: body2, delay: delay + 0.2)
        animateRemoveNode(node: body3, delay: delay + 0.3)
        animateRemoveNode(node: body4, delay: delay + 0.4)
        animateRemoveNode(node: face1, delay: delay + 0.3)
        animateRemoveNode(node: face2, delay: delay + 0.4)

        //Longest animation sequence. Use for completion handling.
        animateRemoveNode(node: face3, delay: delay + 3.0, fadeOut: 0.25) { [unowned self] in
            removeFromParent()
            completion?()
        }
    }
    
    /**
     Helper function to facilitate with showing the minion nodes.
     */
    private func animateAppearNode(node: SKNode, delay: TimeInterval, completion: (() -> Void)? = nil) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.fadeIn(withDuration: 0)
        ])) {
            completion?()
        }
    }
    
    /**
     Helper function to facilitatew with hiding the minion nodes.
     */
    private func animateHideNode(node: SKNode, delay: TimeInterval, completion: (() -> Void)? = nil) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.fadeOut(withDuration: 0)
        ])) {
            completion?()
        }
    }
    
    /**
     Helper function to facilitate with hiding and removing the minion nodes.
     */
    private func animateRemoveNode(node: SKNode, delay: TimeInterval, fadeOut: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.fadeOut(withDuration: fadeOut ?? 0),
            SKAction.removeFromParent()
        ])) {
            completion?()
        }
    }
    
    /**
     Issues a series of minion attacks for the prescribed duration.
     */
    func minionAttackSeries(duration: TimeInterval, completion: @escaping () -> Void) {
        let attackSpeed: TimeInterval = 0.8 //the lower the number, the harder he is to get an attack in
        let attackPoint: CGFloat = 0.12
        let drainPoint: CGFloat = 0.01
        
        //VERY IMPORTANT to assign keys to the below actions, AND remove them when exiting the completion!! 9/29/24
        let key = "minionAttackSeries"
        let key2 = "braveryReduction"
        let key3 = "finalCompletion"
        
        isDisabled = false
        
        func cleanupCompletion(flashMax: Bool) {
            //IMPORTANT to stop all actions!!
            removeAction(forKey: key)
            removeAction(forKey: key2)
            removeAction(forKey: key3)
            
            isDisabled = true
            braveryBar.removeStatus(flashMax: flashMax, completion: completion)
        }
        
        //Minion swipes at PUZL Boy, lowering Bravery.
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [unowned self] in
                minionAttack(attackPoint: attackPoint)
            },
            SKAction.wait(forDuration: attackSpeed)
        ])), withKey: key)
        
        //Constant drain of bravery just for merely being in its presence.
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.run { [unowned self] in
                if braveryCounter.getCount() >= 1 {
                    cleanupCompletion(flashMax: true)
                    return
                }
                else if braveryCounter.getCount() <= 0 && !braveryReachedZero {
                    braveryReachedZero = true
                    AudioManager.shared.playSound(for: "scarylaugh")
                }
                else {
                    braveryCounter.decrement(by: drainPoint)
                    braveryBar.animateAndUpdate(percentage: braveryCounter.getCount())
                }
            }
        ])), withKey: key2)

        //Final completion with cleanup.
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run {
                cleanupCompletion(flashMax: false)
                return
            }
        ]), withKey: key3)
    }
    
    /**
     Executes a Minion attack with attackPoint input. Animates the Minion being attacked and updates the bravery counter.
     */
    private func minionAttack(attackPoint: CGFloat) {
        guard !isAnimating else { return }
        guard let parentSprite = parentNode as? SKSpriteNode else { return }
        
        
        //Update states
        isAnimating = true
        braveryCounter.decrement(by: attackPoint)
        braveryBar.animateAndUpdate(percentage: braveryCounter.getCount())

        
        //Scratch Marks
        let scratchOffset: CGFloat = 50
        let cooloffDuration: TimeInterval = 2
        
        let scratchScreen = SKSpriteNode(imageNamed: "enemyScratch")
        scratchScreen.size = parentSprite.size
        scratchScreen.position.y += scratchOffset
        scratchScreen.anchorPoint = .zero
        scratchScreen.zRotation = CGFloat.random(in: (-.pi / 12)...(.pi / 12))
        scratchScreen.zPosition = leftHand.zPosition + 1
        
        parentSprite.addChild(scratchScreen)
        
        scratchScreen.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveTo(y: -scratchOffset, duration: cooloffDuration),
                SKAction.scale(by: 0.90, duration: cooloffDuration),
                SKAction.fadeOut(withDuration: cooloffDuration)
            ]),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            isAnimating = false
        }
        
        AudioManager.shared.playSound(for: "enemyscratch")
        AudioManager.shared.playSound(for: "boypain\(Int.random(in: 1...4))")
        AudioManager.shared.playSoundThenStop(for: "littlegirllaugh",
                                              currentTime: TimeInterval.random(in: 0...8),
                                              playForDuration: cooloffDuration, fadeOut: 1)
        Haptics.shared.executeCustomPattern(pattern: .enemy)
        
        
        //Swipe attack
        let resetAngle: CGFloat = 3/5 * .pi
        let rotations: CGFloat = 4
        let swipeSpeed: TimeInterval = 0.12

        leftHand.run(SKAction.sequence([
            SKAction.rotate(toAngle: -resetAngle, duration: 0),
            SKAction.rotate(byAngle: resetAngle, duration: swipeSpeed),
            SKAction.repeat(SKAction.sequence([
                SKAction.wait(forDuration: (cooloffDuration - swipeSpeed) / rotations),
                SKAction.rotate(byAngle: -resetAngle / rotations, duration: 0)
            ]), count: Int(rotations))
        ]))
    }
    
    func hitMinion() {
        guard !isAnimating else { return }

        let braveryPoint: CGFloat = 0.04
        let hitArmsOffset: CGFloat = 40
        let cooloffDuration: TimeInterval = 0.1
        let hitAction = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0),
            SKAction.colorize(with: .white, colorBlendFactor: 0, duration: cooloffDuration)
        ])

        
        //Update states
        isAnimating = true
        punchCounter.increment()
        braveryCounter.increment(by: braveryPoint)
        braveryBar.animateAndUpdate(percentage: braveryCounter.getCount())
        
        
        //Minion hit animation
        executeActionOnNodes(hitAction)
        
        animateHideNode(node: body1, delay: 0)
        animateHideNode(node: face1, delay: 0) { [unowned self] in
            animateAppearNode(node: face1, delay: cooloffDuration)
            animateAppearNode(node: body1, delay: cooloffDuration) { [unowned self] in
                //The final completion...
                isAnimating = false
                
                rightArm.run(SKAction.moveBy(x: hitArmsOffset, y: 0, duration: 0))
                rightHand.run(SKAction.moveBy(x: hitArmsOffset, y: 0, duration: 0))
                leftArm.run(SKAction.moveBy(x: 0, y: hitArmsOffset, duration: 0))
                leftHand.run(SKAction.moveBy(x: 0, y: hitArmsOffset, duration: 0))
            }
        }
        
        //This moves the arms and hands in slightly so there's no gap between them and the body.
        rightArm.run(SKAction.moveBy(x: -hitArmsOffset, y: 0, duration: 0))
        rightHand.run(SKAction.moveBy(x: -hitArmsOffset, y: 0, duration: 0))
        leftArm.run(SKAction.moveBy(x: 0, y: -hitArmsOffset, duration: 0))
        leftHand.run(SKAction.group([
            SKAction.rotate(toAngle: 0, duration: 0),
            SKAction.moveBy(x: 0, y: -hitArmsOffset, duration: 0)
        ]))
        
        
        //Sound effects
        switch punchCounter.getCount() {
        case let num where num.truncatingRemainder(dividingBy: 2) == 0:
            AudioManager.shared.playSound(for: "punchwhack1")
        case let num where num.truncatingRemainder(dividingBy: 2) != 0:
            AudioManager.shared.playSound(for: "punchwhack2")
        default:
            break
        }

        Haptics.shared.addHapticFeedback(withStyle: .heavy)
    }
    
    /**
     Helper function to run an SKAction across all body parts (nodes).
     */
    private func executeActionOnNodes(_ action: SKAction) {
        leftHand.run(action)
        leftArm.run(action)
        rightHand.run(action)
        rightArm.run(action)
        face1.run(action)
        face2.run(action)
        face3.run(action)
        body1.run(action)
        body2.run(action)
        body3.run(action)
        body4.run(action)
    }
    
    /**
     Helper function that shows a Miss and a flash scren.
     */
    private func animateMiss(scene: SKScene, location: CGPoint) {
        //"Miss!" textuality
        let pointsSprite = SKLabelNode(text: "Miss!")
        pointsSprite.fontName = UIFont.chatFont
        pointsSprite.fontSize = UIFont.chatFontSizeLarge
        pointsSprite.fontColor = UIFont.chatFontColor
        pointsSprite.position = location + CGPoint(x: 0, y: 50)
        pointsSprite.zPosition = K.ZPosition.itemsPoints
        pointsSprite.addDropShadow()

        let moveUpAction = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1.0)
        let fadeOutAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.75),
            SKAction.fadeOut(withDuration: 0.25)
        ])
        
        pointsSprite.run(SKAction.sequence([
            SKAction.group([moveUpAction, fadeOutAction]),
            SKAction.removeFromParent()
        ]))
        
        //On-screen Flash
        let flash = SKSpriteNode(color: .white, size: scene.size)
        flash.anchorPoint = .zero
        flash.alpha = 0
        flash.zPosition = K.ZPosition.gameboard + K.ZPosition.bloodOverlay
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(by: 0.5, duration: 0),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
        
        //Don't forget to add to scene!
        scene.addChild(pointsSprite)
        scene.addChild(flash)
    }
    
    
}
