//
//  APIController.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//
import UIKit

let googleKey = "..." // to be added before building the app
enum APIError: Error {
    case unvalidURL(url : String)
    var localizedDescription: String{
        switch self {
        case .unvalidURL(let url):
            return "Couldn't creat URL from \(url)"
        }
    }
}

enum API{
    case hospitals(page:Int)
    case illnesses(page:Int)
    case eta(origin: String, destinations: [String], mode: String)
    
    var url: String{
        switch self {
        case .illnesses(let page):
            return "http://dmmw-api.australiaeast.cloudapp.azure.com:8080/illnesses?limit=20&page=\(page)"
        case .hospitals(let page):
            return "http://dmmw-api.australiaeast.cloudapp.azure.com:8080/hospitals?limit=20&page=\(page)"
        case .eta(let origin, let destinations, let mode):
            let destinationsStr = destinations.joined(separator: "%7C")
            return "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(origin)&destinations=\(destinationsStr)&mode=\(mode)&key=\(googleKey)"
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
                }
                
            }catch let error as NSError{
                print("error \(error.localizedDescription)")
                print("error \(error.userInfo)")
                
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    func request (urlStr : String,completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        guard let url = URL(string: urlStr) else{
            completionHandler(nil, nil, APIError.unvalidURL(url: urlStr))
            return
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}
