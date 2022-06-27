//
//  AssetsViewModel+Amount.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation

extension AssetsViewModel {
    
    func getTotalAmounts(_ assets: [AssetRaw]) {
        
		let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF"]
		
        let totalFloor = Double(round(100 * assets.map({$0.floorPrice}).reduce(0, +)) / 100)
        let totalAverage = Double(round(100 * assets.map({$0.averagePrice}).reduce(0, +)) / 100)
        
        totalAmount.floor.eth = "Ξ \(String(totalFloor))"
        totalAmount.average.eth = "Ξ \(String(totalAverage))"
        
        let currency = availableCurrencies.first(where: {$0 == Locale.current.currencyCode}) ?? "USD"
        
        coinbaseService.getFiatPrice(currency) { [weak self] result in
			guard let self = self else { return } 
			if case .success(let value) = result {
				
				let fiatPrice = Double(value.data.amount ?? "0.0") ?? 0.0
				
				self.totalAmount.floor.fiat = self.convertToFiat(totalFloor * fiatPrice, currency)
				self.totalAmount.average.fiat = self.convertToFiat(totalAverage * fiatPrice, currency)
			}
        }
    }
    
    func convertToFiat(_ amount : Double, _ currency: String) -> String {
        let localeSymbol = Locale
            .availableIdentifiers
            .lazy
            .map { Locale(identifier: $0) }
            .first { $0.currencyCode == currency }
        
        if let locale = localeSymbol {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = locale
            return formatter.string(from: NSNumber(value: amount))?.replacingOccurrences(of: "\u{00a0}", with: "") ?? String(amount)
        }
        
        return String(amount)
    }
}
