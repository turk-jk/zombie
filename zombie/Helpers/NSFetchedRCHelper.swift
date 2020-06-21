//
//  NSFetchedRCHelper.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import CoreData

protocol FRCTableViewDelegate: class {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
}

/// NSFetchRequestResult helper to bind tableView to Coredata entity
class FRCTableViewDataSource<FetchRequestResult: NSFetchRequestResult>: NSObject, UITableViewDataSource ,NSFetchedResultsControllerDelegate{
    let frc: NSFetchedResultsController<FetchRequestResult>
    weak var tableView: UITableView?
    weak var delegate: FRCTableViewDelegate?
    init(fetchRequest: NSFetchRequest<FetchRequestResult>, context: NSManagedObjectContext, sectionNameKeyPath: String?) {
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        super.init()
        frc.delegate = self
        
    }
    var managedObjectContext : NSManagedObjectContext{
        return frc.managedObjectContext
    }
    func performFetch() throws {
        try frc.performFetch()
        self.tableView?.reloadData()
    }
    func object(at indexPath: IndexPath) -> FetchRequestResult {
        return frc.object(at: indexPath)
    }
    
    func objects() -> [FetchRequestResult]? {
        return frc.fetchedObjects
    }
    
    // MARK: - UITableViewDataSource
    
    
    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return frc.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        guard let sections = frc.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let delegate = delegate {
            return delegate.tableView(tableView, cellForRowAt: indexPath)
        } else {
            return UITableViewCell()
        }
    }
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .right)
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .left)
        case .move: break
        case .update: break
        @unknown default:break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .right)
            tableView?.reloadSections(IndexSet(integer: newIndexPath!.section), with: .fade)
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .left)
            if tableView?.numberOfRows(inSection: indexPath!.section) ?? 0 > 0 {
                self.tableView?.reloadSections(IndexSet(integer: indexPath!.section), with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView?.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            tableView?.moveRow(at: indexPath!, to: newIndexPath!)
            if tableView?.numberOfRows(inSection: newIndexPath!.section) ?? 0 > 0 {
                self.tableView?.reloadSections(IndexSet(integer: newIndexPath!.section), with: .fade)
            }
            if tableView?.numberOfRows(inSection: indexPath!.section) ?? 0 > 0 {
                self.tableView?.reloadSections(IndexSet(integer: indexPath!.section), with: .fade)
            }
        @unknown default:break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
