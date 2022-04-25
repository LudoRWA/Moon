//
//  AssetsViewModel+Online.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import FirebaseCrashlytics

extension AssetsViewModel {
    
    func getOnlineData(completion: @escaping ([AssetStorage]) -> ()) {
        
        let oldAssets = self.assets
        var currentAssets = [AssetStorage]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            for wallet in self.wallets {
                
                if (self.shouldStopSync) { break }
                
                self.getAssets(oldAssets, currentAssets, nil, wallet) { success, updatedUserAssets, error in
                    
                    if let error = error, !success {
                        self.shouldStopSync = true
                        self.showErrorMessage?(error)
                    }
                    
                    currentAssets = updatedUserAssets
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
    
    func getAssets(_ oldAssets: [AssetStorage], _ currentAssets: [AssetStorage], _ cursor: String?, _ wallet: WalletStorage, completion: @escaping (Bool, [AssetStorage], String?) -> ()) {
        
        var currentUserAssets = currentAssets
        
        self.openseaService.getAssets(50, wallet.address ?? "", cursor) { value, _ in
            
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
                    
                    if (nftName == nil) { nftName = "#\(token_id ?? "")" }
                    
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
                    completion(true, currentUserAssets, nil)
                } else {
                    
                    self.getAssets(oldAssets, currentUserAssets, nextCursor, wallet) { success, updatedUserAssets, error  in
                        
                        completion(true, updatedUserAssets, nil)
                    }
                }
                
            } else {
                
				completion(false, [], "Alert.Failure.OpenSea.Error.Try".localized)
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
                        self.openseaService.getCollection(originalCollection_slug) { value in
                            
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
                            
                            let newCollection = Asset()
                            newCollection.collection_slug = originalCollection_slug
                            newCollection.floor_price = roundedFloorPrice
                            newCollection.average_price = roundedAveragePrice
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
    
    func removeFromCoreData(oldArray: [AssetStorage], newArray: [AssetStorage]) {
        for oldAsset in oldArray {
            if newArray.filter({ $0.collection_slug == oldAsset.collection_slug }).first == nil {
                do {
                    CoreDataStack.sharedInstance.viewContext.delete(oldAsset)
                    try CoreDataStack.sharedInstance.viewContext.save()
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    print("error delete item database : \(error)")
                }
            }
        }
    }
    
}
