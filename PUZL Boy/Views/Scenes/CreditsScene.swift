//
//  CreditsScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/5/23.
//

import SpriteKit

protocol CreditsSceneDelegate: AnyObject {
    func goBackTapped()
}

class CreditsScene: SKScene {
    
    // MARK: - Properties
    
    var goBackLabel: SKLabelNode
    
    weak var creditsSceneDelegate: CreditsSceneDelegate?
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        goBackLabel = SKLabelNode(text: "COMING SOON")
        goBackLabel.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        goBackLabel.fontName = UIFont.gameFont
        goBackLabel.fontSize = UIFont.gameFontSizeLarge
        goBackLabel.fontColor = .yellow
        goBackLabel.horizontalAlignmentMode = .center
        goBackLabel.addDropShadow(shadowOffset: CGPoint(x: -10, y: -10), alpha: 0.25)
        goBackLabel.name = "goBack"
        
        super.init(size: size)
        
        backgroundColor = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit CreditsScene")
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        addChild(goBackLabel)
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let _ = nodes(at: location).first(where: { $0.name == "goBack" }) else { return }
        
        run(SKAction.fadeOut(withDuration: 1.0)) { [unowned self] in
            removeAllActions()
            removeAllChildren()
            removeFromParent()

            creditsSceneDelegate?.goBackTapped()
        }
        
        ButtonTap.shared.tap(type: .buttontap1)
    }
}