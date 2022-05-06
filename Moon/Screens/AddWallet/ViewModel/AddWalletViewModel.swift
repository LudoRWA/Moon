//
//  AddWalletViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import Foundation

class AddWalletViewModel: NSObject {
    var openSeaService: OpenSeaServiceProtocol
	var coreDataService: CoreDataServiceProtocol
	
    var wallets = [WalletStorage]()
    
    init(openSeaService: OpenSeaServiceProtocol = OpenSeaService(), coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        
        self.openSeaService = openSeaService
		self.coreDataService = coreDataService
    }
    
    func addWallet(address: String?, completion: @escaping (Result<WalletStorage, OpenSeaError>) -> ()) {
        
        if let address = address?.trimmingCharacters(in: .whitespacesAndNewlines), !address.isEmpty {
            
            openSeaService.getAssets(1, address, nil) { [weak self] result in
					
				switch result {
				case .success(_):
					
					if (self?.wallets.firstIndex(where: {$0.address == address}) == nil) {
						
						let newWallet = WalletStorage(context: CoreDataStack.sharedInstance.viewContext)
						newWallet.address = address
						self?.coreDataService.save()
						
						completion(.success(newWallet))
					} else {
						
						completion(.failure(.duplicateWallet))
					}
				case .failure(let error):
					
					completion(.failure(error))
				}
            }
        }
    }
}
