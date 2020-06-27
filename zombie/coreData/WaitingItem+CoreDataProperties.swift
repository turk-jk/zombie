//
//  WaitingItem+CoreDataProperties.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//
//

import Foundation
import CoreData


extension WaitingItem {

    
    @NSManaged public var patientCount: Int
    @NSManaged public var levelOfPain: Int
    @NSManaged public var averageProcessTime: Int
    @NSManaged public var waitingTime: Int
    @NSManaged public var waitingTime_drivingETA: Int
    @NSManaged public var waitingTime_walkingETA: Int
    @NSManaged public var waitingTime_bicyclingETA: Int
    @NSManaged public var waitingTime_transitETA: Int
    @NSManaged public var drivingDis: Int
    @NSManaged public var walkingDis: Int
    @NSManaged public var bicyclingDis: Int
    @NSManaged public var transitDis: Int
    @NSManaged public var hospital: Hospitals

}
