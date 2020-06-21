//
//  zombieTests.swift
//  zombieTests
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import XCTest
@testable import zombie
import CoreData

class zombie_apocalypseTests: XCTestCase {
    
    var hospitalsVC: hospialListViewController!
    var illnessVC: illnessListViewController!
    
    override func setUpWithError() throws {
        hospitalsVC = hospialListViewController(levelOfPain: 0)
        hospitalsVC.loadViewIfNeeded()
        
        illnessVC = illnessListViewController()
        illnessVC.loadViewIfNeeded()
        
    }
    override func tearDownWithError() throws {
        hospitalsVC = nil
        illnessVC = nil
    }
    
    
    
    // request
    func test_requesting_fetching_hospitals() {
        
        // Hospitals API request
        let hospitalsExpectation = self.expectation(description: "Requesting Fetch Hospitals")
        let hospitalsAPI = API.hospitals(page: 0)
        
        hospitalsAPI.request(urlStr: hospitalsAPI.url) { (data, response, error) in
            XCTAssertNil(error)
            guard let data = data else {
                XCTFail()
                return
            }
            
            do{
                let _struct = try JSONDecoder().decode(HospitalStruct.self, from: data)
                XCTAssertNotNil(_struct)
                hospitalsExpectation.fulfill()
            }catch let error as NSError{
                XCTAssertNil(error)
            }
        }
        // illnesses API request
        let illnessesExpectation = self.expectation(description: "Requesting Fetch illnesses")
        let illnessesAPI = API.illnesses(page: 0)
        
        illnessesAPI.request(urlStr: illnessesAPI.url) { (data, response, error) in
            XCTAssertNil(error)
            guard let data = data else {
                XCTFail()
                return
            }
            
            do{
                let _struct = try JSONDecoder().decode(IllnessesStruct.self, from: data)
                XCTAssertNotNil(_struct)
                illnessesExpectation.fulfill()
            }catch let error as NSError{
                XCTAssertNil(error)
            }
        }
        
        // ETA request
        let etaExpectation = self.expectation(description: "Requesting Fetch ETA")
        let destination = "-33.880409,151.220958"
        let origin = "-33.909252,151.130298"
        let mode = transportMode.driving
        let etaAPIURL = API.eta(origin: origin, destinations: [destination], mode: mode.st)
        etaAPIURL.request(urlStr: etaAPIURL.url) { (data, response, error) in
            XCTAssertNil(error)
            guard let data = data else {
                XCTFail()
                return
            }
            
            do{
                let _struct = try JSONDecoder().decode(MapsStruct.self, from: data)
                XCTAssertNotNil(_struct)
                etaExpectation.fulfill()
            }catch let error as NSError{
                XCTAssertNil(error)
            }
        }
        
        wait(for: [hospitalsExpectation, illnessesExpectation, etaExpectation], timeout: 20)
    }
    
    //fetch
    func test_fetching() {
        let HospitalsExpectation = self.expectation(description: "Fetch Hospitals")
        API.hospitals(page: 0).fetch { (_struct, error) in
            XCTAssertNil(error)
            guard let _ = _struct as? HospitalStruct else{
                XCTFail()
                return
            }
            HospitalsExpectation.fulfill()
        }
        let IllnessesExpectation = self.expectation(description: "Fetch Illnesses")
        API.illnesses(page: 0).fetch { (_struct, error) in
            XCTAssertNil(error)
            guard let _ = _struct as? IllnessesStruct else{
                XCTFail()
                return
            }
            IllnessesExpectation.fulfill()
        }
        
        let etaExpectation = self.expectation(description: "Fetch ETA")
        let destination = "-33.880409,151.220958"
        let origin = "-33.909252,151.130298"
        let mode = transportMode.driving
        API.eta(origin: origin, destinations: [destination], mode: mode.st).fetch { (_struct, error) in
            XCTAssertNil(error)
            guard let _ = _struct as? MapsStruct else{
                XCTFail()
                return
            }
            etaExpectation.fulfill()
        }
        wait(for: [HospitalsExpectation, IllnessesExpectation, etaExpectation], timeout: 4)
    }
    
    
    
    
    //MARK: - API Tests
    //APIURLs
    func test_APIURLs() {
        let page = 0
        let hospitalsAPIURL = API.hospitals(page: page).url
        let illnessesAPIURL = API.illnesses(page: page).url
        
        
        let destination = "-33.880409,151.220958"
        let origin = "-33.909252,151.130298"
        let mode = transportMode.driving
        let etaAPIURL = API.eta(origin: "-33.909252,151.130298", destinations: [destination], mode: mode.st).url
        
        XCTAssertEqual(hospitalsAPIURL, "http://dmmw-api.australiaeast.cloudapp.azure.com:8080/hospitals?limit=20&page=\(page)")
        XCTAssertEqual(illnessesAPIURL, "http://dmmw-api.australiaeast.cloudapp.azure.com:8080/illnesses?limit=20&page=\(page)")
        XCTAssertEqual(etaAPIURL, "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(origin)&destinations=\(destination)&mode=\(mode.st)&key=\(googleKey)")
    }
    
    //TransportMode
    func testTransportMode() {
        let driving = transportMode.init(number: 0)
        let walking = transportMode.init(number: 1)
        let bicycling = transportMode.init(number: 2)
        let transit = transportMode.init(number: 3)
        
        XCTAssertEqual(driving.st, "driving")
        XCTAssertEqual(walking.st, "walking")
        XCTAssertEqual(bicycling.st, "bicycling")
        XCTAssertEqual(transit.st, "transit")
    }
    
    //MARK: - Coredata
    func test_coredata_waitingItem_get_objects() {
        let objects = WaitingItem.getObjects()
        let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WaitingItem")
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            let objects2 = results as! [WaitingItem]
            XCTAssertEqual(Set(objects2), Set(objects))
        } catch let error as NSError {
            print("Could not fetch \(error)")
            XCTFail()
        }
    }
    
    func test_coredata_hospitals_waitingItm_init_fetch_delete() {
        let hospitalID = 100
        let name = "hospital Name"
        
        let location = Location(lat: 0.1234, lng: 0.9876)
        let moc = CoreDataStack.shared.persistentContainer.viewContext
        
        let patientCount = 10
        let levelOfPain = 5
        let averageProcessTime = 1
        let waitingItemStruct = waitingItem(patientCount: patientCount, levelOfPain: levelOfPain, averageProcessTime: averageProcessTime)
        
        let ItemStruct = hospital(id: hospitalID, name: name, waitingList: [waitingItemStruct], location: location)
        let itemCoredata = Hospitals.init(context: moc, item: ItemStruct)
        
        XCTAssertEqual(itemCoredata.id, hospitalID)
        XCTAssertEqual(itemCoredata.name, name)
        XCTAssertEqual(itemCoredata.lat, location.lat)
        XCTAssertEqual(itemCoredata.lng, location.lng)
        XCTAssertEqual(itemCoredata.waitingList?.first?.patientCount, patientCount)
        XCTAssertEqual(itemCoredata.waitingList?.first?.levelOfPain, levelOfPain)
        XCTAssertEqual(itemCoredata.waitingList?.first?.averageProcessTime, averageProcessTime)
        
        
        let mocExpectation = self.expectation(description: "save moc")
        moc.perform {
            do {
                try moc.save()
                mocExpectation.fulfill()
            }catch let error as NSError{
                print("1 userInfo error \(error.userInfo)")
                print("1 localizedDescription error \(error.localizedDescription)")
                XCTFail("couldn't save")
                
            }
        }
        wait(for: [mocExpectation], timeout: 2)
        
        // Test fetching the waiting item
        XCTAssertNotNil(WaitingItem.hasWaitingItem(moc, levelOfPain: levelOfPain, hospitalID: hospitalID))
        
        
        
        let deleteItemExpectation = self.expectation(description: "delete hospital")
        // test fetching the hospital item
        if let _hospital = Hospitals.hasHospitals(moc, id: hospitalID){
            
            moc.perform {
                moc.delete(_hospital)
                do {
                    try moc.save()
                    deleteItemExpectation.fulfill()
                }catch let error as NSError{
                    print("2 userInfo error \(error.userInfo)")
                    print("2 localizedDescription error \(error.localizedDescription)")
                    XCTFail("couldn't save")
                    
                }
            }
            
        }else{
            XCTFail("Hospital was not saved")
        }
        wait(for: [deleteItemExpectation], timeout: 2)
        
    }
    
    func test_coredata_hospitals_get_objects() {
        let objects = Hospitals.getObjects()
        let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Hospitals")
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            let objects2 = results as! [Hospitals]
            XCTAssertEqual(Set(objects2), Set(objects))
        } catch let error as NSError {
            print("Could not fetch \(error)")
            XCTFail()
        }
    }

    
    
    func test_hospitalView_has_tableView_mapView() {
        XCTAssertNotNil(hospitalsVC.tableView,
                        "hospitalsVC should have a tableview")
        XCTAssertNotNil(hospitalsVC.mapView,
                        "hospitalsVC should have a mapView")
        
    }
    
    func test_hospitalView_fetched_hosptials() {
        hospitalsVC.viewDidAppear(false)
        
        guard let objects = self.hospitalsVC.fetchedResultController.objects() else{
            XCTFail()
            return
        }
        XCTAssertTrue(objects.count > 0)
    }
    
    func test_illnessView_has_tableView() {
        XCTAssertNotNil(illnessVC.tableView,
                        "illnessVC should have a tableview")
    }
    
}

