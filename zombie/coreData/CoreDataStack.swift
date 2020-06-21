//
//  CoreDataStack.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class CoreDataStack {
    private static var coordinator: CoreDataStack?
    public class var shared : CoreDataStack {
        if coordinator == nil {
            coordinator = CoreDataStack()
        }
        return coordinator!
    }
    private init() {
    }
 
//    static let sharedInstance = CoreDataStack()
//    private override init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name:  "zombie")
       
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("localizedDescription: ",error.localizedDescription)
                print("userInfo: ",error.userInfo)
                print("localizedFailureReason: ",error.localizedFailureReason ?? "N/A")
                print("localizedRecoverySuggestion: ",error.localizedRecoverySuggestion ?? "N/A")
                print("localizedRecoveryOptions: ",error.localizedRecoveryOptions ?? "N/A")
                
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
//                fatalError("in CoreDataStack Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                context.automaticallyMergesChangesFromParent = true
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                //FIXME: handle error
                print("error in saveContext localizedDescription: ",nserror.localizedDescription)
                print("error in saveContext  nserror.userInfo: ",nserror.userInfo)
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataStack {
    //MARK: - perform methods
    static func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        CoreDataStack.shared.persistentContainer.performBackgroundTask(block)
    }
    
    static func performViewTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        block(CoreDataStack.shared.persistentContainer.viewContext)
    }
    func applicationDocumentsDirectory() {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "yo.BlogReaderApp" in the application's documents directory.
        if FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last != nil {
             
        }
    }
}
extension NSManagedObjectContext {
    func saveContext() {
        do{
            self.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.automaticallyMergesChangesFromParent = true
            try self.save()
        }catch let error as NSError{
            //FIXME: handle error
            print("saveContext erro \(error.localizedDescription)")
            print("saveContext erro \(error.userInfo)")
        }
    }
}
