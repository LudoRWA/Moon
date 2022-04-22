//
//  CoinbaseServiceProtocol.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import Alamofire

protocol CoinbaseServiceProtocol {
    func getFiatPrice(_ currentCurrency: String, completion: @escaping (_ value: CoinbaseData?) -> ())
}

class CoinbaseService: CoinbaseServiceProtocol {
    
    func getFiatPrice(_ currentCurrency: String, completion: @escaping (CoinbaseData?) -> ()) {
        
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request("https://api.coinbase.com/v2/prices/ETH-\(currentCurrency)/spot", headers: headers).responseDecodable(of: CoinbaseData.self, queue: .global(qos: .userInitiated)) { response in
            
            completion(response.value)
        }
    }
}

