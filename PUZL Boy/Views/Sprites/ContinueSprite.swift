//
//  ContinueSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/28/23.
//

import SpriteKit

protocol ContinueSpriteDelegate: AnyObject {
    func didTapWatchAd()
    func didTapBuyButton()
}

class ContinueSprite: SKNode {
    
    // MARK: - Properties
    
    static let extraLivesAd = 3
    static let extraLivesBuy = 25
    
    private(set) var backgroundSprite: SKShapeNode
    private(set) var watchAdButton: DecisionButtonSprite
    private(set) var buyButton: DecisionButtonSprite
    
    weak var delegate: ContinueSpriteDelegate?

    
    // MARK: - Initialization
    
    override init() {
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth / 2),
                                       cornerRadius: 20)
        backgroundSprite.fillColor = .systemGray
        backgroundSprite.fillTexture = SKTexture(image: UIImage.chatGradientTexture)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(GameboardSprite.spriteScale)
        
        watchAdButton = DecisionButtonSprite(text: "Watch Ad: +3🚶🏻‍♂️", color: .systemBlue)
        watchAdButton.position = CGPoint(x: -K.ScreenDimensions.iPhoneWidth / 4, y: -K.ScreenDimensions.iPhoneWidth / 8)
        watchAdButton.name = "watchAdButton"
        
        buyButton = DecisionButtonSprite(text: "Buy $0.99: +25🚶🏻‍♂️", color: .systemGreen)
        buyButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: -K.ScreenDimensions.iPhoneWidth / 8)
        buyButton.name = "buyButton"
        
        super.init()
        
        let continueLabel = SKLabelNode(text: "CONTINUE?")
        continueLabel.fontName = UIFont.gameFont
        continueLabel.fontSize = UIFont.gameFontSizeMedium
        continueLabel.fontColor = UIFont.gameFontColor
        continueLabel.position = CGPoint(x: 0, y: K.ScreenDimensions.iPhoneWidth / 4 - 80)
        
        let livesRefreshLabel = SKLabelNode(text: "...or wait for 5 lives in: 03:00")
        livesRefreshLabel.fontName = UIFont.chatFont
        livesRefreshLabel.fontSize = UIFont.chatFontSize
        livesRefreshLabel.fontColor = UIFont.chatFontColor
        livesRefreshLabel.position = CGPoint(x: 0, y: continueLabel.position.y - 100)
        
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.messagePrompt
        
        addChild(backgroundSprite)
        backgroundSprite.addChild(continueLabel)
        backgroundSprite.addChild(livesRefreshLabel)
        backgroundSprite.addChild(watchAdButton)
        backgroundSprite.addChild(buyButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    func animateShow(completion: @escaping (() -> Void)) {
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2),
        ]), completion: completion)
    }
    
    func animateHide(completion: @escaping (() -> Void)) {
        AudioManager.shared.playSound(for: "chatclose")
        
        run(SKAction.scale(to: 0, duration: 0.25), completion: completion)
    }
    
    func didTapButton(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return print("Error capturing touch in ContinueSprite.didTapButton") }
        
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "watchAdButton" {
                watchAdButton.tapButton()
                delegate?.didTapWatchAd()
                return
            }
            else if node.name == "buyButton" {
                buyButton.tapButton()
                delegate?.didTapBuyButton()
                return
            }
            else {
                print("Nothing tapped....")
            }
        }
    }
    
    
}
