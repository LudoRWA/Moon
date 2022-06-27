//
//  AssetsViewModel+Online.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation

extension AssetsViewModel {
    
    func getOnlineData(completion: @escaping ([AssetRaw]) -> ()) {
        
		let assets = self.assets
        var newAssets = [AssetRaw]()
        
        DispatchQueue.global(qos: .userInitiated).async {
			
            let semaphore = DispatchSemaphore(value: 0)
            
            for wallet in self.wallets {
                
                if (self.shouldStopSync) { break }
                
				self.getAssets(assets, newAssets, nil, wallet) {  [weak self] result in
					switch result {
					case .success(let updatedAssets):
						
						newAssets = updatedAssets
					case .failure(let error):
						
						self?.shouldStopSync = true
						self?.showErrorMessage?(error.rawValue.localized)
					}
			
                    semaphore.signal()
                }
                
                semaphore.wait()
            }
            
            self.assetHeaderViewModel.progress = 0.15
            
            self.getValues(newAssets) { updatedAssets in
                
                completion(updatedAssets)
            }
        }
    }
    
    func getAssets(_ assets: [AssetRaw], _ newAssets: [AssetRaw], _ cursor: String?, _ wallet: WalletRaw, completion: @escaping (Result<[AssetRaw], OpenSeaError>) -> ()) {
        
        var newAssets = newAssets
        
        openSeaService.getAssets(50, wallet.address ?? "", cursor) { [weak self] result in

			switch result {
			case .success(let value):
				
				value.assets.forEach {
					
					let id = $0.id
					let tokenId = $0.tokenId
					let nftImageURL = $0.imageUrl
					var nftName = $0.name
					let nftPermalink = $0.permalink
					let collectionSlug = $0.collection.slug
					let collectionName = $0.collection.name
					let collectionDescription = $0.collection.description
					let collectionImageURL = $0.collection.imageUrl
					
					if (nftName == nil) { nftName = "#\(tokenId ?? "Label.Unknown".localized)" }
					let foundAsset = assets.filter({ $0.id == id }).first?.reference
					
					let asset = AssetRaw(reference: foundAsset,
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
					
					newAssets.append(asset)
				}
				
				let nextCursor = value.next
				let maxReached = nextCursor == nil
				
				if (maxReached) {
					
					completion(.success(newAssets))
				} else {
					
					self?.getAssets(assets, newAssets, nextCursor, wallet) { result  in
						switch result {
						case .success(let updatedAssets):
							
							completion(.success(updatedAssets))
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
    
    func getValues(_ assets: [AssetRaw], completionHandler: @escaping ([AssetRaw]) -> ()) {
        
		var assets = assets
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            for (i, dict) in assets.enumerated() {
                
                if (self.shouldStopSync) { break }
                
                self.assetHeaderViewModel.progress = Float(0.15) + (Float(0.85) / Float(assets.count) * Float(i))
                
                var usedCollections = [Asset]()
                
                if let collectionSlug = dict.collectionSlug {
                    
                    if let currentCollection = usedCollections.filter({$0.collectionSlug == collectionSlug}).first {
                        
						assets[i].floorPrice = currentCollection.floorPrice
						assets[i].averagePrice = currentCollection.floorPrice
                        
                        semaphore.signal()
                    } else {
						self.openSeaService.getCollection(collectionSlug) { result in
						
							switch result {
							case .success(let value):
								
								let roundedFloor = round(100 * (Double(value.collection.stats.floorPrice ?? 0.0))) / 100
								let roundedAverage = round(100 * Double(value.collection.stats.averagePrice ?? 0.0)) / 100
								
								assets[i].floorPrice = roundedFloor
								assets[i].averagePrice = roundedAverage
								
								let collection = Asset(collectionSlug: collectionSlug,
														  collectionName: "",
														  collectionImageURL: "",
														  collectionDescription: "",
														  floorPrice: roundedFloor,
														  averagePrice: roundedAverage)
								usedCollections.append(collection)
								
							case .failure(_):
								
								sleep(5)
							}
                           
                            semaphore.signal()
                        }
                    }
                }
                semaphore.wait()
            }
            
            completionHandler(assets)
        }
    }
}
