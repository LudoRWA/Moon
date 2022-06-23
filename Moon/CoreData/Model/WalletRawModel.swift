//
//  WalletRawModel.swift
//  Moon
//
//  Created by Ludovic Roullier on 09/05/2022.
//

import CoreData

struct WalletRaw: Equatable {
	var reference: NSManagedObjectID!
	let address: String!
}
