//
//  OpenSeaServiceModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

struct OpenseaAssets: Decodable {
    let next: String?
    let assets: [OpenseaAssetsCollection]
}

struct OpenseaAssetsCollection: Decodable {
    let id: Int32
    let tokenId: String?
    let collection: OpenseaAssetsCollectionSlug
    let imageUrl: String?
    let name: String?
    let permalink: String?
}

struct OpenseaAssetsCollectionSlug: Decodable {
    let slug: String?
    let name: String?
    let imageUrl: String?
    let description: String?
}

struct OpenseaCollection: Decodable {
    let collection: OpenseaCollectionStats
}

struct OpenseaCollectionStats: Decodable {
    let stats: OpenseaCollectionStatsFloor
}

struct OpenseaCollectionStatsFloor: Decodable {
    let floorPrice: Double?
    let averagePrice: Double?
}
