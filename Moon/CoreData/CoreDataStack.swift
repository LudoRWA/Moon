//
//  CoreDataStack.swift
//  Moon
//
//  Created by Ludovic Roullier on 14/04/2022.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    static let sharedInstance = CoreDataStack()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Moon")
        let storeURL = URL.storeURL(for: "group.co.luggy.moon", databaseName: "Moon")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistentContainer
    }()
    
    var viewContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.persistentContainer.viewContext
    }
}
