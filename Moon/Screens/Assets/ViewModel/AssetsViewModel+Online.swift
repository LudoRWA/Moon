//
//  AssetsViewModel+Online.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation

extension AssetsViewModel {
    
    func getOnlineData(completion: @escaping ([AssetRaw]) -> ()) {
        
        let oldAssets = assets
        var currentAssets = [AssetRaw]()
        
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
    
    func getAssets(_ oldAssets: [AssetRaw], _ currentAssets: [AssetRaw], _ cursor: String?, _ wallet: WalletRaw, completion: @escaping (Result<[AssetRaw], OpenSeaError>) -> ()) {
        
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
					let foundAsset = oldAssets.filter({ $0.id == id }).first?.reference
					
					let newAsset = AssetRaw(reference: foundAsset,
											id: id,
											collectionSlug: collectionSlug,
											collectionName: collectionName,
											collectionDescription: collectionDescription,
											collectionImageURL: collectionImageURL,
											floorPrice: 0.0,
											averagePrice: 0.0,
											nftName: nftName,
											nftPermalink: nftPermalink,
											nftImageURL: nftImageURL,
											wallet: wallet)
					
					currentUserAssets.append(newAsset)
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
    
    func getPrice(_ userAssets: [AssetRaw], completionHandler: @escaping ([AssetRaw]) -> ()) {
        
		var currentUserAssets = userAssets
        
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
						
							switch result {
							case .success(let value):
								
								let roundedFloorPrice = round(100 * (Double(value.collection.stats.floor_price ?? 0.0))) / 100
								let roundedAveragePrice = round(100 * Double(value.collection.stats.average_price ?? 0.0)) / 100
								
								currentUserAssets[i].floorPrice = roundedFloorPrice
								currentUserAssets[i].averagePrice = roundedAveragePrice
								
								let newCollection = Asset(collectionSlug: originalCollectionSlug,
														  floorPrice: roundedFloorPrice,
														  averagePrice: roundedAveragePrice)
								usedSlugs.append(newCollection)
								
							case .failure(_):
								
								sleep(5)
							}
                           
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
