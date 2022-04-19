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
        let container = NSCustomPersistentContainer(name: "Moon")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.persistentContainer.viewContext
    }
}
