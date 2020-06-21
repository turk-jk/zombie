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

    case tutorial_toggleMap = "tutorial_toggleMap"
    case tutorial_showRoute = "tutorial_showRoute"
    case tutorial_ETA = "tutorial_ETA"
    case tutorial_transportMode = "tutorial_transportMode"
    case tutorial_refresh = "tutorial_refresh"
    case tutorial = "tutorial"
    
    var s: String{
        return self.rawValue
    }
}
