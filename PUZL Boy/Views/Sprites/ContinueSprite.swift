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
        
        buyButton = DecisionButtonSprite(text: "Buy $0.99: +25🚶🏻‍♂️", color: .systemGreen)
        buyButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: -K.ScreenDimensions.iPhoneWidth / 8)
        
        super.init()
        
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
        zPosition = K.ZPosition.messagePrompt
        
        addChild(backgroundSprite)
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
    
    func didTapButton(in location: CGPoint) {
        if inBounds(location: location, button: watchAdButton) {
            watchAdButton.tapButton()
            delegate?.didTapWatchAd()
        }
        else if inBounds(location: location, button: buyButton) {
            buyButton.tapButton()
            delegate?.didTapBuyButton()
        }
    }
    
    private func inBounds(location: CGPoint, button: DecisionButtonSprite) -> Bool {
        // FIXME: - Hit bounds are not exactly within the button...
        return (location.x >= position.x + button.position.x /*+ button.shadowOffset.x*/ - button.buttonSize.width / 2 &&
                location.x <= position.x + button.position.x /*+ button.shadowOffset.x*/ + button.buttonSize.width / 2 &&
                location.y >= position.y + button.position.y + button.shadowOffset.y - button.buttonSize.height / 2 &&
                location.y <= position.y + button.position.y + button.shadowOffset.y + button.buttonSize.height / 2)
    }
}
