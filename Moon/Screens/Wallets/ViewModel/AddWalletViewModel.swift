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
                            completion(false, nil, "An error has occurred. Please try again.")
                        }
                    } else {
                        completion(false, nil, "You have already added this wallet.")
                    }
                    
                } else {
                    if (statusCode == 400) {
                        
                        completion(false, nil, "OpenSea doesn't know this wallet. Please verify your wallet address and try again.")
                    } else {
                        
                        completion(false, nil, "OpenSea is not accessible at the moment. Please try again later or check @apiopensea on Twitter.")
                    }
                }
            }
        } else {
            completion(false, nil, nil)
        }
    }
}
