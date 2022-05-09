//
//  NSManagedObjectContext+Wallet.swift
//  Moon
//
//  Created by Ludovic Roullier on 09/05/2022.
//

import CoreData

extension NSManagedObjectContext {
	
	func add(wallet: WalletRaw, completion: ((NSManagedObjectID) -> ())?) {
		perform {
			let newWallet = WalletMO(context: self)
			newWallet.address = wallet.address
			self.save() { result in
				if case .success = result {
					completion?(newWallet.objectID)
				}
			}
		}
	}
	
	func delete(wallet: WalletRaw, completion: ((VoidResult) -> ())?) {
		guard wallet.reference != nil else { return }
		perform {
			if let entity = self.object(with: wallet.reference) as? WalletMO {
				self.delete(entity)
				self.save(completion: completion)
			}
		}
	}
}
