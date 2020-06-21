//
//  fetchHospitals.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation

import Foundation
import CoreData

extension hospialListViewController{
    
    func fetchHospitalsLocally() {
        let fetchRequest  = WaitingItem.createFetchRequest()
        let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
        fetchRequest.fetchBatchSize = 30
        fetchRequest.predicate = NSPredicate(format: "levelOfPain == \(levelOfPain)")
        if !calculateTransport{
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "waitingTime", ascending: true)]
            
        }else{

            switch self.selectedMode {
            case .driving:
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "waitingTime_drivingETA", ascending: true)]
            case .walking:
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "waitingTime_walkingETA", ascending: true)]
            case .bicycling:
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "waitingTime_bicyclingETA", ascending: true)]
            case .transit:
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "waitingTime_transitETA", ascending: true)]
            }
        }
        let resultsController = FRCTableViewDataSource.init(fetchRequest: fetchRequest, context: managedObjectContext, sectionNameKeyPath: nil)
        
        self.fetchedResultController = resultsController
        self.fetchedResultController.tableView = self.tableView
        self.tableView.dataSource = fetchedResultController
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
            self.addAnnotation()
        }catch let error as NSError{
            print("fetchHospitalsLocally error userInfo \(error.userInfo)")
            print("fetchHospitalsLocally error localizedDescription \(error.localizedDescription)")
        }
    }
    
    func fetchremoteHospitals(page: Int = 0) {
        API.hospitals(page: page).fetch { (_struct, error) in
            if let error = error{
                print("error in fetchIllness is \(error.localizedDescription)")
                return
            }
            guard let _struct = _struct as? HospitalStruct else{
                return
            }
            // check if there is more hotbitals to download
            if let next = _struct._links.next?.href, !next.isEmpty{
                print("bringing more hospitals")
                self.fetchremoteHospitals(page: page + 1)
            }else{
                print("no more hospitals")
                self.addAnnotation()
                
            }
            print("_struct \(_struct.hospitals.count)")
            
            let moc = CoreDataStack.shared.persistentContainer.newBackgroundContext()
            moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            moc.perform {
                for item in _struct.hospitals {
                    Hospitals.addHospital(moc, hospital: item)
                }
                do{
                    try moc.save()
                    DispatchQueue.main.async {
                        self.fetchHospitalsLocally()
                    }
                }catch let nserror as NSError {
                    //FIXME: handle error
                    print("moc.save nserror \(nserror.localizedDescription)")
                    print("moc.save nserror \(nserror.userInfo)")
                }
            }
        }
    }
}
