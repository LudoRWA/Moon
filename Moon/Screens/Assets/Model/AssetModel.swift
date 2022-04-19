//
//  AssetModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import Foundation

class Asset {
    
    var collection_slug: String!
    var collection_name: String?
    var collection_image_url: String?
    var collection_description: String?
    var floor_price: Double = 0.0
    var average_price: Double = 0.0
    var nfts = [NFT]()
}
