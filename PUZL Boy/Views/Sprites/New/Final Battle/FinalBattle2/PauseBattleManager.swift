//
//  PauseBattleManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/28/25.
//

import SpriteKit

protocol PauseBattleManagerDelegate: AnyObject {
    func didTapPauseButton(isPaused: Bool)
    func didTapPauseButtonTest(isPaused: Bool)
}

class PauseBattleManager {
    
    // MARK: - Properties
    
    private let buttonTexture: (day: SKTexture, nite: SKTexture) = (SKTexture(imageNamed: "settingsButton"), SKTexture(imageNamed: "settingsButtonNITE"))
    private weak var superScene: SKScene?
    private var pauseButton: SKSpriteNode
    private var isPaused: Bool
    
    private var pauseButtonTest: SKSpriteNode
    private var isPausedTest: Bool
    
    weak var delegate: PauseBattleManagerDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        pauseButton = SKSpriteNode(texture: buttonTexture.nite)
        pauseButton.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.bottomMargin)
        pauseButton.scale(to: CGSize(width: 180, height: 180))
        pauseButton.anchorPoint.y = 0
        pauseButton.name = "pauseButton"

        isPaused = false
        
        
        pauseButtonTest = pauseButton.copy() as! SKSpriteNode
        pauseButtonTest.texture = buttonTexture.day
        pauseButtonTest.position.x += 200
        pauseButtonTest.name = "pauseButtonNITE"
        
        isPausedTest = false
    }
    
    
    // MARK: - Functions
    
    func addToScene(_ scene: SKScene) {
        self.superScene = scene
        
        scene.addChild(pauseButton)
        scene.addChild(pauseButtonTest)
    }
    
    func tapPauseButton(at location: CGPoint) {
        guard superScene?.nodes(at: location).first(where: { $0.name == "pauseButton" }) != nil else { return }
        
        isPaused.toggle()
        ButtonTap.shared.tap(type: .buttontap7)
        delegate?.didTapPauseButton(isPaused: isPaused)
        
        
        pauseButton.texture = isPaused ? buttonTexture.day : buttonTexture.nite
    }
    
    func tapPauseButtonTest(at location: CGPoint) {
        guard superScene?.nodes(at: location).first(where: { $0.name == "pauseButtonNITE" }) != nil else { return }
        
        isPausedTest.toggle()
        AudioManager.shared.playSound(for: "villainpain2")
        delegate?.didTapPauseButtonTest(isPaused: isPausedTest)
        
        
        pauseButtonTest.texture = isPausedTest ? buttonTexture.nite : buttonTexture.day
    }
    
    
}
