//
//  NFTCellViewModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 18/04/2022.
//

import Foundation

struct NFTCellViewModel: Equatable {
	var name: String? = "Label.Unknown".localized
    var image_url: URL?
    var pager: String?
}
