//
//  NSManagedObjectContext+Asset.swift
//  Moon
//
//  Created by Ludovic Roullier on 09/05/2022.
//

import CoreData

extension NSManagedObjectContext {
	
	func add(asset: AssetRaw, completion: ((NSManagedObjectID) -> ())?) {
		perform {
			
			if let wallet = self.object(with: asset.wallet.reference) as? WalletMO {
		
				let newAsset = AssetMO(context: self)
				
				newAsset.id = asset.id
				
				newAsset.collectionSlug = asset.collectionSlug
				newAsset.collectionName = asset.collectionName
				newAsset.collectionDescription = asset.collectionDescription
				newAsset.collectionImageURL = asset.collectionImageURL
				newAsset.floorPrice = asset.floorPrice
				newAsset.averagePrice = asset.averagePrice
				
				newAsset.nftName = asset.nftName
				newAsset.nftPermalink = asset.nftPermalink
				newAsset.nftImageURL = asset.nftImageURL
				newAsset.wallet = wallet
				
				self.save() { result in
					if case .success = result {
						completion?(newAsset.objectID)
					}
				}
			}
		}
	}
	
	func edit(asset: AssetRaw, completion: ((VoidResult) -> ())?) {
		guard asset.reference != nil else { return }
		perform {
			if let entity = self.object(with: asset.reference) as? AssetMO,
			   let wallet = self.object(with: asset.wallet.reference) as? WalletMO {
				
				entity.collectionName = asset.collectionName
				entity.collectionDescription = asset.collectionDescription
				entity.collectionImageURL = asset.collectionImageURL
				entity.floorPrice = asset.floorPrice
				entity.averagePrice = asset.averagePrice
				
				entity.nftName = asset.nftName
				entity.nftPermalink = asset.nftPermalink
				entity.nftImageURL = asset.nftImageURL
				
				entity.wallet = wallet
				
				self.save(completion: completion)
			}
		}
	}
	
	func delete(asset: AssetRaw, completion: ((VoidResult) -> ())?) {
		guard asset.reference != nil else { return }
		perform {
			if let entity = self.object(with: asset.reference) as? AssetMO {
				self.delete(entity)
				self.save(completion: completion)
			}
		}
	}
}
