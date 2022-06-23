//
//  Asset.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

struct Asset {
    
	let collectionSlug: String
    let collectionName: String
    let collectionImageURL: String
    let collectionDescription: String
	var floorPrice: Double
    var averagePrice: Double
	
	var nfts = [NFT]()
	
	struct NFT {
		
		let id: Int32
		let nftImageURL: String
		let nftName: String
		let nftPermalink: String
	}
}
