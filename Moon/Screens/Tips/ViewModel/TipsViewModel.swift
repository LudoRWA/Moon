//
//  TipsViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 12/05/2022.
//

import Foundation
import StoreKit

class TipsViewModel: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	var updateCellsCollectionView: (() -> Void)?
	var transaction: ((Result<Bool, TransactionError>) -> Void)?

	let productIdentifiers: Set = ["smallTip", "bigTip"]
	
	var tipCellViewModels = [TipCellViewModel]() {
		didSet {
			updateCellsCollectionView?()
		}
	}
	
	// MARK: - FETCH PRODUCT
	func fetchAvailableProducts()  {
		
		let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
		productsRequest.delegate = self
		productsRequest.start()
	}
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		if (!response.products.isEmpty) {
			var newCells = [TipCellViewModel]()
			for product in response.products {
				newCells.append(TipCellViewModel(price: product.localizedPrice ?? product.price.stringValue, IAPProduct: product))
			}
			newCells.sort{ $0.price < $1.price }
			tipCellViewModels = newCells
		}
	}
	
	// MARK: - MAKE PURCHASE
	func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
	func purchaseProduct(_ product: SKProduct) {
		if canMakePurchases() {
			
			let payment = SKPayment(product: product)
			SKPaymentQueue.default().add(self)
			SKPaymentQueue.default().add(payment)
		} else {
			
			transaction?(.failure(.disabled))
		}
	}
	
	// MARK: - IAP PAYMENT QUEUE
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .purchased:
				SKPaymentQueue.default().finishTransaction(transaction)
				self.transaction?(.success(true))
				break
			case .failed:
				SKPaymentQueue.default().finishTransaction(transaction)
				break
			default: break
			}
		}
	}
	
	func getCellViewModel(at indexPath: IndexPath) -> TipCellViewModel? {
		return tipCellViewModels[safeIndex: indexPath.row]
	}
}
