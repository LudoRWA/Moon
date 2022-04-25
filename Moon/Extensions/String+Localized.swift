//
//  String+Localized.swift
//  Moon
//
//  Created by Ludovic Roullier on 22/04/2022.
//

import Foundation

extension String {
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
}
