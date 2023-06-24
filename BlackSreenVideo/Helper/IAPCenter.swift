//
//  IAPCenter.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/12/2.
//

import Foundation
import StoreKit



class IAPCenter: NSObject {
    
    static let shared = IAPCenter()
    
    var products = [SKProduct]()
    
    var productRequest: SKProductsRequest?
    
    var requestComplete: (([String])->())?
    
    var storeComplete: (()->())?
    
    var buyTypes: [CodeModel] = []
    
    func getProducts() {
        //TODO: 透過後台把type變成活動的
        APIService.shared.requestWithParam(urlText: .TinaDJTypeURL,
                                           param: [:],
                                           modelType: IAPModel.self) { jsonModel, error in

           
            self.buyTypes = jsonModel?.canBuyType ?? []
             
            let productIds = self.buyTypes.map { $0.id }
            
            let productIdsSet = Set(productIds)
            self.productRequest = SKProductsRequest(productIdentifiers: productIdsSet)
            self.productRequest?.delegate = self
            self.productRequest?.start()
        }
    }
    
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
}
extension IAPCenter: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("產品列表")
        if response.products.count != 0 {
            response.products.forEach {
                print($0.localizedTitle, $0.price, $0.localizedDescription)
            }
            self.products = response.products
            requestComplete?([])
        } else {
            self.products = response.products
            requestComplete?(response.invalidProductIdentifiers)
            print(response.invalidProductIdentifiers)
            print(response.description)
            print(response.debugDescription)
        }

       
        
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
        
        for transaction in transactions {
            print(transaction.payment.productIdentifier, transaction.transactionState.rawValue)
            switch transaction.transactionState {
            case .purchased:
              SKPaymentQueue.default().finishTransaction(transaction)
                
                if let first = self.buyTypes.first(where:{transaction.payment.productIdentifier == $0.id}) {
                    RecordingTimeCenter.shard.appenTime(first.number)
                }
                
            case .failed:
                print(transaction.error ?? "")
              SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
              SKPaymentQueue.default().finishTransaction(transaction)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }

    }
    
}
