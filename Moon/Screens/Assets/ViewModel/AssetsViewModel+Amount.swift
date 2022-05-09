//
//  AssetsViewModel+Amount.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation

extension AssetsViewModel {
    
    func getTotalAmounts(_ currentAssets: [AssetRaw]) {
        
        var totalAmountFloor = 0.0
        var totalAmountAverage = 0.0
        
        currentAssets.forEach {
            totalAmountFloor += ($0.floorPrice)
            totalAmountAverage += ($0.averagePrice)
        }
        
        totalAmountFloor = Double(round(100 * totalAmountFloor) / 100)
        totalAmountAverage = Double(round(100 * totalAmountAverage) / 100)
        
        totalAmount.floor.eth = "Ξ \(String(totalAmountFloor))"
        totalAmount.average.eth = "Ξ \(String(totalAmountAverage))"
        
        let currentCurrency = availableCurrencies.first(where: {$0 == Locale.current.currencyCode}) ?? "USD"
        
        coinbaseService.getFiatPrice(currentCurrency) { [weak self] result in
			guard let self = self else { return } 
			if case .success(let value) = result {
				
				let fiatPrice = Double(value.data.amount ?? "0.0") ?? 0.0
				let totalFloorPrice = totalAmountFloor * fiatPrice
				let totalAveragePrice = totalAmountAverage * fiatPrice
				
				self.totalAmount.floor.fiat = self.convertToFiat(totalFloorPrice, currentCurrency)
				self.totalAmount.average.fiat = self.convertToFiat(totalAveragePrice, currentCurrency)
			}
        }
    }
    
    func convertToFiat(_ amount : Double, _ currentCurrency: String) -> String {
        let localeSymbol = Locale
            .availableIdentifiers
            .lazy
            .map { Locale(identifier: $0) }
            .first { $0.currencyCode == currentCurrency }
        
        if let locale = localeSymbol {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = locale
            return formatter.string(from: NSNumber(value: amount))?.replacingOccurrences(of: "\u{00a0}", with: "") ?? String(amount)
        }
        
        return String(amount)
    }
}
