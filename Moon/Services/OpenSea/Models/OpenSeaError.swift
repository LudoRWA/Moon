//
//  OpenSeaError.swift
//  Moon
//
//  Created by Ludovic Roullier on 06/05/2022.
//

enum OpenSeaError: String, Error {
	case error = "Alert.Failure.OpenSea.Error.Try"
	case unknown = "Alert.Failure.OpenSea.Unknown.Try"
	case duplicate = "Alert.Failure.Duplicate.Wallet"
	case cancel
}
