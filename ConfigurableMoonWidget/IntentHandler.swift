//
//  IntentHandler.swift
//  ConfigurableMoonWidget
//
//  Created by Ludovic ROULLIER on 14/01/2022.
//

import Intents

class IntentHandler: INExtension, SelectNFTIntentHandling {
    
    func provideNftOptionsCollection(for intent: SelectNFTIntent, with completion: @escaping (INObjectCollection<UserNFT>?, Error?) -> Void) {
        
        let coredataService = CoreDataService()
        coredataService.getAllAssets() { assets in

			let nfts: [UserNFT] = assets.map { asset in
					
				let nft = UserNFT(
					identifier: String(asset.id),
					display: "\(asset.nftName ?? "Label.Unknown".localized) - \(asset.collectionName ?? "Label.Unknown".localized)"
				)
					
				nft.nftName = asset.nftName
				nft.nftImageURL = asset.nftImageURL
				nft.collectionSlug = asset.collectionSlug
				return nft
			}
				
			completion(INObjectCollection(items: nfts), nil)
        }
    }
}
