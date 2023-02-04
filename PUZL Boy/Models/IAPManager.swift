//
//  IAPManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/2/23.
//

import StoreKit

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}

protocol IAPManagerDelegate: AnyObject {
    func didCompletePurchase(transaction: SKPaymentTransaction)
    func purchaseDidFail(transaction: SKPaymentTransaction)
    func isPurchasing(transaction: SKPaymentTransaction)
}

class IAPManager: NSObject {
    
    // MARK: - Properties
        
    static let shared: IAPManager = {
        let iapManager = IAPManager(productIds: ["com.5playapps.PUZLBoy.25Lives"])
        
        //Additional setup
        
        return iapManager
    }()

    typealias ProductIdentifier = String
    typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productRequests: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    weak var delegate: IAPManagerDelegate?
    
    
    // MARK: - Initialization
    
    init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        
        for productIdentifier in productIdentifiers {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        
        super.init()
        
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
    
    func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}


// MARK: - SKProductsRequestDelegate

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for product in products {
            print("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    func clearRequestAndHandler() {
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
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred:
                break
            case .purchasing:
                delegate?.isPurchasing(transaction: transaction)
            default:
                break
            }
        }
        
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("Purchase Complete")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        
        delegate?.didCompletePurchase(transaction: transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("Purchase Restored \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("Purchase Failed")
        
        if let transactionError = transaction.error as NSError?, let localizedDescription = transaction.error?.localizedDescription, transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        
        delegate?.purchaseDidFail(transaction: transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        
        //This cool little notifiation is so that when things change, you can have it update the tableView, for instance.
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
}
