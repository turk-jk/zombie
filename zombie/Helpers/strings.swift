//
//  strings.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation
enum st: String{
    case illnessName = "illnessName"
    case levelOfPain = "levelOfPain"
    case userLocation = "userLocation"
    case hasLevelOfPain = "hasLevelOfPain"
    case UI_Testing = "UI_Testing"
    var s: String{
        return self.rawValue
    }
}
