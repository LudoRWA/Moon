//
//  NSManagedObjectContext.swift
//  Moon
//
//  Created by Ludovic Roullier on 09/05/2022.
//

import FirebaseCrashlytics
import CoreData

extension NSManagedObjectContext {
	
	func save(completion: ((VoidResult) -> ())?) {
		do {
			try self.save()
			completion?(.success)
		} catch let error {
			self.rollback()
			debugPrint("Error saving Core Data : \(error)")
			Crashlytics.crashlytics().record(error: error)
			completion?(.failure(error))
		}
	}
}
