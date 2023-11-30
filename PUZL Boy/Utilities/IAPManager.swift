//
//  IAPManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/2/23.
//

import StoreKit

protocol IAPManagerDelegate: AnyObject {
    func didCompletePurchase(transaction: SKPaymentTransaction)
    func purchaseDidFail(transaction: SKPaymentTransaction)
    func isPurchasing(transaction: SKPaymentTransaction)
}

class IAPManager: NSObject {
    
    // MARK: - Properties
    
    //Appstore Connect ID's
    static let idMoves5 = "com.5playapps.PUZLBoy.5Moves"
    static let idHints10 = "com.5playapps.PUZLBoy.10Hints"
    static let idSkipLevel = "com.5playapps.PUZLBoy.SkipLevel"
    static let idLives25 = "com.5playapps.PUZLBoy.25Lives"
    static let idLives100 = "com.5playapps.PUZLBoy.100Lives"
    
    //Reward Amounts
    static let rewardAmountLivesAd = 1
    static let rewardAmountMovesBuy5 = 5
    static let rewardAmountHintsBuy10 = 10
    static let rewardAmountLivesBuy25 = 25
    static let rewardAmountLivesBuy100 = 100
        
    static let shared: IAPManager = {
        let iapManager = IAPManager(productIds: [
            IAPManager.idMoves5,
            IAPManager.idHints10,
            IAPManager.idSkipLevel,
            IAPManager.idLives25,
            IAPManager.idLives100
        ])
        
        //Additional setup
        iapManager.requestProducts { success, products in
            //Do nothing here, just needed to populate allProducts!
        }
        
        return iapManager
    }()

    typealias ProductIdentifier = String
    typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

    private let productIdentifiers: Set<ProductIdentifier>
    private var productRequests: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    var allProducts: [SKProduct] = []
    
    weak var delegate: IAPManagerDelegate?
    
    
    // MARK: - Initialization
    
    init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
                
        super.init()
        
        //Starts the payment queue process
        SKPaymentQueue.default().add(self)
    }
}


// MARK: - StoreKit API

extension IAPManager {
    func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productRequests?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productRequests = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequests!.delegate = self
        productRequests!.start()
    }
    
    func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}


// MARK: - SKProductsRequestDelegate

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for product in products {
//            print("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
            allProducts.append(product)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products. Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productRequests = nil
        productsRequestCompletionHandler = nil
    }
}


// MARK: - SKPaymentTransactionObserver

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                purchased(transaction: transaction)
            case .failed:
                failed(transaction: transaction)
            case .purchasing:
                delegate?.isPurchasing(transaction: transaction)
            case .deferred:
                break
            case .restored:
                break
            default:
                break
            }
        }
        
    }
    
    private func purchased(transaction: SKPaymentTransaction) {
        print("Purchase Complete")
        SKPaymentQueue.default().finishTransaction(transaction)
        
        delegate?.didCompletePurchase(transaction: transaction)
        
        //Update Game Center Achievements!!!
        if let purchasedProduct = allProducts.first(where: { $0.productIdentifier == transaction.payment.productIdentifier }) {
            GameCenterManager.shared.updateProgress(achievement: .bigSpender,
                                                    increment: purchasedProduct.price.doubleValue,
                                                    shouldReportImmediately: true)

            GameCenterManager.shared.updateProgress(achievement: .endlessWallet,
                                                    increment: purchasedProduct.price.doubleValue,
                                                    shouldReportImmediately: true)
            
            GameCenterManager.shared.updateProgress(achievement: .fatCat,
                                                    increment: purchasedProduct.price.doubleValue,
                                                    shouldReportImmediately: true)
        }
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        print("Purchase Failed")
        
        if let transactionError = transaction.error as NSError?, let localizedDescription = transaction.error?.localizedDescription, transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        
        delegate?.purchaseDidFail(transaction: transaction)
    }
}
