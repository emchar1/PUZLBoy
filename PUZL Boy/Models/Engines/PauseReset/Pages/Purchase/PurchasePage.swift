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
    
    private var activityIndicator: ActivityIndicatorSprite!
    private var isDisabled = false
    
    private var buy099Button: PurchaseTapButton!
    private var watchAdButton: PurchaseTapButton!
    private var buy299Button: PurchaseTapButton!
    private var buy499Button: PurchaseTapButton!
    private var buy999Button: PurchaseTapButton!
    private var buy1999Button: PurchaseTapButton!
    private(set) var currentButton: PurchaseTapButton?
    
    weak var delegate: PurchasePageDelegate?
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize) {
        super.init(contentSize: contentSize, titleText: "Shop")

        self.nodeName = "purchasePage"
        self.contentSize = contentSize
        name = nodeName
        
        IAPManager.shared.delegate = self //1. need this here to initialize
        
        let topMargin: CGFloat = UIDevice.isiPad ? 280 : 200
        let paddingFactor: CGFloat = UIDevice.isiPad ? 2 : 1
        let buttonSize: CGSize = PurchaseTapButton.buttonSize
        let imageScale: CGFloat = UIDevice.isiPad ? 2.0 : 1.25

        //Left column
        watchAdButton = PurchaseTapButton(price: 0,
                                          text: "+1 Life - ▶️ Ad",
                                          type: .add1Life,
                                          color: DecisionButtonSprite.colorBlue,
                                          image: "iconPlayer",
                                          imageScale: imageScale)
        watchAdButton.position = CGPoint(x: PurchasePage.padding, y: -topMargin)
        watchAdButton.zPosition = 10
        watchAdButton.delegate = self

        buy299Button = PurchaseTapButton(price: 2.99,
                                         text: "Skip Level",
                                         type: .skipLevel,
                                         color: DecisionButtonSprite.colorYellow,
                                         image: "iconPrincess",
                                         imageScale: imageScale)
        buy299Button.position = CGPoint(x: PurchasePage.padding, y: watchAdButton.position.y - buttonSize.height - paddingFactor * PurchasePage.padding)
        buy299Button.zPosition = 10
        buy299Button.delegate = self

        buy999Button = PurchaseTapButton(price: 9.99,
                                         text: "+100 Lives",
                                         type: .add100Lives,
                                         color: DecisionButtonSprite.colorGreen,
                                         image: "iconPlayer",
                                         imageScale: imageScale)
        buy999Button.position = CGPoint(x: PurchasePage.padding, y: buy299Button.position.y - buttonSize.height - paddingFactor * PurchasePage.padding)
        buy999Button.zPosition = 10
        buy999Button.delegate = self

        //Right column
        buy099Button = PurchaseTapButton(price: 0.99,
                                         text: "+5 Moves",
                                         type: .add5Moves,
                                         color: DecisionButtonSprite.colorBlue,
                                         image: "iconBoot",
                                         imageScale: imageScale)
        buy099Button.position = CGPoint(x: watchAdButton.position.x + PurchaseTapButton.buttonSize.width + PurchasePage.padding, y: -topMargin)
        buy099Button.zPosition = 10
        buy099Button.delegate = self
        
        buy499Button = PurchaseTapButton(price: 4.99,
                                         text: "+25 Lives",
                                         type: .add25Lives,
                                         color: DecisionButtonSprite.colorYellow,
                                         image: "iconPlayer",
                                         imageScale: imageScale)
        buy499Button.position = CGPoint(x: watchAdButton.position.x + buttonSize.width + PurchasePage.padding,
                                        y: buy099Button.position.y - buttonSize.height - paddingFactor * PurchasePage.padding)
        buy499Button.zPosition = 10
        buy499Button.delegate = self

        buy1999Button = PurchaseTapButton(price: 19.99,
                                          text: "+1,000 Lives",
                                          type: .add1000Lives,
                                          color: DecisionButtonSprite.colorGreen,
                                          image: "iconPlayer",
                                          imageScale: imageScale)
        buy1999Button.position = CGPoint(x: watchAdButton.position.x + PurchaseTapButton.buttonSize.width + PurchasePage.padding,
                                         y: buy499Button.position.y - buttonSize.height - paddingFactor * PurchasePage.padding)
        buy1999Button.zPosition = 10
        buy1999Button.delegate = self


        addChild(contentNode)
        contentNode.addChild(super.titleLabel)
        contentNode.addChild(watchAdButton)
        contentNode.addChild(buy099Button)
        contentNode.addChild(buy299Button)
        contentNode.addChild(buy499Button)
        contentNode.addChild(buy999Button)
        contentNode.addChild(buy1999Button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Touch Functions
    
    override func touchDown(for touches: Set<UITouch>) {
        super.touchDown(for: touches)
        
        guard !isDisabled else { return }
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }

        watchAdButton.touchDown(in: location)
        buy099Button.touchDown(in: location)
        buy299Button.touchDown(in: location)
        buy499Button.touchDown(in: location)
        buy999Button.touchDown(in: location)
        buy1999Button.touchDown(in: location)
    }
    
    override func touchUp(for touches: Set<UITouch>) {
        guard !isDisabled else { return }

        watchAdButton.touchUp()
        buy099Button.touchUp()
        buy299Button.touchUp()
        buy499Button.touchUp()
        buy999Button.touchUp()
        buy1999Button.touchUp()
    }
    
    override func touchNode(for touches: Set<UITouch>) {
        super.touchNode(for: touches)
        
        guard !isDisabled else { return }
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        watchAdButton.tapButton(in: location)
        buy099Button.tapButton(in: location)
        buy299Button.tapButton(in: location)
        buy499Button.tapButton(in: location)
        buy999Button.tapButton(in: location)
        buy1999Button.tapButton(in: location)
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

            AdMobManager.shared.presentRewarded { (adReward) in
                self.currentButton = self.watchAdButton

                print("You were rewarded: \(adReward.amount) lives!")
            }
        case .add5Moves:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.moves5 }) else {
                print("Unable to find IAP: 5 Moves ($0.99)")
                return
            }
            
            currentButton = buy099Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .skipLevel:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.skipLevel }) else {
                print("Unable to find IAP: Skip Level ($1.99)")
                return
            }
            
            currentButton = buy299Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .add25Lives:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives25 }) else {
                print("Unable to find IAP: 25 Lives ($4.99)")
                return
            }
            
            currentButton = buy499Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .add100Lives:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives100 }) else {
                print("Unable to find IAP: 100 Lives ($9.99)")
                return
            }
            
            currentButton = buy999Button
            IAPManager.shared.buyProduct(productToPurchase)
        case .add1000Lives:
            IAPManager.shared.delegate = self

            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives1000 }) else {
                print("Unable to find IAP: 1000 Lives ($19.99)")
                return
            }
            
            currentButton = buy1999Button
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
        touchUp(for: [])
    }
    
    ///To be used in IAPManagerDelegate and AdMobManagerDelegate, when purchase/reward has failed.
    private func failedPurchaseOrRewarded() {
        isDisabled = false
        activityIndicator.removeFromParent()
        
        delegate?.purchaseFailed()
        
        //I hate how this is needed, otherwise button won't touch up after purchase is made
        touchUp(for: [])
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
    
    
    // MARK: - Rewarded ads
    
    func willPresentRewarded() {
        AudioManager.shared.lowerVolume(for: AudioManager.shared.currentTheme, fadeDuration: 1.0)
    }
    
    func didDismissRewarded() {
        completePurchaseOrRewarded()

        AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme, fadeDuration: 1.0)
    }
    
    func rewardedFailed() {
        failedPurchaseOrRewarded()
    }
    
}
