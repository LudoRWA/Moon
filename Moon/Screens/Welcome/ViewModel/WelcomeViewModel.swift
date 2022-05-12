//
//  WelcomeViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import FirebaseAnalytics
import FirebaseCrashlytics
import SQLite
import Nuke

class WelcomeViewModel: NSObject {
    var coreDataService: CoreDataServiceProtocol
    var login: ((Bool, [WalletRaw]) -> Void)?
    
    var wallets = [WalletRaw]()
    
    init(coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        self.coreDataService = coreDataService
        
        ImageCache.shared.countLimit = 200
        DataLoader.sharedUrlCache.diskCapacity = 100 * 1024 * 1024
        DataLoader.sharedUrlCache.memoryCapacity = 0
        
        let pipeline = ImagePipeline {
            $0.dataCache = .none
            $0.imageCache = .none
        }
        
        ImagePipeline.shared = pipeline
        
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    //MARK: - Get Local Data
    func getWallets(_ animated: Bool = false) {
		coreDataService.getWallets { [weak self] wallets in
			guard let self = self else { return }
			self.wallets = wallets
			if (!self.wallets.isEmpty) {
				
				self.login?(animated, self.wallets)
			} else {
				
				self.checkOldVersions()
			}
        }
    }
	
	//MARK: - Manage old versions
	func checkOldVersions() {
		//Version < 1.0.3 were not using Core Data, so we transfer wallets from the old DB to Core Data
		let databaseURL = AppGroup.old.containerURL.appendingPathComponent("nft.sqlite")
		if ((try? databaseURL.checkResourceIsReachable()) ?? false) {
			getWalletsFromOldDB(path: databaseURL.path) { [weak self] wallets in
				guard let self = self else { return }
				
				self.wallets = wallets
				self.removeOldDB(path: databaseURL.path)
				
				if (!self.wallets.isEmpty) {
					self.login?(false, self.wallets)
				}
			}
		}
	}
	
	func getWalletsFromOldDB(path: String, completion: @escaping ([WalletRaw]) -> ()) {
		
		var wallets = [WalletRaw]()
		let group = DispatchGroup()
		
		do {
			let db = try Connection(path)
			let walletsTable = Table("wallets")
			let addressField = Expression<String>("address")
			
			for wallet in try db.prepare(walletsTable) {
				group.enter()
				var newWallet = WalletRaw(reference: nil, address: wallet[addressField])
				CoreDataStack.sharedInstance.viewContext.add(wallet: newWallet) { objectID in
					newWallet.reference = objectID
					wallets.append(newWallet)
					group.leave()
				}
			}
			
			group.notify(queue: .main) {
				completion(wallets)
			}
		} catch let error as NSError {
			
			Crashlytics.crashlytics().record(error: error)
			debugPrint("Error fetching wallets from old DB! Error:\(error.description)")
		}
	}
	
	func removeOldDB(path: String) {
		do {
			let fileManager = FileManager.default
			try fileManager.removeItem(atPath: path)
		} catch let error as NSError {
			
			Crashlytics.crashlytics().record(error: error)
			debugPrint("Error removing old DB! Error:\(error.description)")
		}
	}
}
