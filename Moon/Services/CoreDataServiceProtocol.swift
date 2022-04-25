//
//  CoreDataServiceProtocol.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import FirebaseCrashlytics
import CoreData

protocol CoreDataServiceProtocol {
    func getWallets(completion: @escaping (_ success: Bool, _ results: [WalletStorage], _ error: String?) -> ())
    func getAssetsFrom(wallets: [WalletStorage], completion: @escaping (_ success: Bool, _ results: [AssetStorage], _ error: String?) -> ())
    func getAllAssets(completion: @escaping (_ success: Bool, _ results: [AssetStorage], _ error: String?) -> ())
}

class CoreDataService: CoreDataServiceProtocol {
    func getWallets(completion: @escaping (Bool, [WalletStorage], String?) -> ()) {
        
        do {
            let request: NSFetchRequest<WalletStorage> = WalletStorage.fetchRequest()
            let wallets = try CoreDataStack.sharedInstance.viewContext.fetch(request)
            completion(true, wallets, nil)
        } catch {
            
            Crashlytics.crashlytics().record(error: error)
			completion(false, [], "Alert.Failure.Retrieving.Items.Core.Data".localized)
            
            debugPrint("Error retrieving items from Core Data : \(error)")
        }
    }
    
    func getAssetsFrom(wallets: [WalletStorage], completion: @escaping (Bool, [AssetStorage], String?) -> ()) {
        
        do {
            
            let fetchRequest: NSFetchRequest<AssetStorage> = AssetStorage.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "ANY wallet IN %@", wallets)
            let assets = try CoreDataStack.sharedInstance.viewContext.fetch(fetchRequest) as [AssetStorage]
            completion(true, assets, nil)
        } catch {
            
            Crashlytics.crashlytics().record(error: error)
            completion(false, [], "Alert.Failure.Retrieving.Items.Core.Data".localized)
            
            debugPrint("Error retrieving items from Core Data : \(error)")
        }
    }
    
    func getAllAssets(completion: @escaping (Bool, [AssetStorage], String?) -> ()) {
        
        do {
            
            let fetchRequest: NSFetchRequest<AssetStorage> = AssetStorage.fetchRequest()
            let assets = try CoreDataStack.sharedInstance.viewContext.fetch(fetchRequest) as [AssetStorage]
            completion(true, assets, nil)
        } catch {
            
            Crashlytics.crashlytics().record(error: error)
            completion(false, [], "Alert.Failure.Retrieving.Items.Core.Data".localized)
            
            debugPrint("Error retrieving items from Core Data : \(error)")
        }
    }
}
