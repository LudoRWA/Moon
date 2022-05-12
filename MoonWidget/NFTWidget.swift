//
//  NFTWidget.swift
//  Moon Widget
//
//  Created by Ludovic ROULLIER on 03/01/2022.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    var coreDataService: CoreDataServiceProtocol
    var openSeaService: OpenSeaServiceProtocol
    
    init(coreDataService: CoreDataServiceProtocol = CoreDataService(),
		 openSeaService: OpenSeaServiceProtocol = OpenSeaService()) {
        
        self.coreDataService = coreDataService
        self.openSeaService = openSeaService
    }
    
    func placeholder(in context: Context) -> NFTEntry {
        NFTEntry(date: Date(), nftImageURL: "", nftName: "", floorPrice: "", isEmpty: false, configuration: SelectNFTIntent())
    }
    
    func getSnapshot(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (NFTEntry) -> ()) {
        
		coreDataService.getAllAssets() { assets in
			
			if !assets.isEmpty, let randomNFT = assets.randomElement() {
					
				let nftName = randomNFT.nftName ?? ""
				let nftImageURL = randomNFT.nftImageURL ?? ""
				let collectionSlug = randomNFT.collectionSlug
					
				guard let collectionSlug = collectionSlug else { return }
					
				self.openSeaService.getCollection(collectionSlug) { result in
					
					var floorText = "---"
					
					if case .success(let value) = result, let floorPrice = value.collection.stats.floor_price {
						floorText = "Ξ \(String(Double(round(100 * Double(floorPrice)) / 100)))"
					}
						
					let entry = NFTEntry(date: Date(), nftImageURL: nftImageURL, nftName: nftName, floorPrice: floorText, isEmpty: false, configuration: configuration)
					completion(entry)
				}
			} else {
					
				let entry = NFTEntry(date: Date(), nftImageURL: "https://lh3.googleusercontent.com/8wZj0mVMGq2poWacZhflWaEXu1B3_czpBL6snzSlFL1l8XAnN0fyfULx6jRIu-Hz_4o2Ba2aYJQo3Gx0Yvz0bjuHvZIsf54Is-vZyg=w600", nftName: "Doggy #1344", floorPrice: "2.4", isEmpty: false, configuration: configuration)
					completion(entry)
			}
        }
    }
    
    func getTimeline(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (Timeline<NFTEntry>) -> ()) {
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 45, to: currentDate)!
        
		coreDataService.getAllAssets() { assets in
			
			if !assets.isEmpty {
				
				var nftName = ""
				var nftImageURL = ""
				var collectionSlug: String?
			
				if let selectedNFT = configuration.nft {
				
					nftName = selectedNFT.nftName ?? ""
					nftImageURL = selectedNFT.nftImageURL ?? ""
					collectionSlug = selectedNFT.collectionSlug
				} else {
				
					if let randomNFT = assets.randomElement() {
					
						nftName = randomNFT.nftName ?? ""
						nftImageURL = randomNFT.nftImageURL ?? ""
						collectionSlug = randomNFT.collectionSlug
					}
				}
			
				guard let collectionSlug = collectionSlug else { return }
			
				self.openSeaService.getCollection(collectionSlug) { result in
				
					if case .success(let value) = result, let floorPrice = value.collection.stats.floor_price {
					
						let floorText = "Ξ \(String(Double(round(100 * Double(floorPrice)) / 100)))"
					
						let entry = NFTEntry(date: currentDate, nftImageURL: nftImageURL, nftName: nftName, floorPrice: floorText, isEmpty: false, configuration: configuration)
						let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
						completion(timeline)
					}
				}
			} else {
				
				let entry = NFTEntry(date: currentDate, nftImageURL: "", nftName: "", floorPrice: "", isEmpty: true, configuration: configuration)
				let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
				completion(timeline)
			}
		}
    }
}
