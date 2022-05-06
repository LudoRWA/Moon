//
//  CoreDataServiceProtocol.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import FirebaseCrashlytics
import CoreData

protocol CoreDataServiceProtocol {
	func save()
	
	func getAssetsFrom(wallets: [WalletStorage], completion: @escaping (_ results: [AssetStorage]) -> ())
    func getAllAssets(completion: @escaping (_ results: [AssetStorage]) -> ())
	func remove(asset: AssetStorage)
	
	func getWallets(completion: @escaping (_ results: [WalletStorage]) -> ())
	func remove(wallet: WalletStorage)
	func removeAll(wallets: [WalletStorage])
}

class CoreDataService: CoreDataServiceProtocol {
    
	func save() {
		do {
			try CoreDataStack.sharedInstance.viewContext.save()
		} catch {
			Crashlytics.crashlytics().record(error: error)
			debugPrint("Error saving Core Data : \(error)")
		}
	}
	
	//MARK: - Assets
    func getAssetsFrom(wallets: [WalletStorage], completion: @escaping ([AssetStorage]) -> ()) {
        
		var assets = [AssetStorage]()
        do {
            
            let fetchRequest: NSFetchRequest<AssetStorage> = AssetStorage.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "ANY wallet IN %@", wallets)
			assets = try CoreDataStack.sharedInstance.viewContext.fetch(fetchRequest) as [AssetStorage]
        } catch {
            
            Crashlytics.crashlytics().record(error: error)
            debugPrint("Error retrieving assets from Core Data : \(error)")
        }
		
		completion(assets)
    }
    
    func getAllAssets(completion: @escaping ([AssetStorage]) -> ()) {
        
		var assets = [AssetStorage]()
        do {
            
            let fetchRequest: NSFetchRequest<AssetStorage> = AssetStorage.fetchRequest()
            assets = try CoreDataStack.sharedInstance.viewContext.fetch(fetchRequest) as [AssetStorage]
        } catch {
            
            Crashlytics.crashlytics().record(error: error)
            debugPrint("Error retrieving assets from Core Data : \(error)")
        }
		
		completion(assets)
    }
	
	func remove(asset: AssetStorage) {
		CoreDataStack.sharedInstance.viewContext.delete(asset)
		save()
	}
	
	//MARK: - Wallets
	func getWallets(completion: @escaping ([WalletStorage]) -> ()) {
		
		var wallets = [WalletStorage]()
		do {
			
			let request: NSFetchRequest<WalletStorage> = WalletStorage.fetchRequest()
			wallets = try CoreDataStack.sharedInstance.viewContext.fetch(request)
		} catch {
			
			Crashlytics.crashlytics().record(error: error)
			debugPrint("Error retrieving wallets from Core Data : \(error)")
		}
		
		completion(wallets)
	}
	
	func remove(wallet: WalletStorage) {
		CoreDataStack.sharedInstance.viewContext.delete(wallet)
		save()
	}
	
	func removeAll(wallets: [WalletStorage]) {
		wallets.forEach { CoreDataStack.sharedInstance.viewContext.delete($0) }
		save()
	}
}
