//
//  locationAndETA.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

extension hospialListViewController: CLLocationManagerDelegate{
    
    @objc func calculateETAChanged(_ sender: UISwitch)  {
        print("\n\ncalculateETAChanged \(sender.isOn)")
        
        vibeIt(.light)
        if sender.isOn {
            
            self.locationManger?.delegate = self
            // check location permision
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("notDetermined")
                // ask for permissionx
                self.locationManger?.requestWhenInUseAuthorization()
                break
            case .restricted, .denied:
                print("denied")
                print("restricted")
                sender.isOn = false
                // show user that there is no persmision to do so,
                let alert = UIAlertController(title: "Permssion denied", message: "App needs location permssion to calculate ETA. Go to settings and change the permssion!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }))
                alert.addAction(UIAlertAction(title: "Later", style: .destructive, handler: { (_) in
                    alert.dismiss(animated: true)
                }))
                self.present(alert, animated: true)
                break
            case .authorizedWhenInUse, .authorizedAlways:
                print("authorizedWhenInUse")
                print("authorizedAlways")
                self.locationManger?.startUpdatingLocation()
                break
            @unknown default:
                break
            }
        }else{
            self.calculateTransport = sender.isOn
            self.fetchHospitalsLocally()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("\n\ndidChangeAuthorization")
        switch status {
        case .notDetermined, .restricted, .denied:
            print("notDetermined")
            print("restricted")
            print("denied")
            calculateTransport = false
            tableView.reloadData()
        case .authorizedAlways, .authorizedWhenInUse:
            print("authorizedAlways")
            print("authorizedWhenInUse")
            calculateTransport = true
            tableView.reloadData()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("\n\ndidUpdateLocations")
        // stop updating location
        manager.stopUpdatingLocation()
        
        calculateTransport = true
        
        //store user location
        if let userLocation = locations.last{
            let origin = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
            print("origin is \(origin)")
            UserDefaults.standard.set(origin, forKey: st.userLocation.s)
            updateETA()
        }else{
            calculateTransport = false
            tableView.reloadData()
            
        }
        // update user location, fetch distances
        
    }
    func updateETA() {
        
        if !calculateTransport{
            fetchHospitalsLocally()
            return
        }
        
        // get user location
        guard let origin = UserDefaults.standard.string(forKey: st.userLocation.s)else{
            print("did not find user location ")
            calculateTransport = false
            fetchHospitalsLocally()
            return
        }
        
        let start = Date()
        if let objects = fetchedResultController.objects(){
            let moc = self.fetchedResultController.managedObjectContext
            moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            moc.perform {
                let destinations = objects.map{"\($0.hospital.lat),\($0.hospital.lng)"}
                
                
                API.eta(origin: origin, destinations: destinations, mode: self.selectedMode.st)
                    .fetch { (mapStruct, error) in
                        if let error = error{
                            // FIXME: handle error
                            print("API.eta error \(error.localizedDescription)")
                            return
                        }
                        
                        guard let _struct = mapStruct as? MapsStruct,
                            let durations = _struct.durations,
                            let elements = _struct.elements else{
                                print("not MapsStruct \(String(describing: error?.localizedDescription))")
                                return
                        }
                        self.apiResponded(startAt: start, status: "\(durations)")
                        self.apiResponded(startAt: start, status: "\(elements.map{$0.status})")
                        for (i , _element) in elements.enumerated(){
                            let object = objects[i]
                            let _duration = _element.duration.value
                            let duration = _duration / 60
                            if _element.status == "ZERO_RESULTS" {
                                continue
                            }
                            switch self.selectedMode {
                            case .driving:
                                object.hospital.drivingETA = duration
                                object.waitingTime_drivingETA = object.waitingTime + duration
                            case .walking:
                                object.hospital.walkingETA = duration
                                object.waitingTime_walkingETA = object.waitingTime + duration
                            case .bicycling:
                                object.hospital.bicyclingETA = duration
                                object.waitingTime_bicyclingETA = object.waitingTime + duration
                            case .transit:
                                object.hospital.transitETA = duration
                                object.waitingTime_transitETA = object.waitingTime + duration
                            }
                            
                        }
                        
                        
                        do{
                            try moc.save()
                        }catch let nserror as NSError {
                            print("erge453jytyr didnt save bcuz \(nserror.localizedDescription)")
                            print("f43r346ge didnt save bcuz \(nserror.userInfo)")
                        }
                        self.fetchHospitalsLocally()
                }
            }
            
        }
    }
    func apiResponded(startAt:Date, status:String) {
        let interval = Date().timeIntervalSince(startAt)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = .full
        
        let formattedString = formatter.string(from: TimeInterval(interval))
        
        print("api responded with state \(status), in time: \(formattedString ?? "N/A")")
    }
    
}
