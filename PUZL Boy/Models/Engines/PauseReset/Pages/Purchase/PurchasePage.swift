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
    private var buy199Button: PurchaseTapButton!
    private var buy299Button: PurchaseTapButton!
    private var buy499Button: PurchaseTapButton!
    private var buy999Button: PurchaseTapButton!
    private(set) var currentButton: PurchaseTapButton?
    
    weak var delegate: PurchasePageDelegate?
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize) {
        super.init(contentSize: contentSize, titleText: "Purchase")

        self.nodeName = "purchasePage"
        self.contentSize = contentSize
        name = nodeName
        
        IAPManager.shared.delegate = self //1. need this here to initialize
        
        let topMargin: CGFloat = UIDevice.isiPad ? 280 : 200
        let paddingFactor: CGFloat = UIDevice.isiPad ? 2 : 1
        let buttonSize: CGSize = PurchaseTapButton.buttonSize

        //Left column
        buy099Button = PurchaseTapButton(price: 0.99, text: "Add 5 Moves", image: "iconBoot", imageScale: UIDevice.isiPad ? 3 : 1.5)
        buy099Button.position = CGPoint(x: PurchasePage.padding, y: -topMargin)
        buy099Button.zPosition = 10
        buy099Button.delegate = self
                
        buy299Button = PurchaseTapButton(price: 2.99, text: "Skip Level", image: "enemy", imageScale: UIDevice.isiPad ? 1 : 0.75)
        buy299Button.position = CGPoint(x: PurchasePage.padding, y: buy099Button.position.y - buttonSize.height - paddingFactor * PurchasePage.padding)
        buy299Button.zPosition = 10
        buy299Button.delegate = self

        buy999Button = PurchaseTapButton(price: 9.99, text: "100 Lives", image: "iconPlayer", imageScale: UIDevice.isiPad ? 3 : 1.5)
        buy999Button.position = CGPoint(x: PurchasePage.padding, y: buy299Button.position.y - buttonSize.height - paddingFactor * PurchasePage.padding)
        buy999Button.zPosition = 10
        buy999Button.delegate = self

        //Right column
        buy199Button = PurchaseTapButton(price: 1.99, text: "10 Hints", image: "iconPlayer", imageScale: UIDevice.isiPad ? 3 : 1.5)
        buy199Button.position = CGPoint(x: buy099Button.position.x + PurchaseTapButton.buttonSize.width + PurchasePage.padding, y: -topMargin)
        buy199Button.zPosition = 10
        buy199Button.delegate = self

        buy499Button = PurchaseTapButton(price: 4.99, text: "25 Lives", image: "iconPlayer", imageScale: UIDevice.isiPad ? 3 : 1.5)
        buy499Button.position = CGPoint(x: buy099Button.position.x + buttonSize.width + PurchasePage.padding,
                                        y: buy199Button.position.y - buttonSize.height - paddingFactor * PurchasePage.padding)
        buy499Button.zPosition = 10
        buy499Button.delegate = self

        addChild(contentNode)
        contentNode.addChild(super.titleLabel)
        contentNode.addChild(buy099Button)
        contentNode.addChild(buy299Button)
        contentNode.addChild(buy999Button)
        contentNode.addChild(buy199Button)
        contentNode.addChild(buy499Button)
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

        buy099Button.touchDown(in: location)
        buy299Button.touchDown(in: location)
        buy999Button.touchDown(in: location)
        buy199Button.touchDown(in: location)
        buy499Button.touchDown(in: location)
    }
    
    override func touchUp(for touches: Set<UITouch>) {
        guard !isDisabled else { return }

        buy099Button.touchUp()
        buy299Button.touchUp()
        buy999Button.touchUp()
        buy199Button.touchUp()
        buy499Button.touchUp()
    }
    
    override func touchNode(for touches: Set<UITouch>) {
        super.touchNode(for: touches)
        
        guard !isDisabled else { return }
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        buy099Button.tapButton(in: location)
        buy299Button.tapButton(in: location)
        buy999Button.tapButton(in: location)
        buy199Button.tapButton(in: location)
        buy499Button.tapButton(in: location)
    }
}


// MARK: - PurchaseTapButtonDelegate

extension PurchasePage: PurchaseTapButtonDelegate {
    func didTapButton(_ buttonNode: PurchaseTapButton) {
        isDisabled = true

        activityIndicator = ActivityIndicatorSprite()
        activityIndicator.move(toParent: contentNode)

        IAPManager.shared.delegate = self //2. need this here as well, to re-assign delegate to PurchasePage

        switch buttonNode {
        case let buttonNode where buttonNode == buy099Button:
            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.moves5 }) else {
                print("Unable to find IAP: 5 Moves ($0.99)")
                return
            }
            
            currentButton = buy099Button
            IAPManager.shared.buyProduct(productToPurchase)
        case let buttonNode where buttonNode == buy299Button:
            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.skipLevel }) else {
                print("Unable to find IAP: Skip Level ($1.99)")
                return
            }
            
            currentButton = buy299Button
            IAPManager.shared.buyProduct(productToPurchase)
        case let buttonNode where buttonNode == buy999Button:
            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives100 }) else {
                print("Unable to find IAP: 100 Lives ($9.99)")
                return
            }
            
            currentButton = buy999Button
            IAPManager.shared.buyProduct(productToPurchase)
        case let buttonNode where buttonNode == buy199Button:
            //TODO: - 10 Hints???
            currentButton = buy199Button
            isDisabled = false
            activityIndicator.removeFromParent()
            touchUp(for: [])
        case let buttonNode where buttonNode == buy499Button:
            guard let productToPurchase = IAPManager.shared.allProducts.first(where: { $0.productIdentifier == IAPManager.lives25 }) else {
                print("Unable to find IAP: 25 Lives ($4.99)")
                return
            }
            
            currentButton = buy499Button
            IAPManager.shared.buyProduct(productToPurchase)
        default:
            print("Unknown button tapped.")
        }
        
        delegate?.purchaseDidTap()
    }
}


// MARK: - IAPManagerDelegate

extension PurchasePage: IAPManagerDelegate {
    func didCompletePurchase(transaction: SKPaymentTransaction) {
        isDisabled = false
        activityIndicator.removeFromParent()

        if let currentButton = currentButton {
            delegate?.purchaseCompleted(currentButton)
        }
        
        //FIXME: - I hate how this is needed, otherwise button won't touch up after purchase is made
        touchUp(for: [])
    }
    
    func purchaseDidFail(transaction: SKPaymentTransaction) {
        isDisabled = false
        activityIndicator.removeFromParent()
        
        delegate?.purchaseFailed()
        
        //FIXME: - I hate how this is needed, otherwise button won't touch up after purchase is made
        touchUp(for: [])
    }
    
    func isPurchasing(transaction: SKPaymentTransaction) {
        //TODO: - No implementation needed??
    }
    
}
