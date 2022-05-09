//
//  WalletsViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import Foundation

class WalletsViewModel: NSObject {
	var coreDataService: CoreDataServiceProtocol
    var updateCellsTableView: ((([IndexPath], [IndexPath]), Bool) -> Void)?
    
    var wallets = [WalletRaw]() {
        didSet {
			
			updateCellsTableView?(getTableViewReady(oldArray: oldValue, newArray: wallets), wallets.isEmpty)
        }
    }
    
    var shouldUpdateViewController = false
    
	init(coreDataService: CoreDataServiceProtocol = CoreDataService()) {
		
		self.coreDataService = coreDataService
	}
	
    public func addWallet(wallet: WalletRaw) {
        shouldUpdateViewController = true
        wallets.append(wallet)
    }
    
    func remove(wallet: WalletRaw) {
		
		CoreDataStack.sharedInstance.viewContext.delete(wallet: wallet, completion: nil)
		wallets.removeAll{$0 == wallet}
		shouldUpdateViewController = true
    }
    
    func removeAll() {
		
		for wallet in wallets {
			
			CoreDataStack.sharedInstance.viewContext.delete(wallet: wallet, completion: nil)
		}
		
		wallets.removeAll()
		shouldUpdateViewController = true
    }
    
    func getTableViewReady(oldArray: [WalletRaw], newArray: [WalletRaw]) -> ([IndexPath], [IndexPath]) {
        
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
    
    func getCellViewModel(at indexPath: IndexPath) -> WalletRaw {
        return wallets[indexPath.row]
    }
}
