//
//  AssetsViewModel+Online.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation

extension AssetsViewModel {
    
    func getOnlineData(completion: @escaping ([AssetStorage]) -> ()) {
        
        let oldAssets = self.assets
        var currentAssets = [AssetStorage]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            for wallet in self.wallets {
                
                if (self.shouldStopSync) { break }
                
                self.getAssets(oldAssets, currentAssets, nil, wallet) { result in
					switch result {
					case .success(let updatedUserAssets):
						
						currentAssets = updatedUserAssets
					case .failure(let error):
						
                        self.shouldStopSync = true
						self.showErrorMessage?(error.rawValue)
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
        
        self.openSeaService.getAssets(50, wallet.address ?? "", cursor) { value, _ in
            
            if let value = value {
                
                value.assets.forEach {
                    
                    let id = $0.id
                    let token_id = $0.token_id
                    let nftImage = $0.image_url
                    var nftName = $0.name
                    let nftPermalink = $0.permalink
                    let collectionSlug = $0.collection.slug
                    let collectionName = $0.collection.name
                    let collectionDescription = $0.collection.description
                    let collectionImage = $0.collection.image_url
                    
                    if (nftName == nil) { nftName = "#\(token_id ?? "Unknown")" }
                    
                    let foundAsset = oldAssets.filter({ $0.id == id }).first
                    
                    if let foundAsset = foundAsset {
                        
                        foundAsset.collection_name = collectionName
                        foundAsset.collection_description = collectionDescription
                        foundAsset.collection_image_url = collectionImage
                        foundAsset.nft_name = nftName
                        foundAsset.nft_permalink = nftPermalink
                        foundAsset.nft_image = nftImage
                        foundAsset.wallet = wallet
                        
                        currentUserAssets.append(foundAsset)
                    } else {
                        
                        let newAsset = AssetStorage(context: CoreDataStack.sharedInstance.viewContext)
                        
                        newAsset.collection_slug = collectionSlug
                        newAsset.collection_name = collectionName
                        newAsset.collection_description = collectionDescription
                        newAsset.collection_image_url = collectionImage
                        
                        newAsset.id = id
                        newAsset.nft_name = nftName
                        newAsset.nft_permalink = nftPermalink
                        newAsset.nft_image = nftImage
                        newAsset.wallet = wallet
                        
                        currentUserAssets.append(newAsset)
                    }
                }
                
                let nextCursor = value.next
                let maxReached = nextCursor == nil
                
                if (maxReached) {
					completion(.success(currentUserAssets))
                } else {
                    
                    self.getAssets(oldAssets, currentUserAssets, nextCursor, wallet) { result  in
						switch result {
						case .success(let updatedUserAssets):
							
							completion(.success(updatedUserAssets))
						case .failure(_):
							
							completion(.failure(.error))
						}
                    }
                }
                
            } else {
                
				completion(.failure(.error))
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
                
                if let originalCollection_slug = dict.collection_slug {
                    
                    if let currentCollection = usedSlugs.filter({$0.collection_slug == originalCollection_slug}).first {
                        
                        currentUserAssets[i].floor_price = currentCollection.floor_price
                        currentUserAssets[i].average_price = currentCollection.average_price
                        
                        semaphore.signal()
                    } else {
                        self.openSeaService.getCollection(originalCollection_slug) { value in
                            
                            var roundedFloorPrice = 0.0
                            var roundedAveragePrice = 0.0
                            
                            if let value = value {
                                roundedFloorPrice = round(100 * (Double(value.collection.stats.floor_price ?? 0.0))) / 100
                                roundedAveragePrice = round(100 * Double(value.collection.stats.average_price ?? 0.0)) / 100
                            } else {
                                sleep(5)
                            }
                            
                            currentUserAssets[i].floor_price = roundedFloorPrice
                            currentUserAssets[i].average_price = roundedAveragePrice
                            
							let newCollection = Asset(collection_slug: originalCollection_slug,
													  floor_price: roundedFloorPrice,
													  average_price: roundedAveragePrice)
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
