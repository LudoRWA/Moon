//
//  Array+SafeIndex.swift
//  Moon
//
//  Created by Ludovic Roullier on 13/05/2022.
//

import Foundation

extension Array {
	public subscript(safeIndex index: Int) -> Element? {
		guard index >= startIndex, index < endIndex else {
			return nil
		}
		
		return self[index]
	}
}
