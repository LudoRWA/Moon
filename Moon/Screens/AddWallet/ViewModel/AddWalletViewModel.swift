//
//  AddWalletViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import Foundation

class AddWalletViewModel: NSObject {
    var openseaService: OpenSeaServiceProtocol
	var coreDataService: CoreDataServiceProtocol
	
    var wallets = [WalletStorage]()
    
    init(openseaService: OpenSeaServiceProtocol = OpenSeaService(), coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        
        self.openseaService = openseaService
		self.coreDataService = coreDataService
    }
    
    func addWallet(address: String?, completion: @escaping (Bool, WalletStorage?, String?) -> ()) {
        
        if let address = address?.trimmingCharacters(in: .whitespacesAndNewlines), !address.isEmpty {
            
            self.openseaService.getAssets(1, address, nil) { value, statusCode in
                
                if (value?.assets != nil) {
                    
                    if (self.wallets.firstIndex(where: {$0.address == address}) == nil) {
                        
                        let newWallet = WalletStorage(context: CoreDataStack.sharedInstance.viewContext)
                        newWallet.address = address
						self.coreDataService.save()
						
						completion(true, newWallet, nil)
                    } else {
						
						completion(false, nil, "Alert.Failure.Duplicate.Wallet".localized)
                    }
                    
                } else {
                    if (statusCode == 400) {
                        
						completion(false, nil, "Alert.Failure.OpenSea.Unknown.Try".localized)
                    } else {
                        
						completion(false, nil, "Alert.Failure.OpenSea.Error.Try".localized)
                    }
                }
            }
        } else {
            completion(false, nil, nil)
        }
    }
}
