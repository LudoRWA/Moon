//
//  AssetsViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import Foundation

class AssetsViewModel: NSObject {
    var coreDataService: CoreDataServiceProtocol
    var openSeaService: OpenSeaServiceProtocol
    var coinbaseService: CoinbaseServiceProtocol
    
    var updateCellsTableView: ((([IndexPath], [IndexPath])) -> Void)?
    var updateHeaderTableView: ((AssetHeaderViewModel) -> Void)?
    var showErrorMessage: ((String?) -> Void)?
    var logout: (() -> Void)?
    
    var wallets = [WalletStorage]() //wallets from and for coredata
    var assets = [AssetStorage]() //assets from and for coredata
    
    let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF"]
    
    var shouldStopSync = false
    var isSyncActive = false
    
    var totalAmount = AmountModel() {
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
            updateCellsTableView?(getTableViewReady(oldArray: oldValue, newArray: assetCellViewModels))
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
        
        if (!self.wallets.isEmpty) {
            
            self.coreDataService.getAssetsFrom(wallets: wallets) { assets in
			self.processFetchedData(assets: assets)
				if (assets.isEmpty || forceSync) {
					self.startSync()
				}
            }
        } else {
            
            self.logout?()
        }
    }
    
    func setWallets(_ wallets: [WalletStorage], forceSync: Bool = false) {
        self.wallets = wallets
        getLocalData(forceSync)
    }
    
    
    //MARK: - Actions
    func startSync() {
        
        if (!isSyncActive) {
            
            isSyncActive = true
            assetHeaderViewModel.progress = 0.05
            
            getOnlineData() { currentUserAssets in
                
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
    func processFetchedData(assets: [AssetStorage], _ isOnline: Bool = false) {
        
        getTotalAmounts(assets)
        
        if (isOnline) {
            removeFromCoreData(oldArray: self.assets, newArray: assets)
			coreDataService.save()
        }
        
        self.assets = assets
        
        updateHeader()
        getCellsReady()
    }
    
	func removeFromCoreData(oldArray: [AssetStorage], newArray: [AssetStorage]) {
		for oldAsset in oldArray {
			if newArray.filter({ $0.collectionSlug == oldAsset.collectionSlug }).first == nil {
				
				coreDataService.remove(asset: oldAsset)
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
        
        let collectionImageURL = URL(string: (asset.collectionImageURL ?? ""))
		let collectionName = asset.collectionName ?? "Label.Unknown".localized
        let count = String(asset.nfts.count)
        var price = "Ξ \(String(asset.floorPrice))"
        
        if (UserDefaults.standard.bool(forKey: "isAverage")) {
            price = "Ξ \(String(asset.averagePrice))"
        }
        
        return AssetCellViewModel(collectionName: collectionName, collectionImageURL: collectionImageURL, price: price, count: count, asset: asset)
    }
    
    func friendlyData(_ assets: [AssetStorage]) -> [Asset] {
        
        var friendlyAssets = [Asset]()
        
        for asset in assets {
            
			let newNFT = NFT(id: asset.id,
							 nftImageURL: asset.nftImageURL,
							 nftName: asset.nftName,
							 nftPermalink: asset.nftPermalink)
            
            if let foundAsset = friendlyAssets.filter({ $0.collectionSlug == asset.collectionSlug }).first {
                
                let index = foundAsset.nfts.insertionIndexOf(newNFT) { $0.id < $1.id }
                foundAsset.nfts.insert(newNFT, at: index)
            } else {
                
				let newAsset = Asset(collectionSlug: asset.collectionSlug,
									 collectionName: asset.collectionName,
									 collectionImageURL: asset.collectionImageURL,
									 collectionDescription: asset.collectionDescription,
									 floorPrice: asset.floorPrice,
									 averagePrice: asset.averagePrice,
									 nfts: [newNFT])
				
                friendlyAssets.append(newAsset)
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
