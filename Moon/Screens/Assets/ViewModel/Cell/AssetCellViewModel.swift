//
//  AssetCellViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import Foundation

struct AssetCellViewModel: Equatable {
    static func == (lhs: AssetCellViewModel, rhs: AssetCellViewModel) -> Bool {
        return (lhs.collection_name == rhs.collection_name
        && lhs.collection_image_url == rhs.collection_image_url
        && lhs.price == rhs.price
        && lhs.count == rhs.count)
    }
    
    let collection_name: String
    let collection_image_url: URL?
    let price: String
    let count: String
    let asset: Asset
}

