//
//  SKProduct+LocalizedPrice.swift
//  Moon
//
//  Created by Ludovic Roullier on 13/05/2022.
//

import StoreKit

extension SKProduct {
	
	var localizedPrice: String? {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = priceLocale
		return formatter.string(from: price)?.replacingOccurrences(of: "\u{00a0}", with: "")
	}
}
