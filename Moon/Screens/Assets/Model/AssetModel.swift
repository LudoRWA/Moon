//
//  AssetModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

class Asset {
    
	let collection_slug: String?
    let collection_name: String?
    let collection_image_url: String?
    let collection_description: String?
	let floor_price: Double
    let average_price: Double
	
	var nfts = [NFT]()
	
	init(collection_slug: String?,
		 collection_name: String? = nil,
		 collection_image_url: String? = nil,
		 collection_description: String? = nil,
		 floor_price: Double,
		 average_price: Double,
		 nfts: [NFT] = []) {
		
		self.collection_slug = collection_slug
		self.collection_name = collection_name
		self.collection_image_url = collection_image_url
		self.collection_description = collection_description
		self.floor_price = floor_price
		self.average_price = average_price
		self.nfts = nfts
	}
}
