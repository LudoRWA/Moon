//
//  AddWalletViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import CoreData
import FirebaseCrashlytics

class AddWalletViewModel: NSObject {
    var openseaService: OpenSeaServiceProtocol
    var wallets = [WalletStorage]()
    
    init(openseaService: OpenSeaServiceProtocol = OpenSeaService()) {
        
        self.openseaService = openseaService
    }
    
    func addWallet(address: String?, completion: @escaping (Bool, WalletStorage?, String?) -> ()) {
        
        if let address = address?.trimmingCharacters(in: .whitespacesAndNewlines), !address.isEmpty {
            
            self.openseaService.getAssets(1, address, nil) { value, statusCode in
                
                if (value?.assets != nil) {
                    
                    if (self.wallets.firstIndex(where: {$0.address == address}) == nil) {
                        
                        let newWallet = WalletStorage(context: CoreDataStack.sharedInstance.viewContext)
                        newWallet.address = address
                        
                        do {
                            try CoreDataStack.sharedInstance.viewContext.save()
                            completion(true, newWallet, nil)
                        } catch {
                            Crashlytics.crashlytics().record(error: error)
							completion(false, nil, "Alert.Failure.Error.Try".localized)
                        }
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
