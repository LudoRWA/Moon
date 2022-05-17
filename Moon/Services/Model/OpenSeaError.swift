//
//  OpenSeaError.swift
//  Moon
//
//  Created by Ludovic Roullier on 06/05/2022.
//

import Foundation

enum OpenSeaError: String, Error {
	case error = "Alert.Failure.OpenSea.Error.Try"
	case unknownWallet = "Alert.Failure.OpenSea.Unknown.Try"
	case duplicateWallet = "Alert.Failure.Duplicate.Wallet"
	case cancel
}
