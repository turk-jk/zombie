//
//  transportMode.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import MapKit

enum transportMode: CaseIterable {
    case  driving, walking, bicycling, transit
    var st: String{
        switch self {
        case .driving: return "driving"
        case .walking: return "walking"
        case .bicycling: return "bicycling"
        case .transit: return "transit"
        }
    }
    var transportType: MKDirectionsTransportType?{
        switch self {
        case .driving: return .automobile
        case .walking: return .walking
        case .bicycling: return nil
        case .transit: return .transit
        }
    }
    var image: UIImage{
        switch self {
        case .driving: return #imageLiteral(resourceName: "icons8-car-20")
        case .walking: return #imageLiteral(resourceName: "icons8-walking-20")
        case .bicycling: return #imageLiteral(resourceName: "icons8-cycling_road_filled-20")
        case .transit: return #imageLiteral(resourceName: "icons8-train-20")
        }
    }
    var fillImage: UIImage{
        switch self {
        case .driving: return #imageLiteral(resourceName: "icons8-car_filled-20")
        case .walking: return #imageLiteral(resourceName: "icons8-walking_filled-20")
        case .bicycling: return #imageLiteral(resourceName: "icons8-cycling_road_filled-20")
        case .transit: return #imageLiteral(resourceName: "icons8-train_filled-20")
        }
    }
    init(number: Int){
        switch number {
        case 0: self = .driving
        case 1: self = .walking
        case 2: self = .bicycling
        case 3: self = .transit
        default:
            self = .driving
        }
    }
}
