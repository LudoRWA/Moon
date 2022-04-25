//
//  UITextView+Localizable.swift
//  Moon
//
//  Created by Ludovic Roullier on 22/04/2022.
//

import UIKit

class LocalisableTextView: UITextView {
	
	@IBInspectable var localisedKey: String? {
		didSet {
			guard let key = localisedKey else { return }
			text = key.localized
		}
	}
}
