//
//  CoreDataServiceProtocol.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import FirebaseCrashlytics
import CoreData

protocol CoreDataServiceProtocol {
	func getAssetsFrom(wallets: [WalletRaw], completion: @escaping (_ result: [AssetRaw]) -> ())
    func getAllAssets(completion: @escaping (_ result: [AssetRaw]) -> ())
	
	func getWallets(completion: @escaping (_ result: [WalletRaw]) -> ())
}

class CoreDataService: CoreDataServiceProtocol {
	
	//MARK: - Assets
    func getAssetsFrom(wallets: [WalletRaw], completion: @escaping ([AssetRaw]) -> ()) {
		let walletsObjectID = wallets.map{ $0.reference }

		var assets = [AssetRaw]()
        do {
            
            let fetchRequest: NSFetchRequest<AssetMO> = AssetMO.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "ANY wallet IN %@", walletsObjectID)
			let assetsMO = try CoreDataStack.sharedInstance.viewContext.fetch(fetchRequest) as [AssetMO]
			
			for asset in assetsMO {
				
				let wallet = WalletRaw(reference: asset.wallet?.objectID, address: asset.wallet?.address)
				let asset = AssetRaw(reference: asset.objectID,
										id: asset.id,
										collectionSlug: asset.collectionSlug,
										collectionName: asset.collectionName,
										collectionDescription: asset.collectionDescription,
										collectionImageURL: asset.collectionImageURL,
										floorPrice: asset.floorPrice,
										averagePrice: asset.averagePrice,
										nftName: asset.nftName,
										nftPermalink: asset.nftPermalink,
										nftImageURL: asset.nftImageURL,
										wallet: wallet)
				
				assets.append(asset)
			}
        } catch {
            
            Crashlytics.crashlytics().record(error: error)
            debugPrint("Error retrieving assets from Core Data : \(error)")
        }
		
		completion(assets)
    }
    
    func getAllAssets(completion: @escaping ([AssetRaw]) -> ()) {
        
		var assets = [AssetRaw]()
        do {
            
            let fetchRequest: NSFetchRequest<AssetMO> = AssetMO.fetchRequest()
            let assetsMO = try CoreDataStack.sharedInstance.viewContext.fetch(fetchRequest) as [AssetMO]
			
			for asset in assetsMO {
				
				let wallet = WalletRaw(reference: asset.wallet?.objectID, address: asset.wallet?.address)
				let asset = AssetRaw(reference: asset.objectID,
										id: asset.id,
										collectionSlug: asset.collectionSlug,
										collectionName: asset.collectionName,
										collectionDescription: asset.collectionDescription,
										collectionImageURL: asset.collectionImageURL,
										floorPrice: asset.floorPrice,
										averagePrice: asset.averagePrice,
										nftName: asset.nftName,
										nftPermalink: asset.nftPermalink,
										nftImageURL: asset.nftImageURL,
										wallet: wallet)
				
				assets.append(asset)
			}
        } catch {
            
            Crashlytics.crashlytics().record(error: error)
            debugPrint("Error retrieving assets from Core Data : \(error)")
        }
		
		completion(assets)
    }
	
	//MARK: - Wallets
	func getWallets(completion: @escaping ([WalletRaw]) -> ()) {
		
		var wallets = [WalletRaw]()
		do {
			
			let request: NSFetchRequest<WalletMO> = WalletMO.fetchRequest()
			let walletsMO = try CoreDataStack.sharedInstance.viewContext.fetch(request)
			
			for wallet in walletsMO {
				if let address = wallet.address {
					
					let wallet = WalletRaw(reference: wallet.objectID, address: address)
					wallets.append(wallet)
				}
			}
		} catch {
			
			Crashlytics.crashlytics().record(error: error)
			debugPrint("Error retrieving wallets from Core Data : \(error)")
		}
		
		completion(wallets)
	}
}
