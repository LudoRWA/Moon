//
//  WelcomeViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import FirebaseAnalytics
import Nuke

class WelcomeViewModel: NSObject {
    var coreDataService: CoreDataServiceProtocol
    var login: ((Bool, [WalletStorage]) -> Void)?
    
    var wallets = [WalletStorage]()
    
    init(coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        self.coreDataService = coreDataService
        
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
		coreDataService.getWallets { [weak self] wallets in
			guard let self = self else { return }
			self.wallets = wallets
			if (!self.wallets.isEmpty) {
				self.login?(animated, self.wallets)
            }
        }
    }
}
