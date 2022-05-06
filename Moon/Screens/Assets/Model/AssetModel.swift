//
//  AssetModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

class Asset {
    
	let collectionSlug: String?
    let collectionName: String?
    let collectionImageURL: String?
    let collectionDescription: String?
	let floorPrice: Double
    let averagePrice: Double
	
	var nfts = [NFT]()
	
	init(collectionSlug: String?,
		 collectionName: String? = nil,
		 collectionImageURL: String? = nil,
		 collectionDescription: String? = nil,
		 floorPrice: Double,
		 averagePrice: Double,
		 nfts: [NFT] = []) {
		
		self.collectionSlug = collectionSlug
		self.collectionName = collectionName
		self.collectionImageURL = collectionImageURL
		self.collectionDescription = collectionDescription
		self.floorPrice = floorPrice
		self.averagePrice = averagePrice
		self.nfts = nfts
	}
}
