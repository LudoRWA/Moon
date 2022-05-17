//
//  TransactionError.swift
//  Moon
//
//  Created by Ludovic Roullier on 13/05/2022.
//

import Foundation

enum TransactionError: String, Error {
	case error = "Alert.Failure.Error.Try"
	case disabled = "Alert.Failure.Transaction.Disabled"
	case cancel
}
