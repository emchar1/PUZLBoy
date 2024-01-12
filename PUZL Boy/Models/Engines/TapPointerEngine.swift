//
//  TapPointerEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/11/24.
//

import SpriteKit

class TapPointerEngine: SKNode {
    
    // MARK: - Properties
    
    private let pointerSize = K.ScreenDimensions.size * 0.05
    private var pointer: SKShapeNode?
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        pointer = SKShapeNode(ellipseOf: pointerSize)
        
        guard let pointer = pointer else { return }
        
        pointer.strokeColor = .white
        pointer.lineWidth = 4
        pointer.zPosition = K.ZPosition.activityIndicator + 10
        
        pointer.run(SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi, duration: .random(in: 0.5...1))))
        pointer.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    deinit {
        print("TapPointerEngine deinit")
    }
    
    
    // MARK: - Functions
    
    
    
    func move(to superScene: SKScene, at location: CGPoint) {
        for i in -1...1 {
            guard let pointerCopy = pointer?.copy() as! SKShapeNode? else { return }
            
            pointerCopy.strokeColor = UIColor(red: .random(in: 0.9...1), green: .random(in: 0.8...0.9), blue: .random(in: 0.4...0.8), alpha: 1)
            pointerCopy.zRotation = .random(in: 0...CGFloat.pi)
            pointerCopy.position = CGPoint(x: location.x + (CGFloat(i) * pointerSize.width * .random(in: 0...0.5)),
                                           y: location.y - (CGFloat(abs(i)) * pointerSize.width * .random(in: 0...0.5)))

            superScene.addChild(pointerCopy)
        }
        
        ParticleEngine.shared.animateParticles(type: .pointer,
                                               toNode: superScene,
                                               position: location,
                                               scale: 1,
                                               zPosition: K.ZPosition.activityIndicator + 10,
                                               duration: 2)
    }
}
