//
//  Amount.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import Foundation

struct AmountModel {
    var floor = CurrenciesAmountModel()
    var average = CurrenciesAmountModel()
}

struct CurrenciesAmountModel {
    var eth: String? = "Ξ ---"
    var fiat: String? = "Loading..."
}
