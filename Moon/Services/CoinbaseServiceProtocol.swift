//
//  CoinbaseServiceProtocol.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import Alamofire

protocol CoinbaseServiceProtocol {
    func getFiatPrice(_ currentCurrency: String, completion: @escaping (_ result: Result<CoinbaseData, CoinbaseError>) -> ())
}

class CoinbaseService: CoinbaseServiceProtocol {
    
    func getFiatPrice(_ currentCurrency: String, completion: @escaping (Result<CoinbaseData, CoinbaseError>) -> ()) {
        
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request("https://api.coinbase.com/v2/prices/ETH-\(currentCurrency)/spot", headers: headers).responseDecodable(of: CoinbaseData.self, queue: .global(qos: .userInitiated)) { response in
            
			if let result = response.value {
				
				completion(.success(result))
			} else {
				
				completion(.failure(.error))
			}
        }
    }
}

