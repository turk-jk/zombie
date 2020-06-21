//
//  Hospitals+CoreDataClass.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//
//

import Foundation
import CoreData


public class Hospitals: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Hospitals> {
        return NSFetchRequest<Hospitals>(entityName: "Hospitals")
    }
    static func getObjects(_ context : NSManagedObjectContext? = nil ,predicates : NSPredicate? = nil, sort :[NSSortDescriptor]?  = nil , fetchLimit :Int?  = nil ) -> [Hospitals]  {
        let request = Hospitals.createFetchRequest()
        
        request.predicate = predicates
        request.sortDescriptors = sort
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        var result = [Hospitals]()
        
        do {
            result =  try (context ?? CoreDataStack.shared.persistentContainer.viewContext).fetch(request)
        } catch {
            print("Hospitals Fetch failed \(error.localizedDescription)")
        }
        return result
    }
    convenience init (_ context : NSManagedObjectContext){
        self.init(context: context)
        id = 0
        name = ""
        lat = 0
        lng = 0
        drivingETA = 0
        walkingETA = 0
        transitETA = 0
        bicyclingETA = 0
    }
    static func hasHospitals(_ context : NSManagedObjectContext? = nil, id: Int) -> Hospitals? {
        let predicate = NSPredicate(format: "id == \(id)")
        return getObjects(context, predicates: predicate,fetchLimit:1).first
    }
}
