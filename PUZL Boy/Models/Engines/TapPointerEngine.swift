//
//  TapPointerEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/11/24.
//

import SpriteKit

class TapPointerEngine: SKNode {
    
    // MARK: - Properties
    
    static let nodeName = ParticleEngine.nodeNamePrefix
    
    private let pointerSize = K.ScreenDimensions.size * 0.05
    private var superScene: SKScene?
    private var location: CGPoint?
    private var pointerColor: UIColor?
    private var randomGold: UIColor { UIColor(red: .random(in: 0.9...1), green: .random(in: 0.8...0.9), blue: .random(in: 0.4...0.8), alpha: 1) }
    private var randomColor: UIColor {
        guard let pointerColor = pointerColor else { return randomGold }
        
        let randomMin: CGFloat = -0.2
        let randomMax: CGFloat = 0.2
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        pointerColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red += max(0, min(1, .random(in: randomMin...randomMax)))
        green += max(0, min(1, .random(in: randomMin...randomMax)))
        blue += max(0, min(1, .random(in: randomMin...randomMax)))

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private var pointerNode: SKShapeNode?           //several triangular nodes
    private var sparkNode: SKSpriteNode?            //a hazy, round dot
    
    
    // MARK: - Initialization
    
    init(using color: UIColor? = nil) {
        pointerColor = color
        
        super.init()
        
        setupNodes()
    }
    
    /**
     Initialize pointerColor based on ChosenSword.
     */
    convenience init(using chosenSword: ChosenSword) {
        let pointerColor: UIColor?
        
        switch chosenSword.type {
        case .celestialBroadsword:  pointerColor = nil
        case .heavenlySaber:        pointerColor = UIColor(red: 68/255, green: 149/255, blue: 193/255, alpha: 1)
        case .cosmicCleaver:        pointerColor = UIColor(red: 68/255, green: 193/255, blue: 135/255, alpha: 1)
        case .eternalBlade:         pointerColor = .systemPink
        case .plainSword:           pointerColor = .black
        }
        
        self.init(using: pointerColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
//        setupPointerNode()
        setupSparkNode()
    }
    
    private func setupPointerNode() {
        let size = pointerSize.width
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: size, y: -size))
        path.addLine(to: CGPoint(x: -size, y: -size))
        path.addLine(to: CGPoint(x: 0, y: size))
        
        pointerNode = SKShapeNode(path: path.cgPath)
        
        guard let pointerNode = pointerNode else { return }
        
        pointerNode.strokeColor = .white
        pointerNode.lineWidth = 4
        pointerNode.zPosition = K.ZPosition.activityIndicator + 10
        pointerNode.name = TapPointerEngine.nodeName
        
        pointerNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi, duration: .random(in: 0.5...1))))
        pointerNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    private func setupSparkNode() {
        sparkNode = SKSpriteNode(imageNamed: "spark")
        
        guard let sparkNode = sparkNode else { return }
        
        sparkNode.size = CGSize(width: pointerSize.height, height: pointerSize.height)
        sparkNode.colorBlendFactor = 1
        sparkNode.setScale(2)
        sparkNode.zPosition = K.ZPosition.activityIndicator + 10
        sparkNode.name = TapPointerEngine.nodeName
        
        sparkNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    deinit {
        print("TapPointerEngine deinit")
    }
    
    
    // MARK: - Functions
    
    func move(to superScene: SKScene, at location: CGPoint, particleType: ParticleEngine.ParticleType) {
        self.superScene = superScene
        self.location = location

//        addPointerNode()
        addSparkNode()
        addParticleNode(type: particleType)
    }
    
    func changeColor(to color: UIColor?) {
        pointerColor = color
    }
    
    
    // MARK: - Helper Functions
    
    private func addPointerNode() {
        guard let superScene = superScene else { return }
        guard let location = location else { return }
        
        for i in -1...1 {
            guard let pointerCopy = pointerNode?.copy() as! SKShapeNode? else { return }
            
            pointerCopy.strokeColor = randomColor
            pointerCopy.zRotation = .random(in: 0...CGFloat.pi)
            pointerCopy.position = CGPoint(x: location.x + (CGFloat(i) * pointerSize.width * .random(in: 0...0.5)),
                                           y: location.y - (CGFloat(abs(i)) * pointerSize.width * .random(in: 0...0.5)))
            
            superScene.addChild(pointerCopy)
        }
    }
    
    private func addSparkNode() {
        guard let superScene = superScene else { return }
        guard let location = location else { return }

        guard let sparkCopy = sparkNode?.copy() as! SKSpriteNode? else { return }

        sparkCopy.color = randomColor
        sparkCopy.position = location
        
        superScene.addChild(sparkCopy)
    }
    
    private func addParticleNode(type: ParticleEngine.ParticleType) {
        guard let superScene = superScene else { return }
        guard let location = location else { return }
        
        ParticleEngine.shared.animateParticles(type: type,
                                               toNode: superScene,
                                               position: location,
                                               scale: UIDevice.spriteScale,
                                               zPosition: K.ZPosition.activityIndicator + 20,
                                               duration: 2)
    }
}
