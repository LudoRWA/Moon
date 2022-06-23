//
//  AssetsViewModel+Amount.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation

extension AssetsViewModel {
    
    func getTotalAmounts(_ currentAssets: [AssetRaw]) {
        
		let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF"]
		
        let totalAmountFloor = Double(round(100 * currentAssets.map({$0.floorPrice}).reduce(0, +)) / 100)
        let totalAmountAverage = Double(round(100 * currentAssets.map({$0.averagePrice}).reduce(0, +)) / 100)
        
        totalAmount.floor.eth = "Ξ \(String(totalAmountFloor))"
        totalAmount.average.eth = "Ξ \(String(totalAmountAverage))"
        
        let currency = availableCurrencies.first(where: {$0 == Locale.current.currencyCode}) ?? "USD"
        
        coinbaseService.getFiatPrice(currency) { [weak self] result in
			guard let self = self else { return } 
			if case .success(let value) = result {
				
				let fiatPrice = Double(value.data.amount ?? "0.0") ?? 0.0
				let totalFloorPrice = totalAmountFloor * fiatPrice
				let totalAveragePrice = totalAmountAverage * fiatPrice
				
				self.totalAmount.floor.fiat = self.convertToFiat(totalFloorPrice, currency)
				self.totalAmount.average.fiat = self.convertToFiat(totalAveragePrice, currency)
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
