//
//  AssetRawModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 09/05/2022.
//

import CoreData

struct AssetRaw: Equatable {
	var reference: NSManagedObjectID!
	
	var id: Int32!
	var collectionSlug: String!
	var collectionName: String?
	var collectionDescription: String?
	var collectionImageURL: String?
	var floorPrice: Double
	var averagePrice: Double
	var nftName: String?
	var nftPermalink: String?
	var nftImageURL: String?
	var wallet: WalletRaw!
}
