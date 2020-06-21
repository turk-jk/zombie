//
//  APIController.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//
import UIKit
import MapKit

let googleKey = "" // to be added before building the app
enum APIError: Error {
    case unvalidURL
    case ZERO_RESULTS
    var localizedDescription: String{
        switch self {
        case .unvalidURL:
            return "Couldn't creat URL from "
        case .ZERO_RESULTS:
        return "no results form the distance matrix"
        }
    }
}

enum API{
    case hospitals(page:Int)
    case illnesses(page:Int)
    case eta(origin: String, destinations: [String], mode: String)
    case AppleETA(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D , mode: MKDirectionsTransportType)
    var url: String{
        switch self {
        case .illnesses(let page):
            return "http://dmmw-api.australiaeast.cloudapp.azure.com:8080/illnesses?limit=20&page=\(page)"
        case .hospitals(let page):
            return "http://dmmw-api.australiaeast.cloudapp.azure.com:8080/hospitals?limit=20&page=\(page)"
        case .eta(let origin, let destinations, let mode):
            let destinationsStr = destinations.joined(separator: "%7C")
            
            return "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(origin)&destinations=\(destinationsStr)&mode=\(mode)&key=\(googleKey)"
        case .AppleETA:
            return "https://apple.com"
        }
    }
    func fetch(completionHandler: @escaping (Any? , Error?) -> Void) {
        request(urlStr: url) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do{
                switch self {
                case .illnesses:
                    let mapsStruct = try JSONDecoder().decode(IllnessesStruct.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(mapsStruct, nil)
                    }
                case .hospitals:
                    
                    let mapsStruct = try JSONDecoder().decode(HospitalStruct.self, from: data)
                    
                    DispatchQueue.main.async {
                        completionHandler(mapsStruct, nil)
                    }
                case .eta:
                    
                    let mapsStruct = try JSONDecoder().decode(MapsStruct.self, from: data)
                    DispatchQueue.main.async {
                        
                        completionHandler(mapsStruct, nil)
                    }
                case .AppleETA( let source, let destination, let mode):
                    let r = MKDirections.Request()
                    r.transportType = mode
                    r.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
                    r.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
                    let dir = MKDirections(request: r)
                    dir.calculate { (response, error) in
                        if let route = response?.routes.first{
                            completionHandler(route, nil)
                        }else{
                            completionHandler(nil, error)
                        }
                    }
                }
                
                
                
            }catch let error as NSError{
                print("2 error \(error.localizedDescription)")
                print("2 error \(error.userInfo)")
                
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    func calculate(completionHandler: @escaping (MKRoute? , Error?) -> Void) {
         
        if case .AppleETA( let source, let destination, let mode) = self {
            
            let r = MKDirections.Request()
            r.transportType = mode
            r.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            r.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            let dir = MKDirections(request: r)
            dir.calculate { (response, error) in
                if let route = response?.routes.first{
                    completionHandler(route, nil)
                }else{
                    completionHandler(nil, error)
                }
            }
        }else{
            completionHandler(nil, nil)
        }
    }
    func request (urlStr : String,completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        guard let url = URL(string: urlStr) else{
            completionHandler(nil, nil, APIError.unvalidURL)
            return
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}
