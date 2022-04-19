//
//  WelcomeViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import FirebaseCrashlytics
import FirebaseAnalytics
import Nuke

class WelcomeViewModel: NSObject {
    var coredataService: CoreDataServiceProtocol
    var login: ((Bool, [WalletStorage]) -> Void)?
    
    var wallets = [WalletStorage]()
    
    init(coredataService: CoreDataServiceProtocol = CoreDataService()) {
        self.coredataService = coredataService
        
        ImageCache.shared.countLimit = 200
        DataLoader.sharedUrlCache.diskCapacity = 100 * 1024 * 1024
        DataLoader.sharedUrlCache.memoryCapacity = 0
        
        let pipeline = ImagePipeline {
            $0.dataCache = .none
            $0.imageCache = .none
        }
        
        ImagePipeline.shared = pipeline
        
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    //MARK: - Get Local Data
    func getWallets(_ animated: Bool = false) {
        coredataService.getWallets { _, wallets,_ in
            self.wallets = wallets
            if (!self.wallets.isEmpty) {
                self.login?(animated, self.wallets)
            }
        }
    }
}
