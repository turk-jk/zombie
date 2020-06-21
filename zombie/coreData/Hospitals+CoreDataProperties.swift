//
//  Hospitals+CoreDataProperties.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//
//

import Foundation
import CoreData


extension Hospitals {

    @NSManaged public var id: Int
    @NSManaged public var name: String
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var drivingETA: Int
    @NSManaged public var walkingETA: Int
    @NSManaged public var transitETA: Int
    @NSManaged public var bicyclingETA: Int
    @NSManaged public var waitingList: Set<WaitingItem>?

}

// MARK: Generated accessors for waitingList
extension Hospitals {

    @objc(addWaitingListObject:)
    @NSManaged public func addToWaitingList(_ value: WaitingItem)

    @objc(removeWaitingListObject:)
    @NSManaged public func removeFromWaitingList(_ value: WaitingItem)

    @objc(addWaitingList:)
    @NSManaged public func addToWaitingList(_ values: Set<WaitingItem>)

    @objc(removeWaitingList:)
    @NSManaged public func removeFromWaitingList(_ values: Set<WaitingItem>)

}
