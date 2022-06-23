//
//  TipCellViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 13/05/2022.
//

import StoreKit

struct TipCellViewModel: Equatable {
	static func == (lhs: TipCellViewModel, rhs: TipCellViewModel) -> Bool {
		return (lhs.price == rhs.price && lhs.IAPProduct == rhs.IAPProduct)
	}
	
	let price: String
	let IAPProduct: SKProduct
}
