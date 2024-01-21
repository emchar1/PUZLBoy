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
    
    private let backgroundSize = CGSize(width: K.ScreenDimensions.size.width, height: K.ScreenDimensions.size.width * (UIDevice.isiPad ? 1.2 : 1.25))
    
    private var disableControls: Bool = true
    private var backgroundSprite: SKShapeNode!
    private var gemsLineItem: PartyResultsLineItemSprite!
    private var gemsDoubleLineItem: PartyResultsLineItemSprite!
    private var gemsTripleLineItem: PartyResultsLineItemSprite!
    private var gemsTotalLineItem: PartyResultsLineItemSprite!
    private var hintsLineItem: PartyResultsLineItemSprite!
    private var livesLineItem: PartyResultsLineItemSprite!
    private var livesTotalLineItem: PartyResultsLineItemSprite!
    private var continueButton: SettingsTapButton!
    
    weak var delegate: PartyResultsSpriteDelegate?
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()

        setScale(0)
        position = CGPoint(x: K.ScreenDimensions.size.width / 2,
                           y: K.ScreenDimensions.topOfGameboard - backgroundSize.height / 2 * UIDevice.spriteScale + GameboardSprite.padding)
        zPosition = K.ZPosition.messagePrompt

        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("PartyResultsSprite deinit")
    }
    
    private func setupSprites() {
        let backgroundCorner: CGFloat = 20
        let topBorder: CGFloat = UIDevice.isiPad ? 160 : 120
        
        backgroundSprite = SKShapeNode(rectOf: backgroundSize, cornerRadius: backgroundCorner)
        backgroundSprite.fillColor = .magenta
        backgroundSprite.strokeColor = .white
        backgroundSprite.lineWidth = 0
        backgroundSprite.setScale(UIDevice.spriteScale)
        backgroundSprite.addShadow(rectOf: backgroundSize, cornerRadius: backgroundCorner, shadowOffset: 10, shadowColor: .cyan)

        gemsLineItem = PartyResultsLineItemSprite(iconName: "partyGem", iconDescription: "Gems", amount: 0)
        gemsLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                        y: backgroundSize.height / 2 - PartyResultsLineItemSprite.lineItemHeight - topBorder)
        
        gemsDoubleLineItem = PartyResultsLineItemSprite(iconName: "partyGemDouble", iconDescription: "2x Multiplier", amount: 0)
        gemsDoubleLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                              y: gemsLineItem.position.y - PartyResultsLineItemSprite.lineItemHeight)
        
        gemsTripleLineItem = PartyResultsLineItemSprite(iconName: "partyGemTriple", iconDescription: "3x Multiplier", amount: 0)
        gemsTripleLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                              y: gemsDoubleLineItem.position.y - PartyResultsLineItemSprite.lineItemHeight)
        
        gemsTotalLineItem = PartyResultsLineItemSprite(iconName: nil, iconDescription: "Total Gems", amount: 0)
        gemsTotalLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                             y: gemsTripleLineItem.position.y - PartyResultsLineItemSprite.lineItemHeight)

        hintsLineItem = PartyResultsLineItemSprite(iconName: "partyHint", iconDescription: "Hints", amount: 0)
        hintsLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                         y: gemsTotalLineItem.position.y - PartyResultsLineItemSprite.lineItemHeight - topBorder / 3)

        livesLineItem = PartyResultsLineItemSprite(iconName: "partyLife", iconDescription: "Lives", amount: 0)
        livesLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                         y: hintsLineItem.position.y - PartyResultsLineItemSprite.lineItemHeight)
        
        livesTotalLineItem = PartyResultsLineItemSprite(iconName: nil, iconDescription: "Total Lives", amount: 0)
        livesTotalLineItem.position = CGPoint(x: -backgroundSize.width / 2,
                                              y: livesLineItem.position.y - PartyResultsLineItemSprite.lineItemHeight)
        
        let titleLabel = SKLabelNode(text: "RESULTS")
        titleLabel.fontName = UIFont.gameFont
        titleLabel.fontSize = UIFont.gameFontSizeLarge
        titleLabel.fontColor = UIFont.gameFontColor
        titleLabel.position = CGPoint(x: 0, y: (backgroundSprite.frame.height - titleLabel.frame.height) / (2 * UIDevice.spriteScale))
        titleLabel.verticalAlignmentMode = .top
        titleLabel.zPosition = 10
        titleLabel.addHeavyDropShadow()
        
        continueButton = SettingsTapButton(text: "Continue", colors: (DecisionButtonSprite.colorBlue, .cyan))
        continueButton.position = CGPoint(x: SettingsTapButton.buttonSize.width / 2, y: -backgroundSprite.frame.size.height / 2 + titleLabel.frame.height / (UIDevice.isiPad ? -1 : 1))
        continueButton.zPosition = 10
        continueButton.delegate = self
        continueButton.alpha = 0

        backgroundSprite.addChild(titleLabel)
        backgroundSprite.addChild(gemsLineItem)
        backgroundSprite.addChild(gemsDoubleLineItem)
        backgroundSprite.addChild(gemsTripleLineItem)
        backgroundSprite.addChild(gemsTotalLineItem)
        backgroundSprite.addChild(hintsLineItem)
        backgroundSprite.addChild(livesLineItem)
        backgroundSprite.addChild(livesTotalLineItem)
        backgroundSprite.addChild(continueButton)
    }
    
    
    // MARK: - Functions
    
    func updateAmounts(gems: Int, gemsDouble: Int, gemsTriple: Int, hints: Int, lives: Int) {
        gemsLineItem.updateAmount(gems)
        gemsDoubleLineItem.updateAmount(gemsDouble)
        gemsTripleLineItem.updateAmount(gemsTriple)
        gemsTotalLineItem.updateAmount(0)
        hintsLineItem.updateAmount(hints)
        livesLineItem.updateAmount(lives)
        livesTotalLineItem.updateAmount(lives)
    }
    
    func animateShow(totalGems: Int, lives: Int, totalLives: Int, completion: @escaping (() -> Void)) {
        backgroundSprite.removeFromParent()
        
        addChild(backgroundSprite)
        
        backgroundSprite.fillTexture = SKTexture(image: DayTheme.getSkyImage())
        
        let xPosition = -backgroundSize.width / 2
        let waitDuration = 0.25

        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.25),
            SKAction.scale(to: 0.95, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2),
            SKAction.run { [unowned self] in backgroundSprite.showShadow(animationDuration: 0.1, completion: nil) },
            SKAction.run { [unowned self] in gemsLineItem.animateAppear(xPosition: xPosition) },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [unowned self] in gemsDoubleLineItem.animateAppear(xPosition: xPosition) },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [unowned self] in gemsTripleLineItem.animateAppear(xPosition: xPosition) },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [unowned self] in gemsTotalLineItem.animateAppear(xPosition: xPosition) },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [unowned self] in hintsLineItem.animateAppear(xPosition: xPosition) },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [unowned self] in livesLineItem.animateAppear(xPosition: xPosition) },
            SKAction.wait(forDuration: waitDuration),
            SKAction.run { [unowned self] in livesTotalLineItem.animateAppear(xPosition: xPosition) }
        ])) { [unowned self] in
            animateHelper(totalGems: totalGems, lives: lives, totalLives: totalLives, completion: completion)
        }
    }
    
    private func animateHelper(totalGems: Int, lives: Int, totalLives: Int, completion: @escaping (() -> Void)) {
        let waitFactor: TimeInterval = 3
        let multiplier: Int = Int(max(CGFloat(totalGems) / CGFloat(PartyInventory.gemsPerLife), 1))
        let wait = SKAction.wait(forDuration: min(CGFloat(multiplier) * waitFactor / CGFloat(totalGems),
                                                  waitFactor / CGFloat(PartyInventory.gemsPerLife)))
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
                
                AudioManager.shared.playSound(for: "gemcollectpartylife")
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
                
                AudioManager.shared.playSound(for: "gemcollectpartylife")
            }
            
            continueButton.animateAppear()

            disableControls = false
            completion()
        }
    }
    
    func animateHide(completion: @escaping (() -> Void)) {
        disableControls = true
        
        backgroundSprite.hideShadow(animationDuration: 0.05, completion: nil)
        
        let fadeBackground = SKSpriteNode(color: .white, size: K.ScreenDimensions.size)
        fadeBackground.alpha = 0
        fadeBackground.zPosition = K.ZPosition.messagePrompt + 100
        
        addChild(fadeBackground)
        
        fadeBackground.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.0),
            SKAction.removeFromParent()
        ])) { [unowned self] in
            gemsLineItem.animateDisappear()
            gemsDoubleLineItem.animateDisappear()
            gemsTripleLineItem.animateDisappear()
            gemsTotalLineItem.animateDisappear()
            hintsLineItem.animateDisappear()
            livesLineItem.animateDisappear()
            livesTotalLineItem.animateDisappear()
            continueButton.alpha = 0

            backgroundSprite.removeFromParent()
            completion()
        }
    }
    
    
    // MARK: - UI Controls
    
    func touchDown(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard let decisionSprite = node as? SettingsTapButton else { continue }
            
            decisionSprite.touchDown(in: location)
        }
    }
    
    func touchUp() {
        continueButton.touchUp()
    }
    
    
    func didTapButton(in location: CGPoint) {
        guard !disableControls else { return }
        guard let nodes = scene?.nodes(at: location) else { return }
        
        for node in nodes {
            guard let decisionSprite = node as? SettingsTapButton else { continue }
            
            decisionSprite.tapButton(in: location, type: .buttontap3)
        }
    }
    
    
}


// MARK: - SettingsTapButtonDelegate

extension PartyResultsSprite: SettingsTapButtonDelegate {
    func didTapButton(_ buttonNode: SettingsTapButton) {
        delegate?.didTapConfirm()
    }
}
