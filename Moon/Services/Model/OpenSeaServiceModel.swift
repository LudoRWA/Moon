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
    let token_id: String?
    let collection: OpenseaAssetsCollectionSlug
    let image_url: String?
    let name: String?
    let permalink: String?
}

struct OpenseaAssetsCollectionSlug: Decodable {
    let slug: String?
    let name: String?
    let image_url: String?
    let description: String?
}

struct OpenseaCollection: Decodable {
    let collection: OpenseaCollectionStats
}

struct OpenseaCollectionStats: Decodable {
    let stats: OpenseaCollectionStatsFloor
}

struct OpenseaCollectionStatsFloor: Decodable {
    let floor_price: Double?
    let average_price: Double?
}
