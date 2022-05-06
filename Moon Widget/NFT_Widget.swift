//
//  NFT_Widget.swift
//  Moon Widget
//
//  Created by Ludovic ROULLIER on 03/01/2022.
//

import WidgetKit
import SwiftUI
import Intents
import Alamofire
import CoreData

struct Provider: IntentTimelineProvider {
    var coreDataService: CoreDataServiceProtocol
    var openSeaService: OpenSeaServiceProtocol
    
    init(coreDataService: CoreDataServiceProtocol = CoreDataService(),
		 openSeaService: OpenSeaServiceProtocol = OpenSeaService()) {
        
        self.coreDataService = coreDataService
        self.openSeaService = openSeaService
    }
    
    func placeholder(in context: Context) -> NFTEntry {
        NFTEntry(date: Date(), nft_image: "", nft_name: "", floor_price: "", isEmpty: false, configuration: SelectNFTIntent())
    }
    
    func getSnapshot(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (NFTEntry) -> ()) {
        
		coreDataService.getAllAssets() { assets in
			
			if !assets.isEmpty, let randomNFT = assets.randomElement() {
					
				let nft_name = randomNFT.nft_name ?? ""
				let nft_image = randomNFT.nft_image ?? ""
				let collection_slug = randomNFT.collection_slug
					
				guard let collectionSlug = collection_slug else { return }
					
				self.openSeaService.getCollection(collectionSlug) { value in
						
					var floorText = "---"
					if let floorPrice = value?.collection.stats.floor_price {
							floorText = "Ξ \(String(Double(round(100 * Double(floorPrice)) / 100)))"
					}
						
					let entry = NFTEntry(date: Date(), nft_image: nft_image, nft_name: nft_name, floor_price: floorText, isEmpty: false, configuration: configuration)
					completion(entry)
				}
			} else {
					
				let entry = NFTEntry(date: Date(), nft_image: "https://lh3.googleusercontent.com/8wZj0mVMGq2poWacZhflWaEXu1B3_czpBL6snzSlFL1l8XAnN0fyfULx6jRIu-Hz_4o2Ba2aYJQo3Gx0Yvz0bjuHvZIsf54Is-vZyg=w600", nft_name: "Doggy #1344", floor_price: "2.4", isEmpty: false, configuration: configuration)
					completion(entry)
			}
        }
    }
    
    func getTimeline(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (Timeline<NFTEntry>) -> ()) {
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 45, to: currentDate)!
        
		var nft_name = ""
		var nft_image = ""
		var collection_slug: String?
        
        if let selectedNFT = configuration.nft {
            
            nft_name = selectedNFT.nft_name ?? ""
            nft_image = selectedNFT.nft_image ?? ""
            collection_slug = selectedNFT.collection_slug
        } else {
            
			coreDataService.getAllAssets() { assets in
		
				if !assets.isEmpty, let randomNFT = assets.randomElement() {
						
					nft_name = randomNFT.nft_name ?? ""
					nft_image = randomNFT.nft_image ?? ""
					collection_slug = randomNFT.collection_slug
				}
            }
        }
        
		guard let collectionSlug = collection_slug else { return }
		
        self.openSeaService.getCollection(collectionSlug) { value in
            
            if let floorPrice = value?.collection.stats.floor_price {
				
                let floorText = "Ξ \(String(Double(round(100 * Double(floorPrice)) / 100)))"
				
				let entry = NFTEntry(date: currentDate, nft_image: nft_image, nft_name: nft_name, floor_price: floorText, isEmpty: false, configuration: configuration)
				let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
				completion(timeline)
            }
        }
    }
}
