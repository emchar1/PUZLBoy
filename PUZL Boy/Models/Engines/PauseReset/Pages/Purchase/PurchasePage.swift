//
//  PurchasePage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/22/23.
//

import SpriteKit
import StoreKit

protocol PurchasePageDelegate: AnyObject {
    func purchaseCompleted(_ currentButton: PurchaseTapButton)
    func purchaseFailed()
    func purchaseDidTap()
}


class PurchasePage: ParentPage {
    
    // MARK: - Properties
    
    private let hintButtonUnlockedPrice: Double = 1.99
    private let hintButtonUnlockedText: String = "+10 Hints"
    private var isDisabled = false
    
    private var watchAdButton: PurchaseTapButton!
    private var buy099Button: PurchaseTapButton!
    private var buy199Button: PurchaseTapButton!
    private var buy299Button: PurchaseTapButton!
    private var buy499Button: PurchaseTapButton!
    private var buy999Button: PurchaseTapButton!
    private(set) var currentButton: PurchaseTapButton?
    private var activityIndicator: ActivityIndicatorSprite!
    private var currentLevel: Int

    weak var delegate: PurchasePageDelegate?
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize, currentLevel: Int) {
        self.currentLevel = currentLevel
        
        super.init(contentSize: contentSize, titleText: "Shop")
        
        self.nodeName = "purchasePage"
        name = nodeName
        
        IAPManager.shared.delegate = self //1. need this here to initialize

        setupSprites()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        let topMargin: CGFloat = UIDevice.isiPad ? 280 : 200
        let paddingFactor: CGFloat = UIDevice.isiPad ? 1.5 : 1

        //Left column
        watchAdButton = PurchaseTapButton(price: 0,
                                          text: "+1 Life:  ▶️ Ad",
                                          type: .add1Life,
                                          buttonColor: DecisionButtonSprite.colorBlue,
                                          image: "buttonAd")
        watchAdButton.position = CGPoint(x: PurchasePage.padding, y: -topMargin)
        watchAdButton.zPosition = 10
        watchAdButton.delegate = self
        checkWatchAdButtonIsDisabled()
        
        buy199Button = PurchaseTapButton(price: hintButtonUnlockedPrice,
                                         text: hintButtonUnlockedText,
                                         type: .add10Hints,
                                         buttonColor: DecisionButtonSprite.colorYellow,
                                         image: "buttonHints")
        buy199Button.position = CGPoint(x: PurchasePage.padding,
                                        y: watchAdButton.position.y - PurchaseTapButton.buttonSize.height - paddingFactor * PurchasePage.padding)
        buy199Button.zPosition = 10
        buy199Button.delegate = self
        
        buy499Button = PurchaseTapButton(price: 4.99,
                                         text: "+25 Lives",
                                         type: .add25Lives,
                                         buttonColor: DecisionButtonSprite.colorViolet,
                                         image: "buttonLives25")
        buy499Button.position = CGPoint(x: PurchasePage.padding,
                                        y: buy199Button.position.y - PurchaseTapButton.buttonSize.height - paddingFactor * PurchasePage.padding)
        buy499Button.zPosition = 10
        buy499Button.delegate = self

        //Right column
        buy099Button = PurchaseTapButton(price: 0.99,
                                         text: "+5 Moves",
                                         type: .add5Moves,
                                         buttonColor: DecisionButtonSprite.colorBlue,
                                         image: "buttonMoves")
        buy099Button.position = CGPoint(x: watchAdButton.position.x + PurchaseTapButton.buttonSize.width + PurchasePage.padding,
                                        y: -topMargin)
        buy099Button.zPosition = 10
        buy099Button.delegate = self
        
        buy299Button = PurchaseTapButton(price: 2.99,
                                         text: "Skip Level",
                                         type: .skipLevel,
                                         buttonColor: DecisionButtonSprite.colorYellow,
                                         image: "buttonSkip")
        buy299Button.position = CGPoint(x: watchAdButton.position.x + PurchaseTapButton.buttonSize.width + PurchasePage.padding,
                                        y: buy099Button.position.y - PurchaseTapButton.buttonSize.height - paddingFactor * PurchasePage.padding)
        buy299Button.zPosition = 10
        buy299Button.delegate = self
        
        buy999Button = PurchaseTapButton(price: 9.99,
                                         text: "+100 Lives",
                                         type: .add100Lives,
                                         buttonColor: DecisionButtonSprite.colorViolet,
                                         image: "buttonLives100")
        buy999Button.position = CGPoint(x: watchAdButton.position.x + PurchaseTapButton.buttonSize.width + PurchasePage.padding,
                                        y: buy299Button.position.y - PurchaseTapButton.buttonSize.height - paddingFactor * PurchasePage.padding)
        buy999Button.zPosition = 10
        buy999Button.delegate = self

        contentNode.addChild(watchAdButton)
        contentNode.addChild(buy099Button)
        contentNode.addChild(buy199Button)
        contentNode.addChild(buy299Button)
        contentNode.addChild(buy499Button)
        contentNode.addChild(buy999Button)
    }
    
    
    // MARK: - Touch Functions
    
    override func touchDown(for touches: Set<UITouch>) {
        super.touchDown(for: touches)
        
        guard !isDisabled else { return }
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }

        watchAdButton.touchDown(in: location)
        buy099Button.touchDown(in: location)
        buy199Button.touchDown(in: location)
        buy299Button.touchDown(in: location)
        buy499Button.touchDown(in: location)
        buy999Button.touchDown(in: location)
    }
    
    override func touchUp() {
        super.touchUp()
        
        guard !isDisabled else { return }

        watchAdButton.touchUp()
        buy099Button.touchUp()
        buy199Button.touchUp()
        buy299Button.touchUp()
        buy499Button.touchUp()
        buy999Button.touchUp()
    }
    
    override func touchNode(for touches: Set<UITouch>) {
        super.touchNode(for: touches)
        
        guard !isDisabled else { return }
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        watchAdButton.tapButton(in: location)
        buy099Button.tapButton(in: location)
        buy199Button.tapButton(in: location)
        buy299Button.tapButton(in: location)
        buy499Button.tapButton(in: location)
        buy999Button.tapButton(in: location)
    }
    
    
    // MARK: - Other Functions
    
    func checkWatchAdButtonIsDisabled() {
        watchAdButton.isDisabled = !AdMobManager.rewardedAdIsReady
        
        if watchAdButton.isDisabled {
            AdMobManager.shared.createAndLoadRewarded()
        }
        
        print("watchAdButton is\(watchAdButton.isDisabled ? " NOT" : "") available!")
    }
    
    func checkBuyHintsAvailable(level: Int) {
        currentLevel = level
        
        if currentLevel >= PauseResetEngine.hintButtonUnlock {
            buy199Button.setButtonValues(price: hintButtonUnlockedPrice,
                                         text: hintButtonUnlockedText,
                                         image: "buttonHints",
                                         isDisabled: false)
        }
        else {
            buy199Button.setButtonValues(price: -1, 
                                         text: "Unlock LV \(PauseResetEngine.hintButtonUnlock)",
                                         image: "buttonHints",
                                         isDisabled: true)
        }
    }
}


// MARK: - PurchaseTapButtonDelegate

extension PurchasePage: PurchaseTapButtonDelegate {
    func didTapButton(_ buttonNode: PurchaseTapButton) {
        isDisabled = true

        activityIndicator = ActivityIndicatorSprite()
        activityIndicator.move(toParent: contentNode)

        switch buttonNode.type {
        case .add1Life:
            AdMobManager.shared.delegate = self

            AdMobManager.shared.presentRewarded { [weak self] (adReward) in
                self?.currentButton = self?.watchAdButton

                print("You were rewarded: \(adReward.amount) lives!")
            }
        case .add5Moves:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idMoves5 }) else {
                print("Unable to find IAP: 5 Moves ($0.99)")
                return
            }
            
            currentButton = buy099Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .add10Hints:
            IAPManager.shared.delegate = self
            
            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idHints10 }) else {
                print("Unable to find IAP: 10 Hints ($1.99)")
                return
            }
            
            currentButton = buy199Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .skipLevel:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idSkipLevel }) else {
                print("Unable to find IAP: Skip Level ($2.99)")
                return
            }
            
            currentButton = buy299Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .add25Lives:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idLives25 }) else {
                print("Unable to find IAP: 25 Lives ($4.99)")
                return
            }
            
            currentButton = buy499Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .add100Lives:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.idLives100 }) else {
                print("Unable to find IAP: 100 Lives ($9.99)")
                return
            }
            
            currentButton = buy999Button
            IAPManager.shared.buyProduct(productToPurchase)
        }
        
        delegate?.purchaseDidTap()
    }
}


// MARK: - IAPManagerDelegate

extension PurchasePage: IAPManagerDelegate {
    func didCompletePurchase(transaction: SKPaymentTransaction) {
        completePurchaseOrRewarded()
    }
    
    func purchaseDidFail(transaction: SKPaymentTransaction) {
        failedPurchaseOrRewarded()
    }
    
    func isPurchasing(transaction: SKPaymentTransaction) {

    }
    
    ///To be used in IAPManagerDelegate and AdMobManagerDelegate, when purchase/reward is completed.
    private func completePurchaseOrRewarded() {
        isDisabled = false
        activityIndicator.removeFromParent()

        if let currentButton = currentButton {
            delegate?.purchaseCompleted(currentButton)
        }
        
        //I hate how this is needed, otherwise button won't touch up after purchase is made
        touchUp()
    }
    
    ///To be used in IAPManagerDelegate and AdMobManagerDelegate, when purchase/reward has failed.
    private func failedPurchaseOrRewarded() {
        isDisabled = false
        activityIndicator.removeFromParent()
        
        delegate?.purchaseFailed()
        
        //I hate how this is needed, otherwise button won't touch up after purchase is made
        touchUp()
    }
}


// MARK: - AdMobManagerDelegate

extension PurchasePage: AdMobManagerDelegate {
    
    // MARK: - Interstitial Ads
    
    func willPresentInterstitial() {
        //No implementation
    }
    
    func didDismissInterstitial() {
        //No implementation
    }
    
    func interstitialFailed() {
        //No implementation
    }
    
    
    // MARK: - Rewarded Ads
    
    func willPresentRewarded() {
        AudioManager.shared.lowerVolume(for: ThemeManager.getCurrentThemeAudio(sound: .overworld), fadeDuration: 1.0)
    }
    
    func didDismissRewarded() {
        completePurchaseOrRewarded()

        AudioManager.shared.raiseVolume(for: ThemeManager.getCurrentThemeAudio(sound: .overworld), fadeDuration: 1.0)
    }
    
    func rewardedFailed() {
        failedPurchaseOrRewarded()
    }
    
}
