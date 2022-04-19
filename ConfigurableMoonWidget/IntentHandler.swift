//
//  IntentHandler.swift
//  ConfigurableMoonWidget
//
//  Created by Ludovic ROULLIER on 14/01/2022.
//

import Intents
import CoreData

class IntentHandler: INExtension, SelectNFTIntentHandling {
    
    func provideNftOptionsCollection(for intent: SelectNFTIntent, with completion: @escaping (INObjectCollection<UserNFT>?, Error?) -> Void) {
        
        let coredataService = CoreDataService()
        coredataService.getAllAssets() { success, assets, error in
            
            let nfts: [UserNFT] = assets.map { asset in
                
                let nft = UserNFT(
                    identifier: String(asset.id),
                    display: "\(asset.nft_name ?? "Unknown") - \(asset.collection_name ?? "Unknown")"
                )
                
                nft.nft_name = asset.nft_name
                nft.nft_image = asset.nft_image
                nft.collection_slug = asset.collection_slug
                return nft
            }
            
            completion(INObjectCollection(items: nfts), nil)
        }
    }
}
