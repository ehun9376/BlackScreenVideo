//
//  IAPCenter.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/12/2.
//

import Foundation
import StoreKit

enum ProductID: String {
    case alwaysCanUse = "alwaysCanUse"
}

class IAPCenter: NSObject {
    
    static let shared = IAPCenter()
    
    var products = [SKProduct]()
    
    var productRequest: SKProductsRequest?
    
    var requestComplete: (()->())?
    
 
    
    //總共有多少購買項目
    func getProductIDs() -> [String] {
        
        return [
            ProductID.alwaysCanUse.rawValue
        ]
    }
    
    func getProducts() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        let productIds = getProductIDs()
        let productIdsSet = Set(productIds)
        productRequest = SKProductsRequest(productIdentifiers: productIdsSet)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    func buy(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    
}
extension IAPCenter: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("產品列表")
        response.products.forEach {
            print($0.localizedTitle, $0.price, $0.localizedDescription)
        }
        self.products = response.products
        requestComplete?()
    }
    
}

extension IAPCenter: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(error.localizedDescription)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        if let controller = window?.rootViewController as? BaseViewController {
            controller.showSingleAlert(title: "錯誤",
                                       message: error.localizedDescription,
                                       confirmTitle: "OK",
                                       confirmAction: nil)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        var iapedIDs = UserInfoCenter.shared.loadValue(.iaped) as? [String] ?? []

        transactions.forEach {

            print($0.payment.productIdentifier, $0.transactionState.rawValue)
            switch $0.transactionState {
            case .purchased:
              SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print($0.error ?? "")
                if ($0.error as? SKError)?.code != .paymentCancelled {
                    // show error
                }
              SKPaymentQueue.default().finishTransaction($0)
            case .restored:
              SKPaymentQueue.default().finishTransaction($0)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
            
            if $0.transactionState == .purchased ||  $0.transactionState == .restored {
                
                if !iapedIDs.contains($0.payment.productIdentifier) {
                    iapedIDs.append($0.payment.productIdentifier)
                }
                
            }
            
        }
        UserInfoCenter.shared.storeValue(.iaped, data: iapedIDs)
    }
    
}
