//
//  OpenSeaServiceProtocol.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import Alamofire

protocol OpenSeaServiceProtocol {
    func getAssets(_ limit: Int, _ wallet: String, _ cursor: String?, completion: @escaping (_ result: Result<OpenseaAssets, OpenSeaError>) -> ())
    func getCollection(_ collectionSlug: String, completion: @escaping (_ result: Result<OpenseaCollection, OpenSeaError>) -> ())
}

class OpenSeaService: OpenSeaServiceProtocol {
    
    func getAssets(_ limit: Int, _ wallet: String, _ cursor: String?, completion: @escaping (Result<OpenseaAssets, OpenSeaError>) -> ()) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "X-API-KEY": "7c52a7933c7d4fcfb9e4df55a92f7b54"
        ]
        
        AF.request("https://api.opensea.io/api/v1/assets?owner=\(wallet)&limit=\(limit)&cursor=\(cursor ?? "")", headers: headers).responseDecodable(of: OpenseaAssets.self, queue: .global(qos: .userInitiated)) { response in
			
			if let result = response.value {
				
				completion(.success(result))
			} else {
				
				if (response.response?.statusCode == 400) {
					
					completion(.failure(.unknownWallet))
				} else {
					
					completion(.failure(.error))
				}
			}
        }
    }
    
    func getCollection(_ collectionSlug: String, completion: @escaping (Result<OpenseaCollection, OpenSeaError>) -> ()) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "X-API-KEY": "7c52a7933c7d4fcfb9e4df55a92f7b54"
        ]
        
        AF.request("https://api.opensea.io/api/v1/collection/\(collectionSlug)", headers: headers).responseDecodable(of: OpenseaCollection.self, queue: .global(qos: .userInitiated)) { response in

			if let result = response.value {
				
				completion(.success(result))
			} else {
				
				completion(.failure(.error))
			}
        }
    }
}
