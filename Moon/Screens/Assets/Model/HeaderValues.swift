//
//  HeaderValues.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

struct HeaderValues {
    var floor = CurrenciesAmountModel()
    var average = CurrenciesAmountModel()
	
	struct CurrenciesAmountModel {
		var eth = "Ξ ---"
		var fiat = "Label.Loading".localized
	}
}
