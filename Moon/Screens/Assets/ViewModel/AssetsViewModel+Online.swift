//
//  AssetsViewModel+Online.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation

extension AssetsViewModel {
    
    func getOnlineData(completion: @escaping ([AssetStorage]) -> ()) {
        
        let oldAssets = assets
        var currentAssets = [AssetStorage]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            for wallet in self.wallets {
                
                if (self.shouldStopSync) { break }
                
                self.getAssets(oldAssets, currentAssets, nil, wallet) {  [weak self] result in
					switch result {
					case .success(let updatedUserAssets):
						
						currentAssets = updatedUserAssets
					case .failure(let error):
						
						self?.shouldStopSync = true
						self?.showErrorMessage?(error.rawValue.localized)
					}
			
                    semaphore.signal()
                }
                
                semaphore.wait()
            }
            
            self.assetHeaderViewModel.progress = 0.15
            
            self.getPrice(currentAssets) { finalUserAssets in
                
                completion(finalUserAssets)
            }
        }
    }
    
    func getAssets(_ oldAssets: [AssetStorage], _ currentAssets: [AssetStorage], _ cursor: String?, _ wallet: WalletStorage, completion: @escaping (Result<[AssetStorage], OpenSeaError>) -> ()) {
        
        var currentUserAssets = currentAssets
        
        openSeaService.getAssets(50, wallet.address ?? "", cursor) { [weak self] result in
            
			switch result {
			case .success(let value):
				
				value.assets.forEach {
					
					let id = $0.id
					let tokenId = $0.token_id
					let nftImageURL = $0.image_url
					var nftName = $0.name
					let nftPermalink = $0.permalink
					let collectionSlug = $0.collection.slug
					let collectionName = $0.collection.name
					let collectionDescription = $0.collection.description
					let collectionImageURL = $0.collection.image_url
					
					if (nftName == nil) { nftName = "#\(tokenId ?? "Unknown")" }
					
					let foundAsset = oldAssets.filter({ $0.id == id }).first
					
					if let foundAsset = foundAsset {
						
						foundAsset.collectionName = collectionName
						foundAsset.collectionDescription = collectionDescription
						foundAsset.collectionImageURL = collectionImageURL
						foundAsset.nftName = nftName
						foundAsset.nftPermalink = nftPermalink
						foundAsset.nftImageURL = nftImageURL
						foundAsset.wallet = wallet
						
						currentUserAssets.append(foundAsset)
					} else {
						
						let newAsset = AssetStorage(context: CoreDataStack.sharedInstance.viewContext)
						
						newAsset.collectionSlug = collectionSlug
						newAsset.collectionName = collectionName
						newAsset.collectionDescription = collectionDescription
						newAsset.collectionImageURL = collectionImageURL
						
						newAsset.id = id
						newAsset.nftName = nftName
						newAsset.nftPermalink = nftPermalink
						newAsset.nftImageURL = nftImageURL
						newAsset.wallet = wallet
						
						currentUserAssets.append(newAsset)
					}
				}
				
				let nextCursor = value.next
				let maxReached = nextCursor == nil
				
				if (maxReached) {
					
					completion(.success(currentUserAssets))
				} else {
					
					self?.getAssets(oldAssets, currentUserAssets, nextCursor, wallet) { result  in
						switch result {
						case .success(let updatedUserAssets):
							
							completion(.success(updatedUserAssets))
						case .failure(_):
							
							completion(.failure(.error))
						}
					}
				}
				
			case .failure(let error):
				
				completion(.failure(error))
			}
        }
    }
    
    func getPrice(_ userAssets: [AssetStorage], completionHandler: @escaping ([AssetStorage]) -> ()) {
        
        let currentUserAssets = userAssets
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            for (i, dict) in currentUserAssets.enumerated() {
                
                if (self.shouldStopSync) { break }
                
                self.assetHeaderViewModel.progress = Float(0.15) + (Float(0.85) / Float(currentUserAssets.count) * Float(i))
                
                var usedSlugs = [Asset]()
                
                if let originalCollectionSlug = dict.collectionSlug {
                    
                    if let currentCollection = usedSlugs.filter({$0.collectionSlug == originalCollectionSlug}).first {
                        
                        currentUserAssets[i].floorPrice = currentCollection.floorPrice
                        currentUserAssets[i].averagePrice = currentCollection.floorPrice
                        
                        semaphore.signal()
                    } else {
						self.openSeaService.getCollection(originalCollectionSlug) { result in
							
							var roundedFloorPrice = 0.0
							var roundedAveragePrice = 0.0
							
							switch result {
							case .success(let value):
								
								roundedFloorPrice = round(100 * (Double(value.collection.stats.floor_price ?? 0.0))) / 100
								roundedAveragePrice = round(100 * Double(value.collection.stats.average_price ?? 0.0)) / 100
							case .failure(_):
								
								sleep(5)
							}
                            
                            currentUserAssets[i].floorPrice = roundedFloorPrice
                            currentUserAssets[i].averagePrice = roundedAveragePrice
                            
							let newCollection = Asset(collectionSlug: originalCollectionSlug,
													  floorPrice: roundedFloorPrice,
													  averagePrice: roundedAveragePrice)
                            usedSlugs.append(newCollection)
                            
                            semaphore.signal()
                        }
                    }
                }
                semaphore.wait()
            }
            
            completionHandler(currentUserAssets)
        }
    }
}
