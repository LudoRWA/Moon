//
//  AppGroup.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 14/01/2022.
//

import Foundation

public enum AppGroup: String {
    case facts = "group.co.luggy.moon"
	case old = "group.co.luggy.moon.group" //used in version < 1.0.3
	
    public var containerURL: URL {
        switch self {
        case .facts:
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
		case .old:
			return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
        }
    }
}
