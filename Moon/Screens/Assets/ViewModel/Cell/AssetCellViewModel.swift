//
//  AssetCellViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 15/04/2022.
//

import Foundation

struct AssetCellViewModel: Equatable {
    static func == (lhs: AssetCellViewModel, rhs: AssetCellViewModel) -> Bool {
        return (lhs.collectionName == rhs.collectionName
        && lhs.collectionImageURL == rhs.collectionImageURL
        && lhs.price == rhs.price
        && lhs.count == rhs.count)
    }
    
    let collectionName: String
    let collectionImageURL: URL?
    let price: String
    let count: String
    let asset: Asset
}

