//
//  UIButton+Localizable.swift
//  Moon
//
//  Created by Ludovic Roullier on 22/04/2022.
//

import UIKit

class LocalisableButton: UIButton {
	
	@IBInspectable var localisedKey: String? {
		didSet {
			guard let key = localisedKey else { return }
			UIView.performWithoutAnimation {
				setTitle(key.localized, for: .normal)
				layoutIfNeeded()
			}
		}
	}
}
