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
	
    var wallets = [WalletRaw]()
    
    init(openSeaService: OpenSeaServiceProtocol = OpenSeaService(), coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        
        self.openSeaService = openSeaService
		self.coreDataService = coreDataService
    }
    
    func add(wallet: String?, completion: @escaping (Result<WalletRaw, OpenSeaError>) -> ()) {
        
        if let address = wallet?.trimmingCharacters(in: .whitespacesAndNewlines), !address.isEmpty {
            
            openSeaService.getAssets(1, address, nil) { [weak self] result in
					
				switch result {
				case .success(_):
					
					if (self?.wallets.firstIndex(where: {$0.address == address}) == nil) {
						
						var newWallet = WalletRaw(reference: nil, address: address)
						CoreDataStack.sharedInstance.viewContext.add(wallet: newWallet) { objectID in
							newWallet.reference = objectID
							completion(.success(newWallet))
						}
					} else {
						
						completion(.failure(.duplicate))
					}
				case .failure(let error):
					
					completion(.failure(error))
				}
            }
		} else {
			
			completion(.failure(.cancel))
		}
    }
}
