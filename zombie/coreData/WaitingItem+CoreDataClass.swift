//
//  WaitingItem+CoreDataClass.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//
//

import Foundation
import CoreData


public class WaitingItem: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<WaitingItem> {
        return NSFetchRequest<WaitingItem>(entityName: "WaitingItem")
    }
    static func getObjects(_ context : NSManagedObjectContext? = nil ,predicates : NSPredicate? = nil, sort :[NSSortDescriptor]?  = nil , fetchLimit :Int?  = nil ) -> [WaitingItem]  {
        let request = WaitingItem.createFetchRequest()
        
        request.predicate = predicates
        request.sortDescriptors = sort
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        var result = [WaitingItem]()
        
        do {
            result =  try (context ?? CoreDataStack.shared.persistentContainer.viewContext).fetch(request)
        } catch {
            print("WaitingItem Fetch failed \(error.localizedDescription)")
        }
        return result
    }
    
    convenience init (_ context : NSManagedObjectContext){
        self.init(context: context)
        patientCount = 0
        levelOfPain = 0
        averageProcessTime = 0
        waitingTime = 0
    }
    static func hasWaitingItem(_ context : NSManagedObjectContext? = nil, levelOfPain: Int, hospitalID: Int) -> WaitingItem? {
        let predicate = NSPredicate(format: "hospital.id == %i && levelOfPain == %i", hospitalID, levelOfPain)
        return getObjects(context, predicates: predicate,fetchLimit:1).first
    }
}
