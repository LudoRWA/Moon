//
//  WalletsViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import Foundation
import CoreData
import FirebaseCrashlytics

class WalletsViewModel: NSObject {
    
    var updateCellsTableView: ((([IndexPath], [IndexPath]), Bool) -> Void)?
    
    var wallets = [WalletStorage]() {
        didSet {
            walletCellViewModels = getCellsReady(wallets: wallets)
        }
    }
    var walletCellViewModels = [WalletCellViewModel]() {
        didSet {
            updateCellsTableView?(getTableViewReady(oldArray: oldValue, newArray: walletCellViewModels), walletCellViewModels.isEmpty)
        }
    }
    
    var shouldUpdateViewController = false
    
    public func addWallet(wallet: WalletStorage) {
        shouldUpdateViewController = true
        wallets.append(wallet)
    }
    
    func remove(wallet: WalletStorage) {
        do {
            CoreDataStack.sharedInstance.viewContext.delete(wallet)
            try CoreDataStack.sharedInstance.viewContext.save()
            wallets.removeAll{$0 == wallet}
            shouldUpdateViewController = true
        } catch {
            Crashlytics.crashlytics().record(error: error)
            print("error logout database : \(error)")
        }
    }
    
    func removeAll() {
        do {
            for wallet in wallets {
                CoreDataStack.sharedInstance.viewContext.delete(wallet)
            }
            try CoreDataStack.sharedInstance.viewContext.save()
            wallets.removeAll()
            shouldUpdateViewController = true
        } catch {
            Crashlytics.crashlytics().record(error: error)
            print("error logout database : \(error)")
        }
    }
    
    func getCellsReady(wallets: [WalletStorage]) -> [WalletCellViewModel] {
        
        var newWalletCellViewModels = [WalletCellViewModel]()
        wallets.forEach {
            let address = $0.address
            let newCell = WalletCellViewModel(address: address, wallet: $0)
            newWalletCellViewModels.append(newCell)
        }

        return newWalletCellViewModels
    }
    
    func getTableViewReady(oldArray: [WalletCellViewModel], newArray: [WalletCellViewModel]) -> ([IndexPath], [IndexPath]) {
        
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
    
    func getCellViewModel(at indexPath: IndexPath) -> WalletCellViewModel {
        return walletCellViewModels[indexPath.row]
    }
}
