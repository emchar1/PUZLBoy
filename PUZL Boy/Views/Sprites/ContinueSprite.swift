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
    
    let offset = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2, y: K.ScreenDimensions.height / 2)
    
    private(set) var backgroundSprite: SKShapeNode
    private(set) var watchAdButton: DecisionButtonSprite
    private(set) var buyButton: DecisionButtonSprite
    
    weak var delegate: ContinueSpriteDelegate?

    
    // MARK: - Initialization
    
    override init() {
        let gradient: UIImage = UIImage.gradientImage(
            withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height),
            startPoint: CGPoint(x: 0.5, y: 1),
            endPoint: CGPoint(x: 0.5, y: 0.5),
            colors: [UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1).cgColor,
                     UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor])
        
        backgroundSprite = SKShapeNode(rectOf: CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth / 2),
                                       cornerRadius: 20)
        backgroundSprite.fillColor = .systemGray
        backgroundSprite.fillTexture = SKTexture(image: gradient)
        backgroundSprite.lineWidth = 12
        backgroundSprite.strokeColor = .white
        backgroundSprite.setScale(GameboardSprite.spriteScale)
        
        watchAdButton = DecisionButtonSprite(text: "Watch Ad: +3🚶🏻‍♂️", color: .systemBlue)
        watchAdButton.position = CGPoint(x: -K.ScreenDimensions.iPhoneWidth / 4, y: 0)
        
        buyButton = DecisionButtonSprite(text: "Buy $0.99: +25🚶🏻‍♂️", color: .systemGreen)
        buyButton.position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 4, y: 0)
        
        super.init()
        
        setScale(0)
        position = offset
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
        return (location.x >= offset.x + button.position.x - button.buttonSize.width / 2 &&
                location.x <= offset.x + button.position.x + button.buttonSize.width / 2 &&
                location.y >= offset.y + button.position.y - button.buttonSize.height / 2  &&
                location.y <= offset.y + button.position.y + button.buttonSize.height / 2)
    }
}
