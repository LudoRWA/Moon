//
//  DetailsViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import Foundation

class DetailsViewModel: NSObject {
    
    var asset: Asset? {
        didSet {
            if let nfts = asset?.nfts {
                nftCellViewModels = getCellsReady(nfts: nfts)
            }
        }
    }
    var currentCollectionViewIndex: Int = 0
    
    var nftCellViewModels = [NFTCellViewModel]()
    
	func getCellsReady(nfts: [Asset.NFT]) -> [NFTCellViewModel] {
        
        var newNFTCellViewModels = [NFTCellViewModel]()
        
        for (i, nft) in nfts.enumerated() {
            
			let name = nft.nftName
			let imageURL = URL(string: nft.nftImageURL)
            let pager = "\(i+1) / \(nfts.count)"
            
            let newCell = NFTCellViewModel(name: name, imageURL: imageURL, pager: pager)
            newNFTCellViewModels.append(newCell)
        }
        
        return newNFTCellViewModels
    }
    
    func getCellViewModel(at row: Int) -> NFTCellViewModel {
        return nftCellViewModels[row]
    }
}
