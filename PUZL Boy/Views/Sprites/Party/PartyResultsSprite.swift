//
//  PartyResultsSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 6/21/23.
//

import SpriteKit

protocol PartyResultsSpriteDelegate: AnyObject {
    func didTapConfirm()
}

class PartyResultsSprite: SKNode {
    
    // MARK: - Properties
    
    private let backgroundSize = CGSize(width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.iPhoneWidth * (UIDevice.isiPad ? 1.2 : 1.25))
    
    private var disableControls: Bool = true
    private var backgroundSprite: SKShapeNode
    private var gemsLineItem: PartyResultsLineItemSprite
    private var gemsDoubleLineItem: PartyResultsLineItemSprite
    private var gemsTripleLineItem: PartyResultsLineItemSprite
    private var gemsTotalLineItem: PartyResultsLineItemSprite
    private var livesLineItem: PartyResultsLineItemSprite
    private var livesTotalLineItem: PartyResultsLineItemSprite
    private var confirmButton: DecisionButtonSprite
    
    weak var delegate: PartyResultsSpriteDelegate?
    
    
    // MARK: - Initialization
    
    override init() {
        let backgroundCorner: CGFloat = 20
        let topBorder: CGFloat = UIDevice.isiPad ? 200 : 150
        
        backgroundSprite = SKShapeNode(rectOf: backgroundSize, cornerRadius: backgroundCorner)
        backgroundSprite.fillColor = .magenta
        backgroundSprite.strokeColor = .white
        backgroundSprite.lineWidth = 0
        backgroundSprite.setScale(GameboardSprite.spriteScale)
        
        gemsLineItem = PartyResultsLineItemSprite(iconName: "partyGem", iconDescription: "Gems", amount: 0)
        gemsLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                        y: backgroundSize.height / 2 - PartyResultsLineItemSprite.height - topBorder)
        
        gemsDoubleLineItem = PartyResultsLineItemSprite(iconName: "partyGemDouble", iconDescription: "2x Multiplier", amount: 0)
        gemsDoubleLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                              y: gemsLineItem.position.y - PartyResultsLineItemSprite.height)
        
        gemsTripleLineItem = PartyResultsLineItemSprite(iconName: "partyGemTriple", iconDescription: "3x Multiplier", amount: 0)
        gemsTripleLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                              y: gemsDoubleLineItem.position.y - PartyResultsLineItemSprite.height)
        
        gemsTotalLineItem = PartyResultsLineItemSprite(iconName: nil, iconDescription: "Total Gems", amount: 0)
        gemsTotalLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                             y: gemsTripleLineItem.position.y - PartyResultsLineItemSprite.height)
        
        livesLineItem = PartyResultsLineItemSprite(iconName: "partyLife", iconDescription: "Lives", amount: 0)
        livesLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                         y: gemsTotalLineItem.position.y - PartyResultsLineItemSprite.height - topBorder / 2)
        
        livesTotalLineItem = PartyResultsLineItemSprite(iconName: nil, iconDescription: "Total Lives", amount: 0)
        livesTotalLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                              y: livesLineItem.position.y - PartyResultsLineItemSprite.height)
        
        let titleLabel = SKLabelNode(text: "RESULTS")
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIDevice.isiPad ? UIFont.gameFontSizeExtraLarge : UIFont.gameFontSizeMedium
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.position = CGPoint(x: 0, y: backgroundSprite.frame.size.height / (UIDevice.isiPad ? 1.5 : 2) - titleLabel.frame.size.height / 2)
        titleLabel.verticalAlignmentMode = .top
        titleLabel.zPosition = 10
        titleLabel.addHeavyDropShadow()
        
        confirmButton = DecisionButtonSprite(text: "Continue", color: DecisionButtonSprite.colorBlue, iconImageName: nil)
        confirmButton.position = CGPoint(x: 0, y: -backgroundSprite.frame.size.height / 2 + titleLabel.frame.height / (UIDevice.isiPad ? 2 : 0.5))
        
        super.init()
        
        confirmButton.delegate = self
        
        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.iPhoneWidth / 2,
                           y: K.ScreenDimensions.topOfGameboard - backgroundSize.height / 2 * GameboardSprite.spriteScale + GameboardSprite.padding)
        zPosition = K.ZPosition.messagePrompt
        
        backgroundSprite.addShadow(rectOf: backgroundSize, cornerRadius: backgroundCorner, shadowOffset: 10, shadowColor: .cyan)
        confirmButton.alpha = 0

        backgroundSprite.addChild(titleLabel)
        backgroundSprite.addChild(gemsLineItem)
        backgroundSprite.addChild(gemsDoubleLineItem)
        backgroundSprite.addChild(gemsTripleLineItem)
        backgroundSprite.addChild(gemsTotalLineItem)
        backgroundSprite.addChild(livesLineItem)
        backgroundSprite.addChild(livesTotalLineItem)
        backgroundSprite.addChild(confirmButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ConfirmSprite deinit")
    }
    
    
    // MARK: - Functions
    
    func updateAmounts(gems: Int, gemsDouble: Int, gemsTriple: Int, lives: Int) {
        gemsLineItem.updateAmount(gems)
        gemsDoubleLineItem.updateAmount(gemsDouble)
        gemsTripleLineItem.updateAmount(gemsTriple)
        gemsTotalLineItem.updateAmount(0)
        livesLineItem.updateAmount(lives)
        livesTotalLineItem.updateAmount(lives)
    }
    
    func animateShow(totalGems: Int, lives: Int, totalLives: Int, completion: @escaping (() -> Void)) {
        backgroundSprite.removeFromParent()
        
        addChild(backgroundSprite)
        
        backgroundSprite.fillTexture = SKTexture(image: UIImage.skyGradientTexture)
        
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2),
        ])) { [unowned self] in
            let xPosition = -backgroundSize.width / 2
            
            backgroundSprite.showShadow(animationDuration: 0.1, completion: nil)
            
            // FIXME: - I hate this nesting of death
            gemsLineItem.animateAppear(xPosition: xPosition) { [unowned self] in
                gemsDoubleLineItem.animateAppear(xPosition: xPosition) { [unowned self] in
                    gemsTripleLineItem.animateAppear(xPosition: xPosition) { [unowned self] in
                        gemsTotalLineItem.animateAppear(xPosition: xPosition) { [unowned self] in
                            livesLineItem.animateAppear(xPosition: xPosition) { [unowned self] in
                                livesTotalLineItem.animateAppear(xPosition: xPosition) { [unowned self] in
                                    let multiplierIncrement: CGFloat = 100
                                    let waitFactor: TimeInterval = 3
                                    let multiplier: Int = Int(max(CGFloat(totalGems) / multiplierIncrement, 1))
                                    let wait = SKAction.wait(forDuration: min(CGFloat(multiplier) * waitFactor / CGFloat(totalGems),
                                                                              waitFactor / multiplierIncrement))
                                    var counter: Int = 0
                                    var lifeCounter: Int = 0
                                    var livesToIncrement: Int = lives
                                    
                                    let incrementAction = SKAction.run { [unowned self] in
                                        gemsTotalLineItem.animateAmount(counter) { }
                                                                                
                                        counter += multiplier
                                        lifeCounter += multiplier
                                        
                                        if lifeCounter > 100 {
                                            livesToIncrement += 1
                                            lifeCounter = 0
                                            
                                            gemsTotalLineItem.addTextAnimation("1-UP")
                                            livesTotalLineItem.animateAmount(livesToIncrement) { }
                                            
                                            AudioManager.shared.playSound(for: "boywin")
                                        }
                                    }
                                    
                                    let incrementRepeat = SKAction.repeat(SKAction.sequence([
                                        wait,
                                        incrementAction
                                    ]), count: Int(CGFloat(totalGems) / CGFloat(multiplier)))
                                
                                    run(incrementRepeat) { [unowned self] in
                                        if totalGems > 0 {
                                            gemsTotalLineItem.animateAmount(totalGems) { }
                                        }
                                            
                                        if livesToIncrement != totalLives {
                                            livesTotalLineItem.animateAmount(totalLives) { }
                                            
                                            AudioManager.shared.playSound(for: "boywin")
                                        }
                                        
                                        confirmButton.animateAppear()

                                        disableControls = false
                                        completion()
                                    }
                                }
                            }
                        }
                    }
                }
            } //end nesting of death

        }
    }
    
    func animateHide(completion: @escaping (() -> Void)) {
        disableControls = true
        
        backgroundSprite.hideShadow(animationDuration: 0.05, completion: nil)
        
        let fadeBackground = SKSpriteNode(color: .white, size: K.ScreenDimensions.screenSize)
        fadeBackground.alpha = 0
        fadeBackground.zPosition = K.ZPosition.messagePrompt + 100
        
        addChild(fadeBackground)
        
        fadeBackground.run(SKAction.fadeIn(withDuration: 1.0)) { [unowned self] in
            gemsLineItem.animateDisappear()
            gemsDoubleLineItem.animateDisappear()
            gemsTripleLineItem.animateDisappear()
            gemsTotalLineItem.animateDisappear()
            livesLineItem.animateDisappear()
            livesTotalLineItem.animateDisappear()
            confirmButton.alpha = 0

            fadeBackground.removeFromParent()
            backgroundSprite.removeFromParent()
            completion()
        }
    }
    
    
    // MARK: - UI Controls
    
    func touchDown(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard node.name == DecisionButtonSprite.tappableAreaName else { continue }
            guard let decisionSprite = node.parent as? DecisionButtonSprite else { continue }
            
            decisionSprite.touchDown(in: location)
        }
    }
    
    func touchUp() {
        confirmButton.touchUp()
    }
    
    
    func didTapButton(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard node.name == DecisionButtonSprite.tappableAreaName else { continue }
            guard let decisionSprite = node.parent as? DecisionButtonSprite else { continue }
            
            let buttonType: ButtonTap.ButtonType = .buttontap3
            
            decisionSprite.tapButton(in: location, type: buttonType)
        }
    }
    
    
}


// MARK: - DecisionButtonSpriteDelegate

extension PartyResultsSprite: DecisionButtonSpriteDelegate {
    func buttonWasTapped(_ node: DecisionButtonSprite) {
        delegate?.didTapConfirm()
    }
}
