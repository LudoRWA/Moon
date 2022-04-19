//
//  NSCustomPersistentContainer.swift
//  Moon
//
//  Created by Ludovic Roullier on 14/04/2022.
//

import Foundation
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.luggy.moon.group")
        storeURL = storeURL?.appendingPathComponent("Moon.sqlite")
        return storeURL!
    }
    
}
