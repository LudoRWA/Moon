//
//  CoinbaseServiceModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

struct CoinbaseData: Decodable {
    let data: CoinbaseDataAmount
}

struct CoinbaseDataAmount: Decodable {
    let amount : String?
}
