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
    convenience init( context : NSManagedObjectContext , item: hospital){
        self.init(context)
        modifyTo( context, item:item)
    }
    func modifyTo(_ context : NSManagedObjectContext, item: hospital){
        
        id = item.id
        name = item.name
        lat = item.location.lat
        lng = item.location.lng
        
        
        for waitingItem in item.waitingList {
            if let _waitingItem = waitingList?.filter({$0.levelOfPain == waitingItem.levelOfPain}).first {
                _waitingItem.modifyTo(context, item: waitingItem)
            }else{
                addToWaitingList(WaitingItem.init(context: context, item: waitingItem))
            }
        }
    }
    
    static func addHospital(_ context : NSManagedObjectContext, hospital: hospital){
        if let _hospital = hasHospitals(context,id: hospital.id){
            _hospital.modifyTo( context, item:hospital)
        }else{
            _ = Hospitals.init(context: context, item: hospital)
        }
    }
    static func hasHospitals(_ context : NSManagedObjectContext? = nil, id: Int) -> Hospitals? {
        let predicate = NSPredicate(format: "id == \(id)")
        return getObjects(context, predicates: predicate,fetchLimit:1).first
    }
}
