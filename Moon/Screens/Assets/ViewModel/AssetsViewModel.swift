//
//  AssetsViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import StoreKit

class AssetsViewModel: NSObject {
	var coreDataService: CoreDataServiceProtocol
	var openSeaService: OpenSeaServiceProtocol
	var coinbaseService: CoinbaseServiceProtocol
	
	var syncInProgress: ((Bool) -> Void)?
	var updateCellsTableView: ((([IndexPath], [IndexPath]), Bool) -> Void)?
	var updateHeaderTableView: ((AssetHeaderViewModel) -> Void)?
	var showErrorMessage: ((String?) -> Void)?
	var logout: (() -> Void)?
	
	var wallets = [WalletRaw]()
	var assets = [AssetRaw]()
	
	var isFirstLoad = true
	var shouldStopSync = false
	var isSyncActive = false {
		didSet {
			syncInProgress?(isSyncActive)
		}
	}
	
	var totalAmount = HeaderValues() {
		didSet {
			updateHeader()
		}
	}
	
	var assetHeaderViewModel = AssetHeaderViewModel() {
		didSet {
			updateHeaderTableView?(assetHeaderViewModel)
		}
	}
	
	var assetCellViewModels = [AssetCellViewModel]() {
		didSet {
			updateCellsTableView?(getTableViewReady(oldArray: oldValue, newArray: assetCellViewModels), isFirstLoad)
			isFirstLoad = false
		}
	}
	
	init(coreDataService: CoreDataServiceProtocol = CoreDataService(),
		 openSeaService: OpenSeaServiceProtocol = OpenSeaService(),
		 coinbaseService: CoinbaseServiceProtocol = CoinbaseService()) {
		
		self.coreDataService = coreDataService
		self.openSeaService = openSeaService
		self.coinbaseService = coinbaseService
	}
	
	//MARK: - Get Local Data
	func getLocalData(_ forceSync: Bool = false) {
		
		if (!wallets.isEmpty) {
			
			coreDataService.getAssetsFrom(wallets: wallets) { [weak self] assets in
				self?.processFetchedData(assets: assets)
				if (assets.isEmpty || forceSync) {
					self?.startSync()
				}
			}
		} else {
			
			logout?()
		}
	}
	
	func setWallets(_ wallets: [WalletRaw], forceSync: Bool = false) {
		self.wallets = wallets
		getLocalData(forceSync)
	}
	
	//MARK: - Actions
	func startSync() {
		
		if (!isSyncActive) {
			
			let currentCount = UserDefaults.standard.integer(forKey: "syncCount")
			UserDefaults.standard.set(currentCount-1, forKey:"syncCount")
			if currentCount % 12 == 0 && currentCount != 0 {
				SKStoreReviewController.requestReview()
			}
			
			isSyncActive = true
			assetHeaderViewModel.progress = 0.05
			
			getOnlineData() { [weak self] currentUserAssets in
				guard let self = self else { return }
				if (!self.shouldStopSync) {
					self.processFetchedData(assets: currentUserAssets, true)
				}
				
				self.assetHeaderViewModel.progress = 0.0
				self.isSyncActive = false
				self.shouldStopSync = false
			}
		}
	}
	
	func switchTotalAmount() {
		
		let isAverage = !UserDefaults.standard.bool(forKey: "isAverage")
		UserDefaults.standard.set(isAverage, forKey: "isAverage")
		
		getCellsReady()
		updateHeader()
	}
	
	//MARK: - Update Data
	func processFetchedData(assets: [AssetRaw], _ isOnline: Bool = false) {
		
		let group = DispatchGroup()
		var assets = assets
		getTotalAmounts(assets)
		
		if (isOnline) {
			removeFromCoreData(oldArray: self.assets, newArray: assets)
			
			for (i, asset) in assets.enumerated() {
				
				group.enter()
				if asset.reference == nil {
					CoreDataStack.sharedInstance.viewContext.add(asset: asset) { objectID in
						
						assets[i].reference = objectID
						group.leave()
					}
				} else {
					CoreDataStack.sharedInstance.viewContext.edit(asset: asset, completion: nil)
					group.leave()
				}
			}
		}
		
		group.notify(queue: .main) {
			self.assets = assets
			
			self.updateHeader()
			self.getCellsReady()
		}
	}
	
	func removeFromCoreData(oldArray: [AssetRaw], newArray: [AssetRaw]) {
		for oldAsset in oldArray {
			if newArray.filter({ $0.collectionSlug == oldAsset.collectionSlug }).first == nil {
				
				CoreDataStack.sharedInstance.viewContext.delete(asset: oldAsset, completion: nil)
			}
		}
	}
	
	func updateHeader() {
		if (UserDefaults.standard.bool(forKey: "isAverage")) {
			assetHeaderViewModel.totalAmountText = "Label.Title.Total.Average.Value".localized
			assetHeaderViewModel.totalAmountFiat = totalAmount.average.fiat
			assetHeaderViewModel.totalAmountEth = totalAmount.average.eth
		} else {
			
			assetHeaderViewModel.totalAmountText = "Label.Title.Total.Floor.Value".localized
			assetHeaderViewModel.totalAmountFiat = totalAmount.floor.fiat
			assetHeaderViewModel.totalAmountEth = totalAmount.floor.eth
		}
	}
	
	func getCellsReady() {
		var assets = friendlyData(self.assets)
		if (UserDefaults.standard.bool(forKey: "isAverage")) {
			assets = assets.sorted{ $0.averagePrice > $1.averagePrice }
		} else {
			assets = assets.sorted{ $0.floorPrice > $1.floorPrice }
		}
		
		var vms = [AssetCellViewModel]()
		for asset in assets {
			vms.append(createCellModel(asset: asset))
		}
		
		assetCellViewModels = vms
	}
	
	func createCellModel(asset: Asset) -> AssetCellViewModel {
		
		let collectionImageURL = URL(string: asset.collectionImageURL)
		let collectionName = asset.collectionName
		let count = String(asset.nfts.count)
		var price = "Ξ \(String(asset.floorPrice))"
		
		if (UserDefaults.standard.bool(forKey: "isAverage")) {
			price = "Ξ \(String(asset.averagePrice))"
		}
		
		return AssetCellViewModel(collectionName: collectionName, collectionImageURL: collectionImageURL, price: price, count: count, asset: asset)
	}
	
	func friendlyData(_ assets: [AssetRaw]) -> [Asset] {
		
		var friendlyAssets = [Asset]()
		
		for asset in assets {
			
			if let collectionSlug = asset.collectionSlug,
			   let tokenId = asset.id {
				
				let collectionName = asset.collectionName ?? collectionSlug
				let collectionDescription = asset.collectionDescription ?? "Unknown description."
				let collectionImageURL = asset.collectionImageURL ?? ""
				
				let nftName = asset.nftName ?? "#\(tokenId)"
				let nftPermalink = asset.nftPermalink ?? "https://opensea.io/collection/\(collectionSlug)"
				let nftImageUrl = asset.nftImageURL ?? ""
				
				let floorPrice = asset.floorPrice
				let averagePrice = asset.averagePrice
				
				let NFT = Asset.NFT(id: tokenId,
									   nftImageURL: nftImageUrl,
									   nftName: nftName,
									   nftPermalink: nftPermalink)
				
				if let index = friendlyAssets.firstIndex(where: { $0.collectionSlug == collectionSlug }) {
					
					let insertionIndex = friendlyAssets[index].nfts.insertionIndexOf(NFT) { $0.id < $1.id }
					friendlyAssets[index].nfts.insert(NFT, at: insertionIndex)
				} else {
					
					let asset = Asset(collectionSlug: collectionSlug,
										 collectionName: collectionName,
										 collectionImageURL: collectionImageURL,
										 collectionDescription: collectionDescription,
										 floorPrice: floorPrice,
										 averagePrice: averagePrice,
										 nfts: [NFT])
					
					friendlyAssets.append(asset)
				}
			}
		}
		
		return friendlyAssets
	}
	
	func getTableViewReady(oldArray: [AssetCellViewModel], newArray: [AssetCellViewModel]) -> ([IndexPath], [IndexPath]) {
		
		let changes = newArray.difference(from: oldArray)
		
		let insertedIndexPaths = changes.insertions.compactMap { change -> IndexPath? in
			guard case let .insert(offset, _, _) = change
			else { return nil }
			
			return IndexPath(row: offset, section: 0)
		}
		
		let removedIndexPaths = changes.removals.compactMap { change -> IndexPath? in
			guard case let .remove(offset, _, _) = change
			else { return nil }
			
			return IndexPath(row: offset, section: 0)
		}
		
		return (insertedIndexPaths, removedIndexPaths)
	}
	
	func getCellViewModel(at indexPath: IndexPath) -> AssetCellViewModel {
		return assetCellViewModels[indexPath.row]
	}
}
